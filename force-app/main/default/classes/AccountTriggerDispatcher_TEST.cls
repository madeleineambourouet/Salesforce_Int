@isTest
public class AccountTriggerDispatcher_TEST {
@testSetup 
    static void setup() {
        
        List<Reference__c> listReferences = new List<Reference__c>();
        List<User> listUsers = new List<User>();
        List<Account> listAccounts = new List<Account>();
        List<Competence__c> listCompetences = new List<Competence__c>();
        List<Zuora__Subscription__c> listZuora_Subscriptions = new List<Zuora__Subscription__c>();
        List<Zuora__SubscriptionProductCharge__c> listZuoraSubscriptionProductCharges = new List<Zuora__SubscriptionProductCharge__c>();

        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User testUser = new User(Alias = 'uPATest', Email='uPATest@testorg.com', 
	         EmailEncodingKey='UTF-8', LastName='uPATest', LanguageLocaleKey='en_US', 
	         LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',//MAJ_ProjetAffiliation
	         TimeZoneSidKey='America/Los_Angeles', UserName='uPATest@testorg.com');
        User testUser2 = new User(Alias = 'uPATest', Email='uPATest2@testorg.com', 
	         EmailEncodingKey='UTF-8', LastName='uPATest', LanguageLocaleKey='en_US', 
	         LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',//MAJ_ProjetAffiliation
	         TimeZoneSidKey='America/Los_Angeles', UserName='uPATest2@testorg.com');
        User testUser3 = new User(Alias = 'uPATest', Email='uPATest3@testorg.com', 
	         EmailEncodingKey='UTF-8', LastName='uPATest', LanguageLocaleKey='en_US', 
	         LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',//MAJ_ProjetAffiliation
	         TimeZoneSidKey='America/Los_Angeles', UserName='uPATest3@testorg.com');
        listUsers.add(testUser);
        listUsers.add(testUser2);
        listUsers.add(testUser3);
        insert listUsers;
        testUser.TC_ITC_Referent_Binome__c = testUser2.Id;
        testUser2.TC_ITC_Referent_Binome__c = testUser3.Id;
        update listUsers;
        listReferences.add(CP);
        listReferences.add(competence);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        insert listReferences;

        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
		
		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		Account professionnel2 = new Account();
        professionnel2.RecordTypeId = TestFactory.RTComptePro;
        professionnel2.Name = 'Test account2';
        professionnel2.Phone = '+33635136117';
        professionnel2.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
        professionnel2.Flux_code_Enseigne__c = enseigne.key__c;
        professionnel2.SIRET_texte__c = '32212091600207';
        professionnel2.Code_NAF_APE_societe_declarante__c = NAF.id;
        professionnel2.A_ne_jamais_rappeler__c = false;
        professionnel2.Statut_activation__c = 'Nouveau';
        
		professionnel.OwnerId = testUser.Id;
		professionnel2.OwnerId = testUser2.Id;
		professionnel.TC_Referent__c = testUser.Id;
		professionnel2.TC_Referent__c = testUser2.Id;

        listAccounts.add(professionnel);
        listAccounts.add(professionnel2);
        listAccounts.add(particulier);
        insert listAccounts; 

        Projet__c projet = TestFactory.createProject(particulier, CP, pays, testUser2);
        projet.Statut_Projet__c = 'Qualifié';
        projet.Etat__c = 'ODC ouverte';
        projet.Source__c = 'VANN';
        projet.Demande_du_Part__c = 'Artisans qualifiés';  
        insert projet;

        String labelListeOnboardingTaches = Label.Onboarding_taches;
        List<string> listeOnboardingTaches = new List<string>();
        listeOnboardingTaches.addAll(labelListeOnboardingTaches.split(';'));
        if(!listeOnboardingTaches.isEmpty()){
            String temp = listeOnboardingTaches[0];
            Task t = new Task(Subject=temp, WhatId=professionnel.Id);
            insert t;
        }
    }
    static testmethod void testOwnerAndTasks() {        
        Test.startTest();
        User us = [SELECT Id,TC_ITC_Referent_Binome__c FROM User WHERE Email = 'uPATest@testorg.com' LIMIT 1];
        User us2 = [SELECT Id FROM User WHERE Email = 'uPATest2@testorg.com' LIMIT 1];
        Account acc = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account' LIMIT 1];
        Account acc2 = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account2' LIMIT 1];
        System.debug('onboardingTraitements_TEST* us '+ us);
        acc.OwnerId = us2.Id;
        acc2.TC_Referent__c = us.Id;
        Task t = new Task(Subject='Welcome Call',OwnerId=us.Id, WhatId=acc.Id);
        Task t2 = new Task(Subject='Welcome Call',OwnerId=us2.Id, WhatId=acc.Id);
        List<Task> listTasks = new List<Task>();
        listTasks.add(t);
        listTasks.add(t2);
        insert listTasks;
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(acc);
        listAccounts.add(acc2);
        update listAccounts;
        Test.stopTest();
    }	
    static testmethod void testOwnerAndCases() {        
        Test.startTest();
        User us = [SELECT Id,TC_ITC_Referent_Binome__c FROM User WHERE Email = 'uPATest@testorg.com' LIMIT 1];
        User us2 = [SELECT Id FROM User WHERE Email = 'uPATest2@testorg.com' LIMIT 1];
        Account acc = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account' LIMIT 1];
        Account acc2 = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account2' LIMIT 1];
        System.debug('onboardingTraitements_TEST* us '+ us);
        acc.OwnerId = us2.Id;
        acc2.TC_Referent__c = us.Id;
        Case c = new Case(OwnerId=us.Id, AccountId=acc.Id);
        Case c2 = new Case(OwnerId=us2.Id, AccountId=acc.Id);
        List<Case> listCases = new List<Case>();
        listCases.add(c);
        listCases.add(c2);
        insert listCases;
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(acc);
        listAccounts.add(acc2);
        update listAccounts;
        Test.stopTest();
    }   
    static testmethod void testSubscriptionChanges() {        
        Test.startTest();
        User us = [SELECT Id,TC_ITC_Referent_Binome__c FROM User WHERE Email = 'uPATest@testorg.com' LIMIT 1];
        User us2 = [SELECT Id FROM User WHERE Email = 'uPATest2@testorg.com' LIMIT 1];
        Account acc = [SELECT Id,TC_Referent__c,Contact_principal__c FROM Account where Name = 'Test account' LIMIT 1];
        Account acc2 = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account2' LIMIT 1];
        System.debug('onboardingTraitements_TEST* us '+ us);

        Zuora__CustomerAccount__c billacnt = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=acc.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
        insert billacnt;

        zqu__Quote__c quote = new zqu__Quote__c();  
        quote.Quote_Key__c = Date.today();
        quote.zqu__Amendment_Name__c = 'New';
        quote.zqu__account__c = acc.Id;
        quote.Type_de_geste__c = 'Création de souscription';
        quote.zqu__SoldToContact__c = acc.Contact_principal__c;
        quote.zqu__BillToContact__c = acc.Contact_principal__c; 
        quote.zqu__StartDate__c = Date.today();
        quote.zqu__ValidUntil__c = Date.today().addMonths(1);
        quote.zqu__Status__c = 'New';
        quote.zqu__SubscriptionType__c = 'New Subscription';
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__InvoiceProcessingOption__c = 'Subscription';
        quote.zqu__ZuoraAccountID__c = billacnt.Zuora__Zuora_Id__c;
        quote.zqu__InvoiceOwnerId__c = billacnt.Zuora__Zuora_Id__c;
        quote.zqu__InvoiceOwnerName__c = billacnt.Name;
        quote.zqu__Currency__c = billacnt.Zuora__Currency__c;
        //quote.zqu__ApplyCreditBalance__c = true;
        quote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';
        quote.zqu__SubscriptionVersion__c = 1.0;
        quote.Date_de_validation__c = Date.today(); // trig quote trigger
        quote.zqu__Status__c = 'Sent to Z-Billing';
        quote.Effective_Amendment_Start_Date__c =  Date.today();

        insert quote;

        List<zqu__QuoteAmendment__c> amend = new List<zqu__QuoteAmendment__c>();

        zqu__QuoteAmendment__c quoAmendment1 = new zqu__QuoteAmendment__c();
        quoAmendment1.Name = 'Offre \"Essentiel\" - annuel';
        quoAmendment1.zqu__Type__c = 'NewProduct';
        quoAmendment1.zqu__Quote__c = quote.Id;

        amend.add(quoAmendment1);
        insert amend;

        zqu__ZProduct__c testProduct = new zqu__ZProduct__c();
        testProduct.Name = 'testing';
        testProduct.zqu__SKU__c = 'testSKU';
        testProduct.zqu__ZuoraId__c = '12';
        testProduct.zqu__EffectiveStartDate__c = date.newinstance(2000, 1, 1);
        testProduct.zqu__EffectiveEndDate__c = date.newinstance(2050, 1, 1);
        testProduct.zqu__Deleted__c = false;

        insert testProduct;

        zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
        productRatePlan.Typedeproduit__c = 'Pack';
        productRatePlan.zqu__ZProduct__c = testProduct.Id;
        insert productRatePlan;

        List<zqu__QuoteRatePlan__c> quotesR = new List<zqu__QuoteRatePlan__c>();

        zqu__QuoteRatePlan__c  quoRatePlan1 = new zqu__QuoteRatePlan__c();
        quoRatePlan1.Name = 'Offre \"Essentiel\" - annuel';
        quoRatePlan1.zqu__Quote__c = quote.Id;
        quoRatePlan1.zqu__QuoteAmendment__c = quoAmendment1.Id;
        quoRatePlan1.zqu__AmendmentType__c = 'NewProduct';
        quoRatePlan1.zqu__ProductRatePlan__c = productRatePlan.Id;
        zqu__QuoteRatePlan__c  quoRatePlan2 = new zqu__QuoteRatePlan__c();
        quoRatePlan2.Name = 'Vitrine web';
        quoRatePlan2.zqu__Quote__c = quote.Id;
        quoRatePlan2.zqu__QuoteAmendment__c = quoAmendment1.Id;
        quoRatePlan2.zqu__AmendmentType__c = 'RemoveProduct';
        quoRatePlan2.zqu__ProductRatePlan__c = productRatePlan.Id;
        quotesR.add(quoRatePlan1);
        quotesR.add(quoRatePlan2);
        insert quotesR;



        Zuora__Subscription__c Subscription8 = new Zuora__Subscription__c(Name='A-S00006138', TECH_QuoteID__c= quote.Id, Type_de_geste__c='Création de souscription', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = acc.Id);
        
        insert Subscription8;
        
        Test.stopTest();
    }
    static testmethod void testStatusActivationNouveau() {        
        Test.startTest();
        Account acc = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account' LIMIT 1];
        acc.Statut_activation__c = 'Nouveau';
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(acc);
        update listAccounts;
        Test.stopTest();
    }
    static testmethod void testPersonAcountChangeEmail() {        
        Test.startTest();
        Account acc = [SELECT Id FROM Account where LastName = 'Test' LIMIT 1];
        acc.PersonEmail = 'toto+30012020@gmail.com';
        acc.PersonMobilePhone = '+33999999990';
        acc.Login__c = 'toto+30012020@gmail.com';
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(acc);
        update listAccounts;
        Test.stopTest();
    }
    /*
    static testmethod void testOwnerChange() {        
        Test.startTest();
        Account acc = [SELECT Id,TC_Referent__c FROM Account where Name = 'Test account' LIMIT 1];
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
         User testUser3 = new User(Alias = 'uPATest3', Email='uPATest3@testorg.com', 
	         EmailEncodingKey='UTF-8', LastName='uPATest3', LanguageLocaleKey='en_US', 
	         LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',//MAJ_ProjetAffiliation
	         TimeZoneSidKey='America/Los_Angeles', UserName='uPATest3@testorg.com');
         insert testUser3;
		acc.OwnerId = testUser3.Id;
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(acc);
        update listAccounts;
        Test.stopTest();
    }*/
}