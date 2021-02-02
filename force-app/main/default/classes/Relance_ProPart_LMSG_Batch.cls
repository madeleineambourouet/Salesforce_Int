/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 08-07-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-28-2020   Hassan Dakhcha   Initial Version
**/
global class Relance_ProPart_LMSG_Batch implements Database.Batchable<sObject> , Database.AllowsCallouts, Schedulable {

    global final String relanceType;
    global Relance_ProPart_LMSG_Batch(String typeRelance) {
        this.relanceType = typeRelance;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        purgeCalls();

        String queryStr = '';
        if(this.relanceType == 'relancePro') {
            queryStr = Label.Query_Batch_Relance_Pro_AR3;
            /* 'SELECT id, Identifiant_PP__c,  Nombre_de_MER_restantes__c FROM Projet_LMSG__c ' +
                'WHERE Statut__c =\'PUBLISHED\' ' +
                'AND Nombre_de_MER_restantes__c > 0 ' +
                'AND Date_modification_statut__c = LAST_N_DAYS:2';*/
        }
        if(this.relanceType == 'relancePart') {
            queryStr = Label.Query_Batch_Relance_Part_RDV_Devis;
            /*'SELECT id, Statut__c, Projet_LMSG__r.Nombre_de_MER_restantes__c, Date_Heure_rendez_vous__c '+
              'FROM Mise_en_relation__c '+
              'WHERE Statut__c =\'Pro_selectionne\' '+
              'AND Date_Heure_rendez_vous__c =null AND Date_modification_statut__c =LAST_N_DAYS:2';*/
        }
        System.debug('#### Query Relance_ProPart_LMSG_Batch = ' + queryStr);

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bc, List<SObject> objects) {
        if(objects.isEmpty()) {
            system.debug(' batch relance pro  : Pas d\'objets');
            return;
        }

        if(this.relanceType == 'relancePro') {
            // Construct new calls
            List<String> projectWbeIds = new List<String>();
            for(sObject obj : objects) {
                projectWbeIds.add(((Projet_LMSG__c) obj).Identifiant_PP__c);
            }

            System.enqueueJob(new Relance_ProPart_LMSG(projectWbeIds));
        } 
        if(this.relanceType == 'relancePart') {
            // Construct the new calls
            List<Mise_en_relation__c> merList = new List<Mise_en_relation__c>();
            for(sObject obj : objects) {
                merList.add((Mise_en_relation__c) obj);
            }
            System.enqueueJob(new Relance_ProPart_LMSG(merList));
        }
    }

    private void purgeCalls() {

        String campagneName = '';
        if(this.relanceType =='relancePro') {
            campagneName = Label.Campagne_Relance_Pro_AR3;
        } else if(this.relanceType =='relancePart') {
            campagneName = Label.Campagne_Relance_Part_RDV_DEVIS;
        } else {
            return;
        }

        // Purge the call file Memebers
        String queryPurge = 'SELECT id, vhc__ClickToDial__c, vhc__Status__c, Projet_LMSG__c, vhc__Contact__c FROM vhc__Campaign_Member__c ' + 
                            ' WHERE vhc__Campaign__r.name =\''+ campagneName + '\' AND ' + Label.Campagne_Relance_Criteres_Purge;

        List<vhc__Campaign_Member__c> callFileMembers = Database.query(queryPurge);
        if(callFileMembers.isEmpty()){
            return;
        }
        Set<id> cfmSet = new Set<id>();
        for(vhc__Campaign_Member__c cfm : callFileMembers) {
            cfmSet.add(cfm.id);
        }
        // Query all Calls related to the call members to purge
        List<vhc__call__c> callList = [SELECT id, vhc__Call_File_Member__c FROM vhc__Call__c WHERE vhc__Call_File_Member__c IN : callFileMembers];
        if(!callList.isEmpty()) {
            for(vhc__call__c call : callList) {
                System.debug('### relance Pro : membre Exclus ' + call);
                cfmSet.remove(call.vhc__Call_File_Member__c);
            }
        }

        if(Label.Campagne_Relance_Commit_Debug == 'DEBUG') {
            System.debug('### relance Pro : Nombre de Call a Pruger ' + cfmSet.size());
        } else {
            Database.delete(new List<id>(cfmSet), false);
        }

        // deflager les contact et projets :
        try {
            if(this.relanceType =='relancePro') {
                List<Contact> ctcList = [SELECT id, Date_Relance_CS_AR3__c FROM Contact WHERE Date_Relance_CS_AR3__c != null];
                for(contact ctc : ctcList) {
                    ctc.Date_Relance_CS_AR3__c = null;
                }
                update ctcList;
            }
            if(this.relanceType =='relancePart') {
                List<Projet_LMSG__c> prjList = [SELECT id, Date_Relance_CS_RDV_DEVIS__c FROM Projet_LMSG__c WHERE Date_Relance_CS_RDV_DEVIS__c != null];
                for(Projet_LMSG__c prj : prjList) {
                    prj.Date_Relance_CS_RDV_DEVIS__c = null;
                }           
                update prjList;
            }
        } catch (DmlException e) {
            System.debug('### Purge Relance Exception :  ' +  e.getDmlMessage(0));
        }
    }

    public void finish(Database.BatchableContext bctx) {
    }

    public void execute(SchedulableContext context) {
        Relance_ProPart_LMSG_Batch b = new Relance_ProPart_LMSG_Batch('relancePro'); 
        database.executebatch(b);
        b = new Relance_ProPart_LMSG_Batch('relancePart'); 
        database.executebatch(b);
    }
}