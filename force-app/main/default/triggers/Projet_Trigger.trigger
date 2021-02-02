/**
 * @File Name          : Projet_Trigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/11/2020, 3:42:05 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
**/
// 
// trigger sur les projets
// 14/04/2017, xavier templet, regroupe differents triggers dans un seul   
// 14/04/2017, xavier templet, ajoute le control avec les flags pour le lancement de IntermediationHandler.getMatching   
// 14/06/2017, xavier templet, ajoute le trigger before update pour la MAJ des dates de qualif ou debut / fin ODC_ouverte
// 06/07/2017, Qiuyan Liu, EB-129, Mise à jour affiliation depuis projets Salesforce à BUS
// 31/05/2018, Qiuyan Liu, optimization project's foncitonalities

trigger Projet_Trigger on Projet__c (before insert, before update, after update, before delete, after insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        ProjectMethods.initProjectValues(trigger.new);
    }

    /*if (Trigger.isAfter && Trigger.isInsert) {
        system.debug('after insert!!!!');
        try { ProjectMethods.createClick2call(trigger.new);} catch (Exception e) { System.debug('Erreur création de rappel = ' + e);}
    }*/

    if (Trigger.isBefore && Trigger.isUpdate) {
        ProjectMethods.updateProjectValues(Trigger.oldMap, Trigger.newMap, Trigger.new);
    }

    if (Trigger.isUpdate && trigger.isAfter) {
        Set<Id> Ids_newemail = new Set<Id>();

        CallServiceInstaply.prepareMessageToSend(Trigger.oldMap, Trigger.newMap, Trigger.new); 
        
        for (Projet__c proj: Trigger.new) {
            Projet__c oldproj = Trigger.oldMap.get(proj.Id);
            if (oldproj.email_projet__c != proj.email_projet__c)
                Ids_newemail.add(proj.Id);
         }
        
        List<Intermediation__c> Merchild = (Ids_newemail.size()>0 ? [SELECT Id, Projet__c, Email_mise_en_relation__c from Intermediation__c where Projet__c in :Ids_newemail] : new List<Intermediation__c>());
        List<Intermediation__c> newMerchild = new List<Intermediation__c>();
        
        for (Projet__c proj2: Trigger.new) {
            for (Intermediation__c inter: Merchild) {
                if ((inter.Email_mise_en_relation__c != proj2.email_projet__c) && (inter.Projet__c == proj2.Id)) {
                    inter.Email_mise_en_relation__c = proj2.email_projet__c;
                    newMerchild.add(inter);
                }
            }
        }
        
        if (newMerchild.isEmpty() == false)
            update newMerchild;
        
        
        for (Projet__c proj4mer : Trigger.new) {
            Projet__c oldproj = Trigger.oldMap.get(proj4mer.Id);
            //if (((oldproj.Statut_Projet__c != proj4mer.Statut_Projet__c && proj4mer.Statut_Projet__c == 'Qualifié') || 
            //     (proj4mer.Matching_Demande__c != oldproj.Matching_Demande__c && proj4mer.Matching_Demande__c == true)) && !proj4mer.flag_runOnce__c ) {
            if (((oldproj.Statut_Projet__c != proj4mer.Statut_Projet__c && proj4mer.Statut_Projet__c == 'Qualifié') || 
                 (proj4mer.Matching_Demande__c != oldproj.Matching_Demande__c && proj4mer.Matching_Demande__c == true)) && checkRecursiveSFDC.runOnce()) {     
                IntermediationHandler.getMatching(proj4mer.id);
            }
        }
        
        //EB-129, Mise à jour affiliation depuis projets Salesforce à BUS
        //to bypass fonction in this class, put the function name 'MAJ_ProjetAffiliation' in field "Bypass_Function__c" on User
        ProjetAffiliationWS.MAJ_ProjetAffiliation(Trigger.newMap, Trigger.oldMap);    
    }

    //if (Trigger.isAfter && Trigger.isDelete) {
    //    ProjetAffiliationWS.MAJ_ProjetAffiliationDelete(Trigger.oldMap.keyset());
    //}
    
}