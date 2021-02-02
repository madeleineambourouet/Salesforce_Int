/**
* @author Qiuyan Liu
* @date 23/12/2016
*
* @description Test class for Class Batch_MERSelectionResume
 */
@isTest(SeeAllData=false)
private class Batch_MERSelectionResumeTest {
	
	@testSetup
	static void setup() {
	  
	  ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
      List<Reference__c> listReferences = new List<Reference__c>();
      List<Account> listAccounts = new List<Account>();
      Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
      Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
      Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
      Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
      Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
      Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
      User us = TestFactory.createUser('0123456789', sysAdm);
      Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
      //insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;
      listReferences.add(pays);
      listReferences.add(CP);
      listReferences.add(competence);
      listReferences.add(NAF);
      listReferences.add(enseigne);
      insert listReferences; insert TV;
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
      project.Adresse_mail__c = 'test@gmail.com';
      insert project;
      Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
      miseEnRelation.Date_de_s_lection__c = Date.today();
      insert miseEnRelation;
 
	}

    static testMethod void test() {
        Test.startTest();
        Batch_MERSelectionResume b = new Batch_MERSelectionResume(); 
        database.executebatch(b);
        Test.stopTest();
    }
}