@isTest
public with sharing class CarteITCTest {

	@isTest
	public static void CarteTest() {
		system.debug('>>>>>>>> TEST : Start preping data');
        // Creation of test data
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;

		Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert compte;

        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', AccountId = compte.Id, Phone = '+33111111111');
        insert ctc;

        Geocat__c geocat = new Geocat__c();
        geocat.Contact__c = ctc.Id;
        geocat.Adresse__c = CP.Id;
        geocat.Zone_d_intervention__c = 12;
        geocat.DDP__c = 12;
        geocat.Exclusion__c = '75015, 75017';
        geocat.Date_de_debut__c = Date.Today();
        geocat.Date_de_fin__c = Date.Today() + 30;
        geocat.FaminePoids__c = 10;

        insert geocat;

        ApexPages.StandardController ci = new ApexPages.StandardController(geocat);
        CarteITC itc = new CarteITC(ci);
        itc.redirecto();


	}
}