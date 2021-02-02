/**
 * @File Name          : referenceTrigger.trigger
 * @Description        : trigger on the reference table
 * @Author             : Hassan Dakhcha 
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2/24/2020, 2:59:53 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/24/2020       Hassan Dakcha           Initial Version
**/
trigger referenceTrigger on Reference__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate) {
        // cover the case where the mandatory docs changes on the reference 
        // do the check for Prestation record type
        Id prestationRT = Schema.SObjectType.Reference__c.getRecordTypeInfosByName().get('Prestation').getRecordTypeId();
        Map<id, Reference__c> refMap = new Map<id, Reference__c>();
        for(Reference__c ref : Trigger.new) {
            if(ref.recordTypeId != prestationRT)
                continue;

            if(Trigger.oldMap.get(ref.id).Document_obligatoire__c != ref.Document_obligatoire__c) 
                refMap.put(ref.id, ref);
        }
        // Update 
        List<Prestation_Contact__c> pcList = [SELECT id, Tech_Liste_Doc_Obligatoires_PP__c, Prestation__c
                                              FROM Prestation_Contact__c 
                                              WHERE Prestation__c IN : refMap.keySet()];
        if(pcList.isEmpty())
           return;
        
        for(Prestation_Contact__c pc : pcList) {
            pc.Tech_Liste_Doc_Obligatoires_PP__c = refMap.get(pc.Prestation__c).Document_obligatoire__c;
        }

        MandatoryDocs_StatusSetter.commitUpdatePC(pcList, 'referenceTrigger::AfterUpdate DocList');
                                     
    }
}