@isTest
public with sharing class Batch_ValideIntermediation_TEST {
	
//	@testSetup
//	static void setup() {
//	}
	
    static testMethod void Test_Batch_ValideIntermediation() {
    	
      Test.startTest();
        
	ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
      List<Reference__c> listReferences = new List<Reference__c>();
      List<Account> listAccounts = new List<Account>(); 
      Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
      Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
      Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
      Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
      Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
      Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
      Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
      User us = TestFactory.createUser('0123456789', sysAdm);
      // insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;
      insert TV;
      listReferences.add(competence);
      listReferences.add(NAF);
      listReferences.add(enseigne);
      listReferences.add(CP);
      listReferences.add(pays);
      insert listReferences;

      Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      //insert particulier;
      Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      //insert professionnel;
      listAccounts.add(particulier);
      listAccounts.add(professionnel);
      insert listAccounts;
      Contact contactPro = TestFactory.createContact(professionnel);
      insert contactPro;
	
      Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
      insert project;
      project.Statut_Projet__c = 'Qualifié';
      project.Etat__c = 'ODC ouverte';
      project.Adresse_mail__c = 'test@gmail.com';
      update project;
      Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
      miseEnRelation.Statut_Selection__c = 'Demandee';
      System.debug('miseEnRelation.Statut_Selection__c :' + miseEnRelation.Statut_Selection__c);
      insert miseEnRelation;
      //checkRecursiveSFDC.runSMS = true;
      miseEnRelation.Statut_Selection__c = 'Validee';
      update miseEnRelation;
              
      System.assert(miseEnRelation.url_token__c != '');
      //System.assertEquals(miseEnRelation.Statut_Selection__c, 'Effectuee');
      //System.assertEquals(project.Statut_Projet__c, 'En attente de suivi');
      //System.debug('miseEnRelation.Statut_Selection__c :' + miseEnRelation.Statut_Selection__c);
      //System.debug('miseEnRelation.Date_de_s_lection__c :' + miseEnRelation.Date_de_s_lection__c);
      //System.debug('miseEnRelation.Is_selectionne__c :' + miseEnRelation.Is_selectionne__c);

      Test.stopTest();
      
    }
	
    
}