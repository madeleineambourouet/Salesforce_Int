@isTest (seealldata = false)
private class TestOffreUpdateAccountTrigger {

    @testSetup 
    static void setup() {

        List<Reference__c> listReferences = new List<Reference__c>();
        List<Account> listAccounts = new List<Account>();             
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        ID RTAssurance = [SELECT id FROM RecordType WHERE DeveloperName = 'Document_Assurance' LIMIT 1].id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        
        //ID OFFRES = [SELECT Zuora__Account__c, Zuora__EffectiveStartDate__c, Name, HYRatePlanChargeID__c from Zuora__SubscriptionProductCharge__c where (Name = 
        //'Abonnement Offre Homly Travaux') LIMIT 1].Id;
        //ID OFFRES = [SELECT Zuora__Account__c, Zuora__EffectiveStartDate__c, Name, HYRatePlanChargeID__c from Zuora__SubscriptionProductCharge__c where 
        //Name = 'Offre "Gestion" - annuel' LIMIT 1].Id;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        //insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        //insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'Zimbabwe', key__c = 'ZWE');
        //insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        //insert enseigne;
      
      
        Reference__c assurance = new Reference__c(RecordTypeId = RTAssurance, Name = 'Assurance', key__c = 'Ctest');
        //insert assurance;

        listReferences.add(CP);
        listReferences.add(NAF);
        listReferences.add(FR);
        listReferences.add(enseigne);
        listReferences.add(assurance);
        insert listReferences;       
        Account A = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Statut_de_la_souscription__c = '' );
        insert A;
        
         // Create contact 
         Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = A.Id, DoNotCall = true, Phone = '+33111111111');
         insert ctc;
        
        // Create CI
        GeoCat__c geocat = TestFactory.createGeocat(ctc, CP);
        insert geocat;
                      
        // create Quote
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Quote Name';
        quote.zqu__AutoRenew__c = true;
        quote.zqu__BillToContact__c = ctc.Id;
        quote.zqu__SoldToContact__c = ctc.Id;
        quote.zqu__InitialTerm__c = 12.0;
        quote.zqu__RenewalTerm__c = 6.0;
        quote.zqu__PaymentMethod__c = 'Credit Card';
        quote.zqu__Account__c = A.Id;
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
        
         // create Billing Account
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = A.id, Zuora__AccountNumber__c = '123456');
        insert billingaccount;
        
        // create souscription
        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Pending',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = A.Id);
       
        insert Subscription;
        Subscription.Zuora__Status__c='Active';
        update Subscription;
        
        
        Zuora__Product__c z1 = new Zuora__Product__c(Name='test z', Zuora__SKU__c='SKU-00000001');
        insert z1;
        
        
        // create SubscriptionProductCharge
        //Zuora__SubscriptionProductCharge__c zc = new Zuora__SubscriptionProductCharge__c(Name='Abonnement CapRenov+', Zuora__Account__c=A.Id, Zuora__EffectiveStartDate__c = Date.today(), Zuora__Product__c=z1.Id);
        //insert zc;
        
        Zuora__SubscriptionProductCharge__c zc2 = new Zuora__SubscriptionProductCharge__c(Name='Offre "Gestion" - annuel', Zuora__Account__c=A.Id, Zuora__EffectiveStartDate__c = Date.today().addDays(1), Zuora__Product__c=z1.Id);
        insert zc2;
        
        // TEST UPDATING Account... 
        /*Account C = new Account(Id = A.id, RecordTypeId = RTComptePro, Product_on_offre__c  = 'Abonnement Offre Homly Travaux', Name = 'TEST');
        update C;
        C.Product_on_offre__c   = 'Abonnement Offre Homly Travaux'; 
        update C;*/       
    }
    private static testMethod void test(){
 
        Test.startTest();  
        Account A = [SELECT Id FROM Account LIMIT 1];
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        Account C2 = new Account(Id = A.id, RecordTypeId = RTComptePro, Product_on_offre__c  = '-OES-A-', Name = 'TEST2');    
       	C2.Product_on_offre__c   = '-OES-A-'; 
        update C2;        
        
        system.debug('----->>> END UPDATE C2: ' + C2.Id + 'a été inséré avec succès.');
        Test.stopTest();
    }
}