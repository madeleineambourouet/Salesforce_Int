/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-26-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-11-2020   Hassan Dakhcha   Initial Version
**/
Trigger Facture_LMSG_Trigger on Facture__c (before insert, after insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        Indicateur_LMSG.factureLMSG(Trigger.new, null);
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        Indicateur_LMSG.updateInvoiceProject(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        Indicateur_LMSG.factureLMSG(Trigger.new, Trigger.oldMap);
    }

}