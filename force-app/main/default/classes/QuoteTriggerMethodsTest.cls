/** 
    *
    *@author    Qiuyan Liu
    *@Starts    15/11/2016
    *@Ends      18/11/2016
    */
@isTest
private class QuoteTriggerMethodsTest {
    public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
    public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);
    public static final String DEFAULT_CURRENCY = 'USD';
        
    @isTest static void validStartCancelDateTest() {


        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        
        Reference__c pays = TestFactory.createReference('pays','France','FRA','FRA');
        Reference__c CP = TestFactory.createReference('CP', '75000', '75000', '75000');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'AAA','AAA','AAA');
        Reference__c NAF = TestFactory.createReference('NAF','BBB','BBB','BBB');

        Test.startTest();
        insert pays; insert CP; insert enseigne; insert NAF;
        
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        insert PRO;
        
        Contact con = new Contact(AccountId = pro.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test@test.com');
        insert con;
        
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;
        
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        insert billingaccount;
        
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.zqu__Currency__c = DEFAULT_CURRENCY;
        quote.Name = 'Quote Name';
        quote.zqu__AutoRenew__c = true;
        quote.zqu__BillToContact__c = con.Id;
        quote.zqu__SoldToContact__c = con.Id;
        quote.zqu__InitialTerm__c = 12.0;
        quote.zqu__RenewalTerm__c = 6.0;
        quote.zqu__PaymentMethod__c = 'Credit Card';
        quote.zqu__Account__c = PRO.Id;
        quote.zqu__ValidUntil__c = DEFAULT_EFFECTIVE_START_DATE;
        quote.zqu__StartDate__c = DEFAULT_EFFECTIVE_START_DATE;
        quote.zqu__SubscriptionTermStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
        quote.zqu__SubscriptionTermEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
        quote.zqu__BillingMethod__c = 'Both';
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.PM_SecondTokenId__c = '12344563768';
        quote.PM_TokenId__c = '1343434';
        quote.PM_CreditCardType__c = 'Visa';
        quote.PM_CardNumber__c = '1234567876545676';
        quote.PM_CardHolderName__c = 'Test Test';
        quote.PM_ExpirationYear__c = '2017';
        quote.PM_ExpirationMonth__c = '10';
        try {
          insert quote;
        } catch (Exception e) {
          System.assert(false, 'ExtendedTestDataSetup.prepareTestQuote: Exception occured while inserting Quote record. Exception Details: ' + e.getMessage());
        }
        quote.zqu__CancellationDate__c = DEFAULT_EFFECTIVE_START_DATE;
        //system.debug('*************************************** ' + quote.zqu__CancellationDate__c);
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        quoteList.add(quote);
        String strValid = QuoteTriggerMethods.validStartCancelDate(quoteList, null);
        //System.assertNotEquals(null, strValid);
        quoteList[0].zqu__CancellationDate__c = Date.Today().addMonths(1).toStartOfMonth();
        strValid = QuoteTriggerMethods.validStartCancelDate(quoteList, null);
        //System.assertEquals(null, strValid);
        Test.stopTest();
    }

    @isTest static void CompleteEnseigneInfoTest() {


        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> lReferences = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays','France','FRA','FRA');
        Reference__c CP = TestFactory.createReference('CP', '75000', '75000', '75000');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'AAA','AAA','AAA');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
        Reference__c NAF = TestFactory.createReference('NAF','BBB','BBB','BBB');
        lReferences.add(pays); 
        lReferences.add(CP);
        lReferences.add(enseigne);
        lReferences.add(NAF);
        lReferences.add(agence);

        Test.startTest();
        insert lReferences;
        //insert pays; insert CP; insert enseigne; insert NAF;
       // system.debug('>>>>> After reference creation');
        //System.debug('my agence ' + agence);
        Account PRO = TestFactory.createAccount(true, pays, CP, agence, NAF);
        
        insert PRO;

        ProgrammeFidelite__c pf = new ProgrammeFidelite__c(Agence_Pilote__c=agence.Id, Code_client_groupe__c='test', Compte__c=PRO.Id, DateEntree__c=Date.today(), DateSortie__c=Date.today().addMonths(1));
       // system.debug('my pf ' + pf);
        insert pf;
        PRO.Enseigne_de_facturation__c = pf.Id;
        update PRO;
        //System.debug('my PRO ' + PRO);
        Contact con = new Contact(AccountId = pro.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test@test.com');
        insert con;
        
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;
        
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        insert billingaccount;
        
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.zqu__Currency__c = DEFAULT_CURRENCY;
        quote.Name = 'Quote Name';
        quote.zqu__AutoRenew__c = true;
        quote.zqu__BillToContact__c = con.Id;
        quote.zqu__SoldToContact__c = con.Id;
        quote.zqu__InitialTerm__c = 12.0;
        quote.zqu__RenewalTerm__c = 6.0;
        quote.zqu__PaymentMethod__c = 'Credit Card';
        quote.zqu__Account__c = PRO.Id;
        quote.zqu__ValidUntil__c = DEFAULT_EFFECTIVE_START_DATE;
        quote.zqu__StartDate__c = DEFAULT_EFFECTIVE_START_DATE;
        quote.zqu__SubscriptionTermStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
        quote.zqu__SubscriptionTermEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
        quote.zqu__BillingMethod__c = 'Both';
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.PM_SecondTokenId__c = '12344563768';
        quote.zqu__Status__c = 'En cours';
        quote.PM_TokenId__c = '1343434';
        quote.PM_CreditCardType__c = 'Visa';
        quote.PM_CardNumber__c = '1234567876545676';
        quote.PM_CardHolderName__c = 'Test Test';
        quote.PM_ExpirationYear__c = '2017';
        quote.PM_ExpirationMonth__c = '10';
        quote.LoyaltyProgramID__c = null;
        quote.zqu__SubscriptionType__c = 'Amend Subscription';
        try {
          insert quote;
        } catch (Exception e) {
          System.assert(false, 'ExtendedTestDataSetup.prepareTestQuote: Exception occured while inserting Quote record. Exception Details: ' + e.getMessage());
        }
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        quoteList.add(quote);
        QuoteTriggerMethods.CompleteEnseigneInfo(quoteList);
        zqu__Quote__c toUpdateQuote = new zqu__Quote__c();
        toUpdateQuote.Id = quote.Id;
        toUpdateQuote.zqu__Status__c = 'Sent to Z-Billing';

        update toUpdateQuote;
        Test.stopTest();
    }
    
}