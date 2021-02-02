// 
// Test du Batch pour créer les faits de vente
// 24/01/2018, xavier templet, version initiale   
//

//@isTest
@isTest(seeAllData=true)
private class Batch_Monthly_SalesFact_Test {

	public static String CRON_EXP = '0 26 18 29 3 ? 2022'; // from the 29/3/2022 runs monthly the 29th at 18h26

    public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
    public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);
    public static final String DEFAULT_CURRENCY = 'EUR';
		
	static testmethod void testScheduledJob_Monthly_SalesFact() {
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Batch_Monthly_SalesFact b = new Batch_Monthly_SalesFact(); 
        database.executebatch(b);
        // Schedule the test job
        //String jobId = System.schedule('Scheduled Batch_Monthly_SalesFact ApexTest', CRON_EXP, new Batch_Monthly_SalesFact());
        Test.stopTest();
        //List<xxxx> zq = [select Id from zqu__Quote__c where zqu__Amendment_Name__c = 'Recrédit'   ];  // and zqu__account__c = PRO.Id and zqu__Currency__c = 'EUR' 
      	//System.debug('Batch_Monthly_SalesFact_Test >>>>> List<xxxx> ApexTest : ' + zq);
        //system.assert(zq.size() >= 1);        


    	
    }
}