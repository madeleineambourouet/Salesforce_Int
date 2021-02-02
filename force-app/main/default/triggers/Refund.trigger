trigger Refund on Zuora__Refund__c (after insert) {

	if (trigger.isInsert && trigger.isAfter)
		SalesFact_Methods.Transaction_Salesfact(trigger.new);
}