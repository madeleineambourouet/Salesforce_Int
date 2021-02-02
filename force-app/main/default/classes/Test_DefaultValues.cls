@isTest(SeeAllData=true)
global class Test_DefaultValues extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin {

	public static final String acctId = '12345678901234567890123456789012';
	public static final String subId = '23456789012345678901234567890123';

	@isTest
	private static void testCancelllationDefaultValues() {

		Account acc = createTestAccount(null, true);
		Opportunity opp = createTestOpportunity(acc, true);
		//zqu__Quote__c quote = createTestQuote(acc, opp, null, null, true, true);

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.Name = 'Test Quote';
		quote.zqu__SubscriptionType__c = 'Cancel Subscription';
		quote.zqu__StartDate__c = System.today();
		quote.zqu__ValidUntil__c = System.today();
		quote.zqu__Subscription_Term_Type__c = 'Termed';
		quote.zqu__InitialTerm__c = 12;
		quote.zqu__RenewalTerm__c = 12;
		quote.zqu__Account__c = (acc != null) ? acc.Id : null;
		quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
		quote.zqu__BillToContact__c = null;
		quote.zqu__SoldToContact__c = null;
		quote.zqu__ExistSubscriptionID__c = subId;
		//quote.Type_de_geste__c = 'Création de souscription';
		insert quote;

	  	
	  	Z_PopulateDefaultFieldsForCancelQuote controller = new Z_PopulateDefaultFieldsForCancelQuote();
	  	PageReference createQuote = Page.zqu__ZQCancellation;
	  	createQuote.getParameters().put('oppId', opp.Id);
	  	createQuote.getParameters().put('quoteType', 'Cancellation');
	  	createQuote.getParameters().put('stepNumber', '1');
	  	Test.setCurrentPage(Page.zqu__CreateQuote);

	  	Test.startTest();

 		controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());

	  	Test.stopTest();
	}

	@isTest
	private static void testNewSubDefaultValues2() {

		Account acc = createTestAccount(null, true);
	//	Contact con = TestFactory.createContact(acc);
    //    insert con;
		Opportunity opp = createTestOpportunity(acc, true);
		zqu__Quote__c quote = createTestQuote(acc, opp, null, null, true, true);
	  	
	  	DefaultValues controller = new DefaultValues();
	  	PageReference createQuote = Page.zqu__CreateQuote;
	  	createQuote.getParameters().put('oppId', opp.Id);
	  	createQuote.getParameters().put('quoteType', 'Subscription');
	  	createQuote.getParameters().put('stepNumber', '2');
	  	Test.setCurrentPage(Page.zqu__CreateQuote);

	  	Test.startTest();

 		controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());

	  	Test.stopTest();
	}

	@isTest
	private static void testAmendSubDefaultValuesMonthly() {

		Account acc = createTestAccount(null, true);
		Opportunity opp = createTestOpportunity(acc, true);
		zqu__Quote__c quote = createTestQuote(acc, opp, null, null, false, true);

		Zuora__CustomerAccount__c billAcc = createBillingAccount(acc, true);
		Zuora__Subscription__c sub = createSubscription(acc, billAcc, true, '23456789012345678901234567890124');
		Zuora__SubscriptionProductCharge__c subCharge1 = createSubProdCharge(sub, 'Month', true);
		Zuora__SubscriptionProductCharge__c subCharge2 = createSubProdCharge(sub, 'Month', true);

	  	DefaultValues controller = new DefaultValues();
	  	PageReference createQuote = Page.zqu__CreateQuote;
	  	createQuote.getParameters().put('oppId', opp.Id);
	  	createQuote.getParameters().put('quoteType', 'Amendment');
	  	createQuote.getParameters().put('stepNumber', '2');
	  	createQuote.getParameters().put('billingAccountId', acctId);
	  	createQuote.getParameters().put('subscriptionId', subId);
	  	Test.setCurrentPage(Page.zqu__CreateQuote);

	  	Test.startTest();

 		controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());

	  	Test.stopTest();
	}

	@isTest
	private static void testAmendSubDefaultValuesQuarterly() {

		Account acc = createTestAccount(null, true);
		Opportunity opp = createTestOpportunity(acc, true);
		zqu__Quote__c quote = createTestQuote(acc, opp, null, null, false, true);

		Zuora__CustomerAccount__c billAcc = createBillingAccount(acc, true);
		Zuora__Subscription__c sub = createSubscription(acc, billAcc, true,'23456789012345678901234567890125');
		Zuora__SubscriptionProductCharge__c subCharge1 = createSubProdCharge(sub, 'Quarter', true);
		Zuora__SubscriptionProductCharge__c subCharge2 = createSubProdCharge(sub, 'Quarter', true);

	  	DefaultValues controller = new DefaultValues();
	  	PageReference createQuote = Page.zqu__CreateQuote;
	  	createQuote.getParameters().put('oppId', opp.Id);
	  	createQuote.getParameters().put('quoteType', 'Amendment');
	  	createQuote.getParameters().put('stepNumber', '2');
	  	createQuote.getParameters().put('billingAccountId', acctId);
	  	createQuote.getParameters().put('subscriptionId', subId);
	  	Test.setCurrentPage(Page.zqu__CreateQuote);

	  	Test.startTest();

 		controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());

	  	Test.stopTest();
	}

	@isTest
	private static void testAmendSubDefaultValuesAnnual() {

		Account acc = createTestAccount(null, true);
		Opportunity opp = createTestOpportunity(acc, true);
		zqu__Quote__c quote = createTestQuote(acc, opp, null, null, false, true);
		Zuora__CustomerAccount__c billAcc = createBillingAccount(acc, true);
		Zuora__Subscription__c sub = createSubscription(acc, billAcc, true, '23456789012345678901234567890126');
		Zuora__SubscriptionProductCharge__c subCharge1 = createSubProdCharge(sub, 'Annual', true);
		System.debug('>>>>>>>>>>>>>>> subCharge1 created ' + subCharge1);
		Zuora__SubscriptionProductCharge__c subCharge2 = createSubProdCharge(sub, 'Annual', true);

	  	DefaultValues controller = new DefaultValues();
	  	PageReference createQuote = Page.zqu__CreateQuote;
	  	createQuote.getParameters().put('oppId', opp.Id);
	  	createQuote.getParameters().put('quoteType', 'Amendment');
	  	createQuote.getParameters().put('stepNumber', '2');
	  	createQuote.getParameters().put('billingAccountId', acctId);
	  	createQuote.getParameters().put('subscriptionId', subId);
	  	Test.setCurrentPage(Page.zqu__CreateQuote);

	  	Test.startTest();

 		controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());

	  	Test.stopTest();
	}

	@isTest
	private static void testAmendSubDefaultValuesNoMatch() {

		Account acc = createTestAccount(null, true);
		Opportunity opp = createTestOpportunity(acc, true);
		zqu__Quote__c quote = createTestQuote(acc, opp, null, null, false, true);

		Zuora__CustomerAccount__c billAcc = createBillingAccount(acc, true);
		Zuora__Subscription__c sub = createSubscription(acc, billAcc, true, '23456789012345678901234567890127');
		Zuora__SubscriptionProductCharge__c subCharge1 = createSubProdCharge(sub, 'Month', true);
		Zuora__SubscriptionProductCharge__c subCharge2 = createSubProdCharge(sub, 'Quarter', true);
		Zuora__SubscriptionProductCharge__c subCharge3 = createSubProdCharge(sub, 'Annual', true);

	  	DefaultValues controller = new DefaultValues();
	  	PageReference createQuote = Page.zqu__CreateQuote;
	  	createQuote.getParameters().put('oppId', opp.Id);
	  	createQuote.getParameters().put('quoteType', 'Amendment');
	  	createQuote.getParameters().put('stepNumber', '2');
	  	createQuote.getParameters().put('billingAccountId', acctId);
	  	createQuote.getParameters().put('subscriptionId', subId);
	  	Test.setCurrentPage(Page.zqu__CreateQuote);

	  	Test.startTest();

 		controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());

	  	Test.stopTest();
	}


	public static Zuora__CustomerAccount__c createBillingAccount(Account acc, Boolean doInsert) {
		Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
		billAcc.Name = 'Test Billing Account';
		billAcc.Zuora__Account__c = acc.Id;
		billAcc.Zuora__AccountNumber__c = 'A-001';
		billAcc.Zuora__AutoPay__c = false;
		billAcc.Zuora__Batch__c = 'Batch1';
		billAcc.Zuora__BillCycleDay__c = '1';
		billAcc.Zuora__Balance__c = 0;
		billAcc.Zuora__BillToCity__c = 'Atlanta';
		billAcc.Zuora__BillToCountry__c = 'United States';
		billAcc.Zuora__BillToAddress1__c = '123 Main St';
		billAcc.Zuora__BillToState__c = 'Georgia';
		billAcc.Zuora__BillToPostalCode__c = '12345';
		billAcc.Zuora__BillToId__c = '1234567890';
		billAcc.Zuora__BillToName__c = 'Test Name';
		billAcc.Zuora__BillToWorkEmail__c = 'test@test.com';
		billAcc.Zuora__MRR__c = 100;
		billAcc.Zuora__Credit_Balance__c = 100;
		billAcc.Zuora__Currency__c = 'USD';
		billAcc.Zuora__External_Id__c = acctId;
		billAcc.Zuora__PaymentTerm__c = 'Due Upon Receipt';
		billAcc.Zuora__Status__c = 'Active';
		billAcc.Zuora__Zuora_Id__c = acctId;

		if (doInsert) {
			insert billAcc;
		}
		return billAcc;
	}

	public static Zuora__Subscription__c createSubscription(Account acc, Zuora__CustomerAccount__c billAcc, Boolean doInsert, String subID) {
		Zuora__Subscription__c sub = new Zuora__Subscription__c();
		sub.Zuora__Account__c = acc.Id;
		sub.Zuora__AutoRenew__c = false;
		sub.Zuora__ContractAcceptanceDate__c = System.today();
		sub.Zuora__ContractEffectiveDate__c = System.today();
		sub.Zuora__CustomerAccount__c = billAcc.Id;
		sub.Zuora__External_Id__c = subID;
		sub.Zuora__InitialTerm__c = '12 Months';
		sub.Zuora__InvoiceOwner__c = billAcc.Id;
		sub.Zuora__MRR__c = 100;
		sub.Name = 'Test Subscription';
		sub.Zuora__NextChargeDate__c = System.today().addMonths(1);
		sub.Zuora__NextRenewalDate__c = System.today().addMonths(12);
		sub.Zuora__OriginalCreatedDate__c = System.today();
		sub.Zuora__RenewalTerm__c = '12 Months';
		sub.Zuora__ServiceActivationDate__c = System.today();
		
		sub.Zuora__Status__c = 'Active';
		sub.Zuora__SubscriptionEndDate__c = System.today().addMonths(12);
		sub.Zuora__SubscriptionStartDate__c = System.today();
		sub.Zuora__TCV__c = 1200;
		sub.Zuora__TermEndDate__c = System.today().addMonths(12);
		sub.Zuora__TermSettingType__c = 'TEREMED';
		sub.Zuora__TermStartDate__c = System.today();
		sub.Zuora__Version__c = 1;
		sub.Zuora__Zuora_Id__c = subId;

		if (doInsert) {
			insert sub;
		}
		return sub;
	}

	public static Zuora__SubscriptionProductCharge__c createSubProdCharge(Zuora__Subscription__c sub, String frequency, Boolean doInsert) {
		Zuora__SubscriptionProductCharge__c charge = new Zuora__SubscriptionProductCharge__c();
		charge.Name = 'Test Charge';
		charge.Zuora__Subscription__c = sub.Id;
		charge.Zuora__BillingPeriod__c = frequency;
		
		charge.Zuora__Account__c = sub.Zuora__Account__c;
		
		if (doInsert) {
			insert charge;
		}
		return charge;
	}

	//Create a test Quote
	public static zqu__Quote__c createTestQuote(Account acc, Opportunity opp, Contact billTo, Contact soldTo, Boolean isNewSub, Boolean doInsert) {
		isNewSub = (isNewSub != null) ? isNewSub : true;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.Name = 'Test Quote';
		quote.zqu__SubscriptionType__c = (isNewSub) ? 'New Subscription' : 'Amend Subscription';
		quote.zqu__StartDate__c = System.today();
		quote.zqu__ValidUntil__c = System.today();
		quote.zqu__Subscription_Term_Type__c = 'Termed';
		quote.zqu__InitialTerm__c = 12;
		quote.zqu__RenewalTerm__c = 12;
		quote.zqu__Account__c = (acc != null) ? acc.Id : null;
		quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
		quote.zqu__BillToContact__c = (billTo != null) ? billTo.Id : null;
		quote.zqu__SoldToContact__c = (soldTo != null) ? soldTo.Id : null;
		quote.zqu__ExistSubscriptionID__c = (isNewSub) ? null : subId;
		quote.Type_de_geste__c = 'Création de souscription';
	
		if (doInsert) {
			insert quote;
		}
	
		return quote;
	}

	//Create a test Account
	public static Account createTestAccount(Account parent, Boolean doInsert) 
	{
	    ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null LIMIT 1];
       
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
        
	    Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', login__c = 'a@a.a');
        insert compte;
	    
	    Contact con = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, AccountId = compte.id, DoNotCall = true, Phone = '+33635136116');
        insert con;
	    
	    return compte;
	}

	//Create a test Opportunity
	public static Opportunity createTestOpportunity(Account acc, Boolean doInsert)
	{  		  		 
	    Opportunity opp = new Opportunity();    
	    opp.CloseDate = System.today().addMonths(1);           
	    opp.StageName = 'Closed Won';
	    opp.Type = 'New Business';          
	    opp.Name = 'Test Opportunity';
	    
		if (acc != null) {
			opp.AccountId = acc.Id;
		}        
		if (doInsert) {
			insert opp;
		}
	
	    return opp;
	}
	
}