/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-03-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-16-2020   Hassan Dakhcha   Initial Version
**/
public class Relance_RDV_Call_Consumer implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(database.BatchableContext bc) {
        String queryStr =   ' SELECT id, Compte_Pro__c, Mise_en_relation_LMSG__c, Mise_en_relation_LMSG__r.Statut__c, ' +
                            ' Projet_LMSG__c , Projet_LMSG__r.Telephone_Mobile__c, sms_pro_sent__c, '+ 
                            ' Mise_en_relation_LMSG__r.Date_Heure_rendez_vous__c, Mise_en_relation_LMSG__r.statut_RDV__c, pro_sms_sent_time__c ' +
                            ' FROM Relance_Pro_RDV_MER__c ' +
                            Label.Query_Batch_Relance_RDV_Appel_Part_Consumer;

        /* WHERE call_done__c = false AND  pro_sms_sent_time__c < LAST_N_DAYS:1 AND 
           (Mise_en_relation_LMSG__r.Statut__c ='Pro_selectionne' OR Mise_en_relation_LMSG__r.Statut__c ='Pro_rencontre') AND 
           Mise_en_relation_LMSG__r.Date_Heure_rendez_vous__c = null AND 
           (Mise_en_relation_LMSG__r.statut_RDV__c = null OR Mise_en_relation_LMSG__r.statut_RDV__c = 'En_attente' ) AND 
           sms_pro_sent__c = true
        */

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bc, List<sObject> objectList) {

        // check quote presence
        Set<id> merWithoutQuote = getMersWithoutQuote(objectList);

        Map<id, List<Relance_Pro_RDV_MER__c>> prjRelMap = new Map<id, List<Relance_Pro_RDV_MER__c>>();
        for(sObject obj : objectList) {
            Relance_Pro_RDV_MER__c rel = (Relance_Pro_RDV_MER__c) obj;
            if(!merWithoutQuote.contains(rel.Mise_en_relation_LMSG__c)) {
                continue;
            }

            List<Relance_Pro_RDV_MER__c> rlist = prjRelMap.get(rel.Projet_LMSG__c);
            if(rlist == null) {
                rlist = new List<Relance_Pro_RDV_MER__c> ();
                prjRelMap.put(rel.Projet_LMSG__c, rlist);
            }
            rlist.add(rel);
        }

        // Label : Campagne_Relance_Part_RDV_DEVIS
        vhc__Campaign__c campaignPart = [SELECT id FROM vhc__Campaign__c WHERE Name =:Label.Campagne_Relance_Part_RDV_DEVIS LIMIT 1];
        if(CampaignPart == null) {
            System.debug('#### Relance_RDV_Call_Consumer : ' + Label.Campagne_Relance_Part_RDV_DEVIS +' introuvable ! ');
            return;
        }

        List<vhc__Campaign_Member__c> campaignMembers = new List<vhc__Campaign_Member__c>();
        List<Relance_Pro_RDV_MER__c> flagAsCallDone = new List<Relance_Pro_RDV_MER__c>();
        for(id project : prjRelMap.keySet()) {
            vhc__Campaign_Member__c call = new vhc__Campaign_Member__c( Projet_LMSG__c = project,
                                                                        vhc__Campaign__c = campaignPart.id,
                                                                        vhc__ClickToDial__c = prjRelMap.get(project)[0].Projet_LMSG__r.Telephone_Mobile__c,
                                                                        vhc__Priority__c = 'HIGH',
                                                                        vhc__Status__c = 'To Create');
            campaignMembers.add(call);
            for(Relance_Pro_RDV_MER__c rel : prjRelMap.get(project)) {
                flagAsCallDone.add(new Relance_Pro_RDV_MER__c(id = rel.id, call_done__c = true)); 
            }
            System.debug('### Relance_RDV_Call_Consumer : Call ' + call + ' phone ' + call.vhc__ClickToDial__c); 
        }
        System.debug('### Relance_RDV_Call_Consumer : Nombre de Calls ' + campaignMembers.size()); 

        Database.update(flagAsCallDone, false);

        Database.SaveResult[] results = Database.insert(campaignMembers, false);
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    System.debug('### Relance_RDV_Call_Consumer : Insertion des vhc__Campaign_Member__c a échouée ');                   
                    System.debug('### Relance_RDV_Call_Consumer : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### Relance Part Champs origine de l\'erreur : '  + err.getFields());
                }
            }
        }

    }

    private Set<Id> getMersWithoutQuote(List<sObject> objList) {
        Set<id> merSet = new Set<id>();
        for(sObject obj : objList) {
            Relance_Pro_RDV_MER__c relance = (Relance_Pro_RDV_MER__c)obj;
            if(relance.Mise_en_relation_LMSG__c!=null) {
                merSet.add(relance.Mise_en_relation_LMSG__c);
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

    public void finish(Database.BatchableContext bc) {
    }
    public void execute(SchedulableContext context) {
        database.executebatch(this);
    }
}