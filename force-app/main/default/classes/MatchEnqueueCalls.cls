/**
 * @File Name          : MatchEnqueueCalls.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 10-01-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/24/2020   Hassan Dakhcha     Initial Version
**/
public class MatchEnqueueCalls implements Queueable, Database.AllowsCallouts {
    private Map<String, String> wbeIdSfIdMap;
    private Boolean isPro;
    private Boolean filterArchived;
    private Integer NumPerQueue;
    public MatchEnqueueCalls(Map<String, String> wbeIdSfIdMapArg, Boolean isPro, Boolean filterArchived, Integer NumPerQueue) {
        this.wbeIdSfIdMap = new Map<String, String>(wbeIdSfIdMapArg);
        this.isPro = isPro;
        this.filterArchived = filterArchived;
        this.NumPerQueue = NumPerQueue;
    }
    public void execute(QueueableContext context) {
        List<String> fullIds = new List<String>(wbeIdSfIdMap.keySet());
        List<String> ids = new List<String> ();
        for(String elem : fullIds) {
            ids.add(elem);
            if(ids.size() == this.NumPerQueue)
                break;
        }
        
        //System.debug('#### HDAK elems : ' + ids.size() + ' isPro? ' + this.isPro + ' Archived ? ' + this.filterArchived);
        Map<id, Map<String, Integer>> counterMap = MatchMethods.CountMatchsForObjects(this.isPro? ids:null, this.isPro? null:ids, this.filterArchived);
        //System.debug('#### HDAK counterMap  : ' + counterMap);

        if(counterMap != null && !counterMap.isEmpty()) {
            try {
                List<Account> accList = new List<Account> ();
                List<Projet_LMSG__c> prjList = new List<Projet_LMSG__c> ();
                for(String elem : ids) {
                    String idSf = wbeIdSfIdMap.get(elem);
                    if(isPro==true) {
                        Account obj = new Account(id=idSf, Nombre_de_Match_visibles__c = 0, Nombre_de_matchs_Pros_positionnables__c = 0);
                        if(counterMap!=null && !counterMap.isEmpty() && counterMap.get(idSf)!=null) {
                            obj.Nombre_de_Match_visibles__c= counterMap.get(idSf).get('numVis') == null ? 0 : counterMap.get(idSf).get('numVis');
                            obj.Nombre_de_matchs_Pros_positionnables__c = counterMap.get(idSf).get('NumPos') == null ? 0 : counterMap.get(idSf).get('NumPos');
                        }
                        accList.add(obj);
                    } else {
                        Projet_LMSG__c obj = new Projet_LMSG__c(id=idSf, Nombre_de_Match_visibles__c = 0, Nombre_de_matchs_Pros_positionnables__c = 0);
                        if(counterMap!=null && !counterMap.isEmpty() && counterMap.get(idSf)!=null) {
                            obj.Nombre_de_Match_visibles__c= counterMap.get(idSf).get('numVis') == null ? 0 : counterMap.get(idSf).get('numVis');
                            obj.Nombre_de_matchs_Pros_positionnables__c = counterMap.get(idSf).get('NumPos') == null ? 0 : counterMap.get(idSf).get('NumPos');
                        }
                        prjList.add(obj);
                    }
                }
                if(isPro==true) {
                    Database.update(accList, false);
                } else {
                    Database.update(prjList, false);
                }
            } catch(Exception exp) {
                System.debug('### HDAK object update : MatchEnqueueCalls error = '+ exp.getMessage());
            }
        }
        for(String rm : ids) {
            wbeIdSfIdMap.remove(rm);
        }
        if(!wbeIdSfIdMap.isEmpty()) {
            System.enqueueJob(new MatchEnqueueCalls(this.wbeIdSfIdMap, this.isPro, this.filterArchived, this.NumPerQueue));
        }

    }
}