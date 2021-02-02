/*
 * Prestation Contact Trigger : handels some logic before the prestation contact is inserted
 * Test Method : HerokuConnectTest
 * Created by : Hassan
 * Created Date : 26 Dec 2019
 */

trigger PrestationContactTrigger on Prestation_Contact__c (before insert, after Insert, before update, after update, before delete, after delete) {
	
    // Insertion des prestation contacts par Heroku Connect
    if(Trigger.isBefore && Trigger.isInsert) {
        PrestationContactMethods.setIsUpdatedBySF(Trigger.New);
    	PrestationContactMethods.AttachHKConnectPCToContact(Trigger.New);
        // fill in the key : Email_Cle_Prestation__c
        PrestationContactMethods.initKey(Trigger.New);
        
        //set mandatory doc list cache :
        MandatoryDocs_Synthesizer.setDocList(Trigger.New);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        // Init the Doc list and the statut (Positionnable/ Non Positionnable)
       //System.debug('### HDAK after Insert' + Trigger.new);
        MandatoryDocs_Synthesizer.createJunctionAndNewDocs(Trigger.New);
        // adding a PrestContact just update the calculation
        MandatoryDocs_StatusSetter.evaluatePCStatuts_ForAllPC(Trigger.newMap.keySet());   

        // for PC that are positionnable evaluate the account status :
        Set<id> posSet = new Set<id>();
        for(Prestation_Contact__c pc : Trigger.New) {
            if(pc.Statut__c == 'POS') {
                posSet.add(pc.Contact__c);
           }
         }

        if(!posSet.isEmpty())
            MandatoryDocs_StatusSetter.setAccSatutus_Commit(posSet);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        // Set flag updated
        PrestationContactMethods.setIsUpdatedBySF(Trigger.New);
        
        List<Prestation_Contact__c> pcList = new List<Prestation_Contact__c>();
        for(Prestation_Contact__c pc : Trigger.New) {
            if(pc.Prestation__c != Trigger.OldMap.get(pc.Id).Prestation__c) {
                 pcList.add(pc);
            }
        }
        MandatoryDocs_Synthesizer.setDocList(pcList);
    }

    // Gestion des document manquants
    if(Trigger.isAfter && Trigger.isUpdate) {
        // cases of modification : Contact__c / Prestation__c
        Map<id, Prestation_Contact__c> pcMap = new Map<id, Prestation_Contact__c>();
        Set<id> statusChangedSet = new Set<id>();
        for(Prestation_Contact__c pc : Trigger.New) {
            if(pc.Contact__c == null)
                continue;
            if(pc.Tech_Liste_Doc_Obligatoires_PP__c != Trigger.OldMap.get(pc.Id).Tech_Liste_Doc_Obligatoires_PP__c) {
                 pcMap.put(pc.id, pc);
            } else if(pc.Statut__c != Trigger.OldMap.get(pc.Id).Statut__c) {
                statusChangedSet.add(pc.Contact__c);
           }
         }
        
        if(!pcMap.isEmpty())  {
        // Purge Jonctions :
        MandatoryDocs_JctDocManager.purgeJonction(pcMap.keySet());

        // recalcualte the mandatory Docs on Compte Pro
        MandatoryDocs_Synthesizer.createJunctionAndNewDocs(pcMap.values());
        MandatoryDocs_StatusSetter.evaluatePCStatuts_ForAllPC(pcMap.keySet());
        }
        if(!statusChangedSet.isEmpty()) {
            MandatoryDocs_StatusSetter.setAccSatutus_Commit(statusChangedSet);
        }

    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
        //System.debug('#### HDAK : before delete' + Trigger.old);
        // removing the PrestContact recalcualte the mandatory Docs on Compte Pro
        MandatoryDocs_JctDocManager.pcDeleted(Trigger.oldMap);

        // delete other PC with same PSKU and under the same contact:
        // delete is performed only for manual delete not in bulk
        PrestationContactMethods.deleteSamePSKU(Trigger.oldMap.keySet());
    }
   
}