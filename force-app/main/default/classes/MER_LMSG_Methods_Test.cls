/**
 * @File Name          : MER_LMSG_Methods_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 08-19-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/22/2020   Hassan Dakhcha     Initial Version
**/
@isTest
public with sharing class MER_LMSG_Methods_Test {

    @isTest
    static void updateMER_Counter_On_Projects() {

        Account pro = [SELECT id FROM ACCOUNT WHERE isPersonAccount=false LIMIT 1]; 
        Projet_LMSG__c projet = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c];

        Test.startTest();
        User HK = [SELECT id FROM User WHERE FederationIdentifier='123442567890' LIMIT 1];
        System.runAs(HK) {
            System.assertEquals(0, projet.Nombre_de_MER__c, 'Nombre de mer not null !' );

            // Insert unitaire :
            insert new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id);
            
            projet = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c];
            System.assertEquals(1, projet.Nombre_de_MER__c, 'Nombre de mer doit etre 1' );

            // delete unitaire :
            delete [SELECT id FROM Mise_En_Relation__c];
            projet = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c];
            System.assertEquals(0, projet.Nombre_de_MER__c, 'Nombre de mer doit etre 0' );

            insert new Projet_LMSG__c ( Chiffrage_bsku__c = 'B1001',
                                        Chiffrage_maximum__c = 38500,
                                        Date_de_debut_de_chantier__c = system.today() + 10,
                                        Date_de_fin_de_chantier__c = system.today() + 35,
                                        Particulier__c = [SELECT id FROM ACCOUNT WHERE isPersonAccount=true LIMIT 1].id,
                                        Statut__c = 'DRAFT');
            List<Projet_LMSG__c> projetList = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c];

            // insert en masse
            List<Mise_en_relation__c> merList = new List<Mise_en_relation__c>();
            for(Integer i = 0; i<40; i++) {
                merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = i<20? projetList[0].id : projetList[1].id));
            }
            System.debug('#### HDAK Inserting num MER  = '+ merList.size());

            insert merList;

            projetList = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c];
            System.assertEquals(20, projetList[0].Nombre_de_MER__c, 'Nombre de mer doit etre 20' );
            System.assertEquals(20, projetList[1].Nombre_de_MER__c, 'Nombre de mer doit etre 20' );

            merList = [SELECT id, Projet_LMSG__c FROM Mise_En_Relation__c];
            // delete some 
            List<Mise_en_relation__c> deleteMer1 = new List<Mise_en_relation__c> (); 
            List<Mise_en_relation__c> deleteMer2 = new List<Mise_en_relation__c> ();
            for(Integer idx = 0; idx<merList.size(); idx++ ) {
                if((merList[idx].Projet_LMSG__c == projetList[0].id) && deleteMer1.size()<10) // delete 10 MER
                    deleteMer1.add(merList[idx]); 
                if((merList[idx].Projet_LMSG__c == projetList[1].id) && deleteMer2.size()<6) // Delete 6 MER
                    deleteMer2.add(merList[idx]);
            }
            deleteMer1.addAll(deleteMer2);
            delete deleteMer1;

            projetList = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c];
            System.assertEquals(10, projetList[0].Nombre_de_MER__c, 'Nombre de mer doit etre 10' );
            System.assertEquals(14, projetList[1].Nombre_de_MER__c, 'Nombre de mer doit etre 14' );
        }
      
        Test.stopTest();
    }

    @isTest
    static void update_Nombre_MER_restantes() {
 
        Account pro = [SELECT id FROM ACCOUNT WHERE isPersonAccount=false LIMIT 1]; 
        Projet_LMSG__c projet = [SELECT id, Statut__c, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];

        Test.startTest();
        User HK = [SELECT id FROM User WHERE FederationIdentifier='123442567890' LIMIT 1];
        System.runAs(HK) {
            System.assertEquals(3, projet.Nombre_de_MER_restantes__c, 'Nombre de mer restantes par defaut a 3 !' );
            projet.Statut__c = 'PUBLISHED';
            update projet;
            projet = [SELECT id, Statut__c, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(3, projet.Nombre_de_MER_restantes__c, 'Nombre de mer restantes si projet publié est a 3 !' );

            // Insert unitaire :
            insert new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_positionne');
            
            projet = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(2, projet.Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 2' );

            // delete unitaire :
            delete [SELECT id FROM Mise_En_Relation__c];
            projet = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(3, projet.Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 3' );

            Projet_LMSG__c project2 = new Projet_LMSG__c (  Chiffrage_bsku__c = 'B1001',
                                                            Chiffrage_maximum__c = 38500,
                                                            Date_de_debut_de_chantier__c = system.today() + 10,
                                                            Date_de_fin_de_chantier__c = system.today() + 35,
                                                            Particulier__c = [SELECT id FROM ACCOUNT WHERE isPersonAccount=true LIMIT 1].id,
                                                            Statut__c = 'DRAFT');
            insert project2;
            project2.statut__c = 'PUBLISHED';
            update project2;

            // Abandonne_par_Part  Annulee_par_Pro  Pro_non_selectionne  Pro_positionne
             // Pro_rencontre  Pro_selectionne  Refusee_par_Part  Suivi_des_travaux

            Mise_En_Relation__c mer1 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_positionne');
            insert mer1;
            Mise_En_Relation__c mer2 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_selectionne');
            insert mer2;
            Mise_En_Relation__c mer3 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_positionne');
            insert mer3;
            Mise_En_Relation__c mer4 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_selectionne');
            insert mer4;
            Mise_En_Relation__c mer5 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_positionne');
            insert mer5;
            Mise_En_Relation__c mer6 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_selectionne');
            insert mer6;

            List<Projet_LMSG__c> projetList = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(0, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 0' );
            System.assertEquals(0, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 0' );

            mer1.Statut__c = 'Refusee_par_Part';
            update mer1;

            projetList = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(1, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 1' );
            System.assertEquals(0, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 0' );

            mer4.statut__c = 'Pro_rencontre';
            update mer4;
            projetList = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(1, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 1' );
            System.assertEquals(1, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 1' );
         
            mer6.Statut__c = 'Suivi_des_travaux';
            update mer6;
            Mise_En_Relation__c mer7 = new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_positionne');
            insert mer7;

            projetList = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(0, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 0' );
            System.assertEquals(2, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 2' );

            //Mass delete
            delete [SELECT id FROM Mise_En_Relation__c];
            projetList = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(3, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 3' );
            System.assertEquals(3, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 3' );

            List<Mise_en_relation__c> merList = new List<Mise_En_Relation__c>();
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_positionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_selectionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_positionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = projet.id, Statut__c='Pro_selectionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_positionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_selectionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_positionne'));
            merList.add(new Mise_En_Relation__c(Compte_Pro__c = pro.id, Projet_LMSG__c = project2.id, Statut__c='Pro_positionne'));
            insert(merList);

            projetList = [SELECT id, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(0, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 0' );
            System.assertEquals(0, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 0' );

            for(Mise_en_relation__c mer : merList) {
                mer.Statut__c = 'Refusee_par_Part';
            }
            update(merList);

            projetList = [SELECT id, Statut__c, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(3, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 3' );
            System.assertEquals(3, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes doit etre 3' );

            projetList[0].Statut__c = 'FINISHED';
            projetList[1].Statut__c = 'SIGNED';
            update projetList;
            
            projetList = [SELECT id, Statut__c, Nombre_de_MER_restantes__c FROM Projet_LMSG__c];
            System.assertEquals(0, projetList[0].Nombre_de_MER_restantes__c, 'Nombre de mer restantes sur projet non publié = 0' );
            System.assertEquals(0, projetList[1].Nombre_de_MER_restantes__c, 'Nombre de mer restantes sur projet non  publié = 0' );


        }
      
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
        AccountTeamMember accMem = [SELECT id, AccountId, TeamMemberRole, userId FROM AccountTeamMember WHERE AccountId =:PRO.id];
       
        Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail2@testorg.com', PersonMobilePhone='+33623232323' );
        insert PART;

        insert new Projet_LMSG__c ( Chiffrage_bsku__c = 'B1001',
                                    Chiffrage_maximum__c = 38500,
                                    Date_de_debut_de_chantier__c = system.today() + 10,
                                    Date_de_fin_de_chantier__c = system.today() + 35,
                                    Particulier__c = PART.id,
                                     Statut__c = 'DRAFT');

        Profile admin = TestFactory.getProfilByName('Administrateur système');
        User userHK = new User( Alias='myAlias', Email='PlaceProject@testclasssgdbf.com', EmailEncodingKey='UTF-8', FirstName= 'Project', LastName='Place',
                                LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='HKProject@testclasssgdbf.com',
                                ProfileId=admin.Id, FederationIdentifier='123442567890', Title = 'TC Service Client PRO');
        insert userHK;
   }

    static Account createAccount(String email, String codeClient, String profileId, String Name, String Siret) {
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