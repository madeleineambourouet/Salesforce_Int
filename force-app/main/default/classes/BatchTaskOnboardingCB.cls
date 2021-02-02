global class BatchTaskOnboardingCB implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable, Database.Stateful {
    
	global BatchTaskOnboardingCB() {
        
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Batch start BatchTaskOnboardingCB');
		String query = 'SELECT Id , Zuora__BillCycleDay__c, Zuora__CreditCard_Expiration__c, ExpirationCB__c, Zuora__Account__r.OwnerId, Zuora__Account__r.TC_Referent__c FROM Zuora__CustomerAccount__c ';
		query += 'WHERE Zuora__Account__c IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Status__c = \'Active\' OR Zuora__Status__c = \'Pending Activation\') ';
		query += 'AND ExpirationCB__c != null';
        
		return Database.getQueryLocator(query);
	}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        TaskOnboardingHelper.EcheanceCB(scope, 'CB bientôt expirée');
    }
    
    global void execute(SchedulableContext context) {
		BatchTaskOnboardingCB b = new BatchTaskOnboardingCB();
        database.executebatch(b,100);
    }
    
    global void finish(Database.BatchableContext BC) {
		System.debug('Batch finish ');
    }
}