@isTest
public with sharing class HelperButtonTest1 {
	
	@isTest
	public static void HelperTest1() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;
       
		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		//Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        //insert billingaccount;

		HelperButton.reinitMDP(acc);

		Test.stopTest();
	}
	@isTest
	public static void HelperTest2() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		//Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        //insert billingaccount;

		HelperButton.seConnecter(acc.Id);

		Test.stopTest();
	}
	@isTest
	public static void HelperTest3() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		//Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        //insert billingaccount;

		HelperButton.selectionPro(miseEnRelation.Id);

		Test.stopTest();
	}
	@isTest
	public static void HelperTest4() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		//Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        //insert billingaccount;

		miseEnRelation.Competence__c = competence.Id;
		miseEnRelation.Selection_demandee_a__c = Date.today();
		update miseEnRelation;
		HelperButton.selectionPro(miseEnRelation.Id);

		Test.stopTest();
	}
	@isTest
	public static void HelperTest5() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		//Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        //insert billingaccount;

		miseEnRelation.Statut_Selection__c = null;
		miseEnRelation.Non_selectionnable__c = true;
		update miseEnRelation;

		system.debug('miseEnRelation = ' + miseEnRelation);
		HelperButton.selectionPro(miseEnRelation.Id);

		Test.stopTest();
	}
	@isTest
	public static void HelperTest6() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		//Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        //insert billingaccount;

        miseEnRelation.Non_selectionnable__c = false;
		update miseEnRelation;
		HelperButton.selectionPro(miseEnRelation.Id);
		Test.stopTest();
	}
	@isTest
	public static void HelperTest7() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

        Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;
   		
		HelperButton.annulerMatching(miseEnRelation.Id);

		Test.stopTest();
	}
	@isTest
	public static void HelperTest8() {

   		// Début des tests
   		Test.startTest();
		// initialisation
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

        List<Account> listAccounts = new List<Account>();
		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		//insert acc;  
		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	//insert particulier;
        
        listAccounts.add(acc);
        listAccounts.add(particulier);
        insert listAccounts;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = acc.Id;
        quote.Name = 'Quote Name';
        insert quote;
        
		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
   		miseEnRelation.Competence__c = null;
		miseEnRelation.Statut_Selection__c = 'Refusee';
		miseEnRelation.Non_selectionnable__c = true;
		miseEnRelation.IsModified__c = false;
		insert miseEnRelation;

		miseEnRelation.recredit_quote__c = quote.Id;
		
		update miseEnRelation;
		HelperButton.annulerMatching(miseEnRelation.Id);
		Test.stopTest();
	}
}