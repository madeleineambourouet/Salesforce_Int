global class BatchTaskOnboardingAssurance implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable, Database.Stateful {
    
    global BatchTaskOnboardingAssurance() {
        
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Batch start BatchTaskOnboardingAssurance');
		String query = 'SELECT Id, Compte__r.OwnerId, Compte__r.TC_Referent__c FROM Document_Assurance__c ';
		query += 'WHERE Date_d_expiration__c > NEXT_N_DAYS:29 ';
        query += 'AND Date_d_expiration__c <= NEXT_N_DAYS:30 ';
        query += 'AND Statut__c = \'Validée\' ';
        query += 'AND Compte__c IN (SELECT 	Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Status__c = \'Active\' OR Zuora__Status__c = \'Pending Activation\')';
        
		return Database.getQueryLocator(query);
	}
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        TaskOnboardingHelper.EcheanceAssurance(scope, 'Assurance bientôt expirée');
    }
    
    global void execute(SchedulableContext context) {
		BatchTaskOnboardingAssurance b = new BatchTaskOnboardingAssurance();
        database.executebatch(b,100);
    }
    
    global void finish(Database.BatchableContext BC) {
		System.debug('Batch finish ');
    }
}