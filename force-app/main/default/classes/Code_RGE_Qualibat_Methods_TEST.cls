/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 02-01-2021
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   01-16-2021   Hassan Dakhcha   Initial Version
**/
@isTest
private with sharing class Code_RGE_Qualibat_Methods_TEST {
    @isTest
    static void check_add_Codes_CRC() {
        Profile CRC = TestFactory.getProfilByName('Service Commercial ITCS');
        User userCRC = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='CRC',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=CRC.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userCRC;
        
        Document__c doc = [SELECT id, details__c FROM Document__c];
        String arg = doc.id + ';3212;5333';
        List<String> args = new List<String>{arg};

        Test.startTest();
        System.runAs(userCRC) {
            System.assertEquals(null, doc.Details__c);
            Code_RGE_Qualibat_Methods.addRGECodes(args);
            List<Code_Certif_RGE_Qualibat__c> qualifList = [SELECT id, Document__c,  Code_RGE__c, Code_RGE__r.sku__c FROM Code_Certif_RGE_Qualibat__c];
            System.assertEquals(2, qualifList.size());
            System.assertEquals(true, qualifList[0].Code_RGE__r.sku__c=='3212' && qualifList[1].Code_RGE__r.sku__c=='5333');

            doc = [SELECT id, details__c FROM Document__c];
            System.assertNotEquals(null, doc.Details__c);
            System.assertEquals('{"codes":["3212","5333"]}', doc.Details__c);

            // Delete a Qualif code by CRC
            String deletedCode = qualifList[0].Code_RGE__r.sku__c;
            delete qualifList[0];
            qualifList = [SELECT id, Document__c,  Code_RGE__c, Code_RGE__r.sku__c FROM Code_Certif_RGE_Qualibat__c];
            System.assertEquals(1, qualifList.size());
            System.assertNotEquals(deletedCode, qualifList[0].Code_RGE__r.sku__c);
            
            doc = [SELECT id, details__c FROM Document__c];
            System.assertNotEquals(null, doc.Details__c);
            System.assertEquals('{"codes":["5333"]}', doc.Details__c); 
        }
        
        Test.stopTest();
    }

    @isTest
    static void check_add_Codes_PP() {
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User projectPlace = new User(  Alias = 'HKC', Email='HKConnectTest@testorg.com', 
										EmailEncodingKey='UTF-8', LastName='Place', FirstName ='Project' ,languageLocaleKey='en_US', 
										LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',
										TimeZoneSidKey='America/Los_Angeles', UserName='HKConnectTest@testorg.com');
		insert projectPlace;
        
        Test.startTest();
        System.runAs(projectPlace) {
            // Ajout de la project place d'un doc RGE avec codes !
            Document__c doc = [SELECT id, details__c FROM Document__c];
            System.assertEquals(null, doc.Details__c);

            doc.Details__c = '{"codes":["3212","5333"]}';
            update doc;
            doc = [SELECT id, details__c FROM Document__c];
            System.assertEquals('{"codes":["3212","5333"]}', doc.Details__c);

            List<Code_Certif_RGE_Qualibat__c> qualifList = [SELECT id, Document__c,  Code_RGE__c, Code_RGE__r.sku__c FROM Code_Certif_RGE_Qualibat__c];
            System.assertEquals(2, qualifList.size());
            System.assertEquals(true, qualifList[0].Code_RGE__r.sku__c=='3212' && qualifList[1].Code_RGE__r.sku__c=='5333');

            doc.Details__c = '{"codes":["3212","6261"]}';
            update doc;
            doc = [SELECT id, details__c FROM Document__c];
            System.assertEquals('{"codes":["3212","6261"]}', doc.Details__c);
            qualifList = [SELECT id, Document__c,  Code_RGE__c, Code_RGE__r.sku__c FROM Code_Certif_RGE_Qualibat__c];
            System.assertEquals(2, qualifList.size());
            System.assertEquals(true, qualifList[0].Code_RGE__r.sku__c=='3212' && qualifList[1].Code_RGE__r.sku__c=='6261');

            doc.Details__c = '{"codes":[]}';
            update doc;
            doc = [SELECT id, details__c FROM Document__c];
            System.assertEquals('{"codes":[]}', doc.Details__c);
            qualifList = [SELECT id, Document__c,  Code_RGE__c, Code_RGE__r.sku__c FROM Code_Certif_RGE_Qualibat__c];
            System.assertEquals(0, qualifList.size()); // must create qualif codes

        }
        Test.stopTest();
    }

    // Test positionnement des pro versus RGE !! 
    @isTest
    static void Check_Pro_Status_Vs_RGE() { 

        List<Reference__c> prestaList = [SELECT id, sku__c, key__c, Document_obligatoire__c , Code_RGE_Qualibat__c
                                         FROM Reference__c WHERE recordType.developerName LIKE 'Presta%'];
        prestaList[0].Document_obligatoire__c = 'insurance_rc;cert_rge_qualibat';
        prestaList[0].Code_RGE_Qualibat__c = '3212';
        prestaList[1].Document_obligatoire__c = 'insurance_rc;cert_rge_qualibat;cert_rge_qualifelec';
        prestaList[1].Code_RGE_Qualibat__c = '3412;5333';
        update prestaList;

        Profile CRC = TestFactory.getProfilByName('Service Commercial ITCS');
        User userCRC = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='CRC',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=CRC.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userCRC;
		id validDoc = [SELECT id FROM Reference__c WHERE Key__c ='VALIDATED'].id;
		id newDoc =   [SELECT id FROM Reference__c WHERE Key__c ='NEW'].id;
		id expDoc =   [SELECT id FROM Reference__c WHERE Key__c ='EXPIRED'].id;

      
        System.runAs(userCRC) {

            Document__c qualibat = [SELECT id, Statut__c, details__c, Date_de_validite__c, Evaluate_Expired__c FROM Document__c];
            contact ctc = [SELECT id, Email__c, AccountId FROM Contact ];

            String arg = qualibat.id + ';3212;5333';
            List<String> args = new List<String>{arg};
            Code_RGE_Qualibat_Methods.addRGECodes(args);

            List<Document__c> listDoc = new List<Document__c> ();
            listDoc.add(new Document__c( Compte_Pro__c = ctc.AccountId, Type_de_document__c = 'insurance_rc',
                                         idDocument__c = String.valueOf(Math.random() * 100), Statut__c = validDoc,
                                         Date_de_validite__c = system.today()+20));
            listDoc.add(new Document__c( Compte_Pro__c = ctc.AccountId, Type_de_document__c = 'cert_rge_qualifelec',
                                         idDocument__c = String.valueOf(Math.random() * 100), Statut__c = newDoc));
            insert listDoc;

            // Add Prestation to Contact
            Prestation_Contact__c newPresCt1 = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
                                                                         + prestaList[0].Key__c, Prestation__c = prestaList[0].id); 
            insert newPresCt1;
            Prestation_Contact__c newPresCt2 = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
                                                                         + prestaList[1].Key__c, Prestation__c = prestaList[1].id); 
            insert newPresCt2;

            List<Prestation_Contact__c> presta = [SELECT ID, Statut__c FROM Prestation_Contact__c];
            Test.startTest();
            System.assertEquals('NOT_POS', presta[0].Statut__c);
            System.assertEquals('NOT_POS', presta[1].Statut__c);

            Account Pro = [SELECT ID, Statut_Activation__c FROM Account];
            System.assertEquals('Pro_actif', Pro.Statut_activation__c );


            Document__c qualifelec = [SELECT id, statut__c, date_de_validite__c, Evaluate_Expired__c FROM Document__c
                                      WHERE type_de_document__c='cert_rge_qualifelec'];
            qualifelec.Statut__c = validDoc;
            qualifelec.Date_de_validite__c = System.today() + 40;
            update qualifelec;

            presta = [SELECT ID, Statut__c FROM Prestation_Contact__c];
            System.assertEquals('NOT_POS', presta[0].Statut__c);
            System.assertEquals('POS', presta[1].Statut__c);
            Pro = [SELECT ID, Statut_Activation__c FROM Account];
            System.assertEquals('Pro_actif_positionnable', Pro.Statut_activation__c );


            // Validate the RGE Qualibat : 
            qualibat.Statut__c = validDoc;
            qualibat.Date_de_validite__c = System.today() + 30;
            update qualibat;

            presta = [SELECT ID, Statut__c FROM Prestation_Contact__c];
            System.assertEquals('POS', presta[0].Statut__c);
            System.assertEquals('POS', presta[1].Statut__c);
            Pro = [SELECT ID, Statut_Activation__c FROM Account];
            System.assertEquals('Pro_actif_positionnable', Pro.Statut_activation__c );

            // Delete qualification on qualibat:
            // Must turn non positionnable the presta
            delete [SELECT id FROM Code_Certif_RGE_Qualibat__c WHERE Document__c=:qualibat.id];

            // check details;
            qualibat = [SELECT id, Statut__c, details__c, Date_de_validite__c, Evaluate_Expired__c FROM Document__c WHERE id=:qualibat.id];
            System.assertEquals('{"codes":[]}', qualibat.Details__c);

            presta = [SELECT ID, Statut__c, prestation__r.code_rge_qualibat__c FROM Prestation_Contact__c];
            System.debug('**** code ' + presta[0].Prestation__r.code_rge_qualibat__c);
            System.debug('**** code ' + presta[1].Prestation__r.code_rge_qualibat__c);

            System.assertEquals('NOT_POS', presta[0].Statut__c);
            System.assertEquals('POS', presta[1].Statut__c);
            Pro = [SELECT ID, Statut_Activation__c FROM Account];
            System.assertEquals('Pro_actif_positionnable', Pro.Statut_activation__c );

            // Expire the qualifelec: 
            qualifelec.Statut__c = expDoc;
            qualifelec.Evaluate_Expired__c = true;
            qualifelec.Date_de_validite__c = System.today() + -10;
            update qualifelec;

            presta = [SELECT ID, Statut__c FROM Prestation_Contact__c];
            System.assertEquals('NOT_POS', presta[0].Statut__c);
            System.assertEquals('NOT_POS', presta[1].Statut__c);
            Pro = [SELECT ID, Statut_Activation__c FROM Account];
            System.assertEquals('Pro_actif', Pro.Statut_activation__c );

            // Add Qualif code on Qualibat :
            insert new Code_Certif_RGE_Qualibat__c(Document__c = qualibat.id, 
                                                    Code_RGE__c = [SELECT id FROM reference__c WHERE recordType.DeveloperName='Codes_RGE_Qualibat'
                                                    AND sku__c ='3212'].id);
            qualibat = [SELECT id, Statut__c, details__c, Date_de_validite__c, Evaluate_Expired__c FROM Document__c WHERE id=:qualibat.id];
            System.assertEquals('{"codes":["3212"]}', qualibat.Details__c);

            presta = [SELECT ID, Statut__c FROM Prestation_Contact__c];
            System.assertEquals('POS', presta[0].Statut__c);
            System.assertEquals('NOT_POS', presta[1].Statut__c);
            //Pro = [SELECT ID, Statut_Activation__c FROM Account];
            //System.assertEquals('Pro_actif_positionnable', Pro.Statut_activation__c );

            // Add Qualif code on Qualibat :
            insert new Code_Certif_RGE_Qualibat__c(Document__c = qualibat.id, 
                                                    Code_RGE__c = [SELECT id FROM reference__c WHERE recordType.DeveloperName='Codes_RGE_Qualibat'
                                                    AND sku__c ='5333'].id);
            qualibat = [SELECT id, Statut__c, details__c, Date_de_validite__c, Evaluate_Expired__c FROM Document__c WHERE id=:qualibat.id];
            System.assertEquals('{"codes":["3212","5333"]}', qualibat.Details__c);

            presta = [SELECT ID, Statut__c FROM Prestation_Contact__c];
            System.assertEquals('POS', presta[0].Statut__c);
            System.assertEquals('POS', presta[1].Statut__c);
            //Pro = [SELECT ID, Statut_Activation__c FROM Account];
            //System.assertEquals('Pro_actif_positionnable', Pro.Statut_activation__c );
        }

        Test.stopTest();

    }


    @testSetup static void setup() {
		List<Reference__c> listReferences = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        listReferences.add(CP);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        
        id rt = [select id, DeveloperName from recordtype where DeveloperName like 'Codes_RGE_Qualibat'].id;
        List<String> codes = new List<String>{'3212', '3412', '5333', '6261'};
        for(String cd : codes) {
            listReferences.add(new reference__c(Name=cd, sku__c= cd, key__c='code_rege_'+cd, 
                                                Libelle__c='LABEL : '+cd, recordTypeId = rt));   
        }

        List<String> listDocTypes = new List<String>{'insurance_rc;cert_rge_qualibat;cert_rge_qualifelec'};
        listReferences.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Prest RGE 1', '001', 'P100', 2 /* Pas de Doc Obligatoire*/, listDocTypes));
        listReferences.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Prest RGE 1', '002', 'P200', 3 /* Un Doc Obligatoire*/, listDocTypes));
        
        listReferences.add(TestFactory.createReference('StatutDocument', 'Nouveau','NEW','Nouveau'));
        listReferences.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
        listReferences.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));

        insert listReferences;
        
        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = 'Test account';
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
        compte.Flux_code_Enseigne__c = enseigne.key__c;
        compte.SIRET_texte__c = '32212091600208';
        compte.Code_NAF_APE_societe_declarante__c = NAF.id;
        compte.A_ne_jamais_rappeler__c = false;
        
        compte.Pays_LKP__c = pays.id;
        compte.Code_postal__c = CP.id;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = false;
        compte.Statut_activation__c = 'Pro_actif';
        compte.Login__c = 'mail1@testorg.com';
        compte.Code_client__c = '1111';
        compte.profile_id__c  = '1111';
		insert compte;
		
        Contact ctcPrincipal = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
										   email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = compte.id);
        insert ctcPrincipal;
        
		// Create KYB Documents:
		id newDoc = [SELECT id FROM Reference__c WHERE Key__c ='NEW'].id;
		insert new Document__c( Compte_Pro__c = compte.id,
								Type_de_document__c = 'cert_rge_qualibat',
								idDocument__c = String.valueOf(Math.random() * 100),
								Statut__c = newDoc);
	}
}