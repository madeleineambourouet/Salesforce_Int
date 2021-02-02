/**
* @author Qiuyan Liu
* @date 11/09/2017
*
* @description Created for EB136
* @test class for SubscriptionProductChargeMethods
*/
@isTest(SeeAllData = false)
private class SubscriptionProductChargeMethods_TEST {

	@isTest static void test_method_one() {

        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;        
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTResiliationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Cancellation' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
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
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest');
       
        insert compte;
      
      
      // Create contact 
         Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
      
       // create Quote
        zqu__Quote__c zQuote = new zqu__Quote__c(RecordTypeId = RTResiliationQuote, zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id);
        insert zQuote;
      
      // souscription 
        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = compte.Id, Type_de_geste__c = 'Création de souscription', TECH_QuoteID__c = zQuote.Id);
        insert Subscription;

        Test.startTest();
        Zuora__Product__c z1 = new Zuora__Product__c(Name='test z', Zuora__SKU__c='SKU-00000001');
        insert z1;

        Zuora__SubscriptionProductCharge__c zc = new Zuora__SubscriptionProductCharge__c(Name='Abonnement CapRenov+', Zuora__Account__c=compte.Id, Zuora__EffectiveStartDate__c = Date.today(), Zuora__Product__c=z1.Id);
        insert zc;

        zc.Zuora__EffectiveEndDate__c=Date.today();
        update zc;
        Test.stopTest();
	}
	@isTest static void test_method_tow() {

	    ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;        
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTResiliationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Cancellation' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
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
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest');
       
        insert compte;

        Zuora__Product__c z1 = new Zuora__Product__c(Name='Abonnement Offre Homly Travaux', Zuora__SKU__c='SKU-00000001');
        insert z1;

        Test.startTest();
        
	    List<Zuora__SubscriptionProductCharge__c> zcList = new List<Zuora__SubscriptionProductCharge__c>();
	    Zuora__SubscriptionProductCharge__c zc = new Zuora__SubscriptionProductCharge__c(Name='Abonnement Offre Homly Travaux', Zuora__Account__c=compte.Id, Zuora__EffectiveStartDate__c = Date.today(), Zuora__Product__c=z1.Id);
        zcList.add(zc);

        Zuora__SubscriptionProductCharge__c zc2 = new Zuora__SubscriptionProductCharge__c(Name='Abonnement Offre Homly Travaux', Zuora__Account__c=compte.Id, Zuora__EffectiveStartDate__c = Date.today().addDays(1), Zuora__Product__c=z1.Id);
        zcList.add(zc2);

        Zuora__SubscriptionProductCharge__c zc3 = new Zuora__SubscriptionProductCharge__c(Name='Abonnement Offre Homly Travaux', Zuora__Account__c=compte.Id, Zuora__EffectiveStartDate__c = Date.today().addDays(2), Zuora__Product__c=z1.Id);
        zcList.add(zc3);
	    
	    insert zcList;
	    Test.stopTest();
	}
}