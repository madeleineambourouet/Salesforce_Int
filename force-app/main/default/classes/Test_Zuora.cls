@isTest(seeAllData=true)
private class Test_Zuora 
{
	private static testMethod void Test_VFC_Quote_CustomZBilling()
	{

   		ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Key__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Key__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1');
        insert compFirst;
        Reference__c compSecond = new Reference__c(RecordTypeId = RTCompetence, Key__c = '2', Name = 'Second Competence', Parent__c = '1', Libelle_3__c = 'CAT_2');
        insert compSecond;
        
        
        Account acc = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert acc;
    System.assert(null != acc.Id, 'Apex Test Failed to create Mockup account.');
   /**   
    Account acc = new Account();
    acc.Name = 'account test';
    try {
      insert acc;
    } catch (Exception e) {
      System.assert(false, 'ExtendedTestDataSetup.prepareTestQuote: Exception occured while inserting Account record. Exception Details: ' + e.getMessage());
    }
    **/
    
/**
    Contact billto = new Contact();
    billto.FirstName = 'Bill To FirstName';
    billto.LastName = 'Bill To LastName';
    billto.AccountId = acc.Id;
    try {
      insert billto;
    } catch (Exception e) {
      System.assert(false, 'ExtendedTestDataSetup.prepareTestQuote: Exception occured while inserting Bill To Contact record. Exception Details: ' + e.getMessage());
    }
    System.assert(null != billto.Id, 'Apex Test failed to create Mockup Bill To Contact.');

    Contact soldto = new Contact();
    soldto.FirstName = 'Sold To FirstName';
    soldto.LastName = 'Sold To LastName';
    soldto.AccountId = acc.Id;
    try {
      insert soldto;
    } catch (Exception e) {
      System.assert(false, 'ExtendedTestDataSetup.prepareTestQuote: Exception occured while inserting Sold To Contact record. Exception Details: ' + e.getMessage());
    }
    **/
    Contact con = TestFactory.createContact(acc);
    insert con;
    System.assert(null != con.Id, 'Apex Test failed to create Mockup Sold To Contact and bill to contact.');

/**
    Opportunity opp = new Opportunity();
    opp.Name = OPPORTUNITY_NAME;
    opp.StageName = 'Closed Won';
    opp.CloseDate = DEFAULT_OPPORTUNITY_CLOSE_DATE;
    opp.AccountId = acc.Id;
    try {
      insert opp;
    } catch (Exception e) {
      System.assert(false, 'ExtendedTestDataSetup.prepareTestQuote: Exception occured while inserting Opportunity record. Exception Details: ' + e.getMessage());
    }
    System.assert(null != opp.Id, 'The Insert Opportunity should not be null.');
    System.assert(null != opp.AccountId, 'The Insert Opportunity.AccountId should not be null.');
**/

	    // Prepare the data
	    final zqu__Quote__c zquote = Test_Zuora_ExtendedTestDataSetup.getMyQuote(acc, con);
	    
	    Test.startTest();
	    
	    // Launch the visualforce page
        system.debug('>>>>>>>> TEST : Start Init ctrl');
        PageReference pageRef = Page.VF_Quote_CustomZBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', zQuote.Id);

        // Launch the controller
       // ApexPages.StandardController quoteCtrl = new ApexPages.StandardController(zQuote);
        VFC_Quote_CustomZBilling controller = new VFC_Quote_CustomZBilling(); //quoteCtrl
        system.debug('>>>>>>>> TEST : End Init ctrl');
        
        // step 1
        controller.step1method();
        
        // step 2
        controller.step2Method();
        
        // step 3
        controller.step3Method();
        
        Test.stopTest();
	}
	
	private static testMethod void testZuoraUtilities()
	{
	    
	    Test.startTest();
	    
	    Zuora.zApi zuoraApi = ZuoraUtilities.zuoraApiAccess();
	    
	    String query_subscription = 'SELECT id FROM Subscription';
	    String query_invoiceItem = 'SELECT id FROM InvoiceItem';
	    String query_targetInvoice = 'SELECT id, TargetDate FROM Invoice';
	    String query_invoicePayment = 'SELECT id FROM InvoicePayment';
	    String query_invoice = 'SELECT id FROM Invoice';
	    String query_payment = 'SELECT id FROM Payment';
	
        List<Zuora.zObject> lSubscription = ZuoraUtilities.queryToZuora(zuoraApi, query_subscription);
        List<Zuora.zObject> lItem = ZuoraUtilities.queryToZuora(zuoraApi, query_invoiceItem);
        List<Zuora.zObject> lTargetInvoice = ZuoraUtilities.queryToZuora(zuoraApi, query_targetInvoice);
        List<Zuora.zObject> lInvociePayment = ZuoraUtilities.queryToZuora(zuoraApi, query_invoicePayment);
        List<Zuora.zObject> lInvoice =  ZuoraUtilities.queryToZuora(zuoraApi, query_invoice);
        List<Zuora.zObject> lPayment = ZuoraUtilities.queryToZuora(zuoraApi, query_payment);
        
        Zuora.zApi.AmendResult result = ZuoraUtilities.createCancellationAmendment(zuoraApi, false, false, 'id', 'name', 'description', Date.newInstance(2016, 05,19), Date.newInstance(2016, 05, 19));
        
        VFC_Export_Expansion_Account expansion = new VFC_Export_Expansion_Account();
        expansion.VFC_Export_Expansion_Account();
        
    }
    
   private static testMethod void testZuoraQuery()
    {
        
        Reference__c pays = TestFactory.createReference('pays','France','FRA','FRA');
	    Reference__c CP = TestFactory.createReference('CP', '75000', '75000', '75000');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'AAA','AAA','AAA');
	    Reference__c NAF = TestFactory.createReference('NAF','BBB','BBB','BBB');
	    insert pays; insert CP; insert enseigne; insert NAF;
	    system.debug('>>>>> After reference creation');
	    
	    Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
	    insert PRO;

        Zuora__Subscription__c sub = new Zuora__Subscription__c();

        system.debug('>>>>> PRO '+PRO.Id);
        system.debug('>>>>> PRO '+PRO.code_Client__c);
	    
	    Test.startTest();
	    String billingID = Zuora_Query.getBillingAccountId(PRO.code_Client__c);
	    String subscriptionID = Zuora_Query.getSubscriptionID(billingID);
        List<Zuora__Subscription__c> subList = [SELECT Id, Zuora__External_Id__c FROM Zuora__Subscription__c WHERE Type_de_geste__c='Création de souscription' AND Zuora__Status__c = 'Active' limit 1];
        Date lastInvoicePeriod = Zuora_Query.getLastInvoicePeriod(subList[0].Zuora__External_Id__c);
        String subInfoString  = Zuora_Query.getCurSubscriptionInfo(subList[0].Zuora__External_Id__c); 
        List<Zuora.zObject> listZObject = Zuora_Query.getZObjectList('SELECT id FROM Subscription');
        List<zqu__Quote__c> amendmentlist = [SELECT Id FROM zqu__Quote__c WHERE Type_de_geste__c = 'Modification de souscription' limit 1];
        //ApprovalQuote.Approve(amendmentlist[0].id);
	    Test.stopTest();
    } 

}