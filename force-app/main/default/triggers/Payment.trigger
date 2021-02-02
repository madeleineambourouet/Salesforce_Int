trigger Payment on Zuora__Payment__c (after insert) {

	if (trigger.isInsert && trigger.isAfter)
		SalesFact_Methods.Transaction_Salesfact(trigger.new);
}