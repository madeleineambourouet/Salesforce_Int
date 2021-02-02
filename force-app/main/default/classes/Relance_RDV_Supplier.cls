/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-06-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-15-2020   Hassan Dakhcha   Initial Version
**/
public class Relance_RDV_Supplier implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStr = 'SELECT id, Projet_LMSG__c, Projet_LMSG__r.Owner.firstName, ' +
                          'Compte_Pro__c, Projet_LMSG__r.Particulier__r.FirstName, ' +
                          'Projet_LMSG__r.Particulier__c, Projet_LMSG__r.Telephone_Mobile__c, ' +
                          'Statut__c, statut_RDV__c, Date_Heure_rendez_vous__c, Date_modification_statut_RDV__c, ' +  
                          'Date_selection__c, Date_modification_statut__c, Compte_Pro__r.Statut_activation__c, ' +
                          'Compte_Pro__r.name  FROM Mise_en_relation__c ' + 
                          Label.Query_Batch_Relance_RDV_SMS_Part_Supplier;
/*
            ' WHERE Projet_LMSG__c != null AND Date_Heure_rendez_vous__c = null AND Statut__c =\'Pro_selectionne\' ' +
            ' AND Compte_Pro__r.Statut_activation__c =\'Pro_actif_positionnable\' ' +
            ' AND Projet_LMSG__r.Statut__c=\'PUBLISHED\' ' + 
            ' AND (statut_RDV__c =null OR statut_RDV__c =\'En_attente\' ) ' +
            ' order by Date_selection__c desc '
            ; //and Date_selection__c < LAST_N_DAYS:3 
*/
        System.debug('### Relance_RDV_Supplier Query Filter' + queryStr.substringAfter('WHERE'));

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bctx, List<sObject> objList) {
        System.debug('### Relance_RDV_Supplier' + objList.size());
        List<Relance_RDV_MER__c> insertList = getRelanceRDVRecords(objList);

        if(!insertList.isEmpty()) {
            database.insert(insertList, false); 
        }
    }

    public static List<Relance_RDV_MER__c> getRelanceRDVRecords(List<sObject> objList) {
                // Query already processed MERs : 
        Set<id> merSet = new Set<Id>();
        for(sObject obj : objList) {
            merSet.add(obj.id);
        }

        // check is a MER has a quote :
        List<Devis_LMSG__c> quotes = [SELECT id, createdDate, Mise_en_relation_LMSG__r.Date_Heure_rendez_vous__c 
                                      FROM Devis_LMSG__c WHERE Mise_en_relation_LMSG__c IN :merSet order by createdDate];
        Map<id, datetime> merMap = new Map<id, datetime>();
        for(Devis_LMSG__c qt : quotes) {
            if(qt.Mise_en_relation_LMSG__c !=null && qt.Mise_en_relation_LMSG__r.Date_Heure_rendez_vous__c==null) {
                merMap.put(qt.Mise_en_relation_LMSG__c, qt.CreatedDate -2);
            }
        }
        merSet.removeAll(merMap.keySet());

        List<Mise_en_relation__c> updateMers = new List<Mise_en_relation__c> ();
        for(id mer : merMap.keySet()) {
            updateMers.add(new Mise_en_relation__c(id = mer, Date_Heure_rendez_vous__c = merMap.get(mer)));
        }
        if(!updateMers.isEmpty()) {
            database.update(updateMers, false); 
        }
        
        List<Relance_RDV_MER__c> oldRelanceList = [ SELECT id, MER1__c, MER2__c, MER3__c 
                                                    FROM Relance_RDV_MER__c 
                                                    WHERE relaunch__c = false AND 
                                                          (MER1__c IN:merSet OR MER2__c IN:merSet OR MER3__c IN:merSet)
                                                  ];
        for(Relance_RDV_MER__c relance : oldRelanceList) {
            if(relance.MER1__c != null) {
                merSet.remove(relance.MER1__c);
            }
            if(relance.MER2__c != null) {
                merSet.remove(relance.MER2__c);
            }
            if(relance.MER3__c != null) {
                merSet.remove(relance.MER3__c);
            }
        }

        // Order MERs by project :
        Map<id, List<Mise_en_relation__c>> prjMerMap = new Map<id, List<Mise_en_relation__c>>();
        for(sObject obj : objList) {
            Mise_en_relation__c mer = (Mise_en_relation__c) obj;
            if(!merSet.contains(mer.id)) {
                continue;
            }
            List<Mise_en_relation__c> mList = prjMerMap.get(mer.Projet_LMSG__c);
            if(mList==null) {
                mList = new List<Mise_en_relation__c>();
                prjMerMap.put(mer.Projet_LMSG__c, mList);
            } 
            mList.add(mer);
        }

        List<Relance_RDV_MER__c> relanceList = new List<Relance_RDV_MER__c>();
        for(id prj : prjMerMap.keySet()) {
            List<Mise_en_relation__c> merList = prjMerMap.get(prj);
            relanceList.add(new Relance_RDV_MER__c(Projet_LMSG__c = prj,
                                                   Particulier__c = merList[0].Projet_LMSG__r.Particulier__c,
                                                   SMS_PartPhone__c = merList[0].Projet_LMSG__r.Telephone_Mobile__c,
                                                   Compte_Pro__c = merList[0].Compte_Pro__c,
                                                   SMS_PrenomCA__c = merList[0].Projet_LMSG__r.Owner.FirstName,
                                                   SMS_PrenomPart__c = merList[0].Projet_LMSG__r.Particulier__r.FirstName,
                                                   MER1__c = merList[0].id,
                                                   MER2__c = merList.size() > 1 ? merList[1].id : null,
                                                   MER3__c = merList.size() > 2 ? merList[2].id : null,
                                                   relaunch__c = false,
                                                   part_sms_sent__c = false,
                                                   skip_sms__c = Test.isRunningTest()
                                                   )); 
        }
        return relanceList;
    }

    public void finish(Database.BatchableContext bctx) {
    }

    public void execute(SchedulableContext context) {
        database.executebatch(this);
    }
}