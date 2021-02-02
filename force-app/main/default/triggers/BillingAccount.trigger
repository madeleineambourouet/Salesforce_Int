trigger BillingAccount on Zuora__CustomerAccount__c (after update) {
    if (Trigger.isUpdate && Trigger.isAfter) {
        TaskOnboardingHelper.ProImpaye(Trigger.new, Trigger.oldMap, 'Pro en impayé');
    }
}