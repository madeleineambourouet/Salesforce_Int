@isTest(seealldata = true)
private class Test_QuoteRulesEnginePluginController {

    private static testMethod void test() {

        
        
        zqu__Quote__c zquote = Test_Zuora_ExtendedTestDataSetup.getQuote();
        Account acc = [select ID,  Remises_partenaires_eligibles__c FROM Account Where Id =:zquote.zqu__Account__c];
        acc.Remises_partenaires_eligibles__c = '6677271';
        update acc;
        
        

        Test.startTest();
        
        
        List<zqu.ZQuoteRulesEngine.ChangeLog> logs = new List<zqu.ZQuoteRulesEngine.ChangeLog>(); 
        zqu.ZQuoteRulesEngine.ChangeLog cL = new zqu.ZQuoteRulesEngine.ChangeLog();
        
        cL.description = 'test123';
        logs.add(cL);
        
        
        
        /*system.debug('## System.Label.CRLicenceSuppProductRatePlanId: '+'a0q3E0000001kosQAA');
        //List<String> ratePlanIds = new List<String>{System.Label.CRLicenceSuppProductRatePlanId};
        List<String> ratePlanIds = new List<String>{'a0q3E0000001kosQAA'};
        system.debug('## System.Label.CRLicenceSuppProductRatePlanId: '+'ratePlanIds ');
        
        List<zqu.ZChargeGroup> zcgs = new List<zqu.ZChargeGroup>();
        */
        /*zqu.zChargeGroup chargeGroupCap = zqu.zQuoteUtil.getChargeGroup(zQuote.Id, 'a0q3E0000001kosQAA');
        zqu.ZQuoteUtil.addChargeGroup(chargeGroupCap);*/
        
        /*List<String> ratePlanIdList = new List<String>();
        for(zqu__ProductRatePlan__c ratePlan : ratePlans){
           ratePlanIdList.add(ratePlan.Id);
        }*/
        
        List<zqu.ZChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(zquote.Id);
        
        list<string> ratePlanIdList = new list<string>();
        
        for(zqu.zChargeGroup zcg : chargeGroups)
        {
            ratePlanIdList.add(zcg.productRatePlanId);
            //zcg.productRatePlanId= System.Label.CRLicenceSuppProductRatePlanId;
            for(zqu.zCharge zc : zcg.zCharges)
            {
                //zc.chargeobject = newQC;  
                 System.Debug('## zc' + zc);
                 System.Debug('## zc.chargeobject: ' + zc.chargeobject);  
                zc.QUANTITY = '6';
            }
        } 
        
        QuoteRulesEnginePluginController pluginClass = new QuoteRulesEnginePluginController();
        
        pluginClass.runProductRules(zQuote,ratePlanIdList,logs);
        pluginClass.runValidationRules(zQuote,chargeGroups,logs);
        pluginClass.runpricerules(chargeGroups,logs);   
        
        
        //EmailHelper.sendQuoteByMail(template.Id, ctc.Id, zQuote.Id, new Attachment(Name = 'PDF', Body = Blob.valueOf('corps du PDF')));

    }

    private static testMethod void test2() {
        
    //zqu__ZProduct__c testProd = makeProduct();

    //Map<Id, zqu__ProductRatePlan__c> ONRatePlanMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT Id, Name from zqu__ProductRatePlan__c WHERE zqu__Deleted__c = false AND (Name LIKE 'Remise - Offre de noël%' OR Name LIKE 'Abonnement CapRenov+')]);
    Map<Id, zqu__ProductRatePlan__c> ONRatePlanMap = new Map<Id, zqu__ProductRatePlan__c>([Select Id, Name, zqu__ZProduct__c , zqu__ZuoraId__c ,  zqu__Deleted__c, zqu__EffectiveStartDate__c , zqu__EffectiveEndDate__c   From zqu__ProductRatePlan__c z WHERE zqu__Deleted__c = false AND (Name = 'Abonnement CapRenov+' OR Name LIKE 'Offre Homly Travaux' OR Name LIKE 'Avoir exceptionnel (valide 6 mois à partir de la souscription)')]);
    zqu__ProductRatePlan__c testPRPCap = new zqu__ProductRatePlan__c();
    zqu__ProductRatePlan__c testPRPHT = new zqu__ProductRatePlan__c();
    zqu__ProductRatePlan__c testAvoirExcp = new zqu__ProductRatePlan__c();
    for (zqu__ProductRatePlan__c rp : ONRatePlanMap.values()) {
        if (rp.Name == 'Abonnement CapRenov+') {
            testPRPCap = rp;  
        } else if (rp.Name == 'Offre Homly Travaux') {
            testPRPHT = rp;
        } else if (rp.Name == 'Avoir exceptionnel (valide 6 mois à partir de la souscription)') {
            testAvoirExcp = rp;
        }
    }

    zqu__ProductRatePlanCharge__c testPCCap = makeProductRatePlanCharge(testPRPCap.Id, 'recurring', 'Flat-Fee');
    zqu__ProductRatePlanCharge__c testPCHT = makeProductRatePlanCharge(testPRPHT.Id, 'recurring', 'Flat-Fee');
    zqu__ProductRatePlanCharge__c testPCAvoirExcp = makeProductRatePlanCharge(testAvoirExcp.Id, 'recurring', 'Flat-Fee');

    System.Debug('testPCAvoirExcp: ###  ' + testPCAvoirExcp);  
  
    //zqu__Quote__c zquote = Test_Zuora_ExtendedTestDataSetup.getQuote();
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

        Contact con = TestFactory.createContact(acc);
    insert con;
    zqu__Quote__c zquote = new zqu__Quote__c();
    zquote.zqu__Currency__c = 'USD';
    zquote.Name = 'Quote Name';
    zquote.zqu__AutoRenew__c = true;
    zquote.zqu__account__c = acc.Id;
//    quote.zqu__Opportunity__c = opp.Id;
    zquote.zqu__BillToContact__c = con.Id;
    zquote.zqu__SoldToContact__c = con.Id;
    zquote.zqu__InitialTerm__c = 12.0;
    zquote.zqu__RenewalTerm__c = 6.0;
    zquote.zqu__PaymentMethod__c = 'Credit Card';
    zquote.zqu__ValidUntil__c = Date.today();
    zquote.zqu__StartDate__c = Date.today();
    zquote.zqu__SubscriptionTermStartDate__c = Date.today();
    zquote.zqu__SubscriptionTermEndDate__c = Date.today().addYears(1);
    zquote.zqu__BillingMethod__c = 'Both';
    zquote.zqu__Subscription_Term_Type__c = 'Termed';
    zquote.PM_SecondTokenId__c = '12344563768';
    zquote.PM_TokenId__c = '1343434';
    zquote.PM_CreditCardType__c = 'Visa';
    zquote.PM_CardNumber__c = '1234567876545676';
    zquote.PM_CardHolderName__c = 'Test Test';
    zquote.PM_ExpirationYear__c = '2017';
    zquote.PM_ExpirationMonth__c = '10';
      insert zquote;



    Test.startTest();
    //Account acc = [select ID,  Remises_partenaires_eligibles__c FROM Account Where Id =:zquote.zqu__Account__c];

    //Contact con = makeContact(acc);    
    //Opportunity opp = makeOpportunity(acc);
    //zqu__Quote__c newQuote = makeQuote(opp);
    zqu__QuoteCharge__c newQC1 = makeQuoteCharge(zquote, testPCCap.Id);
    zqu__QuoteCharge__c newQC2 = makeQuoteCharge(zquote, testPCHT.Id);
    zqu__QuoteCharge__c newQC3 = makeQuoteCharge(zquote, testPCAvoirExcp.Id);

    //update zquote; 
    
    List<zqu.ZQuoteRulesEngine.ChangeLog> logs = new List<zqu.ZQuoteRulesEngine.ChangeLog>(); 
    zqu.ZQuoteRulesEngine.ChangeLog cL = new zqu.ZQuoteRulesEngine.ChangeLog();

    cL.description = 'test123';
    logs.add(cL);   

    List<String> ratePlanIds = new List<String>{testPRPCap.Id, testPRPHT.Id};
    List<zqu.ZChargeGroup> zcgs = new List<zqu.ZChargeGroup>();
    List<zqu__Quote__c> quoteList = [SELECT ID FROM zqu__Quote__c WHERE Type__c = 'Création de souscription' LIMIT 1];
    zcgs.add(zqu.zQuoteUtil.getChargeGroup(quoteList[0].Id, testPRPCap.Id));
   zcgs.add(zqu.zQuoteUtil.getChargeGroup(quoteList[0].Id, testPRPHT.Id));
     Integer cnt = 0;
    for(zqu.zChargeGroup zcg : zcgs) {
        for(zqu.zCharge zc : zcg.zCharges) {
            zc.chargeobject = math.mod(cnt , 2) == 0 ? newQC1 : newQC2;  
            cnt++;
             System.Debug('zc' + zc);
             System.Debug('zc.chargeobject: ' + zc.chargeobject);  
            //zc.chargeobject.put('BillingFrequency__c', 'Month');
            //zc.chargeobject.put('CustomDiscount__c', 10);
        }
    }        
    System.Debug('Charges: ' + zcgs);
    System.Debug('Logs:' + logs);

    //QuoteRulesEnginePluginController.runpricerules(zcgs,logs);   
    //QuoteRulesEnginePluginController.runValidationRules(zquote,zcgs,logs);
    //QuoteRulesEnginePluginController.runProductRules(zquote,ratePlanIds,logs);
   QuoteRulesEnginePluginController pluginClass = new QuoteRulesEnginePluginController();
    pluginClass.runProductRules(zquote,ratePlanIds,logs);
     pluginClass.runValidationRules(zquote,zcgs,logs);
   /* pluginClass.runpricerules(zcgs,logs);   

    Test.stopTest();
/*
        zqu__Quote__c zquote = Test_Zuora_ExtendedTestDataSetup.getQuote();
        zQuote.Type_de_geste__c = 'Création de souscription';
        Account acc = [select ID,  Remises_partenaires_eligibles__c FROM Account Where Id =:zquote.zqu__Account__c];
        acc.Remises_partenaires_eligibles__c = '6677271';
        update acc;

        Map<Id, zqu__ProductRatePlan__c> ONRatePlanMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT Id, Name from zqu__ProductRatePlan__c WHERE zqu__Deleted__c = false AND (Name LIKE 'Remise - Offre de noël%' OR Name LIKE 'Abonnement CapRenov+')]);
        

        Test.startTest();
        List<zqu.ZQuoteRulesEngine.ChangeLog> logs = new List<zqu.ZQuoteRulesEngine.ChangeLog>(); 
        zqu.ZQuoteRulesEngine.ChangeLog cL = new zqu.ZQuoteRulesEngine.ChangeLog();
        
        cL.description = 'test123';
        logs.add(cL);

        
        List<zqu.ZChargeGroup> chargeGroups = new List<zqu.ZChargeGroup>();
        for (Id prpId : ONRatePlanMap.keySet()) {
            chargeGroups.add(zqu.zQuoteUtil.getChargeGroup(zquote.Id, prpId));
        }
        
        
        list<string> ratePlanIdList = new list<string>();
        /*for (Id onrpId : ONRatePlanMap.keySet()) {
            ratePlanIdList.add((String)onrpId);
        } 

        ratePlanIdList.add(Label.RemisePackCRProductRatePlanChargeId);
        ratePlanIdList.add(Label.CRLiceneceDegroupProductRatePlanChargeId);
        ratePlanIdList.add(Label.CRAbonnementProductRatePlanChargeId);
        ratePlanIdList.add(Label.HomlyTravauxProductRatePlanChargeId);
        ratePlanIdList.add(Label.CRLiceneceSuppProductRatePlanChargeId);

        
        for(zqu.zChargeGroup zcg : chargeGroups)
        {
            ratePlanIdList.add(zcg.productRatePlanId);
            //zcg.productRatePlanId= System.Label.CRLicenceSuppProductRatePlanId;
            for(zqu.zCharge zc : zcg.zCharges)
            {
                //zc.chargeobject = newQC;  
                 System.Debug('## zc' + zc);
                 System.Debug('## zc.chargeobject: ' + zc.chargeobject);  
                zc.QUANTITY = '6';
            }
        } 
        
        QuoteRulesEnginePluginController pluginClass = new QuoteRulesEnginePluginController();
        
        pluginClass.runProductRules(zQuote,ratePlanIdList,logs);
        pluginClass.runValidationRules(zQuote,chargeGroups,logs);
        pluginClass.runpricerules(chargeGroups,logs);   
        */

    }
    
    /**
    * Insert a test quote based on an opportunity in the db
    */
    public static zqu__QuoteCharge__c makeQuoteCharge(zqu__Quote__c testQuote, Id testPRPCId) {
    
        zqu__QuoteCharge__c testQuoteCharge = new zqu__QuoteCharge__c();
        
        testQuoteCharge.Name = 'my test quote charge';
        testQuoteCharge.zqu__Quote__c = testQuote.Id;
        testQuoteCharge.zqu__ProductRatePlanCharge__c = testPRPCId; 
        
        insert testQuoteCharge;
        return testQuoteCharge;
    }

    public static zqu__ZProduct__c makeProduct() {
        zqu__ZProduct__c testProduct = new zqu__ZProduct__c();
        testProduct.Name = 'testing';
        testProduct.zqu__SKU__c = 'testSKU';
        testProduct.zqu__ZuoraId__c = '12';
        testProduct.zqu__EffectiveStartDate__c = date.newinstance(2000, 1, 1);
        testProduct.zqu__EffectiveEndDate__c = date.newinstance(2050, 1, 1);
        testProduct.zqu__Deleted__c = false;

        insert testProduct;
        return testProduct;
    }

    private static integer ratePlanId = 154657;

    public static zqu__ProductRatePlan__c makeProductRatePlan(String zproduct, String name) {
        zqu__ProductRatePlan__c testrp = new zqu__ProductRatePlan__c();
        testrp.name = 'test rp';
        testrp.zqu__ZProduct__c = zproduct;
        testrp.zqu__ZuoraId__c = String.valueOf(ratePlanId);
        ratePlanId++;
        testrp.zqu__Deleted__c = false;
        //set custom fields 

        //Needed for pricing queries
        testrp.zqu__EffectiveStartDate__c = Date.newInstance(2010, 1, 1);
        testrp.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);
       
        insert testrp;
        return testrp;
    }
    
    private static integer ratePlanChargeId = 125481;
    
    public static zqu__ProductRatePlanCharge__c makeProductRatePlanCharge(String prp, String type, String model)
    {
        zqu__ProductRatePlanCharge__c testprpc = new zqu__ProductRatePlanCharge__c();
        testprpc.zqu__ProductRatePlan__c = prp;
        testprpc.name=type+model+ratePlanChargeId;
        testprpc.zqu__ZuoraId__c = String.valueOf(ratePlanChargeId);
        ratePlanChargeId++;
        testprpc.zqu__UOM__c = 'test UOM';
        testprpc.zqu__Type__c = type;
        testprpc.zqu__RecurringPeriod__c = 'Month';
        testprpc.zqu__PrepaymentPeriods__c = 1;
        testprpc.zqu__Model__c = model;
        testprpc.zqu__MinQuantity__c = 0;
        testprpc.zqu__MaxQuantity__c = 1000;
        testprpc.zqu__ListPrice__c = -5;
        testprpc.zqu__Description__c = 'Test charge';
        testprpc.zqu__DefaultQuantity__c = 5;
        testprpc.zqu__Discount_Apply_Type__c = 0;
        testprpc.zqu__Discount_Level__c = 'RatePlan';
        testprpc.zqu__Upto_How_Many_Periods__c = 0;
        testprpc.zqu__Deleted__c = false;

        insert testprpc;
        return testprpc;
  }

}