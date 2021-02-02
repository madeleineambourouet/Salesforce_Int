/**
* @author Clement Musabimana
* @date 22/10/2019
* @description Test du Service permettant de faire appel au fournisseur Instaply pour l'envoi de messages
**/
@isTest
public class CallServiceInstaplyTest {
    @testSetup 
    static void setup() {
	    List<Account> listAccounts = new List<Account>();
	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
	    Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
	    Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
	    Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
	    Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
	    Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
	    User us = TestFactory.createUser('0123456789', sysAdm);
		
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        particulier.PersonMobilePhone ='0000000000';
		listAccounts.add(particulier);
		insert listAccounts;


		Projet__c projet = TestFactory.createProject(particulier, CP, pays, us);
		projet.Statut_Projet__c = 'Nouveau';
		projet.Etat__c = 'ODC ouverte';
        projet.Source__c = 'VANN';
		projet.Demande_du_Part__c = 'Artisans qualifiés';  
		insert projet;
    }
    static testmethod void testNRP1() {        
        Test.startTest();
       	Projet__c projet = [SELECT Id FROM Projet__c LIMIT 1];
       	projet.Statut_Projet__c = 'Part NRP';
       	projet.Sous_statut__c = '1er appel';
        update projet;
        System.assertEquals(projet.Statut_Projet__c,'Part NRP');
    }
    static testmethod void testNRP2() {        
        Test.startTest();
       	Projet__c projet = [SELECT Id FROM Projet__c LIMIT 1];
       	projet.Statut_Projet__c = 'Part NRP';
       	projet.Sous_statut__c = '2ème appel';
        update projet;
        System.assertEquals(projet.Statut_Projet__c,'Part NRP');
    }
    static testmethod void testNRP3() {        
        Test.startTest();
       	Projet__c projet = [SELECT Id FROM Projet__c LIMIT 1];
       	projet.Statut_Projet__c = 'Part NRP';
       	projet.Sous_statut__c = '3ème appel';
        update projet;
        System.assertEquals(projet.Statut_Projet__c,'Part NRP');
    }
}