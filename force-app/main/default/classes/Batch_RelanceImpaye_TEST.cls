/**
* @author Leila BOUAIFEL
* @date 27/02/2017
* @date 20/09/2019
* @description Test class for Class Batch_RelanceImpaye
*/
@isTest(SeeAllData=false)
private class Batch_RelanceImpaye_TEST {
  
@testSetup
  static void setup() {
   
      // Create Compte pro 
        
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;        
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        
               
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'Zimbabwe', key__c = 'ZWE');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;

        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest',Statut_de_paiement__c = '' );
       
        insert compte;
      
      
      // Create contact 
         Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
      
       // create Quote
        zqu__Quote__c zQuote = new zqu__Quote__c(RecordTypeId = RTCreationQuote, zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id);
        insert zQuote;
      
      // souscription 
        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte.Id, Type_de_geste__c = 'Création de souscription');
        insert Subscription;      
     
      
	  // Create Billing account 
	  
      List<Zuora__CustomerAccount__c> BAList =new List<Zuora__CustomerAccount__c>();      
   
      Zuora__CustomerAccount__c BA1 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Relances_Impayes__c = true , Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA1);

      /*Zuora__CustomerAccount__c BA2 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='2', Email_de_relance_impayes__c = '2ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);    
      BAList.Add(BA2);
      Zuora__CustomerAccount__c BA3 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='3', Email_de_relance_impayes__c = '3ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA3);
      Zuora__CustomerAccount__c BA4 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='4', Email_de_relance_impayes__c = '4ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA4);
      Zuora__CustomerAccount__c BA5 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='5', Email_de_relance_impayes__c = '5ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA5);
      Zuora__CustomerAccount__c BA6 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='6', Email_de_relance_impayes__c = '6ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA6);
      Zuora__CustomerAccount__c BA7 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='7', Email_de_relance_impayes__c = '7ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA7);
      Zuora__CustomerAccount__c BA8 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='8', Email_de_relance_impayes__c = '8ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA8);
      Zuora__CustomerAccount__c BA9 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='9', Email_de_relance_impayes__c = '9ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA9);
      Zuora__CustomerAccount__c BA10 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='10', Email_de_relance_impayes__c = '10ème email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA10);*/
      
      INSERT BAList;
      
       // Create token 
		
        Token__c token = new Token__c(Name = 'test', Compte__c = compte.id, Type_de_token__c = 'Impayé');
        insert token;
     
	}
	
		static testMethod void test() {
        Test.startTest();
        Batch_RelanceImpaye b = new Batch_RelanceImpaye(); 
        database.executebatch(b);
        Test.stopTest();
            
    }
}