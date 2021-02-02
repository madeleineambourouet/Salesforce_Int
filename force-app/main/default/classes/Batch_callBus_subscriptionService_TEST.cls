@isTest
public class Batch_callBus_subscriptionService_TEST {

    static testmethod void changeClientActivationEtaTest() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
       	Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
	    Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
	    Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		insert professionnel;
        Batch_callBus_subscriptionService.changeClientActivationEtat(professionnel.Id, true);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse404());
        Batch_callBus_subscriptionService.changeClientActivationEtat(professionnel.Id, false);


        Test.stopTest();


    }
    static testmethod void executeBatchTest() {        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse404());
       	Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
	    Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
	    Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		insert professionnel;
       	
       	professionnel.Desactivation_des_ODC_impaye_recurrent__c = true;
       	update professionnel; 	
		Date dateDebut = Date.today();
		DateTime todayDateTime = dateDebut;
		String dateDebutString = todayDateTime.formatGMT('yyyy-MM-dd');
		system.debug('Batch_callBus_subscriptionService dateDebutString '+dateDebutString);
        Batch_callBus_subscriptionService b = new Batch_callBus_subscriptionService(dateDebutString); 
        Database.executeBatch(b);


        Test.stopTest();
    }
    static testmethod void sendMailTest() {        
        Test.startTest();
        Batch_callBus_subscriptionService.sendAlertMail('ceci est un message');
        Test.stopTest();
    }

   	public class MockHttpResponse200 implements HttpCalloutMock {
    	// Implement this interface method
   		public HTTPResponse respond(HttpRequest req) {
        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('ok');
	        res.setStatusCode(200);
	        return res;
    	}
	}
   	public class MockHttpResponse404 implements HttpCalloutMock {
    	// Implement this interface method
   		public HTTPResponse respond(HttpRequest req) {
        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('ok');
	        res.setStatusCode(404);
	        return res;
    	}
	}
}