// 
// Test class for ProjectLifeCycle webservice
// 31/07/2017, xavier templet, version initiale   
//

@isTest(seeAllData=true)
global class ProjectLifeCycleWS_TEST {
	
	@isTest 
	static void ProjectLifeCycleWS_TEST() {  
		
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> referenceList = new List<Reference__c>();
        List<Account> accList = new List<Account>();
      	Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France'); //insert pays; 
      	Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
      	Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
      	Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;

        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        insert referenceList;

      	Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      	//insert particulier;
      	Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      	//insert PRO;
        accList.add(particulier);
        accList.add(PRO);
        insert accList;
      	Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.ProjectLifeCycleWS@test.com');
      	insert con;
      	GeoCat__c geocat = TestFactory.createGeocat(con, CP);
      	insert geocat;

      	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
      	project.Adresse_mail__c = 'test+xxx00xxx000@gmail.com';
        project.email_projet__c = 'test2++xxx00xxx000@test.com';
        project.Etat__c = 'ODC ouverte';
      	insert project;
		    ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Nouveau', 'Déposé ailleurs');
        project.Statut_Projet__c = 'Gestion interne CRC';
        update project;
        ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Gestion interne CRC', 'Déposé ailleurs');
        project.Statut_Projet__c = 'Perdu EPH MOE';
        project.Sous_statut__c = 'Autres pros';
        update project;
        ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Perdu EPH MOE', 'Autres pros');
    

        Test.stopTest();
    		//system.assert(ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Qualifié', null) == 'OK');
    		//system.assert(ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id) == 'KO');//'KO-ODCOUVERTE');

    		//system.assert(ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Pas de pros à suivre', null) == 'OK');
    		//system.assert(ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id) == 'OK');//'OK-UPDATED-NOPRO');
    		//system.assert(ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id) == 'OK');//== 'OK-UPDATED');
    		//system.assert(ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Projet partenaire', 'MM2') == 'OK');
    				
    		//system.assert(ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Projet partenaire', 'MM2') == 'OK');
    		//system.assert(ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Projet partenaire transmis', 'MM2') == 'OK');
    		//system.assert(ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id) == 'KO');//== 'OK-NOUPDATE-TRANSMIS');
				
	}

  @isTest 
  static void LandingPageCloturerForJulienWS_NEw_TEST() {  
    
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> referenceList = new List<Reference__c>();
        List<Account> accList = new List<Account>();
  
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France'); //insert pays; 
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;

        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        insert referenceList;
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        //insert particulier;
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        //insert PRO;
        accList.add(particulier);
        accList.add(PRO);
        insert accList;
        Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.ProjectLifeCycleWS@test.com');
        insert con;
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;

        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        project.Adresse_mail__c = 'test+xxx00xxx000@gmail.com';
        project.email_projet__c = 'test2++xxx00xxx000@test.com';
        insert project;
        ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id);
        //project.Statut_Projet__c = 'Projet Partenaire';
        //update project;
        //ProjectLifeCycleWS.UpdateProjectStatus(project.Name, 'Projet Partenaire', 'Déposé ailleurs');

        Test.stopTest();
  }


  @isTest 
  static void LandingPageCloturerForJulienWS_Par_NRP_TEST() {  
    
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> referenceList = new List<Reference__c>();
        List<Account> accList = new List<Account>();
  
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France'); //insert pays; 
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;

        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        insert referenceList;
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        //insert particulier;
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        //insert PRO;
        accList.add(particulier);
        accList.add(PRO);
        insert accList;
        Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.ProjectLifeCycleWS@test.com');
        insert con;
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;

        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        project.Adresse_mail__c = 'test+xxx00xxx000@gmail.com';
        project.email_projet__c = 'test2++xxx00xxx000@test.com';
        insert project;
        project.Statut_Projet__c = 'Part NRP EPH MOE';
        project.Sous_statut__c = '1er appel';
        update project;
        ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id);

        Test.stopTest();
  }


  @isTest 
  static void LandingPageCloturerForJulienWS_Par_NRP_EPH_MOE_TEST() {  
    
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> referenceList = new List<Reference__c>();
        List<Account> accList = new List<Account>();
  
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France'); //insert pays; 
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;

        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        insert referenceList;
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        //insert particulier;
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        //insert PRO;
        accList.add(particulier);
        accList.add(PRO);
        insert accList;
        Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.ProjectLifeCycleWS@test.com');
        insert con;
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;

        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        project.Adresse_mail__c = 'test+xxx00xxx000@gmail.com';
        project.email_projet__c = 'test2++xxx00xxx000@test.com';
        insert project;
        project.Statut_Projet__c = 'Part NRP';
        project.Sous_statut__c = '1er appel';
        update project;
        ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id);

        Test.stopTest();
  }


  @isTest 
  static void LandingPageCloturerForJulienWS_Pas_de_pro_a_suivre_TEST() {  
    
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> referenceList = new List<Reference__c>();
        List<Account> accList = new List<Account>();
  
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France'); //insert pays; 
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;

        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        insert referenceList;
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        //insert particulier;
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        //insert PRO;
        accList.add(particulier);
        accList.add(PRO);
        insert accList;
        Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.ProjectLifeCycleWS@test.com');
        insert con;
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;

        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        project.Adresse_mail__c = 'test+xxx00xxx000@gmail.com';
        project.email_projet__c = 'test2++xxx00xxx000@test.com';
        project.Statut_Projet__c = 'Pas de pros à suivre';
        insert project;
        ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id);

        Test.stopTest();
  }


  @isTest 
  static void LandingPageCloturerForJulienWS_Part_NRP_EPH_TEST() {  
    
    //@testSetup 
    //static void setup() {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        List<Reference__c> referenceList = new List<Reference__c>();
        List<Account> accList = new List<Account>();
  
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France'); //insert pays; 
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;

        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        insert referenceList;
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        //insert particulier;
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        //insert PRO;
        accList.add(particulier);
        accList.add(PRO);
        insert accList;
        Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.ProjectLifeCycleWS@test.com');
        insert con;
        GeoCat__c geocat = TestFactory.createGeocat(con, CP);
        insert geocat;

        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        project.Adresse_mail__c = 'test+xxx00xxx000@gmail.com';
        project.email_projet__c = 'test2++xxx00xxx000@test.com';
        project.Statut_Projet__c = 'Part NRP EPH';
        insert project;
        ProjectLifeCycleWS.LandingPageCloturerForJulienWS(project.Id);

        Test.stopTest();
  }
}