@isTest
private class VFC_QuoteStep1Creation_TEST {
	
	@isTest static void test_method_one() {
		// Implement test code
        // Creation of test data
        Reference__c NAF = TestFactory.createReference('NAF','BBB','BBB','BBB');
		Reference__c FR = TestFactory.createReference('pays','France','FRA','FRA');
        Reference__c CP = TestFactory.createReference('CP', '75000', '75000', '75000');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
        Reference__c compFirst = TestFactory.createReference('Competence', 'First Competence', '1', 'CAT_1');
        Reference__c compSecond = TestFactory.createReference('Competence', 'Second Competence', '2', 'CAT_2');
  		List<Reference__c> lRefs = new List<Reference__c>();
  		lRefs.add(NAF);
  		lRefs.add(FR);
  		lRefs.add(CP);
  		lRefs.add(agence);
  		lRefs.add(compFirst);
  		lRefs.add(compSecond);
  		insert lRefs;

        Account compte = new Account(RecordTypeId = TestFactory.RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert compte;

        ProgrammeFidelite__c pf = new ProgrammeFidelite__c(Agence_Pilote__c=agence.Id, Code_client_groupe__c='test', Compte__c=compte.Id, DateEntree__c=Date.today(), DateSortie__c=Date.today().addMonths(1));
       // system.debug('my pf ' + pf);
        insert pf;
        compte.Enseigne_de_facturation__c = pf.Id;
        update compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', AccountId = compte.Id, Phone = '+33111111111');
        insert ctc;
        
        zqu__Quote__c zQuote = new zqu__Quote__c();
        /*= new zqu__Quote__c(zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id);
        insert zQuote; */

        GeoCat__c geo = TestFactory.createGeoCat(ctc, CP);
        insert geo;
        
        Test.startTest();
        
        // Launch the visualforce page
        PageReference pageRef = Page.VF_Quote_CustomZBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('crmAccountId', compte.Id);
        ApexPages.currentPage().getParameters().put('billingAccountId', '2c92c0f85fde712e015fed62b8860096');
        ApexPages.currentPage().getParameters().put('retUrl', '%2F0013E00000gdrZk'); 
        ApexPages.currentPage().getParameters().put('stepNumber', '1');
        ApexPages.currentPage().getParameters().put('quoteType', 'Subscription');

        // Launch the controller
        ApexPages.StandardController quoteCtrl = new ApexPages.StandardController(zQuote);
        VFC_QuoteStep1Creation controller = new VFC_QuoteStep1Creation(quoteCtrl);
        
        controller.initDefaultValues();
        //controller.getEnseignes();
        controller.navigateNext();
        controller.ValidationRules();
        controller.TypeGesteChange();
        controller.navigateBack();
        controller.cancel();

        Test.stopTest();
	}
	

}