// 
// Test du Batch pour les recrédits sur MERs rejetées
// 17/07/2017, xavier templet, version initiale   
//


@isTest
public class Batch_Recredit_Test {

	public static String CRON_EXP = '0 26 18 29 3 ? 2022'; // from the 29/3/2022 runs monthly the 29th at 18h26

    public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
    public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);
    public static final String DEFAULT_CURRENCY = 'USD';
		
    @testSetup 
    static void setup() {
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);

        List<Reference__c> listReferences = new List<Reference__c>();
        List<Account> listAccounts = new List<Account>();
  
      	Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');//insert pays; 
      	Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris'); //insert CP;
      	Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'); //insert NAF;
      	Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'); //insert enseigne;
      	Reference__c rateplan = TestFactory.createReference('competence', 'RATEPLAN','RATEPLAN','Abonnement Offre Homly Travaux'); //insert rateplan; 


        Reference__c rejetMatching = TestFactory.createReference('Matching_rejet', 'Recrédit - Geste co', 'GCO_REC', 'Recrédit - Geste co'); //insert rejetMatching;
        Reference__c motif = TestFactory.createReference('Motif', 'Recrédit à rattraper','1','Recrédit à rattraper'); 
        Reference__c competence1 = TestFactory.createReference('competence', '1','1','competence1');  
        competence1.Parent__c = '0'; competence1.Libelle_3__c = 'CAT_1'; 
        //insert competence1;

        listReferences.add(pays);
        listReferences.add(CP);
        listReferences.add(enseigne);
        listReferences.add(NAF);
        listReferences.add(rateplan);
        listReferences.add(rejetMatching);
        listReferences.add(competence1);
        listReferences.add(motif);
        insert listReferences; 

      	Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      	//insert particulier;
      	Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      	//insert PRO;
        listAccounts.add(particulier);
        PRO.Name = 'Test account 1';
        PRO.Phone = '+33600000000';
        PRO.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
        PRO.Flux_code_Enseigne__c = enseigne.key__c;
        PRO.SIRET_texte__c = '53008580200037';
        PRO.Code_client__c = '09AAA';
			  //update PRO;    
        listAccounts.add(PRO); 
        insert listAccounts; 	
      	Contact con = new Contact(AccountId = PRO.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'test.BatchRecredit@test.com');
      	insert con;
      	GeoCat__c geocat = TestFactory.createGeocat(con, CP);
      	insert geocat;

      	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
      	//project.Statut_Projet__c = 'Qualifié';
      	//project.Etat__c = 'ODC ouverte';
      	project.Adresse_mail__c = 'test@gmail.com';
      	insert project;
      	
      	Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '09AAA');
      	insert billingaccount;
      	Zuora__Subscription__c ZuoSub = Test_Zuora_ExtendedTestDataSetup.createSubscription(PRO, billingAccount, true, '23456789012345678901234567890666' ); 

      	//System.debug('Batch_Recredit_Test >>>>> competence1 Libelle_3__c: ' + competence1.Libelle_3__c + ' Competence_Price__c: ' + competence1.Competence_Price__c);

		//Reference__c MyCompetence = [select Id from Reference__c where Name ='Isolation des combles perdus' and Libelle_3__c !=null limit 1];		
      	Intermediation__c miseEnRelation1 = TestFactory.createMiseEnRelation(con, competence1, project);
      	miseEnRelation1.Statut_Selection__c = 'Effectuee';
      	miseEnRelation1.IsModified__c = true;
      	miseEnRelation1.Date_de_s_lection__c = date.today();
      	//miseEnRelation1.Recredit__c = false;
      	miseEnRelation1.Matching_rejete_date__c = date.today();
        miseEnRelation1.Matching_rejete__c = rejetMatching.Id;
      	insert miseEnRelation1;
        update miseEnRelation1;

 /* 

      	Account PRO2 = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      	insert PRO2;
		PRO2.Statut_de_paiement__c = 'Résilié impayé';
		update PRO2;
      	Contact con2 = new Contact(AccountId = PRO2.id, FirstName = 'test2', Salutation = 'M.', LastName = 'Test2', Phone = '+33111111112', Email = 'test2@test.com');
      	insert con2;
      	GeoCat__c geocat2 = TestFactory.createGeocat(con2, CP);
      	insert geocat2;
      	Zuora__CustomerAccount__c billingAccount2 = new Zuora__CustomerAccount__c(Zuora__BillCycleDay__c='1st of the month', Name = 'test billing account 2', Zuora__Account__c = PRO2.id, Zuora__AccountNumber__c = '123457');
      	insert billingaccount2;
      	Zuora__Subscription__c ZuoSub2 = Test_Zuora_ExtendedTestDataSetup.createSubscription(PRO2, billingAccount2, true, '23456789012345678901234567890555'); 
 		ZuoSub.Zuora__Status__c = 'Cancelled';
		update ZuoSub;
       	Intermediation__c miseEnRelation2 = TestFactory.createMiseEnRelation(con, competence1, project);
      	miseEnRelation2.Statut_Selection__c = 'Effectuee';
      	miseEnRelation2.IsModified__c = true;
      	miseEnRelation2.Date_de_s_lection__c = date.today();
      	insert miseEnRelation2;
      	miseEnRelation2.Matching_rejete__c = rejetMatching.Id;
      	update miseEnRelation2;
    	
        
	    // zqu__Quote__c zquote = Test_Zuora_ExtendedTestDataSetup.getQuote(PRO, con);
      	Reference__c competence2 = TestFactory.createReference('competence', '2','2','competence2');  
      	competence2.Parent__c = '1'; competence2.Libelle_3__c = 'CAT_2'; 
		insert competence2;
      	Reference__c competence3 = TestFactory.createReference('competence', '3','3','competence3');  
      	competence3.Parent__c = '2'; competence3.Libelle_3__c = 'CAT_3'; 
		insert competence3;
      	System.debug('Batch_Recredit_Test >>>>> competence3 Libelle_3__c: ' + competence3.Libelle_3__c + ' Competence_Price__c: ' + competence3.Competence_Price__c);
      	Reference__c competence4 = TestFactory.createReference('competence', '4','4','competence4');  
      	competence4.Parent__c = '0'; competence4.Libelle_3__c = 'CAT_1'; 
		insert competence4;
      	System.debug('Batch_Recredit_Test >>>>> competence4 Libelle_3__c: ' + competence4.Libelle_3__c + ' Competence_Price__c: ' + competence4.Competence_Price__c);

      	Intermediation__c miseEnRelation2 = TestFactory.createMiseEnRelation(con, competence2, project);
      	miseEnRelation2.Statut_Selection__c = 'Effectuee';
      	miseEnRelation2.Recredit__c = false;
      	miseEnRelation2.Matching_rejete__c = rejetMatching.Id;
      	miseEnRelation2.Date_de_s_lection__c = date.today();
      	insert miseEnRelation2;
      	System.debug('Batch_Recredit_Test >>>>> miseEnRelation2 :' + miseEnRelation2 + ' Libelle_3__c: ' + miseEnRelation2.Competence__r.Libelle_3__c + ' Competence_Price__c: ' + miseEnRelation2.Competence__r.Competence_Price__c);
      	Intermediation__c miseEnRelation3 = TestFactory.createMiseEnRelation(con, competence3, project);
      	miseEnRelation3.Statut_Selection__c = 'Effectuee';
      	miseEnRelation3.Recredit__c = false;
      	miseEnRelation3.Matching_rejete__c = rejetMatching.Id;
      	miseEnRelation3.Date_de_s_lection__c = date.today();
      	insert miseEnRelation3;
      	System.debug('Batch_Recredit_Test >>>>> miseEnRelation3 :' + miseEnRelation3 + ' Libelle_3__c: ' + miseEnRelation3.Competence__r.Libelle_3__c + ' Competence_Price__c: ' + miseEnRelation3.Competence__r.Competence_Price__c);
      	Intermediation__c miseEnRelation4 = TestFactory.createMiseEnRelation(con2, competence1, project);
      	miseEnRelation4.Statut_Selection__c = 'Effectuee';
      	miseEnRelation4.Recredit__c = false;
      	miseEnRelation4.Matching_rejete__c = rejetMatching.Id;
      	miseEnRelation4.Date_de_s_lection__c = date.today();
      	insert miseEnRelation4;
      	System.debug('Batch_Recredit_Test >>>>> miseEnRelation4 :' + miseEnRelation4 + ' Libelle_3__c: ' + miseEnRelation4.Competence__r.Libelle_3__c + ' Competence_Price__c: ' + miseEnRelation4.Competence__r.Competence_Price__c);
      	Intermediation__c miseEnRelation5 = TestFactory.createMiseEnRelation(con2, competence2, project);
      	miseEnRelation5.Statut_Selection__c = 'Effectuee';
      	miseEnRelation5.Recredit__c = false;
      	miseEnRelation5.Matching_rejete__c = rejetMatching.Id;
      	miseEnRelation5.Date_de_s_lection__c = miseEnRelation4.Date_de_s_lection__c.adddays(-35);
      	insert miseEnRelation5;
      	System.debug('Batch_Recredit_Test >>>>> miseEnRelation5 :' + miseEnRelation5 + ' Libelle_3__c: ' + miseEnRelation5.Competence__r.Libelle_3__c + ' Competence_Price__c: ' + miseEnRelation5.Competence__r.Competence_Price__c);
 */       

    }
    
	static testmethod void testScheduledJob_Recredit() {

        Test.startTest();
        Batch_Recredit b = new Batch_Recredit(); 
        database.executebatch(b);

        // Schedule the test job
        //String jobId = System.schedule('Scheduled Batch_Recredit ApexTest', CRON_EXP, new Batch_Recredit());
        Test.stopTest();
        List<zqu__Quote__c> zq = [select Id from zqu__Quote__c where zqu__Amendment_Name__c = 'Recrédit'   ];  // and zqu__account__c = PRO.Id and zqu__Currency__c = 'EUR' 
      	System.debug('Batch_Recredit_Test >>>>> List<zqu__Quote__c> ApexTest : ' + zq);
        system.assert(zq.size() >= 1);        


    	
    }
}