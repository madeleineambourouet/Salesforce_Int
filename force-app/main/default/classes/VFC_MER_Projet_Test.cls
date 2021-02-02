@isTest (SeeAllData=true)
public class VFC_MER_Projet_Test {

    static testMethod void New_MER_Test() {
        
    //@testSetup
    //static void setup() {

      ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
  
      Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
      Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
      Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
      Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
      insert pays; insert CP; insert NAF; insert enseigne; 
      //Reference__c competence = TestFactory.createReference('competence', '1','Aménagement de combles','Aménagement de combles');
	  //insert competence; 
	  
      Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
      //User us = TestFactory.createUser('0123456789', sysAdm);
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;

      //Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
      //insert TV;

		Mapping_CC__c mappingPrj = [SELECT Id, Name, Categorie_key__c, Categorie_libelle__c, Categorie_ref__c
		 		FROM Mapping_CC__c WHERE Actif__c = true AND Categorie_ref__r.Name = 'Aménagement de combles existants' LIMIT 1];

      Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      insert particulier;
      Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      insert professionnel;
      Contact contactPro = TestFactory.createContact(professionnel);
      insert contactPro;
      Projet__c prj = TestFactory.createProject(particulier, CP, pays, us);
      prj.Categorie_lkp__c = mappingPrj.Categorie_ref__c;
      insert prj;

        //Projet__c prj = [SELECT Id FROM Projet__c LIMIT 1];
        
        System.runAs(us) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', prj.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(prj);
			ApexPages.StandardController stdSetC;
            VFC_MER_Projet controller = new VFC_MER_Projet(stdSetC);
			controller.curMER.Professionnel__c = professionnel.Id;
            controller.CompetenceSelected = controller.CompetenceOptions[1].getvalue();
            controller.CompetenceChanged();
            controller.saveNewMER();
            controller.cancelEditMER();
            Test.stopTest();
        }
    }
    
}