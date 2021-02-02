@isTest
public class CleanItemDeletedBatchTest {
	static testmethod void test() {
        String CRON_EXP = '0 0 0 3 9 ? 2022';
   		Test.startTest();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        insert pays; 
        insert CP; 
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        insert particulier;
        delete particulier;
        System.assertNotEquals(0, [SELECT COUNT() FROM ItemDeleted__c WHERE CreatedDate = THIS_WEEK]);
        String jobId = System.schedule('CleanItemDeletedBatch', CRON_EXP, new CleanItemDeletedBatch());
        
        // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
      	// Verify the expressions are the same
      	System.assertEquals(CRON_EXP, ct.CronExpression);
      	// Verify the job has not run
      	System.assertEquals(0, ct.TimesTriggered);
      	// Verify the next time the job will run
      	System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
      	System.assertEquals('Account',[SELECT id, name FROM ItemDeleted__c][0].name);
   		Test.stopTest();
   }
}