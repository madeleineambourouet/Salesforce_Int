// 28/07/2017, Modified by Qiuyan Liu, EB114, call Zuora to generate an invoice and cancel the new subscription is the current record is "post résiliation"
// 22/01/2018, Modified by Xavier Templet, EB164 Refonte des offres - Rémunérations variables / incentives
// 05/04/2018, Modified by Qiuyan Liu, limit DML, soql query, Apex CUP correction, on function ActivationServicesInsert and ActivationServicesUpdate
@isTest (seealldata = false)
private class Test_SubscriptionTrigger {

    private static testMethod void test() {
    
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');

        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');

        List<Reference__c> refs = new List<Reference__c>();

        refs.add(CP);
        refs.add(NAF);
        refs.add(FR);
        insert refs;

        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false, Login__c = 'a@a.a');
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
        
        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Pending',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte.Id);
       
        insert Subscription;
        Subscription.Zuora__Status__c='Active';
        update Subscription;
        Subscription.Zuora__Version__c=3;
        update Subscription;
        
        Zuora__Subscription__c Subscription2 = new Zuora__Subscription__c(Name='A-S00006124',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        insert Subscription2;
        Zuora__Subscription__c Subscription3 = new Zuora__Subscription__c(Name='A-S00006125',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=5,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        insert Subscription3;
        
        // Create Billing account 
    
      List<Zuora__CustomerAccount__c> BAList =new List<Zuora__CustomerAccount__c>();      
   
      Zuora__CustomerAccount__c BA1 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA1);

      INSERT BAList;
    }
    
    private static testMethod void test2() {
    
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');

        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');

        List<Reference__c> refs = new List<Reference__c>();

        refs.add(CP);
        refs.add(NAF);
        refs.add(FR);
        insert refs;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;

        // 28/07/2017, Modified by Qiuyan Liu, EB114, call Zuora to generate an invoice and cancel the new subscription is the current record is "post résiliation"
        //test Zuora__Subscription__c post résiliation
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Zuora__Subscription__c Subscription4 = new Zuora__Subscription__c(Name='A-S00006126', Type_de_geste__c='Geste commercial post-résiliation', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        subList.add(Subscription4);
        Zuora__Subscription__c Subscription5 = new Zuora__Subscription__c(Name='A-S00006127', Type_de_geste__c='Geste commercial post-résiliation', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=5,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        subList.add(Subscription5);
        Zuora__Subscription__c Subscription6 = new Zuora__Subscription__c(Name='A-S00006128', Type_de_geste__c='Geste commercial post-résiliation', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=5,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        subList.add(Subscription6);
        insert subList;
    }
    
    private static testMethod void test3() {
    
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');

        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');

        List<Reference__c> refs = new List<Reference__c>();

        refs.add(CP);
        refs.add(NAF);
        refs.add(FR);
        insert refs;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', Email__c = 'test@test.com',
                                        /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;

        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111', Email = 'test2@test.com');
        insert ctc;
        
        List<Zuora__CustomerAccount__c> BAList =new List<Zuora__CustomerAccount__c>();      
   
        Zuora__CustomerAccount__c billacnt = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
        insert billacnt;
        //BAList.Add(billacnt); INSERT BAList;
      
        ID RTCreaQuote = [SELECT Id FROM RecordType WHERE DeveloperName = 'Amendment' LIMIT 1].Id; 

            zqu__Quote__c quote = new zqu__Quote__c();  
            quote.Quote_Key__c = Date.today();
            //quote.RecordTypeId = RTCreaQuote;
            quote.zqu__Amendment_Name__c = 'New';
            quote.zqu__account__c = compte.Id;
            quote.Type_de_geste__c = 'Création de souscription';
            quote.zqu__SoldToContact__c = compte.Contact_principal__c;
            quote.zqu__BillToContact__c = compte.Contact_principal__c; 
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
            
            insert quote;
            quote.Date_de_validation__c = Date.today(); // trig quote trigger
            quote.zqu__Status__c = 'Envoyée';
            update quote;

            List<zqu__QuoteAmendment__c> amend = new List<zqu__QuoteAmendment__c>();

            zqu__QuoteAmendment__c quoAmendment1 = new zqu__QuoteAmendment__c();
                quoAmendment1.Name = 'Offre \"Essentiel\" - annuel';
                quoAmendment1.zqu__Type__c = 'NewProduct';
                quoAmendment1.zqu__Quote__c = quote.Id;

            zqu__QuoteAmendment__c quoAmendment2 = new zqu__QuoteAmendment__c();
                quoAmendment2.Name = 'Offre \"Energie\" - annuel';
                quoAmendment2.zqu__Type__c = 'NewProduct';
                quoAmendment2.zqu__Quote__c = quote.Id;

            amend.add(quoAmendment1);
            amend.add(quoAmendment2);
            insert amend;

            List<zqu__QuoteRatePlan__c> quotesR = new List<zqu__QuoteRatePlan__c>();

            zqu__QuoteRatePlan__c  quoRatePlan1 = new zqu__QuoteRatePlan__c();
                quoRatePlan1.Name = 'Offre \"Essentiel\" - annuel';
                quoRatePlan1.zqu__Quote__c = quote.Id;
                quoRatePlan1.zqu__QuoteAmendment__c = quoAmendment1.Id;
                quoRatePlan1.zqu__AmendmentType__c = 'NewProduct';

            zqu__QuoteRatePlan__c  quoRatePlan2 = new zqu__QuoteRatePlan__c();
                quoRatePlan2.Name = 'Offre \"Energie\" - annuel';
                quoRatePlan2.zqu__Quote__c = quote.Id;
                quoRatePlan2.zqu__QuoteAmendment__c = quoAmendment2.Id;
                quoRatePlan2.zqu__AmendmentType__c = 'NewProduct';

            quotesR.add(quoRatePlan1);
            quotesR.add(quoRatePlan2);
            insert quotesR;

            

        Zuora__Subscription__c Subscription8 = new Zuora__Subscription__c(Name='A-S00006138', TECH_QuoteID__c= quote.Id, Type_de_geste__c='Création de souscription', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        insert Subscription8;

        Zuora__Subscription__c Subscription7 = new Zuora__Subscription__c(Name='A-S00006129', TECH_QuoteID__c= quote.Id, Type_de_geste__c='Création de souscription', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Pending',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(),Zuora__SubscriptionEndDate__c = null ,Zuora__Account__c = compte.Id);
        insert Subscription7;

        Subscription7.Zuora__Status__c = 'Active';
        update Subscription7;
        
        List<Sales_Facts__c> sfactLst = [select Id, Name from Sales_Facts__c where Subscription__c = :Subscription7.Id];
        //system.assertEquals(sfactLst.size()>2, true);
    }
    
}