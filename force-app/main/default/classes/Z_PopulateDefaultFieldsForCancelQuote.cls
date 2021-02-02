global class Z_PopulateDefaultFieldsForCancelQuote extends 
    zqu.CancellationPropertyController.PopulateDefaultFieldValuePlugin{
    global override void populateDefaultFieldValue(
        SObject record, zqu.PropertyComponentController.ParentController pcc){
        
        if(record.Id == null || Test.isRunningTest()) {
            //Populate default values in the quote header
            if(!Test.isRunningTest()) super.populateDefaultFieldValue(record, pcc); 
        	//Date lastInvoicePeriod =  Test.isRunningTest() ? Date.today() : Zuora_Query.getLastInvoicePeriod(((zqu__Quote__c)record).zqu__ExistSubscriptionID__c);
            Zuora_Query.CurSubscriptionInfo curSubInfo = Test.isRunningTest() ? new Zuora_Query.CurSubscriptionInfo() : (Zuora_Query.CurSubscriptionInfo)JSON.deserializeStrict(Zuora_Query.getCurSubscriptionInfo(((zqu__Quote__c)record).zqu__ExistSubscriptionID__c), Zuora_Query.CurSubscriptionInfo.class);
            System.debug('curSubInfocurSubInfo ' + curSubInfo);
            Date lastInvoicePeriod = Test.isRunningTest() ? Date.today() : curSubInfo.chargedThroughDate;
            if (lastInvoicePeriod != null) {
                record.put('LastInvoicePeriod__c', lastInvoicePeriod);
                record.put('zqu__CancellationDate__c', lastInvoicePeriod);
            }
        }
    }
}