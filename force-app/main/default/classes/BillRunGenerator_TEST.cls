/**
* @author Qiuyan Liu
* @CreatedDate 05 Juillet 2017
* @description test class for BillRunGenerator, EB-114, create a billrun when new subscription(post résiliation) is created 
*/
@isTest(SeeAllData=false)
public class BillRunGenerator_TEST {
    static testMethod void test() {
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
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
        
        Account compte1 = new Account(RecordTypeId = RTComptePro, Name = 'Test account1', Pays_LKP__c = FR.id, 
                                      Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '45325891200017', 
                                      Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Login__c = 'billrun@billrun.com');
        insert compte1;
        
        // Create contact 
        Contact ctc1 = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                   AccountId = compte1.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc1;
        
        // Create Billing account...
        Zuora__CustomerAccount__c BA1 = new Zuora__CustomerAccount__c ( Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte1.id, Zuora__Balance__c = decimal.valueof('30'), EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée');
        insert BA1;    
        // create souscription 
        List<Zuora__Subscription__c> subList = new List<Zuora__Subscription__c>();
        Zuora__Subscription__c Subscription1 = new Zuora__Subscription__c(Zuora__CustomerAccount__c=BA1.Id, Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte1.Id, Zuora__SubscriptionEndDate__c = null, Type_de_geste__c='Geste commercial post-résiliation');
        subList.add(Subscription1);
        Zuora__Subscription__c Subscription2 = new Zuora__Subscription__c(Zuora__CustomerAccount__c=BA1.Id, Name='A-S00006124',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte1.Id, Zuora__SubscriptionEndDate__c = null, Type_de_geste__c='Geste commercial post-résiliation');
        subList.add(Subscription2);
        Zuora__Subscription__c Subscription3 = new Zuora__Subscription__c(Zuora__CustomerAccount__c=BA1.Id, Name='A-S00006125',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte1.Id, Zuora__SubscriptionEndDate__c = null, Type_de_geste__c='Geste commercial post-résiliation');
        subList.add(Subscription3);
        Test.startTest();
        insert subList;
        Test.stopTest();
    }
}