// 22/02/2018, Modified by Xavier Templet, EB164 Refonte des offres - Rémunérations variables / incentives

@isTest//(seealldata = false)
private class Test_QuoteTrigger {

    private static testMethod void test() {

        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        //ID templateID = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Proposition_validee' LIMIT 1];
        
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert TV;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        //EmailTemplate templateNew = new EmailTemplate(DeveloperName = template.DeveloperName, FolderId = template.FolderId, TemplateType= template.TemplateType, Name = template.Name);
        //insert templateNew;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208');
        insert compte;
        
        Contact ctc = new Contact(AccountId = compte.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'pierrot.carpe@businessdecision.com');
        insert ctc;
       
        // AJOUT LEILA
        // After insert : update contact principal on account        
        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id; 
                    update a;
        
        GeoCat__c geocat = TestFactory.createGeocat(ctc, CP);
        Test.startTest();
        zqu__Quote__c zQuote = new zqu__Quote__c(RecordTypeId = RTCreationQuote, zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id, Produit__c = 'Offre Homly Travaux', OwnerId = UserInfo.getUserId());
        insert zQuote;
        
        zQuote.Envoi_mail_generate_PDF__c = true;
        zQuote.Modification_offres__c = true;
        zQuote.Resiliation_offres__c = true;
        zQuote.zqu__Status__c = 'Sent to Z-Billing';
        update zQuote;
        
         // Get 'TC_ITC_Referent_Binome__c' from User Table with ownerid in Quote     	
        User u = [select id,TC_ITC_Referent_Binome__c FROM user WHERE IsActive = true and id=:zQuote.OwnerId];
		        u.TC_ITC_Referent_Binome__c = UserInfo.getUserId();
        
        Attachment PJ = new Attachment(Name = zQuote.Name + '_preview.pdf', ParentId = zQuote.id, Body = Blob.valueOf('corps du PDF'));
        insert PJ;
                   
        a.OwnerId = zQuote.OwnerId;
        a.TC_Referent__c = u.TC_ITC_Referent_Binome__c;
        update a; 
                    
        Test.stopTest();     
    }

    private static testMethod void test3() {
    
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', Email__c = 'test@test.com',
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;

        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111', Email = 'test2@test.com');
        insert ctc;
        
      	List<Zuora__CustomerAccount__c> BAList =new List<Zuora__CustomerAccount__c>();      
   
      	Zuora__CustomerAccount__c billacnt = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      	insert billacnt;
      	      
	    ID RTCreaQuote = [SELECT Id FROM RecordType WHERE DeveloperName = 'Amendment' LIMIT 1].Id; 

			zqu__Quote__c quote = new zqu__Quote__c();  
			quote.Quote_Key__c = Date.today();
			quote.RecordTypeId = RTCreaQuote;
			quote.zqu__Amendment_Name__c = 'Amendment';
	    	quote.zqu__account__c = compte.Id;
        	quote.Type_de_geste__c = 'Modification de souscription';
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

			zqu__QuoteAmendment__c quoAmendment1 = new zqu__QuoteAmendment__c();
		    	quoAmendment1.Name = 'Offre \"Essentiel\" - mensuel';
		    	quoAmendment1.zqu__Type__c = 'RemoveProduct';
				quoAmendment1.zqu__Quote__c = quote.Id;
			insert quoAmendment1;

			zqu__QuoteRatePlan__c  quoRatePlan1 = new zqu__QuoteRatePlan__c();
				quoRatePlan1.Name = 'Offre \"Essentiel\" - mensuel';
				quoRatePlan1.zqu__Quote__c = quote.Id;
				quoRatePlan1.zqu__QuoteAmendment__c = quoAmendment1.Id;
				quoRatePlan1.zqu__AmendmentType__c = 'RemoveProduct';
			insert quoRatePlan1;

			zqu__QuoteChargeSummary__c quoQuoteChargeSummary1a = new zqu__QuoteChargeSummary__c();
				quoQuoteChargeSummary1a.zqu__QuoteRatePlan__c = quoRatePlan1.Id;
				quoQuoteChargeSummary1a.Name = 'Offre \"Essentiel\"';
				//quoQuoteChargeSummary.zqu__QuoteRatePlanCharge__c = xxxx;
				quoQuoteChargeSummary1a.zqu__Description__c = 'zqu__Description__c';
				quoQuoteChargeSummary1a.zqu__Discount__c = 0.0;
				quoQuoteChargeSummary1a.zqu__EffectivePrice__c = 44.00;
				quoQuoteChargeSummary1a.zqu__ListPrice__c = 44.00;
				quoQuoteChargeSummary1a.zqu__ListTotal__c = 44.00;	
				quoQuoteChargeSummary1a.zqu__TotalPrice__c = -44.00;
				quoQuoteChargeSummary1a.zqu__Model__c = 'Flat Fee Pricing';
				quoQuoteChargeSummary1a.zqu__Type__c = 'Recurring';
				quoQuoteChargeSummary1a.zqu__Period__c = 'Month';
				quoQuoteChargeSummary1a.zqu__MRR__c = -44.00;
				quoQuoteChargeSummary1a.zqu__TCV__c = 0.0;
				quoQuoteChargeSummary1a.zqu__Quantity__c = -1;
				quoQuoteChargeSummary1a.zqu__ChangeLog__c = 'Removed xxxxx';
			insert quoQuoteChargeSummary1a;

			zqu__QuoteChargeSummary__c quoQuoteChargeSummary1b = new zqu__QuoteChargeSummary__c();
				quoQuoteChargeSummary1b.zqu__QuoteRatePlan__c = quoRatePlan1.Id;
				quoQuoteChargeSummary1b.Name = 'xxxxxxx';
				//quoQuoteChargeSummary1b.zqu__QuoteRatePlanCharge__c = xxxx;
				quoQuoteChargeSummary1b.zqu__Description__c = 'zqu__Description__c';
				quoQuoteChargeSummary1b.zqu__Discount__c = 0.0;
				quoQuoteChargeSummary1b.zqu__EffectivePrice__c = 0.00;
				quoQuoteChargeSummary1b.zqu__ListPrice__c = 0.00;
				quoQuoteChargeSummary1b.zqu__ListTotal__c = 0.00;	
				quoQuoteChargeSummary1b.zqu__TotalPrice__c = 0.00;
				quoQuoteChargeSummary1b.zqu__Model__c = 'Flat Fee Pricing';
				quoQuoteChargeSummary1b.zqu__Type__c = 'Recurring';
				quoQuoteChargeSummary1b.zqu__Period__c = 'Month';
				quoQuoteChargeSummary1b.zqu__MRR__c = 0.00;
				quoQuoteChargeSummary1b.zqu__TCV__c = 0.0;
				quoQuoteChargeSummary1b.zqu__Quantity__c = -1;
				quoQuoteChargeSummary1b.zqu__ChangeLog__c = 'Removed xxxxx';

			insert quoQuoteChargeSummary1b;

			zqu__QuoteAmendment__c quoAmendment2 = new zqu__QuoteAmendment__c();
		    	quoAmendment2.Name = 'Offre \"Energie\" - mensuel';
		    	quoAmendment2.zqu__Type__c = 'NewProduct';
				quoAmendment2.zqu__Quote__c = quote.Id;
			insert quoAmendment2;

			zqu__QuoteRatePlan__c  quoRatePlan2 = new zqu__QuoteRatePlan__c();
				quoRatePlan2.Name = 'Offre \"Energie\" - mensuel';
				quoRatePlan2.zqu__Quote__c = quote.Id;
				quoRatePlan2.zqu__QuoteAmendment__c = quoAmendment2.Id;
				quoRatePlan2.zqu__AmendmentType__c = 'NewProduct';
			insert quoRatePlan2;

			zqu__QuoteChargeSummary__c quoQuoteChargeSummary2a = new zqu__QuoteChargeSummary__c();
				quoQuoteChargeSummary2a.zqu__QuoteRatePlan__c = quoRatePlan2.Id;
				quoQuoteChargeSummary2a.Name = 'Offre \"Energie\"';
				//quoQuoteChargeSummary2a.zqu__QuoteRatePlanCharge__c = xxxx;
				quoQuoteChargeSummary2a.zqu__Description__c = 'zqu__Description__c';
				quoQuoteChargeSummary2a.zqu__Discount__c = 0.0;
				quoQuoteChargeSummary2a.zqu__EffectivePrice__c = 66.00;
				quoQuoteChargeSummary2a.zqu__ListPrice__c = 66.00;
				quoQuoteChargeSummary2a.zqu__ListTotal__c = 66.00;	
				quoQuoteChargeSummary2a.zqu__TotalPrice__c = 66.00;
				quoQuoteChargeSummary2a.zqu__Model__c = 'Flat Fee Pricing';
				quoQuoteChargeSummary2a.zqu__Type__c = 'Recurring';
				quoQuoteChargeSummary2a.zqu__Period__c = 'Month';
				quoQuoteChargeSummary2a.zqu__MRR__c = 66.00;
				quoQuoteChargeSummary2a.zqu__TCV__c = 0.0;
				quoQuoteChargeSummary2a.zqu__Quantity__c = 1;
				quoQuoteChargeSummary2a.zqu__ChangeLog__c = 'New xxxxx';
			insert quoQuoteChargeSummary2a;

			zqu__QuoteChargeSummary__c quoQuoteChargeSummary2b = new zqu__QuoteChargeSummary__c();
				quoQuoteChargeSummary2b.zqu__QuoteRatePlan__c = quoRatePlan2.Id;
				quoQuoteChargeSummary2b.Name = 'yyyyyyyyyy';
				//quoQuoteChargeSummary1b.zqu__QuoteRatePlanCharge__c = xxxx;
				quoQuoteChargeSummary2b.zqu__Description__c = 'zqu__Description__c';
				quoQuoteChargeSummary2b.zqu__Discount__c = 0.0;
				quoQuoteChargeSummary2b.zqu__EffectivePrice__c = 0.00;
				quoQuoteChargeSummary2b.zqu__ListPrice__c = 0.00;
				quoQuoteChargeSummary2b.zqu__ListTotal__c = 0.00;	
				quoQuoteChargeSummary2b.zqu__TotalPrice__c = 0.00;
				quoQuoteChargeSummary2b.zqu__Model__c = 'Flat Fee Pricing';
				quoQuoteChargeSummary2b.zqu__Type__c = 'Recurring';
				quoQuoteChargeSummary2b.zqu__Period__c = 'Month';
				quoQuoteChargeSummary2b.zqu__MRR__c = 0.00;
				quoQuoteChargeSummary2b.zqu__TCV__c = 0.0;
				quoQuoteChargeSummary2b.zqu__Quantity__c = 1;
				quoQuoteChargeSummary2b.zqu__ChangeLog__c = 'New xxxxx';
			insert quoQuoteChargeSummary2b;

			quote.Date_de_validation__c = Date.today(); // trig quote trigger
			quote.zqu__Status__c = 'Envoyée';
			update quote;

			quote.zqu__Status__c = 'New';
			update quote;

        List<Sales_Facts__c> sfactLst = [select Id, Name from Sales_Facts__c where Quote__c = :quote.Id];
        system.assertEquals(sfactLst.size()>0, true);
    }

}