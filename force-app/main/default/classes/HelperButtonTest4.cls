@isTest
public with sharing class HelperButtonTest4 {
	
	@isTest
	public static void HelperTest() {
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		insert acc;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = acc.Id;
        quote.Name = 'Quote Name';
        quote.zqu__Status__c = 'Sent to Z-Billing';

        zqu__Quote__c quo = new zqu__Quote__c();
		quo.zqu__Account__c = acc.Id;
        quo.Name = 'Quote Name';
        quo.zqu__Status__c = 'En cours';

        zqu__Quote__c quo2 = new zqu__Quote__c();
		quo2.zqu__Account__c = acc.Id;
        quo2.Name = 'Quote Name';
        quo2.zqu__Status__c = 'Envoyée';

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        quotes.add(quote);
        quotes.add(quo);
        quotes.add(quo2);

        insert quotes;

        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Pending Activation',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = acc.Id, Type_de_geste__c = 'Création de souscription', TECH_QuoteID__c = quote.Id);
        insert Subscription;
        Test.startTest();
        helperButton.callVerifierQuoteDateActivation(quote.Id);
        helperButton.callVerifierQuoteRenoncerActivation(quote.Id);
        helperButton.callGenererPdf(quo.Id);
        helperButton.callRegenererPdf(quo2.Id);
        Test.stopTest();
	}
}