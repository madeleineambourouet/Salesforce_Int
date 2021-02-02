/** 
    *Check if the  Cancellation Date(zqu__CancellationDate__c) is birthday of each month
    *according to Zuora__BillCycleDay__c in Zuora__CustomerAccount__c
    *
    *@author    Qiuyan Liu
    *@Starts    15/11/2016
    *@Ends      18/11/2016
    *
    * 
    *@Modification 03/01/2018 EB164
    *@Modification 20/03/2018 EB164 Amendment
    */
trigger QuoteValidStartCancelDate on zqu__Quote__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore &&(Trigger.isInsert || trigger.isUpdate) ) {
        Map<Id, zqu__Quote__c> quoteOldMap = Trigger.isUpdate ? Trigger.oldMap : null;
        String checkValid = QuoteTriggerMethods.validStartCancelDate(Trigger.new, quoteOldMap);
        if (checkValid != null) {
            trigger.new[0].addError(checkValid);
        }
    }
    

    if (Trigger.isAfter && Trigger.isInsert) {
        QuoteTriggerMethods.CompleteEnseigneInfo(trigger.new);
    }

    system.debug('TryAndBuyMethods.triggerStop = ' + TryAndBuyMethods.triggerStop);
    if (Trigger.isAfter && Trigger.isUpdate && TryAndBuyMethods.triggerStop == false) {
        QuoteTriggerMethods.CompleteAccountEnseigneInfo(trigger.oldMap, trigger.newMap); 
        QuoteTriggerMethods.ChangeAmendmentStartDate(trigger.oldMap, trigger.newMap);
    }
}