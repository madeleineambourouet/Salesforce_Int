/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-12-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-19-2020   Hassan Dakhcha   Initial Version
**/
@isTest
public with sharing class UBOMethodsTest {
    
    @isTest
    static void UBO_Extraction_PM_Test_BugFix() {
    
        Test.startTest();
        UBO_HYSO_Mock mock = new UBO_HYSO_Mock();
        mock.setBody(real_response());
        Test.setMock(HttpCalloutMock.class, mock);
        User BD = [SELECT id FROM User WHERE userName='usersgdbf@testclasssgdbf.com'];
        System.runAs(BD) {
            Account acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c FROM Account];
            // Onboarding 
            acc.Compte_Nouvelles_Offres__c = true;
            acc.Statut_activation__c = 'Pro_actif_positionnable';
            update acc;
            Test.stopTest();

            acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c, Tech_extract_UBO__c  FROM Account];
            System.assertEquals('200', acc.Tech_extract_UBO__c); 

             // Check UBOs
             Map<String, Schema.SObjectField> fieldMap = UBO__c.sObjectType.getDescribe().fields.getMap();
             List<String> fields = new List<String>(fieldMap.keySet());
 
             List<UBO__c> uboList = Database.query('SELECT ' + String.join(fields, ',') + ', recordType.developerName FROM UBO__c ORDER BY firstName__c');
             System.assertEquals(4, uboList.size(), 'Must get 4 UBOs'); 
             for(UBO__c ubo : uboList) {
                System.debug('#### UBO  ' + ubo);
                if(ubo.Record_Type_Name__c == 'PM') {
                    System.assertEquals(10, uboList[0].sharesCount__c);
                    System.assertEquals(50.00, uboList[0].share__c);
                    System.assertEquals('PM', uboList[0].RecordType.developerName);
                    System.assertEquals('MF SERVICES', uboList[0].denomination__c);
                    System.assertEquals(null, uboList[0].legalCategoryLabel__c);
                    System.assertEquals(null, uboList[0].siren__c);
                    System.assertEquals(null, uboList[0].StreetName__c);
                    System.assertEquals(null, uboList[0].additionalAddress__c);
                    System.assertEquals(null, uboList[0].zipCode__c);
                    System.assertEquals(null, uboList[0].cityName__c);
                    System.assertEquals('INVALIDABLE', uboList[0].Statut__c);
                } else if(ubo.Record_Type_Name__c == 'PP') {
                    if(ubo.birthName__c == 'SOLTAN') {
                        System.assertEquals(Date.valueOf('1968-03-28 00:00:00'), ubo.birthDate__c);
                    } else if(ubo.birthName__c == 'TAYEBI') {
                        System.assertEquals(Date.valueOf('1965-01-07 00:00:00'), ubo.birthDate__c);
                    } else if(ubo.birthName__c == 'TAYEBI2') {
                        System.assertEquals(null, ubo.birthDate__c);
                    } else {
                        System.assert(false, ' UBO unconnu !!');
                    }
                } else {
                    System.assert(false, ' Record type inconnu !!' );
                }
            }
        }      
    }


    @isTest
    static void UBO_Extraction_test() {
        Test.startTest();
        UBO_HYSO_Mock mock = new UBO_HYSO_Mock();
        mock.setBody(Response_test());
        Test.setMock(HttpCalloutMock.class, mock);
    
        User BD = [SELECT id FROM User WHERE userName='usersgdbf@testclasssgdbf.com'];
        System.runAs(BD) {
            Account acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c FROM Account];
            // Onboarding 
            acc.Compte_Nouvelles_Offres__c = true;
            acc.Statut_activation__c = 'Pro_actif_positionnable';
            update acc;
            Test.stopTest();

            acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c, Tech_extract_UBO__c, nbr_ubo__c, statut_ubo__c  FROM Account];
            System.assertEquals('200', acc.Tech_extract_UBO__c); 
            System.assertEquals('TO_COMPLETE', acc.Statut_UBO__c); 
            //System.assertEquals(2, acc.nbr_ubo__c); 

            // Check UBOs
            Map<String, Schema.SObjectField> fieldMap = UBO__c.sObjectType.getDescribe().fields.getMap();
            List<String> fields = new List<String>(fieldMap.keySet());

            List<UBO__c> uboList = Database.query('SELECT ' + String.join(fields, ',') + ', recordType.developerName FROM UBO__c ORDER BY firstName__c');
            System.assertEquals(3, uboList.size(), 'Must get 3 UBOs'); 
        
            System.assertEquals(50.0, uboList[0].sharesCount__c);
            System.assertEquals(50, uboList[0].share__c);
            System.assertEquals('PM', uboList[0].RecordType.developerName);
            System.assertEquals('ASSOCIEPM', uboList[0].denomination__c);
            System.assertEquals('SARLh', uboList[0].legalCategoryLabel__c);
            System.assertEquals(998998998, uboList[0].siren__c);
            System.assertEquals('70 RUE DE LA VISITATION', uboList[0].StreetName__c);
            System.assertEquals(null, uboList[0].additionalAddress__c);
            System.assertEquals('95000', uboList[0].zipCode__c);
            System.assertEquals('PONTOISEY', uboList[0].cityName__c);
            System.assertEquals('INVALIDABLE', uboList[0].Statut__c);
            
            System.assertEquals(25.0, uboList[1].sharesCount__c);
            System.assertEquals(25, uboList[1].share__c);
            System.assertEquals('PP', uboList[1].RecordType.developerName);
            System.assertEquals('Mme', uboList[1].title__c);
            System.assertEquals('ASSOCIEEPP', uboList[1].lastName__c);
            System.assertEquals('ASSOCIEEPP', uboList[1].birthName__c);
            System.assertEquals('ANNIE', uboList[1].firstName__c);
            System.assertEquals(Date.valueOf('1972-12-11 00:00:00'), uboList[1].birthDate__c);
            System.assertEquals('RENNES(FRANCE)', uboList[1].birthCityName__c);
            System.assertEquals('MISSING', uboList[1].Statut__c);

            System.assertEquals(25.0, uboList[2].sharesCount__c);
            System.assertEquals(25, uboList[2].share__c);
            System.assertEquals('PP', uboList[2].RecordType.developerName);
            System.assertEquals('M.', uboList[2].title__c);
            System.assertEquals('ASSOCIEPP', uboList[2].lastName__c);
            System.assertEquals('ASSOCIEPP', uboList[2].birthName__c);
            System.assertEquals('FABRICE', uboList[2].firstName__c);
            System.assertEquals(Date.valueOf('1978-10-27 00:00:00'), uboList[2].birthDate__c);
            System.assertEquals('MONTMORENCY(FRANCE)', uboList[2].birthCityName__c);
            System.assertEquals('MISSING', uboList[2].Statut__c);
        }
    }

    @isTest
    static void UBO_Validation_test() {

        Test.startTest();
        UBO_HYSO_Mock mock = new UBO_HYSO_Mock();
        mock.setBody(Response_test());
        Test.setMock(HttpCalloutMock.class, mock);
    
        User BD = [SELECT id FROM User WHERE userName='usersgdbf@testclasssgdbf.com'];
        Account acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c FROM Account];
        System.runAs(BD) {
            // Onboarding 
            acc.Compte_Nouvelles_Offres__c = true;
            acc.Statut_activation__c = 'Pro_actif_positionnable';
            update acc;
            Test.stopTest();

            Map<String, Schema.SObjectField> fieldMap = UBO__c.sObjectType.getDescribe().fields.getMap();
            List<String> fields = new List<String>(fieldMap.keySet());
            List<UBO__c> uboList = Database.query('SELECT ' + String.join(fields, ',') + ', recordType.developerName FROM UBO__c ORDER BY firstName__c');
            System.assertEquals(3, uboList.size(), 'Must get 3 UBOs'); 

            uboList[1].Statut__c = 'COMPLETED';
            update uboList[1];
            
            String exceptMsg = '';
            try {
                uboList[1].Statut__c = 'VALIDABLE';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('L\'UBO doit avoir un document pièce d\'identité et un document justificatif de domicile au statut \'Validé\' ou \'A valider Hipay\'',
                                exceptMsg);

            Document__c idDoc = new Document__c(UBO__c = uboList[1].id, Type_de_document__c = 'id', idDocument__c='EZEZEZAEZA1212Z21',
                                    Statut__c=[SELECT id FROM reference__c Where key__c='NEW'].id);
            insert idDoc;
            Document__c adDoc = new Document__c(UBO__c = uboList[1].id, Type_de_document__c = 'address_proof', idDocument__c='EZEZEZ1212Z21',
                                    Statut__c=[SELECT id FROM reference__c Where key__c='NEW'].id);
            insert adDoc;

            exceptMsg = '';
            try {
                Document__c dupDoc = new Document__c(UBO__c = uboList[1].id, Type_de_document__c = 'id', idDocument__c='EZEZEZAEZA1212Z21',
                                                    Statut__c=[SELECT id FROM reference__c Where key__c='NEW'].id);
                insert dupDoc;
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('Un document du même type existe deja pour l\'ubo', exceptMsg);

            exceptMsg = '';
            try {
                uboList[1].Statut__c = 'VALIDABLE';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('L\'UBO doit avoir un document justificatif de domicile au statut \'Validé\' ou \'A valider Hipay\'',
                                exceptMsg);

            adDoc.Statut__c = [SELECT id FROM reference__c Where key__c='VALIDABLE'].id;
            update adDoc;
            
            exceptMsg = '';
            try {
                uboList[1].Statut__c = 'VALIDABLE';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('L\'UBO doit avoir un document pièce d\'identité au statut \'Validé\' ou \'A valider Hipay\'',
                                exceptMsg);
            idDoc.Date_de_validite__c = System.today();
            idDoc.Statut__c = [SELECT id FROM reference__c Where key__c='VALIDABLE'].id;
            update idDoc;

            exceptMsg = '';
            try {
                uboList[1].Statut__c = 'VALIDABLE';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('Merci de remplir tous les champs obligatoire a la validation Hipay, il faut passer par le bouton \'Completer l\'UBO\'', exceptMsg);
          
            uboList[1].StreetName__c = 'rue droite';
            uboList[1].zipCode__c = '45675';
            uboList[1].position__c = 'Other';
            uboList[1].cityName__c = 'city';
            uboList[1].nationality__c = 'FR';
            uboList[1].id_number__c  = 'DEF4344343';
            uboList[1].country_of_birth__c = 'FR';

            exceptMsg = '';
            try {
                uboList[1].Statut__c = 'VALIDABLE';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('Merci de remplir tous les champs obligatoire a la validation Hipay, il faut passer par le bouton \'Completer l\'UBO\'', exceptMsg);
      
            uboList[1].position_detail__c = 'Aucun';
            uboList[1].Statut__c = 'VALIDABLE';
            update uboList[1];
            
            exceptMsg = '';
            try {
                uboList[1].lastName__c = 'MIDIF NAME';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('Les UBOs envoyé pour validation Hipay ne sont pas modifiables, Merci de contacter votre administrateur système', exceptMsg);
        }

        Map<String, Schema.SObjectField> fieldMap = UBO__c.sObjectType.getDescribe().fields.getMap();
        List<String> fields = new List<String>(fieldMap.keySet());
        List<UBO__c> uboList = Database.query('SELECT ' + String.join(fields, ',') + ', recordType.developerName FROM UBO__c ORDER BY firstName__c');
        try {
            uboList[1].Statut__c = 'VALIDATED';
            update uboList[1];
        } catch (DmlException e) {
            System.assertEquals('Exception thrown must not', e.getDmlMessage(0));
        }

        System.runAs(BD) {
            uboList = Database.query('SELECT ' + String.join(fields, ',') + ', recordType.developerName FROM UBO__c ORDER BY firstName__c');
            System.assertEquals('VALIDATED', uboList[1].Statut__c);

            String exceptMsg = '';
            try {
                uboList[1].lastName__c = 'MIDIF NAME';
                update uboList[1];
            } catch (DmlException e) {
                exceptMsg = e.getDmlMessage(0);
            }
            System.assertEquals('Les UBOs envoyé pour validation Hipay ne sont pas modifiables, Merci de contacter votre administrateur système', exceptMsg);
        }
    }

    @isTest
    static void UBO_EI_EIRL_test() {
        
        Test.startTest();

        ID EI_RT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Statut_juridique'].Id;
        Reference__c ref = new Reference__c(RecordTypeId = EI_RT, Name = 'EI', key__c = 'EI', Libelle__c = 'EI');
        insert(ref);
        User BD = [SELECT id FROM User WHERE userName='usersgdbf@testclasssgdbf.com'];
        Account acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c, statut_ubo__c, nbr_ubo__c FROM Account];
        System.runAs(BD) {
            // Onboarding 
            System.assertEquals(true, acc.statut_ubo__c==null || acc.Statut_Ubo__c == 'MISSING');
            System.assertEquals(null, acc.nbr_ubo__c);

            acc.Statut_Juridique__c = ref.id;
            acc.Compte_Nouvelles_Offres__c = true;
            acc.Statut_activation__c = 'Pro_actif_positionnable';
            update acc;

            acc = [SELECT id, Compte_Nouvelles_Offres__c, Statut_activation__c, statut_ubo__c, nbr_ubo__c FROM Account];
            System.assertEquals('VALIDABLE', acc.statut_ubo__c);
            System.assertEquals(0, acc.nbr_ubo__c);

            Test.stopTest();
        }
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
        compte.Statut_activation__c = '';
        compte.Login__c = 'mail1@testorg.com';
        compte.Code_client__c = '1111';
        compte.profile_id__c  = '1111';
		insert compte;
		
        Contact ctcPrincipal = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
										   email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = compte.id);
		
		List<Reference__c> refs = new List<Reference__c>();
        refs.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
		refs.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
		refs.add(TestFactory.createReference('StatutDocument', 'A valider','VALIDABLE','A valider'));
        refs.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));
        refs.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        refs.add(TestFactory.createReference('StatutDocument', 'Refusé','REFUSED','Refusé'));
        refs.add(TestFactory.createReference('StatutDocument', 'Doublon','DUPLICATED','Doublon'));
		insert refs;
		 
		// Create KYB Documents:
		id newDoc = [SELECT id FROM Reference__c WHERE Key__c ='NEW'].id;
		List<Document__c> docList = new List<Document__c>();
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'id',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'address_proof',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		insert docList;

		// user itcs
		Profile BD = TestFactory.getProfilByName('Service Commercial ITCS');
        User userBD = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=BD.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
		insert userBD;
	
		// user HK
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User HKConnectUser = new User(  Alias = 'HKC', Email='HKConnectTest@testorg.com', 
										EmailEncodingKey='UTF-8', LastName='Place', FirstName ='Connect' ,languageLocaleKey='en_US', 
										LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',
										TimeZoneSidKey='America/Los_Angeles', UserName='HKConnectTest@testorg.com');
		insert HKConnectuser;
    }
    
    private static String Response_test(){
        return '{' +
        ' "siren": "999999999",' +
        ' "beneficialOwners": [' + 
            '{' + 
             ' "person": {' + 
                    ' "type": "PM",' + 
                    ' "denomination": "ASSOCIEPM",' + 
                    ' "legalCategoryLabel": "SARLh",' + 
                    ' "siren": "998998998",' + 
                    ' "address": {' + 
                        ' "streetName": "70 RUE DE LA VISITATION",' + 
                        ' "additionalAddress": "",' + 
                        ' "postalCode": "95000",' + 
                        ' "cityName": "PONTOISEY"' + 
                    '}' + 
                '},' + 
                ' "sharesCount": 50,' + 
                ' "sharesPercentage": 50.0' + 
            '},' + 
            '{' + 
                ' "person": {' + 
                    ' "type": "PP",' + 
                    ' "civility": "M.",' + 
                    ' "lastName": "ASSOCIEPP",' + 
                    ' "birthName": "ASSOCIEPP",' + 
                    ' "firstName": "FABRICE",' + 
                    ' "birthdate": [' + 
                        '1978,' + 
                        '10,' + 
                        '27' + 
                    '],' + 
                    ' "birthCityName": "MONTMORENCY(FRANCE)"' + 
                '},' + 
                ' "sharesCount": 25,' + 
                ' "sharesPercentage": 25.0' + 
            '},' + 
            '{' + 
                ' "person": {' + 
                    ' "type": "PP",' + 
                    ' "civility": "Mme",' + 
                    ' "lastName": "ASSOCIEEPP",' + 
                    ' "birthName": "ASSOCIEEPP",' + 
                    ' "firstName": "ANNIE",' + 
                    ' "birthdate": [' + 
                        '1972,' + 
                        '12,' + 
                        '11' + 
                    '],' + 
                    ' "birthCityName": "RENNES(FRANCE)"' + 
                '},' + 
                ' "sharesCount": 25,' + 
                ' "sharesPercentage": 25.0' + 
            '}' + 
        '],' + 
        ' "potentialUBOs": [' + 
            '{' + 
                ' "person": {' +
                    ' "type": "PP",' +
                    ' "civility": "M.",' +
                    ' "lastName": "ASSOCIEPP",' +
                    ' "birthName": "ASSOCIEPP",' + 
                    ' "firstName": "FABRICE",' +
                    ' "birthdate": [' + 
                        '1978,' + 
                        '10,' + 
                        '27' + 
                    '],' + 
                    ' "birthCityName": "MONTMORENCY(FRANCE)"' +
                '},' + 
                ' "sharesCount": 25,' + 
                ' "sharesPercentage": 25.0' +
            '},' +
            '{' +
                ' "person": {' +
                    ' "type": "PP",' +
                    ' "civility": "Mme",' +
                    ' "lastName": "ASSOCIEEPP",' +
                    ' "birthName": "ASSOCIEEPP",' + 
                    ' "firstName": "ANNIE",' + 
                    ' "birthdate": [' + 
                        '1972,' + 
                        '12,' + 
                        '11' + 
                    '],' + 
                    ' "birthCityName": "RENNES(FRANCE)"' + 
                '},' +
                ' "sharesCount": 25,' + 
                ' "sharesPercentage": 25.0' + 
            '}' + 
        ']' + 
    '}';
    }

    private static String real_response() {
        return '{ "siren": "753105139", "beneficialOwners": ['+
            '{ "person": {' + 
                  ' "type": "PM",'+
                  ' "denomination": "MF SERVICES",'+
                  ' "civility": null,'+
                  ' "lastName": null,'+
                  ' "birthName": null,'+
                  ' "firstName": null,'+
                  ' "legalCategoryLabel": null,'+
                  ' "Siren": "",'+
                  ' "address": {'+
                     ' "streetName": null,'+
                     ' "additionalAddress": "",'+
                     ' "postalCode": null,'+
                     ' "cityName": null,'+
                     ' "Cedex": null,'+
                     ' "Pays": null,'+
                     ' "AdresseSuite": null'+
                  '},'+
                  ' "DateNaissance": null,'+
                  ' "DateNaissanceISO": null,'+
                  ' "VilleNaissance": null,'+
                  ' "CodeInseeNaissance": null'+
               '},'+
               ' "sharesCount":10,'+
               ' "sharesPercentage":50.00'+
            '},'+
            '{'+
               ' "person":{' +
                 ' "type": "PP",'+
                  ' "civility": "Mme",'+
                  ' "lastName": "GHERAB",'+
                 ' "birthName": "SOLTAN",'+
                 ' "firstName": "Nassima",'+
                 ' "birthdate": [1968,3,28],'+
                 ' "birthCityName": "EL HARRACH (ALGERIE)"'+
               '},'+
               ' "sharesCount": 1,'+
               ' "sharesPercentage": 5.00'+
            '},'+
            '{'+
               ' "person":{'+
                  ' "type": "PP",'+
                  ' "civility": "Mme",'+
                  ' "lastName": "HEDROUG",'+
                  ' "birthName": "TAYEBI",'+
                  ' "firstName": "SAKINA Taous",'+
                  ' "birthdate": [1965,1,7],'+
                  ' "birthCityName": "ALGER (ALGERIE)"'+
              ' },'+
              ' "sharesCount": 9,'+
              ' "sharesPercentage": 45.00'+
            '},'+
            '{'+
               ' "person":{'+
                  ' "type": "PP",'+
                  ' "civility": "Mme",'+
                  ' "lastName": "HEDROUG2",'+
                  ' "birthName": "TAYEBI2",'+
                  ' "firstName": "SAKINA 22 Taous",'+
                  ' "birthdate": null,'+
                  ' "birthCityName": "ALGER (ALGERIE)"'+
              ' },'+
              ' "sharesCount": 9,'+
              ' "sharesPercentage": 45.00'+
            '}'+
         ']'+
        '}';
    }
}