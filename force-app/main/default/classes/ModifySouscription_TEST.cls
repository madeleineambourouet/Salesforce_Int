/**
* @author Clement Musabimana
* @date 21/02/2019
* @description Classe de test pour la classe ModifySouscription
**/
@isTest(SeeAllData=false)
public without sharing class ModifySouscription_TEST {

	@isTest
	public static void prepareTraitementSouscriptionTest() {
        Test.startTest();
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
        
        Account compte1 = new Account(RecordTypeId = RTComptePro, Name = 'Test account1', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '42325891200017', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Login__c = 'toto@toto.com');
      
        //Passage du compte de facturation en impayé
	    compte1.Desactivation_des_ODC_impaye_recurrent__c = true;
        insert compte1;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());

		//Normalisation du compte de facturation
	    compte1.Desactivation_des_ODC_impaye_recurrent__c = false;
		update compte1;
        //Passage du compte de facturation en impayé
	    compte1.Desactivation_des_ODC_impaye_recurrent__c = true;
		update compte1;

		Test.stopTest();
	}


	@isTest
	public static void changeClientActivationEtatTest() {
        Test.startTest();
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
        
        Account compte1 = new Account(RecordTypeId = RTComptePro, Name = 'Test account1', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '42325891200017', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Login__c = 'toto@toto.com');
              insert compte1;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());

		//suspension
	    ModifySouscription.changeClientActivationEtat(compte1.Id, true);
		//activation
	    ModifySouscription.changeClientActivationEtat(compte1.Id, false);

		Test.stopTest();
	}

	public class MockHttpResponse200 implements HttpCalloutMock {
    // Implement this interface method
   		public HTTPResponse respond(HttpRequest req) {
        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/pdf;charset=UTF-8');
	        res.setBody('ok');
	        res.setStatusCode(200);
	        return res;
    	}
	}
}