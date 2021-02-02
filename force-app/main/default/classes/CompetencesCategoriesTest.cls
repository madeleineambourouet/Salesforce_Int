@IsTest
public without sharing class CompetencesCategoriesTest {
	@IsTest
	private static void exclusionTest() {
		ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;
        ID RTCategorie = [SELECT Id FROM RecordType WHERE DeveloperName = 'Categorie' LIMIT 1].Id;

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

        GeoCat__c geo = new GeoCat__c(Contact__c = ctc.Id, Adresse__c = CP.Id, DDP__c = 10, Categorie_exclu__c = '', Categorie_exclue_TECH__c = '',FaminePoids__c=10);
        insert geo;

        

        Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Libelle__c = 'First Competence', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1', Obsolete__c = false);
        insert compFirst;
        Reference__c compSecond = new Reference__c(RecordTypeId = RTCompetence, Key__c = '2', Libelle__c = 'Second Competence', Name = 'First Competence', Parent__c = '1', Libelle_3__c = 'CAT_2', Obsolete__c = false);
        insert compSecond;
        Reference__c compThird = new Reference__c(RecordTypeId = RTCompetence, Key__c = '3', Libelle__c = 'Third Competence', Name = 'First Competence',Parent__c = '1', Libelle_3__c = 'CAT_2', Obsolete__c = false);
        insert compThird;

        Reference__c catFirst = new Reference__c(RecordTypeId = RTCategorie, Key__c = '1', Name = 'First Categorie', Libelle__c = 'First Categorie');
        insert catFirst;
        Reference__c catSecond = new Reference__c(RecordTypeId = RTCategorie, Key__c = '2', Name = 'Second Categorie', Libelle__c = 'Second Categorie');
        insert catSecond;

        CompetenceCategorie__c cc1 = new CompetenceCategorie__c(Categorie__c = catFirst.Id, Geocat__c = geo.Id);
        insert cc1;

        Mapping_CC__c m1 = new Mapping_CC__c(Competence_ref__c = compThird.Id , Categorie_ref__c = catFirst.Id, Inclus__c = true);
        insert m1;
        Mapping_CC__c m2 = new Mapping_CC__c(Competence_ref__c = compThird.Id , Categorie_ref__c = catSecond.Id, Inclus__c = false);
        insert m2;
        Mapping_CC__c m3 = new Mapping_CC__c(Competence_ref__c = compSecond.Id , Categorie_ref__c = catFirst.Id, Inclus__c = true);
        insert m3;
        Mapping_CC__c m4 = new Mapping_CC__c(Competence_ref__c = compSecond.Id , Categorie_ref__c = catSecond.Id, Inclus__c = true);
        insert m4;

        PageReference pageRef = Page.CompetencesCategories;
        Test.setCurrentPage(pageRef);
        TransitionController.getTest('ok');
        System.currentPageReference().getParameters().put('id', compSecond.id);
        System.currentPageReference().getParameters().put('niv1', compFirst.id);
        System.currentPageReference().getParameters().put('geocat', geo.id);

        CompetencesCategories cc_controller = new CompetencesCategories();
        cc_controller.savemapping();
        geo.Categorie_exclue_TECH__c = '1,2';

        delete cc1;
        CompetenceCategorie__c cc2 = new CompetenceCategorie__c(Categorie__c = catSecond.Id, Geocat__c = geo.Id, ON_IHM__c = true);
        insert cc2;
        
        cc_controller.savemapping();
	}
}