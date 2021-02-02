/**
 * @File Name          : MatchCounterBatch.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 10-30-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/31/2020   Hassan Dakhcha     Initial Version
**/
global class MatchCounterBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
   
    global final String objectName;
    global final Boolean enqeue;
    global final Boolean filterArchived;
    global final Integer numPerQueue;

    global MatchCounterBatch(String objectName, Boolean enqeue, Boolean filterArchived, Integer numPerQueue)  {
       this.objectName = objectName;
       this.enqeue = enqeue;
       this.filterArchived = filterArchived;
       this.numPerQueue = numPerQueue;
    }

    // Start
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryLoc = '';
        if(this.objectName == 'ACCOUNT')
            queryLoc = Label.Query_Batch_Match_Account;
        
        if(this.objectName == 'PROJET_LMSG__C')
            queryLoc = Label.Query_Batch_Match_Projet_LMSG;
        
        return Database.getQueryLocator(queryLoc);
    }

    public void execute(Database.BatchableContext bctx, List<sObject> objects) {

        Map<String, String> wbeIdSfIdMap = new Map<String, String>();
        String idWbe;
        for(sObject obj : objects) {
            if(this.objectName == 'ACCOUNT') {
                idWbe = ((Account)obj).Contact_principal__r.External_Contact_id__c;
            } else if(this.objectName == 'PROJET_LMSG__C') {
                idWbe = ((PROJET_LMSG__C) obj).Identifiant_PP__c;
            } else {
                continue;
            }
            if(idWbe!=null && idWbe!='') {
                wbeIdSfIdMap.put(idWbe, obj.id);
            }
        }

        if(this.enqeue) {
            System.enqueueJob(new MatchEnqueueCalls( wbeIdSfIdMap, this.objectName=='ACCOUNT', this.filterArchived, this.numPerQueue));
        } else {
            bulkCalls(wbeIdSfIdMap);
        }

    }

    private void bulkCalls(Map<String, String> wbeIdSfIdMap) {

        map<id, Map<String, Integer>> counterMap = new map<id, Map<String, Integer>>();
        Set<String> sfIds = new Set<String> (wbeIdSfIdMap.values());
        List<String> fullList = new List<String>(wbeIdSfIdMap.keySet());
        List<String> subList = new  List<String>();
        for(Integer i=0 ; i < fullList.size(); i=i+25) {
            subList.clear();
            for(Integer j = i; j < fullList.size(); j++) {
                subList.add(fullList[j]);
                if(subList.size()==25)
                    break;
            }
            counterMap.putAll(MatchMethods.CountMatchsForObjects( this.ObjectName == 'ACCOUNT' ? subList : null,
                                                                  this.ObjectName == 'PROJET_LMSG__C'? subList : null,
                                                                  this.filterArchived));
        }

        // Update counters 
        if(this.ObjectName == 'ACCOUNT') {    
            List<Account> accList = new List<Account>();
            for(id objId : counterMap.keySet()) {
                if(((String)objId).startsWith('001')) {
                    accList.add(new Account(id = objId,
                                            Nombre_de_Match_visibles__c= counterMap.get(objId).get('numVis'),
                                            Nombre_de_matchs_Pros_positionnables__c = counterMap.get(objId).get('NumPos')));
                }
                sfIds.remove((String)objId);
            }
            for(String accId : sfIds) {
                accList.add(new Account(id = accId,
                                        Nombre_de_Match_visibles__c= 0,
                                        Nombre_de_matchs_Pros_positionnables__c = 0));
            }

            if(!accList.isEmpty())
                Database.update(accList, false);
        }

        if(this.ObjectName == 'PROJET_LMSG__C') {
            List<Projet_LMSG__c> pList = new List<Projet_LMSG__c>();
            for(id prj : counterMap.keySet()) {
                if(!((String)prj).startsWith('001')) {
                    pList.add(new Projet_LMSG__c(id = prj,
                                                 Nombre_de_Match_visibles__c= counterMap.get(prj).get('numVis'),
                                                 Nombre_de_matchs_Pros_positionnables__c = counterMap.get(prj).get('NumPositionnable')));
                }
                sfIds.remove((String)prj);
            }
            for(String prjId : sfIds) {
                pList.add(new Projet_LMSG__c(id =prjId,
                                             Nombre_de_Match_visibles__c= 0,
                                             Nombre_de_matchs_Pros_positionnables__c = 0));
            }

            if(!pList.isEmpty())
                Database.update(pList, false);
        }
    }

    public void finish(Database.BatchableContext bctx) {
    }
    
    public void execute(SchedulableContext context) {
        database.executebatch(this);
    }
}