/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-15-2020   Hassan Dakhcha   Initial Version
**/
@isTest
private class emailReseauMethods_Test {
    @isTest
    private static void AjouterContactAgence_Test() {

        Test.startTest();
        Profile CRC = TestFactory.getProfilByName('Service Commercial ITCS');
        User nonBDAgence = new User( Alias='myAlias', Email='sf.tmptest+testBDOwner@gmail.com', EmailEncodingKey='UTF-8', LastName='CRC',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='sf.tmptest+testBDOwner@gmail.com',ProfileId=CRC.Id,
                                FederationIdentifier='123456337890', Title = 'TC Service Client PRO');
        insert nonBDAgence;

        List<Agence_Contact_Join_Table__c> jointure = [SELECT ID, contact__c, Envoi_email_active__c, Agence_pilote__c FROM Agence_Contact_Join_Table__c];
        System.assertEquals(true, jointure.isEmpty());
        Reference__c ag = [SELECT ID, OwnerID FROM Reference__c WHERE key__c='3835'];
        Id agence = ag.Id;
        String sentList = 'PRO_SELECTED'; // PROJECT_SIGNED ALL

        List<String> args = new List<String>();
        emailReseauMethods.emailReseauMethods(args);
        args.add('');
        emailReseauMethods.emailReseauMethods(args);

        jointure = [SELECT ID, contact__c, Envoi_email_active__c, Agence_pilote__c FROM Agence_Contact_Join_Table__c];
        System.assertEquals(true, jointure.isEmpty());

        args.clear();
        args.add(agence + ';' + sentList + ';testmail1@mail.com');
        System.runAs(nonBDAgence) {
            try {
                emailReseauMethods.emailReseauMethods(args);
            } catch (DmlException e) {
				System.assertEquals('Seulement le BD de l\'agence ou son Manager peuvent créer/modifier/supprimer les contacts de l\'agence',
									e.getDmlMessage(0));
            }

            ag.OwnerId = nonBDAgence.id;
            try {
                update ag;
            } catch (DmlException e) {
				System.assertEquals('Seulement le manager du BD peut modifier le responsable de l\'agence',
									e.getDmlMessage(0));
            }
        }

        emailReseauMethods.emailReseauMethods(args);
        Agence_Contact_Join_Table__c newJointure = [SELECT ID, contact__c, Envoi_email_active__c, contact__r.email, Agence_pilote__c,
                                                    contact__r.Contact_Agence_Pilote__c, contact__r.name, agence_pilote__r.key__c, Liste_d_envoi__c
                                                    FROM Agence_Contact_Join_Table__c];
        System.assertNotEquals(null, newJointure);
        System.assertEquals('testmail1@mail.com', newJointure.Contact__r.email);
        System.assertEquals(true, newJointure.Contact__r.Contact_Agence_Pilote__c);
        System.assertEquals('testmail1@mail.com', newJointure.Contact__r.Name);
        System.assertEquals(true, newJointure.Envoi_email_active__c);
        System.assertEquals('3835', newJointure.agence_pilote__r.key__c);
        System.assertEquals('PRO_SELECTED', newJointure.Liste_d_envoi__c);

        System.runAs(nonBDAgence) {
            try {
                newJointure.Envoi_email_active__c = false;
                update newJointure;
            } catch (DmlException e) {
				System.assertEquals('Seulement le BD de l\'agence ou son Manager peuvent créer/modifier/supprimer les contacts de l\'agence',
									e.getDmlMessage(0));
            }
/*           try {
                delete newJointure;
            } catch (DmlException e) {
				System.assertEquals('Seulement le BD de l\'agence peut créer/modifier/supprimer les contacts de l\'agence',
									e.getDmlMessage(0));
            }  */     
        }

        args[0] = args[0]+';testmail1@mail.com;testmail2@mail.com;testmail3@mail.com;;FAKEMAIL@;FAKEMAIL3.com';
        emailReseauMethods.emailReseauMethods(args);

        jointure = [ SELECT ID, contact__c, Envoi_email_active__c, contact__r.email, Agence_pilote__c,
                     contact__r.Contact_Agence_Pilote__c, contact__r.name, Liste_d_envoi__c
                     FROM Agence_Contact_Join_Table__c];
        List<Contact> ctcList = [SELECT ID, email, Contact_Agence_Pilote__c FROM Contact WHERE Contact_Agence_Pilote__c = true];
        
        System.assertEquals(3, ctcList.size());
        for(Contact ctc : ctcList) {
            System.assertEquals(true, ctc.email.contains('testmail') && ctc.email.contains('@mail.com'));
        }
        
        System.assertEquals(3, jointure.size());
        for(Agence_Contact_Join_Table__c jct : jointure) {
            System.assertEquals(true, jct.Envoi_email_active__c);
            System.assertEquals(agence, jct.agence_pilote__c);
            System.assertEquals(true, jct.contact__r.email.contains('testmail') && jct.contact__r.email.contains('@mail.com'));
        }

        agence = [SELECT ID FROM Reference__c WHERE key__c='1360'].id;
        args[0] = agence + ';' + 'ALL' + ';testmail1@mail.com;testmail2@mail.com;testmail4@mail.com;;;FAKEMAIL@;FAKEMAIL3.com';
        emailReseauMethods.emailReseauMethods(args);

        ctcList = [SELECT ID, email, Contact_Agence_Pilote__c FROM Contact WHERE Contact_Agence_Pilote__c = true];
        System.assertEquals(4, ctcList.size());

        jointure = [ SELECT ID, contact__c, Envoi_email_active__c, contact__r.email, Agence_pilote__c,
                     contact__r.Contact_Agence_Pilote__c, contact__r.name, Liste_d_envoi__c
                     FROM Agence_Contact_Join_Table__c];
        System.assertEquals(6, jointure.size());
        for(Agence_Contact_Join_Table__c jct : jointure) {
            System.assertEquals(true, jct.Envoi_email_active__c);
            System.assertEquals(true, jct.contact__r.email.contains('testmail') && jct.contact__r.email.contains('@mail.com'));
            System.assertEquals(true, newJointure.Liste_d_envoi__c=='ALL' || newJointure.Liste_d_envoi__c=='PRO_SELECTED');
        }              

        agence = [SELECT ID FROM Reference__c WHERE key__c='8013'].id;
        args[0] = agence + ';' + 'PROJECT_SIGNED' + '; testmail1@mail.com;testmail2@mail.com';
        emailReseauMethods.emailReseauMethods(args);

        ctcList = [SELECT ID, email, Contact_Agence_Pilote__c FROM Contact WHERE Contact_Agence_Pilote__c = true];
        System.assertEquals(4, ctcList.size());

        jointure = [ SELECT ID, contact__c, Envoi_email_active__c, contact__r.email, Agence_pilote__c,
                     contact__r.Contact_Agence_Pilote__c, contact__r.name, Liste_d_envoi__c
                     FROM Agence_Contact_Join_Table__c];
        System.assertEquals(8, jointure.size());

        // TODO Test remove jonctions

        Test.stopTest();
    }

    @isTest
    private static void CommDevisSingne_Test() {

        Test.startTest();
        Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id ,
                                                            Projet_LMSG__c = [SELECT id FROM Projet_LMSG__c].id);
        insert MER;

        Devis_LMSG__c quote = new Devis_LMSG__c(Date_demarrage_chantier_theorique__c = system.today() + 10,
                                                Date_emission_du_devis__c = system.today(),
                                                Description__c = 'Devis tres raisonable',
                                                Mise_en_relation_LMSG__c = MER.id,
                                                Montant_HT__c = 500,
                                                Montant_TTC__c = 550,
                                                Statut__c = 'PENDING', 
                                                Pourcentage_accompte__c = 25);
        insert quote;

        quote.Statut__c = 'SIGNED';
        update quote;
        list<EmailMessage>  mails = [select id, subject,  CreatedDate, IsOpened, LastOpenedDate, FirstOpenedDate from EmailMessage];
        system.assertEquals(0, mails.size());

        Id agence = [SELECT ID FROM Reference__c WHERE key__c='3835'].id;
        String sentList = 'PROJECT_SIGNED'; // PROJECT_SIGNED ALL

        List<String> args = new List<String>();
        args.add(agence + ';' + sentList + ';sf.tmptest+Agence@gmail.com');
        emailReseauMethods.emailReseauMethods(args);

        args.clear();
        args.add(agence + ';' + 'CC_PROJECT_SIGNED' + ';sf.tmptest+CopyProject@gmail.com');
        emailReseauMethods.emailReseauMethods(args);

        quote.Statut__c = 'PENDING';
        update quote;

        quote.Statut__c = 'SIGNED';
        update quote;
        mails = [select id, subject,  CreatedDate, IsOpened, LastOpenedDate, FirstOpenedDate from EmailMessage];
        //system.assertEquals(1, mails.size());

        Test.stopTest();
    }

    @isTest
    private static void CommMerSelectionne_Test() {

        Test.startTest();
        Projet_LMSG__c project = [SELECT id, Chiffrage_maximum__c FROM Projet_LMSG__c];

        Mise_en_relation__c MER = new Mise_en_relation__c( Compte_Pro__c = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id ,
                                                           Projet_LMSG__c = project.id, Statut__c = 'Pro_selectionne');
        insert MER;

        list<EmailMessage>  mails = [select id from EmailMessage];
        system.assertEquals(0, mails.size());

        project.Chiffrage_maximum__c = 4000;
        update project;

        MER.Statut__c = 'Pro_positionne';
        update MER;

        MER.Statut__c = 'Pro_selectionne';
        update MER;

        mails = [select id from EmailMessage];
        system.assertEquals(0, mails.size());

        project.Chiffrage_maximum__c = 5000;
        update project;

        MER.Statut__c = 'Pro_positionne';
        update MER;

        MER.Statut__c = 'Pro_selectionne';
        update MER;

        mails = [select id from EmailMessage];
        system.assertEquals(0, mails.size());

        Id agence = [SELECT ID FROM Reference__c WHERE key__c='3835'].id;
        String sentList = 'PRO_SELECTED';

        List<String> args = new List<String>();
        args.add(agence + ';' + sentList + ';sf.tmptest+Agence@gmail.com');
        emailReseauMethods.emailReseauMethods(args);

        Agence_Contact_Join_Table__c jointList = [SELECT ID, contact__c,Agence_pilote__c FROM Agence_Contact_Join_Table__c ];
        insert new Agence_Contact_Join_Table__c(contact__c = jointList.contact__c,Agence_pilote__c= jointList.Agence_pilote__c, Liste_d_envoi__c='PRO_SELECTED');

        args.clear();
        args.add(agence + ';' + 'ALL' + ';sf.tmptest+All@gmail.com');
        emailReseauMethods.emailReseauMethods(args);

        args.clear();
        args.add(agence + ';' + 'CC_PRO_SELECTED' + ';sf.tmptest+copy@gmail.com');
        emailReseauMethods.emailReseauMethods(args);

        MER.Statut__c = 'Pro_positionne';
        update MER;

        MER.Statut__c = 'Pro_selectionne';
        update MER;

        mails = [select id from EmailMessage];
        //system.assertEquals(1, mails.size());

        Test.stopTest();
    }

    @TestSetup
    static void makeData(){
        List<Reference__c> listReferences = new List<Reference__c>();
        listReferences.add(TestFactory.createReference('Agence', 'PERTUIS POINT P', '3835', 'PERTUIS POINT P'));
        listReferences.add(TestFactory.createReference('Agence', 'COIGNIERES DECOCERAM', '1360', 'COIGNIERES DECOCERAM'));
        listReferences.add(TestFactory.createReference('Agence', 'AGENCE FICTIVE DECOCERAM PDL', '8013', 'AGENCE FICTIVE DECOCERAM PDL'));
        listReferences.add(TestFactory.createReference('pays', 'France','FRA','France'));
        listReferences.add(TestFactory.createReference('CP', '75017','75017','Paris'));
        listReferences.add(TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'));
        listReferences.add(TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'));
        
        Profile CRC = TestFactory.getProfilByName('Service Commercial ITCS');
        User userCRC = new User( Alias='myAlias', Email='sf.tmptest+testRun@gmail.com', EmailEncodingKey='UTF-8', LastName='CRC',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='sf.tmptest+testRun@gmail.com',ProfileId=CRC.Id,
                                FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userCRC;
        System.runAs(userCRC) {
            insert listReferences;
            Account PRO = createAccount('mail1@testorg.com', '1111', '1111', 'PRO', '32212091600208' );
        }

        Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail2@testorg.com',
        PersonMobilePhone='+33623232323', Compte_Nouvelles_Offres__c = true);
        insert PART;
        PART.Statut_activation__c = 'Part_actif';
        update PART;

        insert new Projet_LMSG__c ( Chiffrage_bsku__c = 'B1001',
                                    Chiffrage_maximum__c = 500,
                                    Date_de_debut_de_chantier__c = system.today() + 10,
                                    Date_de_fin_de_chantier__c = system.today() + 35,
                                    Particulier__c = PART.id,
                                    Statut__c = 'DRAFT');

    }

    static Account createAccount(String email, String codeClient, String profileId, String Name, String Siret) {
        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = Name;
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c = [SELECT Name FROM Reference__c WHERE recordType.developerName='Enseigne'].Name;
        compte.Flux_code_Enseigne__c = [SELECT Name, key__c FROM Reference__c WHERE recordType.developerName='Enseigne'].key__c;
        compte.SIRET_texte__c = Siret;
        compte.Code_NAF_APE_societe_declarante__c = [SELECT Name FROM Reference__c WHERE recordType.developerName='NAF_Libelle'].id;
        compte.A_ne_jamais_rappeler__c = false;
        compte.agence_user__c = [SELECT ID FROM Reference__c WHERE key__c='3835'].id;
        compte.Pays_LKP__c = [SELECT Name FROM Reference__c WHERE recordType.developerName='Pays'].id;
        compte.Code_postal__c = [SELECT Name FROM Reference__c WHERE recordType.developerName='CP_Ville' LIMIT 1].id;
        
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