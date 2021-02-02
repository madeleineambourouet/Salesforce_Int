/**
 * @File Name          : MetierTrigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 4/29/2020, 3:37:04 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/9/2020   Hassan Dakhcha     Initial Version
**/
trigger MetierTrigger on Metier__c (before insert, before update, before delete) {

    if(Trigger.isInsert && Trigger.isBefore) {
        MetierMethods.setIsUpdatedBySF(Trigger.new);
        MetierMethods.AttachHKConnectMetierToContact(Trigger.new);
        MetierMethods.FillInFields(Trigger.new, null, true);
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        MetierMethods.setIsUpdatedBySF(Trigger.new);
        MetierMethods.FillInFields(Trigger.new, Trigger.oldMap, false);
    } 
}