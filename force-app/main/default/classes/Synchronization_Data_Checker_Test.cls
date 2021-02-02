/**
 * @File Name          : Synchronization_Data_Checker_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/10/2020, 4:22:10 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/5/2020   Hassan Dakhcha     Initial Version
**/
@isTest
private with sharing class Synchronization_Data_Checker_Test {
   
   @isTest
    public static void checkBatch() {

        Test.startTest();
        List<Account> accounts = [SELECT id, pro_Pilote__c, Compte_Nouvelles_Offres__c FROM Account WHERE isPersonAccount = false];
        accounts[0].Compte_Nouvelles_Offres__c = true;
        accounts[1].Compte_Nouvelles_Offres__c = true;
        accounts[0].pro_Pilote__c = true;
        accounts[1].pro_Pilote__c = true;
        accounts[1].External_ID__c = '12323242';
        accounts[0].Statut_activation__c = 'Nouveau';
        accounts[1].Statut_activation__c = 'Pro_resilie';
        update accounts;

        List<Contact> Contacts = [SELECT id, email, email__c FROM Contact];
        Contacts[0].email__c = null;
        update Contacts[0];
        
        // Metier 
        List<Reference__c> refList = [SELECT id from reference__c where recordtype.developerName = 'Metier' ];
        insert (new Metier__c(metier__c = refList[0].id, Contact__c = Contacts[0].id));
        insert (new Metier__c(metier__c = refList[1].id, Contact__c = Contacts[1].id));
     
        // Departement 
        refList = [SELECT id from reference__c where recordtype.developerName = 'Departement' ];
        insert (new Departement__c (Departement__c = refList[0].id, Contact__c = Contacts[0].id));
        insert (new Departement__c (Departement__c = refList[1].id, Contact__c = Contacts[1].id));

        accounts = [SELECT id, Compte_Nouvelles_Offres__c FROM Account WHERE isPersonAccount = true];
        accounts[0].Compte_Nouvelles_Offres__c = true;
        accounts[1].Compte_Nouvelles_Offres__c = false;
        accounts[1].External_ID__c = '12323242';
        accounts[0].Statut_activation__c = 'Nouveau';
        accounts[1].Statut_activation__c = 'Part_actif';
        update accounts;

        List<Metier__c> metiers = [ SELECT id, email_cle_metier__c FROM Metier__c];
        List<Departement__c> dpts = [ SELECT id, email_cle_departement__c FROM Departement__c];
        List<Prestation_Contact__c> pcs = [ SELECT id, email_cle_Prestation__c FROM Prestation_Contact__c];
        
        metiers[0].email_cle_metier__c = 'null_323234';
        metiers[0].email_cle_metier__c = null;
        dpts[0].email_cle_departement__c = 'feferfrerfr@frfr__frfr_null';
        dpts[1].email_cle_departement__c = '';
        pcs[0].email_cle_Prestation__c = 'null_323234';
        pcs[1].email_cle_Prestation__c = 'ferfer_eerg_rgr_null';
        pcs[2].email_cle_Prestation__c = '';
        pcs[3].email_cle_Prestation__c = null;

        update metiers;
        update dpts;
        update pcs;

        Synchronization_Data_Checker b = new Synchronization_Data_Checker('ACCOUNT'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('CONTACT'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('METIER'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('DEPARTEMENT'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('PRESTATION'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('PART'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('PROJET'); 
        database.executebatch(b);
        Test.stopTest();

    }

    @isTest
    // Fonction de test pour : ContactMethods.updateEmailCle
    public static void checkUpdateEmailCle() {
        
        Test.startTest();
        
        List<Contact> Contacts = [SELECT id, email, email__c FROM Contact];
        Account acc = [SELECT id, pro_Pilote__c, Compte_Nouvelles_Offres__c, External_id__c FROM Account WHERE Contact_principal__c = :Contacts[0].id];
        acc.pro_Pilote__c = false;
        acc.External_id__c = null;
        update acc;
        
        // Metier 
        List<Reference__c> refList = [SELECT id from reference__c where recordtype.developerName = 'Metier' ];
        insert (new Metier__c(metier__c = refList[0].id, Contact__c = Contacts[0].id));
        insert (new Metier__c(metier__c = refList[1].id, Contact__c = Contacts[0].id));
     
        // Departement 
        refList = [SELECT id from reference__c where recordtype.developerName = 'Departement' ];
        insert (new Departement__c (Departement__c = refList[0].id, Contact__c = Contacts[0].id));
        insert (new Departement__c (Departement__c = refList[1].id, Contact__c = Contacts[0].id));

        List<Metier__c> metiers = [ SELECT id, email_cle_metier__c FROM Metier__c];
        System.assertEquals(2, metiers.size(), 'Doit avoir 2 metiers');
        for(Metier__c mt : metiers) {
            System.assertEquals(Contacts[0].email__c, mt.email_cle_metier__c.substringBeforeLast('_'), 'Email du contact doit etre le meme que celui de la cle');
        }

        List<Departement__c> dpts = [ SELECT id, email_cle_departement__c FROM Departement__c];
        System.assertEquals(2, dpts.size(), 'Doit avoir 2 departements');
        for(Departement__c dpt : dpts) {
            System.assertEquals(Contacts[0].email__c, dpt.email_cle_departement__c.substringBeforeLast('_'), 'Email du contact doit etre le meme que celui de la cle');
        }

        List<Prestation_Contact__c> pcs = [ SELECT id, email_cle_Prestation__c FROM Prestation_Contact__c WHERE Contact__c=:Contacts[0].id];
        System.assertEquals(4, pcs.size(), 'Doit avoir 4 prestations');
        for(Prestation_Contact__c pc : pcs) {
            System.assertEquals(Contacts[0].email__c, pc.email_cle_prestation__c.substringBeforeLast('_'), 'Email du contact doit etre le meme que celui de la cle');
        }

        Contacts[0].email = 'NouveauEmail@mail.com';
        update Contacts[0];
        Contacts = [SELECT id, email, email__c FROM Contact];
        System.assertEquals('nouveauemail@mail.com', Contacts[0].email__c, 'Email__c du contact doit avoir le nouveau email');

        metiers = [ SELECT id, email_cle_metier__c FROM Metier__c];
        for(Metier__c mt : metiers) {
            System.assertEquals(Contacts[0].email__c, mt.email_cle_metier__c.substringBeforeLast('_'), 'Email du contact doit etre le meme que celui de la cle');
        }

        dpts = [ SELECT id, email_cle_departement__c FROM Departement__c];
        for(Departement__c dpt : dpts) {
            System.assertEquals(Contacts[0].email__c, dpt.email_cle_departement__c.substringBeforeLast('_'), 'Email du contact doit etre le meme que celui de la cle');
        }

        pcs = [ SELECT id, email_cle_Prestation__c FROM Prestation_Contact__c WHERE Contact__c=:Contacts[0].id];
        for(Prestation_Contact__c pc : pcs) {
            System.assertEquals(Contacts[0].email__c, pc.email_cle_prestation__c.substringBeforeLast('_'), 'Email du contact doit etre le meme que celui de la cle');
        }
        Test.stopTest();
    }


    @testSetup static void setup(){
		createRef();
		Profile BD = TestFactory.getProfilByName('Service Commercial ITCS');
        User userBD = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=BD.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userBD;
        System.assertEquals(false, String.isEmpty(userBD.id), 'User BD created' );

		Account PRO1;
        Account PRO2;
        Contact ctc1;
        Contact ctc2;
        System.runAs(userBD) {
			PRO1 = createAccount('mail1@testorg.com', '1111', '1111', 'PRO1', '32212091600208', 'ACC1' /* wbeId*/);
			ctc1 = new Contact( Salutation = 'M.', FirstName = 'Test3', LastName = 'Test3', Contact_Principal_O_N__c = true,
										email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = PRO1.id, External_Contact_Id__c = 'CONTACT1_id');
			insert ctc1;
			PRO2 = createAccount('mail2@testorg.com', '2222', '2222', 'PRO2', '37887802900016', 'ACC2' /* wbeId*/ );
			ctc2 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 2', LastName = 'test', Contact_Principal_O_N__c = true,
										email = 'mail2@testorg.com', Email__c = 'mail2@testorg.com', AccountId = PRO2.id, External_Contact_Id__c = 'CONTACT2_id');
			insert ctc2;
			List<Prestation_Contact__c> pcList = new List<Prestation_Contact__c>();			
			for(Reference__c prest : [SELECT id , key__c, SKU__c FROM reference__c WHERE recordType.developerName='Prestation']) {
				pcList.add(new Prestation_Contact__c(Contact__c = ctc1.id, Email_cle_prestation__c = ctc1.Email__c  + '_' + prest.Key__c, Prestation__c = prest.id)); 
				if(prest.SKU__c == 'B1001' || prest.SKU__c == 'B1002') {
					pcList.add(new Prestation_Contact__c(Contact__c = ctc2.id, Email_cle_prestation__c = ctc2.Email__c  + '_' + prest.Key__c, Prestation__c = prest.id)); 
				}
			}
			insert pcList;
		}

		Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail3@testorg.com' );
        insert PART;
		Account PART2 = new Account(firstName ='Albert2' , lastName = 'Heinestein2', PersonTitle = 'M', PersonEmail = 'mail4@testorg.com' );
        insert PART2;
        
		// Create projects :
		List<Projet_LMSG__c> prjList = new List<Projet_LMSG__c>();
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c ='24353534', Chiffrage_bsku__c = 'B1001', Chiffrage_maximum__c = 10500, Date_de_debut_de_chantier__c = system.today() + 5, Date_de_fin_de_chantier__c = system.today() + 30, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c = '',  Chiffrage_bsku__c = 'B1002', Chiffrage_maximum__c = 10200, Date_de_debut_de_chantier__c = system.today() + 10, Date_de_fin_de_chantier__c = system.today() + 35, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Chiffrage_bsku__c = 'B1003', Chiffrage_maximum__c = 45000, Date_de_debut_de_chantier__c = system.today() + 15, Date_de_fin_de_chantier__c = system.today() + 40, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 80000, Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Chiffrage_bsku__c = 'B1001', Chiffrage_maximum__c = 10500, Date_de_debut_de_chantier__c = system.today() + 5, Date_de_fin_de_chantier__c = system.today() + 30, Particulier__c = PART2.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Chiffrage_bsku__c = 'B1002', Chiffrage_maximum__c = 10200, Date_de_debut_de_chantier__c = system.today() + 10, Date_de_fin_de_chantier__c = system.today() + 35, Particulier__c = PART2.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c = '1331123112', Chiffrage_bsku__c = 'B1003', Chiffrage_maximum__c = 45000, Date_de_debut_de_chantier__c = system.today() + 15, Date_de_fin_de_chantier__c = system.today() + 40, Particulier__c = PART2.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c = '', Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 80000, Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45, Particulier__c = PART2.id, Statut__c = 'PUBLISHED'));
        insert prjList;
	}

	static Account createAccount(String email, String codeClient, String profileId, String Name, String Siret, String wbeId) {       
        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = Name;
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c =  [SELECT id, Name FROM reference__c WHERE Name='ACS'].Name;
        compte.Flux_code_Enseigne__c =  [SELECT id, key__c FROM reference__c WHERE Name='ACS'].key__c;
        compte.SIRET_texte__c = Siret;
        compte.Code_NAF_APE_societe_declarante__c = [SELECT id FROM reference__c WHERE Name='AAA'].id;
        compte.A_ne_jamais_rappeler__c = false;
        compte.External_ID__c = 'pro_'+wbeId;
        compte.Pays_LKP__c = [SELECT id FROM reference__c WHERE Name='France'].id;
        compte.Code_postal__c = [SELECT id FROM reference__c WHERE Name='75017'].id;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = true;
        compte.Statut_activation__c = 'Nouveau';
        compte.Login__c = email;
        compte.Code_client__c = codeClient;
        compte.profile_id__c  = profileId;
		insert compte;
	    return compte;
	}
	
	static void createRef() {
        List<Reference__c> refList = new List<Reference__c>();
		refList.add(TestFactory.createReference('pays', 'France','FRA','France'));
        refList.add(TestFactory.createReference('CP', '75017','75017','Paris'));
        refList.add(TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'));
        refList.add(TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'));
        
        refList.add(TestFactory.createReference('Metier', 'Carreleur','23423Ee','Carreleur'));
        refList.add(TestFactory.createReference('Metier', 'Maçon','423423D','Maçon'));
        
        refList.add(TestFactory.createReference('Departement', '75','5454E','75'));
        refList.add(TestFactory.createReference('Departement', '06','7676E','06'));

		List<String> listDoc = new List<String> ();
		reference__c presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un chauffe-eau','92278f', 'P100', 0, listDoc);
		presta.SKU__c = 'B1001';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un plancher chauffant à eau chaude','c5be38', 'P200', 0 , listDoc);
		presta.SKU__c = 'B1002';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un plancher chauffant électrique','a4bc1e', 'P300', 0 , listDoc);
		presta.SKU__c = 'B1003';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un poêle à bois','fd6898', 'P400', 0 , listDoc);
		presta.SKU__c = 'B1004';
		refList.add(presta);
		insert refList;
	}
}