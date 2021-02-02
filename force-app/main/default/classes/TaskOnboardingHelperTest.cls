@isTest
public class TaskOnboardingHelperTest {
    static testMethod void test() {
        
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;        
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        ID RTAssurance = [SELECT id FROM RecordType WHERE DeveloperName = 'Document_Assurance' LIMIT 1].id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        
               
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'Zimbabwe', key__c = 'ZWE');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
      
      
        Reference__c assurance = new Reference__c(RecordTypeId = RTAssurance, Name = 'Assurance', key__c = 'Ctest');
        insert assurance;
      
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Statut_de_la_souscription__c = '');
       
        insert compte;
      
      // Create contact 
         Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
      
       // create document assurance
        Document_Assurance__c Assur = new Document_Assurance__c(Compte__c = compte.id,  Nom__c = assurance.id , Statut__c = 'Validée', Name='test', Date_d_expiration__c = system.today().addDays(30));
        insert Assur;
        
        Zuora__CustomerAccount__c BA1 = new Zuora__CustomerAccount__c ( Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), EchecsPaiementConsecutifs__c ='0', Email_de_relance_impayes__c = '1er email de facture impayée', ExpirationCB__c = (String.valueOf(date.Today().month()) + '/' + String.valueOf(date.Today().year())));
         insert BA1;    
         // create souscription 
         Zuora__Subscription__c Subscription1 = new Zuora__Subscription__c(Zuora__CustomerAccount__c=BA1.Id, Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte.Id, Zuora__SubscriptionEndDate__c = null);
         insert Subscription1;
        
        BatchTaskOnboardingCB b = new BatchTaskOnboardingCB();
        database.executebatch(b,100);
        
        BatchTaskOnboardingAssurance c = new BatchTaskOnboardingAssurance();
        database.executebatch(c,100);
        
        BA1.EchecsPaiementConsecutifs__c = '1';
        update BA1;
    }
}