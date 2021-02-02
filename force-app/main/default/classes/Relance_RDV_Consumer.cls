/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-06-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-16-2020   Hassan Dakhcha   Initial Version
**/
public class Relance_RDV_Consumer implements Database.Batchable<sObject>, Schedulable {


    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStr =  ' SELECT id, Projet_LMSG__c, MER1__c, MER2__c, MER3__c, ' +
                           ' MER1__r.Compte_Pro__c, MER2__r.Compte_Pro__c, MER3__r.Compte_Pro__c, ' +
                           ' MER1__r.Date_selection__c, MER2__r.Date_selection__c, MER3__r.Date_selection__c, ' + 
                           ' MER1__r.Date_Heure_rendez_vous__c, MER2__r.Date_Heure_rendez_vous__c, MER3__r.Date_Heure_rendez_vous__c, ' +
                           ' MER1__r.statut_RDV__c, MER2__r.statut_RDV__c, MER3__r.statut_RDV__c, ' +
                           ' MER1__r.Statut__c, MER2__r.Statut__c, MER3__r.Statut__c, consumed_for_pro__c ' +
                           ' FROM Relance_RDV_MER__c ' + 
                             Label.Query_Batch_Relance_RDV_SMS_Pro_Consumer;
        
        /* WHERE part_sms_sent_time__c < LAST_N_DAYS:1 AND part_sms_sent__c = true AND consumed_for_pro = false 
           AND (MER1__r.Date_Heure_rendez_vous__c = null OR MER2__r.Date_Heure_rendez_vous__c OR MER3__r.Date_Heure_rendez_vous__c)
        */

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bctx, List<sObject> objList) {

        // Check quote presence;
        Set<Id> MersToKeep = getMersWithoutQuote(objList);

        // gother MERs
        Map<id, id> merProMap = new Map<id, id>();
        Map<id, id> merPrjMap = new Map<id, id>();
        List<Relance_RDV_MER__c> updateProcessed = new List<Relance_RDV_MER__c> ();
        for(sObject obj : objList) {
            Relance_RDV_MER__c relance = (Relance_RDV_MER__c) obj;
            relance.consumed_for_pro__c = true;
            updateProcessed.add(relance);

            if(MersToKeep.contains(relance.MER1__c) && pickUpMer(relance.MER1__c, relance.MER1__r)) {
                merProMap.put(relance.MER1__c, relance.MER1__r.Compte_Pro__c);
                merPrjMap.put(relance.MER1__c, relance.Projet_LMSG__c);
            }
            if(MersToKeep.contains(relance.MER2__c) && pickUpMer(relance.MER2__c, relance.MER2__r)) {
                merProMap.put(relance.MER2__c, relance.MER2__r.Compte_Pro__c);
                merPrjMap.put(relance.MER2__c, relance.Projet_LMSG__c);
            }
            if(MersToKeep.contains(relance.MER3__c) && pickUpMer(relance.MER3__c, relance.MER3__r)) {
                merProMap.put(relance.MER3__c, relance.MER3__r.Compte_Pro__c);
                merPrjMap.put(relance.MER3__c, relance.Projet_LMSG__c);
            }
        }

        Database.update(updateProcessed, false);

        List<Relance_Pro_RDV_MER__c> relanceToCreate = new List<Relance_Pro_RDV_MER__c>();
        for(id key : merPrjMap.keySet()) {
            relanceToCreate.add(new Relance_Pro_RDV_MER__c( Projet_LMSG__c = merPrjMap.get(key),
                                                            Compte_Pro__c = merProMap.get(key),
                                                            Mise_en_relation_LMSG__c = key,
                                                            skip_sms__c = Test.isRunningTest()          
            ));
        }

        insert(relanceToCreate);

    }

    public void finish(Database.BatchableContext bctx) {

    }

    private boolean pickUpMer(id idMer, Mise_en_relation__c mer) {
        if(idMer == null || mer.Date_Heure_rendez_vous__c != null)
            return false;
        
        if(mer.statut_RDV__c != null && mer.statut_RDV__c != '' && mer.statut_RDV__c != 'En_attente')
            return false;

        if(mer.Statut__c != 'Pro_selectionne' && mer.Statut__c != 'Pro_rencontre')
            return false;

        return true;
    }
    
    private Set<Id> getMersWithoutQuote(List<sObject> objList) {
        Set<id> merSet = new Set<Id>();
        for(sObject obj : objList) {
            Relance_RDV_MER__c relance = (Relance_RDV_MER__c) obj;
            if(relance.MER1__c!=null) {
                merSet.add(relance.MER1__c);
            } 
            if(relance.MER2__c!=null) {
                merSet.add(relance.MER2__c);
            }      
            if(relance.MER3__c!=null) {
                merSet.add(relance.MER3__c);
            }                
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

        return merSet;
    }

    public void execute(SchedulableContext context) {
        database.executebatch(this);
    }
}