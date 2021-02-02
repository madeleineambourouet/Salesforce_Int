/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 08-18-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-18-2020   Hassan Dakhcha   Initial Version
**/
trigger Notation_LMSG_Trigger on Notation_LMSG__c (before insert, after insert, after update, after delete) {

    if(Trigger.isBefore && Trigger.isInsert) {
        Notation_LMSG_Methods.attachPart(Trigger.new);
    }

    if(Trigger.isAfter) {
        Notation_LMSG_Methods.updateProRating(Trigger.new, Trigger.isUpdate? Trigger.oldMap : null);
    }
}