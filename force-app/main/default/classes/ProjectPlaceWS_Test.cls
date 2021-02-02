/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 10-15-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-08-2020   Hassan Dakhcha   Initial Version
**/
@isTest
public with sharing class ProjectPlaceWS_Test {

    @isTest
    static void emailChange_PART_NoWbeId() {
        Test.startTest();
        ProjectPlaceWS_Mock mock = new ProjectPlaceWS_Mock();
        mock.setEP('/crc/credentials/email/change');
        mock.setMD('POST');
        mock.setBody('');
        mock.setCode(200);

        Test.setMock(HttpCalloutMock.class, mock);

        // Part    
        Account part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE isPersonAccount = true AND External_ID__c=null];
       
        // No wbe ID
        String returnedValue = ProjectPlaceWS.callProjectPlaceEmailChange(part.Id, 'new_mail_part@testorg.com');
        part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE isPersonAccount = true AND External_ID__c=null];

        System.assertEquals('L\'utilisateur n\'est pas activé nouvelle offre', returnedValue);
        System.assertEquals(null, part.new_email__c);
        System.assertEquals(null, part.email_change_status_code__c);
        Test.stopTest();
    }

    @isTest
    static void emailChange_PART_Success() {
        Test.startTest();
        ProjectPlaceWS_Mock mock = new ProjectPlaceWS_Mock();
        mock.setEP('/crc/credentials/email/change');
        mock.setMD('POST');
        mock.setBody('');
        mock.setCode(200);
        mock.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, mock);

        // Part    
        Account part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c 
                        FROM ACCOUNT WHERE PersonEmail = 'part1234@testorg.com'];
     
        // No wbe ID
        String returnedValue = ProjectPlaceWS.callProjectPlaceEmailChange(part.Id, 'new_mail_part@testorg.com');
        part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE PersonEmail = 'part1234@testorg.com'];

        System.assertEquals('SUCCESS', returnedValue);
        System.assertEquals('new_mail_part@testorg.com', part.new_email__c);
        System.assertEquals('200 OK', part.email_change_status_code__c);

        Test.stopTest();
    }


    @isTest
    static void emailChange_PART_EmailAlreadyUsed() {
        Test.startTest();
        ProjectPlaceWS_Mock mock = new ProjectPlaceWS_Mock();
        mock.setEP('/crc/credentials/email/change');
        mock.setMD('POST');
        Test.setMock(HttpCalloutMock.class, mock);

        // Already know email
        mock.setBody('null');
        mock.setStatus('USERNAME_ALREADY_IN_USE');
        mock.setCode(400);

        Account part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE  PersonEmail = 'part1234@testorg.com'];
        String returnedValue = ProjectPlaceWS.callProjectPlaceEmailChange(part.Id, 'part1234@testorg.com');
        
        part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE  PersonEmail = 'part1234@testorg.com'];

        System.assertEquals('Le nouvel email (part1234@testorg.com) est déja présent dans SF', returnedValue);
        System.assertEquals(null, part.new_email__c);
        System.assertEquals(null, part.email_change_status_code__c);
        Test.stopTest();
    }

    @isTest
    static void emailChange_PART_Completed() {
        Test.startTest();
     
        // Part    
        Account part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE isPersonAccount = true AND External_ID__c=null];
        part.External_ID__c = '36a52226-c5b7-439a-92c8-3292bb34b9e8';
        part.new_email__c = 'new_mail_part@testorg.com';
        part.email_change_status_code__c = '200 OK';
        update part;

        part.PersonEmail = 'new_mail_part@testorg.com';
        update part;

        part = [SELECT id, PersonEmail, new_email__c, email_change_status_code__c, External_ID__c FROM ACCOUNT WHERE id=:part.id];
        System.assertEquals('COMPLETED', part.email_change_status_code__c);
        Test.stopTest();
    }

    @isTest
    static void Check_WS_Call_EmailChange_PRO() {
        Test.startTest();
        ProjectPlaceWS_Mock mock = new ProjectPlaceWS_Mock();
        mock.setEP('/crc/credentials/email/change');
        mock.setMD('POST');
        mock.setBody('');
        mock.setCode(200);
        mock.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, mock);

        // Pro    
        Contact pro = [SELECT id, email__c, new_email__c, email_change_status_code__c, External_Contact_ID__c 
                        FROM Contact WHERE Email__c = 'ctcpro@testorg.com'];
       
        // No wbe ID
        String returnedValue = ProjectPlaceWS.callProjectPlaceEmailChange(pro.Id, 'new_mail_pro@testorg.com');
        pro = [SELECT id, email__c, new_email__c, email_change_status_code__c, External_Contact_ID__c FROM Contact WHERE Email__c = 'ctcpro@testorg.com'];

        System.assertEquals('SUCCESS', returnedValue);
        System.assertEquals('new_mail_pro@testorg.com', pro.new_email__c);
        System.assertEquals('200 OK', pro.email_change_status_code__c);
      

        pro.email__c = 'new_mail_pro@testorg.com';
        update pro;

        pro = [SELECT id, email__c, new_email__c, email_change_status_code__c, External_Contact_ID__c FROM Contact WHERE id=:pro.id];
        System.assertEquals('COMPLETED', pro.email_change_status_code__c);
        Test.stopTest();
    }

    @isTest
    static void Check_WS_Call_Statut_Front_Projet() {
        
        Test.startTest();
        ProjectPlaceWS_Mock mock = new ProjectPlaceWS_Mock();
        mock.setEP('/crc/project-status');
        mock.setMD('GET');
        mock.setBody('RELATIONSHIP_NONE');
        mock.setCode(200);
        mock.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, mock);      

        Projet_LMSG__c project1 = [SELECT id FROM Projet_LMSG__c WHERE Identifiant_PP__c=null];
        
        // No wbe ID
        String returnedValue = ProjectPlaceWS.callProjectPlaceFrontProjectStatus(project1.Id, 'Projet_LMSG__c');
        System.assertEquals('Statut visible par le Part : AUCUN', returnedValue);

        Projet_LMSG__c project2 = [SELECT id FROM Projet_LMSG__c WHERE Identifiant_PP__c!=null];
        returnedValue = ProjectPlaceWS.callProjectPlaceFrontProjectStatus(project2.Id, 'Projet_LMSG__c');
        System.assertEquals('Statut visible par le Part : EN ATTENTE DE PROFESSIONNELS', returnedValue);

        mock.setBody('\"RELATIONSHIP_ACCEPTED\"');
        Mise_en_relation__c mer1 = [SELECT id FROM Mise_en_relation__c WHERE Projet_LMSG__c=:project1.id];

        // No wbe ID
        returnedValue = ProjectPlaceWS.callProjectPlaceFrontProjectStatus(mer1.Id, 'Mise_en_relation__c');
        System.assertEquals('Statut visible par le Pro : AUCUN', returnedValue);
 
        Mise_en_relation__c mer2 = [SELECT id FROM Mise_en_relation__c WHERE Projet_LMSG__c=:project2.id];
        returnedValue = ProjectPlaceWS.callProjectPlaceFrontProjectStatus(mer2.Id, 'Mise_en_relation__c');
        System.assertEquals('Statut visible par le Pro : EN ATTENTE DE RDV', returnedValue);

        Test.stopTest();
    }

    @TestSetup
    static void makeData() {
        Profile BD = TestFactory.getProfilByName('Service Commercial ITCS');
        User userBD = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=BD.Id,
                                FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userBD;
        System.assertEquals(false, String.isEmpty(userBD.id), 'User BD created' );

        Account PRO;
        System.runAs(userBD) {
            PRO = createAccount('mail1@testorg.com', '1111', '1111', 'PRO', '32212091600208' );
        }
        
        insert new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116', External_Contact_ID__c = '1231232132132',
                           email = 'ctcpro@testorg.com', AccountId = PRO.id);

        Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail2@testorg.com', PersonMobilePhone='+33623232323' );
        insert PART;

        Account PART2 = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', External_ID__c = 'part_36a52226-c5b7-439a-92c8-3292bb34b9e8',
                                    PersonEmail = 'part1234@testorg.com', PersonMobilePhone='+33623232323' );
        insert PART2;
        
        // Data for statut callout
      
        Projet_LMSG__c project1 = new Projet_LMSG__c(particulier__c = PART.id, Identifiant_PP__c=null, Statut__c = 'VALIDATING');
        insert project1;

        Projet_LMSG__c project2 = new Projet_LMSG__c(particulier__c = PART2.id, Identifiant_PP__c='befef611-4598-4992-a530-f39010b6e9d7', Statut__c='VALIDATING');
        insert project2;

        Mise_en_relation__c mer1 = new Mise_en_relation__c(Projet_LMSG__c = project1.id, Statut__c = 'Pro_positionne' , Compte_Pro__c = PRO.id);
        insert mer1;

        Mise_en_relation__c mer2 = new Mise_en_relation__c(Projet_LMSG__c = project2.id, Statut__c = 'Pro_positionne', Compte_Pro__c = PRO.id );
        insert mer2;

   }

    static Account createAccount(String email, String codeClient, String profileId, String Name, String Siret) {
        List<Reference__c> listReferences = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        reference__c cp2 = TestFactory.createReference('CP', '69120','69120_69256','Paris');
        cp2.Lov_Type__c = 'CP_Ville';
        listReferences.add(cp2);

        reference__c cp3 = TestFactory.createReference('CP', '94500','94500_94017','Paris');
        cp3.Lov_Type__c = 'CP_Ville';
        listReferences.add(cp3);

        recordtype rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Besoins_Travaux'];
        listReferences.add(new Reference__c(recordTypeId = rt.id, key__c='B1101', sku__c = 'B1101'));
        listReferences.add(new Reference__c(recordTypeId = rt.id, key__c = 'B1904', sku__c = 'B1904'));

        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        listReferences.add(CP);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        
        insert listReferences;
        
        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = Name;
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
        compte.Flux_code_Enseigne__c = enseigne.key__c;
        compte.SIRET_texte__c = Siret;
        compte.Code_NAF_APE_societe_declarante__c = NAF.id;
        compte.A_ne_jamais_rappeler__c = false;
        
        compte.Pays_LKP__c = pays.id;
        compte.Code_postal__c = CP.id;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = true;
        compte.Statut_activation__c = 'Nouveau';
        compte.Login__c = email;
        compte.Code_client__c = codeClient;
        compte.profile_id__c  = profileId;
        insert compte;
        return compte;
    }
}