/**
 * @File Name          : Jointure_Documents_Prestations_Trigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 01-16-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/24/2020      Hassan Dakhcha           Initial Version
**/
trigger Jointure_Documents_Prestations_Trigger on Jointure_Documents_Prestations__c (before insert) {

    // New Jonction : verify the new PC statuts
    // Update Jonct :
    //           - Doc type changed : verify the existing jonction (possible remove)
    //           - PC list doc changed : purge the jonctions and verify the pc jonctions based on the new list
    // Jonction Deleted : verify the new PC statuts

    // PC List to maintain because it comes from a multi picklist field
    if(Trigger.isBefore && Trigger.isInsert) {
        Set<id> pcIdSet = new Set<id>();
        for(Jointure_Documents_Prestations__c jct : Trigger.new) {
            pcIdSet.add(jct.prestation__c);
        }
        if(pcIdSet.isEmpty())
            return;
        Map<id, Prestation_Contact__c> pcMap = new Map<id, Prestation_Contact__c> ([ SELECT id, Tech_Liste_Doc_Obligatoires_PP__c, prestation__r.Code_RGE_Qualibat__c
                                                                                     FROM Prestation_Contact__c Where id IN :pcIdSet]);
        for(Jointure_Documents_Prestations__c jct : Trigger.new) {
           jct.Tech_Liste_Doc_Obligatoires__c = pcMap.get(jct.Prestation__c).Tech_Liste_Doc_Obligatoires_PP__c;
        }
    }

    /*
    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('###### HDAK afterUp trig ' );

        Map<id, Jointure_Documents_Prestations__c> jctMap = new Map<id, Jointure_Documents_Prestations__c>();
        List<Jointure_Documents_Prestations__c> jctDocStatusChanged = new List<Jointure_Documents_Prestations__c>();
        for(Jointure_Documents_Prestations__c jct : Trigger.New) {
            if(Trigger.oldMap.get(jct.id).Type_de_document__c != Trigger.newMap.get(jct.id).Type_de_document__c)
                jctMap.put(jct.id, jct);
                System.debug('###### HDAK afterUp trig ' + Trigger.oldMap.get(jct.id).Tech_key_doc_status__c  + ' ' + Trigger.newMap.get(jct.id).Tech_key_doc_status__c  );

            if(Trigger.oldMap.get(jct.id).Tech_key_doc_status__c != Trigger.newMap.get(jct.id).Tech_key_doc_status__c
               && (Trigger.oldMap.get(jct.id).Tech_key_doc_status__c=='VALIDATED' 
                   || Trigger.newMap.get(jct.id).Tech_key_doc_status__c =='VALIDATED'))
                jctDocStatusChanged.add(jct);
        }
        if(!jctMap.isEmpty())
            MandatoryDocs_JctDocManager.docTypeChanged(jctMap);
        if(!jctDocStatusChanged.isEmpty())
            MandatoryDocs_JctDocManager.docStatusChanged(jctDocStatusChanged);
    }
*/
    // Jonction delete  origins :
    // before update doc type changed 
    // have to lauch the analysis
    
}