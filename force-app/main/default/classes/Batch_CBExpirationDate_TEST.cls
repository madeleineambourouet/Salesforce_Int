/**
* @author Leila BOUAIFEL
* @date 27/02/2017
*
* @description Test class for Class Batch_CBExpirationDate
 */
@isTest(SeeAllData=false)
private class Batch_CBExpirationDate_TEST {
 
@testSetup
  static void setup() {
 
     // Create Compte pro ...
                          
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;        
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
      
              
        /*Technical_Values__c TV = new Technical_Values__c(Name = 'Technical values', Code_client__c = 'XZZZZ');
        insert TV;*/
               
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;

        Account compte1 = new Account(RecordTypeId = RTComptePro, Name = 'Test account1', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '42325891200017', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Login__c = 'toto@toto.com');
      
        insert compte1;
      
        // Create contact 
        Contact ctc1 = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte1.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc1;
        
        // Create Billing account...
         Zuora__CustomerAccount__c BA1 = new Zuora__CustomerAccount__c ( Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte1.id, Zuora__Balance__c = decimal.valueof('30'), EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée');
         insert BA1;    
         // create souscription 
         Zuora__Subscription__c Subscription1 = new Zuora__Subscription__c(Zuora__CustomerAccount__c=BA1.Id, Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte1.Id, Zuora__SubscriptionEndDate__c = null);
         insert Subscription1;
         
        // Create token...
    
          Token__c token1 = new Token__c(Name = 'test', Compte__c = compte1.id, Type_de_token__c = 'Expiration CB');
          insert token1;
      
         
         
         
      
         // Create Payment method
            List<Zuora__PaymentMethod__c> PMList =new List<Zuora__PaymentMethod__c>();
            
            Zuora__PaymentMethod__c PM1 = new Zuora__PaymentMethod__c (Name='a0I3E0000000ykh',  Zuora__CreditCardExpirationMonth__c = String.ValueOf(Date.Today().month()), Zuora__CreditCardExpirationYear__c=String.ValueOf(Date.Today().year()),Token__c = token1.Name, Zuora__BillingAccount__c= BA1.id, Email_expiration_CB__c = '1er Email expiration CB', Email_du_contact_principal__c = 'testi@test.fr', Zuora__DefaultPaymentMethod__c = true);
            PMList.Add(PM1);
            
            Zuora__PaymentMethod__c PM2 = new Zuora__PaymentMethod__c ( Name='a0I3E0000000ykh', Zuora__CreditCardExpirationMonth__c = String.ValueOf(Date.Today().month()), Zuora__CreditCardExpirationYear__c=String.ValueOf(Date.Today().year()),Token__c = token1.Name, Zuora__BillingAccount__c= BA1.id, Email_expiration_CB__c = '2ème Email expiration CB', Email_du_contact_principal__c = 'testi@test.fr', Zuora__DefaultPaymentMethod__c = true);
            PMList.Add(PM2);
             
            Zuora__PaymentMethod__c PM3 = new Zuora__PaymentMethod__c ( Name='a0I3E0000000ykh', Zuora__CreditCardExpirationMonth__c = String.ValueOf(Date.Today().month()), Zuora__CreditCardExpirationYear__c=String.ValueOf(Date.Today().year()),Token__c = token1.Name, Zuora__BillingAccount__c= BA1.id, Email_expiration_CB__c = '3ème Email expiration CB', Email_du_contact_principal__c = 'testi@test.fr', Zuora__DefaultPaymentMethod__c = true);
            PMList.Add(PM3);
             
            Zuora__PaymentMethod__c PM4 = new Zuora__PaymentMethod__c ( Name='a0I3E0000000ykh', Zuora__CreditCardExpirationMonth__c = String.ValueOf(Date.Today().month()), Zuora__CreditCardExpirationYear__c=String.ValueOf(Date.Today().year()),Token__c = token1.Name, Zuora__BillingAccount__c= BA1.id, Email_expiration_CB__c = '4ème Email expiration CB', Email_du_contact_principal__c = 'testi@test.fr', Zuora__DefaultPaymentMethod__c = true);
            PMList.Add(PM4);
            
            Zuora__PaymentMethod__c PM5 = new Zuora__PaymentMethod__c ( Name='a0I3E0000000ykh', Zuora__CreditCardExpirationMonth__c = String.ValueOf(Date.Today().month() - 1), Zuora__CreditCardExpirationYear__c=String.ValueOf(Date.Today().year()),Token__c = token1.Name, Zuora__BillingAccount__c= BA1.id, Email_expiration_CB__c = '5ème Email expiration CB', Email_du_contact_principal__c = 'testi@test.fr', Zuora__DefaultPaymentMethod__c = true);
            PMList.Add(PM5);
      
       INSERT PMList;
            
    }   
        static testMethod void test() {
        Test.startTest();
        Batch_CBExpirationDate b = new Batch_CBExpirationDate(); 
        database.executebatch(b);
        Test.stopTest();
            
    }
}