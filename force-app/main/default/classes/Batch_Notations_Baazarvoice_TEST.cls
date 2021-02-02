@isTest
public class Batch_Notations_Baazarvoice_TEST {
    @testSetup 
    static void setup() {

	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
	    Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
	    Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
	    Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
	    Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
	    Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
	    User us = TestFactory.createUser('0123456789', sysAdm);
		
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
		insert particulier;
		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		insert professionnel;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro;


		Projet__c projet = TestFactory.createProject(particulier, CP, pays, us);
		projet.Statut_Projet__c = 'Qualifié';
		projet.Etat__c = 'ODC ouverte';
        projet.Source__c = 'VANN';
		projet.Demande_du_Part__c = 'Artisans qualifiés';  

		insert projet;
    }
    static testmethod void test() {        
        Test.startTest();
        Batch_Notations_Baazarvoice bbn = new Batch_Notations_Baazarvoice('2018-06-25','2018-06-26');
        Database.executeBatch(bbn);
        Batch_Notations_Baazarvoice bbn2 = new Batch_Notations_Baazarvoice('2018-06-25','2018-06-26');
        Database.executeBatch(bbn2);
        Test.stopTest();
       	Projet__c projet = [SELECT Id FROM Projet__c LIMIT 1];
       	Notation__c notation = [SELECT Id, Projet__c,LastModifiedDate FROM Notation__c LIMIT 1];
        System.assertEquals(notation.projet__c,projet.Id);
    }
    static testmethod void rappelerServiceTest() {        
        Test.startTest();
        Batch_Notations_Baazarvoice bbn = new Batch_Notations_Baazarvoice('2018-06-25','2018-06-26');
        NotationsBaazarvoiceWrapper.DataNotations projetsNotations = new NotationsBaazarvoiceWrapper.DataNotations();
        projetsNotations.TotalResults = 2;
        projetsNotations.Offset = 2;
        Boolean retourRappelerService = bbn.rappelerService(projetsNotations);
        System.assertEquals(false, retourRappelerService);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
    }
}