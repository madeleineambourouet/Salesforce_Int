/**
 * @File Name          : Projet_LMSG_Trigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 12-28-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/1/2020   Hassan Dakhcha     Initial Version
**/
Trigger Projet_LMSG_Trigger on Projet_LMSG__c (before insert, after insert, before update, after update) {

    if(Trigger.isInsert && Trigger.isBefore) {
       Projet_LMSG_Methods.updateDetails(Trigger.new, null);
       Projet_LMSG_Methods.setIsUpdatedBySF(Trigger.new, null);
       Projet_LMSG_Methods.majIdLeadAndProjetHYStatus(Trigger.new);
       Projet_LMSG_Methods.copyPhoneFromPart(Trigger.new);
       Indicateur_LMSG.projet_LMSG(Trigger.new, null);
    }
    if(Trigger.isInsert && Trigger.isAfter) {
        Projet_LMSG_Methods.insertPP(Trigger.new);
        Projet_LMSG_AffiliationWS.notifyAffiliation(null, Trigger.newMap);
    }
    if(Trigger.isUpdate && Trigger.isBefore) {
        // When JSON is changed by Heroku we update Prestation Projets and other details:
        Projet_LMSG_Methods.updateDetails(Trigger.new, Trigger.oldMap);
        Projet_LMSG_Methods.setIsUpdatedBySF(Trigger.new, Trigger.oldMap); 
        Projet_LMSG_Methods.updateNumMerRestantes(Trigger.new, Trigger.oldMap);
        Indicateur_LMSG.projet_LMSG(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isUpdate && Trigger.isAfter) {
        Projet_LMSG_AffiliationWS.notifyAffiliation(Trigger.oldMap, Trigger.newMap);
        // add calls if needed
        Relance_ProPart_LMSG.createProjectCallFileMembers(Trigger.new, Trigger.oldMap);
    }

}