@isTest
private class TaskMethods_TEST {
	
	@isTest(SeeAllData = true)
	static void test_method_one() {
		Account acct = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        insert acct;
        Task tsk1 = new Task(WhatId = acct.Id, Subject = 'Call: apex test', ActivityDate = date.today(), Status = 'Achevée', CallType='Outbound');
		Task tsk2 = new Task(WhatId = acct.Id, Subject = 'Call: apex test', ActivityDate = date.today(), Status = 'Achevée', CallType='Outbound');
		Task tsk3 = new Task(WhatId = acct.Id, Subject = 'Call: apex test', ActivityDate = date.today().addYears(-2), Status = 'Achevée', CallType='Inbound');
		Task[] tskList = new List<Task>{ tsk1, tsk2, tsk3 };
		insert tskList;
		tsk1.Status = 'Transféré';
		update tsk1;
	}
	
}