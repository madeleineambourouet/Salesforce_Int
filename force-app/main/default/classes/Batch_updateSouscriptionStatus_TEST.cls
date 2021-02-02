/**
* @author Leila BOUAIFEL
* @date 11/04/2017
*
* @description Test class for Class Batch_updateSouscriptionStatus
 */
@isTest(SeeAllData=false)
private class Batch_updateSouscriptionStatus_TEST {
  
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

        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account',  Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Statut_de_la_souscription__c = '', Login__c = 'test@test.fr');
       
        insert compte;
      
      
      // Create contact 
         Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, Email = 'test@test.fr',
                                        AccountId = compte.Id, DoNotCall = true);
        insert ctc;
      
       // create Quote
        zqu__Quote__c zQuote = new zqu__Quote__c(RecordTypeId = RTCreationQuote, zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id);
        insert zQuote;
      
      // souscription 
        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123', Zuora__Status__c = 'Cancelled',Zuora__Version__c=1,Zuora__SubscriptionEndDate__c = Date.newInstance(2017, 01, 8),Zuora__Account__c = compte.Id);
        insert Subscription;
      
    // Create Billing account 
    
      List<Zuora__CustomerAccount__c> BAList =new List<Zuora__CustomerAccount__c>();      
   
      Zuora__CustomerAccount__c BA1 = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      BAList.Add(BA1);

      INSERT BAList;
    
  }
  
    static testMethod void test() {
        Test.startTest();
        Batch_updateSouscriptionStatus b = new Batch_updateSouscriptionStatus(); 
        database.executebatch(b);
        Test.stopTest();
            
    }
}