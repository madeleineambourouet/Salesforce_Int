/**
 * @File Name          : Projet_LMSG_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 12-28-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/13/2020   Hassan Dakhcha     Initial Version
**/
@isTest
public class Projet_LMSG_Test {
  
    public static String idLeadCst = '961b17df-bb5f-4518-9770-43818cd12ddb';

    @isTest
    static void testIdLead() {

        Account part = [SELECT id FROM ACCOUNT WHERE isPersonAccount=true LIMIT 1];
        Projet__c projetHY = [SELECT id FROM Projet__c];
        Test.startTest();
  
        Projet_LMSG__c projetLMSG = [SELECT id, idLead__c FROM Projet_LMSG__c];
        System.debug('#### HDAK Devis ' +  projetLMSG);
        System.assertEquals(idLeadCst, projetLMSG.idLead__c, 'idLead n\' a pas été copié dans le projet LMSG' );
        
        projetHY = [SELECT id, Statut_Projet__c, etat__c FROM Projet__c];
        System.debug('#### HDAK Projet ' +  projetHY);
        System.assertEquals('Transformé PP', projetHY.Statut_Projet__c, 'Le statut du projet HY doit etre Transformé PP apres transformation en projet LMSG' );      
        System.assertEquals('ODC close', projetHY.Etat__c, 'L\'etat du projet HY doit etre ODC close apres transformation en projet LMSG' );      

        Test.stopTest();
    }

    @isTest
    static void testAffiliationWS_Success() {
        Test.startTest();
        Projet_LMSG__c project = [SELECT id, idLead__c FROM Projet_LMSG__c LIMIT 1];
        
        String endPointArgs = project.idLead__c; 
		String responseBody =  '{"sfPPProjectId": "' + project.id +'","status": "DRAFT","subStatus": "Differe","reason": "Demande_precoce"}';
        Projet_LMSG_AffiliationWS_Test_Mock mock = new Projet_LMSG_AffiliationWS_Test_Mock(responseBody, endPointArgs, 200, false, true);
        Test.setMock(HttpCalloutMock.class, mock);

        // Success :
        project.Sous_statut__c = 'Differe';
    	project.Statut__c = 'DRAFT';
        project.motif__c = 'Demande_precoce';
        update project;
        Test.stopTest();
        // check the Queue
        List<AsyncApexJob> jobs = [SELECT Id, status, ApexClass.Name, ExtendedStatus  FROM AsyncApexJob WHERE ApexClass.Name ='Projet_LMSG_AffiliationWS'];
        System.assertEquals(3, jobs.size(), 'We must have 3 jobs ');
        for(AsyncApexJob job : jobs)
            System.assertEquals('Completed', job.Status, 'Job must be completed ');  
    }

    @isTest
    static void testAffiliationWS_Error_Control() {

        Test.startTest();
        Projet_LMSG__c project = [SELECT id, idLead__c FROM Projet_LMSG__c WHERE motif__c != 'Autorisation_manquante' LIMIT 1];
    
        String endPointArgs = project.idLead__c; 
        // Lead not found : HttpServiceException:Lead not found with id [idLeadCst]
        String responseBody =  ' {"message":"Fatal failure id [29427662-9cb9-471c-8456-1fe163190983] service [LeadStatus.updateStatusAndSubStatus]' + 
                        ' exception [HttpServiceException:Lead not found with id ['+ idLeadCst +']] translated as [HttpServiceExce';

        Projet_LMSG_AffiliationWS_Test_Mock mock = new Projet_LMSG_AffiliationWS_Test_Mock(responseBody, endPointArgs, 404, false, true);
        Test.setMock(HttpCalloutMock.class, mock);

        project.Sous_statut__c = 'Differe';
    	project.Statut__c = 'DRAFT';
        project.motif__c = 'Autorisation_manquante';
        update project;
        
        Test.stopTest();
        // Exception
        List<Exception_Control__c> exeptList = [select id,Objet__c, ErrorMSG__c,  CreatedDate  from Exception_Control__c where Objet__c='Projet_LMSG__c'];
        for(Exception_Control__c ex : exeptList) {
            if(!ex.ErrorMSG__c.contains('Methods defined as TestMethod do not support Web service callouts'))
                System.assertEquals(true, (ex.ErrorMSG__c).contains('Lead not found with id ['+project.idLead__c+']'), 'Msg must indicate [Lead Not Found]');
        }       
    }

    @isTest
    static void testAffiliationWS_ThrowException() {

        Test.startTest();

        Projet_LMSG__c project = [SELECT id, idLead__c FROM Projet_LMSG__c WHERE motif__c != 'Autorisation_manquante' LIMIT 1];
        String endPointArgs = project.idLead__c; 
		
        // Lead not found : HttpServiceException:Lead not found with id [idLeadCst]
        String responseBody =  ' {"message":"Fatal failure id [29427662-9cb9-471c-8456-1fe163190983] service [LeadStatus.updateStatusAndSubStatus]' + 
                        ' exception [HttpServiceException:Lead not found with id ['+ idLeadCst +']] translated as [HttpServiceExce';
        Projet_LMSG_AffiliationWS_Test_Mock mock = new Projet_LMSG_AffiliationWS_Test_Mock(responseBody, endPointArgs, 404, true, true);
        Test.setMock(HttpCalloutMock.class, mock);

        project.Sous_statut__c = 'Differe';
    	project.Statut__c = 'DRAFT';
        project.motif__c = 'Autorisation_manquante';
        update project;
        
        Test.stopTest();

        List<Exception_Control__c> exeptList = [select id,Objet__c, ErrorMSG__c,  CreatedDate  from Exception_Control__c where Objet__c='Projet_LMSG__c'];
        for(Exception_Control__c ex : exeptList) {
            if(!ex.ErrorMsg__c.contains('Methods defined as TestMethod do not support Web service callouts'))
                System.assertEquals(true, ex.ErrorMsg__c.contains('Test Exception from Partnership!'), 'Test Exception from Partnership!');
        }
            
        List<AsyncApexJob> jobs = [SELECT Id, status, ApexClass.Name, ExtendedStatus  FROM AsyncApexJob WHERE ApexClass.Name ='Projet_LMSG_AffiliationWS'];
        System.assertEquals(3, jobs.size(), 'We must have 3 jobs ');
        for(AsyncApexJob job : jobs)
            System.assertEquals('Completed', job.Status, 'Job must be completed ');  
    }
    
 /*   @isTest
    static void test_MasseUpdate() {
        Account part = [SELECT id FROM ACCOUNT WHERE isPersonAccount=true LIMIT 1];
        Projet__c projetHY = [SELECT id FROM Projet__c];
        
        List<Projet_LMSG__c> NewPrjList = new List<Projet_LMSG__c> ();
        for(Integer i=0; i<10; i++) {
            NewPrjList.add(new Projet_LMSG__c(  Chiffrage_bsku__c = 'B1001',
                                                Chiffrage_maximum__c = 38500,
                                                Date_de_debut_de_chantier__c = system.today() + 10,
                                                Date_de_fin_de_chantier__c = system.today() + 35,
                                                Particulier__c = part.id,
                                                Projet_Parent__c = projetHY.id,
                                                Statut__c = 'DRAFT'));
        }
        insert NewPrjList;

        String endPointArgs = NewPrjList[0].idLead__c; 
		String responseBody =  '{"sfPPProjectId": "' + NewPrjList[0].id +'","status": "DRAFT","subStatus": "Differe","reason": "Demande_precoce"}';
        Projet_LMSG_AffiliationWS_Test_Mock mock = new Projet_LMSG_AffiliationWS_Test_Mock(responseBody, endPointArgs, 200, false, false);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        for(Projet_LMSG__c project : NewPrjList) {
            project.Sous_statut__c = 'Differe';
            project.Statut__c = 'DRAFT';
            project.motif__c = 'Autorisation_manquante';
        }
        //update NewPrjList;

        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, status, ApexClass.Name, ExtendedStatus  FROM AsyncApexJob WHERE ApexClass.Name ='Projet_LMSG_AffiliationWS'];
        //System.assertEquals(2, jobs.size(), 'We must have 2 jobs ');
        System.debug('####  HDAK num jobs ' +  jobs.size());

        for(AsyncApexJob job : jobs) {
            //System.assertEquals('Completed', job.Status, 'Job must be completed ');  
            System.debug('####  HDAK num jobs ' + job.Status);
            System.debug('####  HDAK num jobs ' + job.ExtendedStatus);
        }
    }
*/

    @isTest
    static void GeneratePrestationProjet() {

        Profile admin = TestFactory.getProfilByName('Administrateur système');
        User userHK = new User( Alias='myAlias', Email='herokuConnect@testclasssgdbf.com', EmailEncodingKey='UTF-8', FirstName= 'Project', LastName='Place',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='HKCONNECT@testclasssgdbf.com',ProfileId=admin.Id,
                                FederationIdentifier='123442567890', Title = 'TC Service Client PRO');
        insert userHK;

        Account part = [SELECT id FROM ACCOUNT WHERE isPersonAccount=true LIMIT 1];
        delete [SELECT id FROM Prestation_Projet__c];
        delete [SELECT id FROM Projet_LMSG__c];
        
        Test.startTest();
        System.runAs(userHK) {
            Projet_LMSG__c projet =  new Projet_LMSG__c (   Date_de_debut_de_chantier__c = system.today() + 10,
                                                            Date_de_fin_de_chantier__c = system.today() + 35,
                                                            Particulier__c = part.id,
                                                            Statut__c = 'DRAFT',
                                                            Chiffrage_json__c = '{"package_info":{"id":2035,"code":"PACK_FUNNEL_SIMPLE_ISOLATIONS_MURS","name":"Funnel' +
                                                                            'Isolation des murs par l\'intérieur","BSKU":"B1904"},"summary":{"surface":12,"sections"' +
                                                                            ':[{"code":"CARACTERISTIQUES","label":"Caractéristiques techniques","items":[{"code":"PERFORMANCE"' +
                                                                            ',"label":"Isolation thermique standard","value":true},{"code":"ANCIENNE_ISOLATION_RETIRER","label"'+
                                                                            ':"Isolation à retirer","value":"oui"}]},{"code":"ISOLATION_THERMIQUE","label":"Isolation thermique"'+
                                                                            ',"categories":[{"code":"ISOLATION_INTERIEURE","label":"Isolation intérieure","items":[{"code":"SURFA'+
                                                                            'CE","label":"Surface à isoler","value":"12 m²"}]}]}]},"tva":{"minimum":100,"maximum":120},"total":{"m'+
                                                                            'inimum":1100,"maximum":1400},"postalCode":{"postalCode":"69120","inseeCode":"69256","name":"VAULX EN '+
                                                                            'VELIN"},"parameters":{"surface":"12","performance":{"label":"Standard","legend":"Eligible aux aides '+
                                                                            'financières","name":"FUNNEL_ISOLATIONS_MURS_PERFORMANCE_STANDARD"},"options":[{"label":"Aucune","name":'+
                                                                            '"NB_FUNNEL_ISOLATIONS_MURS_OPTIONS_ISO_AUCUNE","quantity":1}],"peinture":{"name":"no","label":"Non"},'+
                                                                            '"retirer_isolation":{"label":"Je ne sais pas","name":"BOOLEEN_JNSP"},"geographic_question_insee":'+
                                                                            '{"postalCode":"69120","inseeCode":"69256","name":"VAULX EN VELIN"}},"prestations":[{"id_prestation":'+
                                                                            '"P0906","id":1972,"name":"PRESTA : Isolation des murs par l\'intérieur","code":"ELEM_PRESTA_ISO_MURS_'+
                                                                            'PAR_INTERIEUR","total":{"minimum":1110,"maximum":1340}}]}' );

            insert projet;
     
            // Check for prestation projet :
            List<Prestation_Projet__c> pList = [ SELECT id, Projet_LMSG__c FROM Prestation_Projet__c];
            projet = [ SELECT id, Chiffrage_bsku__c, Chiffrage_maximum__c, 
                              Chiffrage_minimum__c, TaroId__c, Code_postal__r.key__c, Besoin_Travaux__c, Besoin_Travaux__r.key__c
                       FROM Projet_LMSG__c WHERE id = :projet.id];

            System.assertEquals(1, pList.size(), 'Une prestation projet doit etre generée' );
            System.assertEquals('B1904', projet.Chiffrage_bsku__c, 'BSKU' );
            System.assertEquals(1400, projet.Chiffrage_maximum__c, 'Chiffrage maximum' );
            System.assertEquals(1100, projet.Chiffrage_minimum__c, 'chiffrage minimum' );
            System.assertEquals(null, projet.TaroId__c, 'taroId doit etre vide' );
            System.assertEquals('69120_69256', projet.Code_postal__r.key__c, 'Code postal insee' );
            System.assertEquals('B1904', projet.Besoin_Travaux__r.key__c, 'clé besoin travaux' );

            projet.Chiffrage_json__c =  '{"package_info":{"id":1985,"code":"PACK_FUNNEL_MAISON","name":"Funnel Maison","BSKU":"B1101"},"summary":{"surface":49,"sections":'+
                                        '[{"code":"PIECES_MAISON","label":"Pièces à rénover","items":[{"code":"BUANDERIE","label":"Buanderie","value":"1"},{"code":"ENTREE'+
                                        '_COULOIR","label":"Entrée - Couloir","value":"1"}]},{"code":"EQUIPEMENT_A_INSTALLER","label":"Équipement à installer","categories'+
                                        '":[{"code":"CUISINE","label":"Cuisine","items":[{"code":"MEUBLE_CUISINE","label":"Meubles de cuisine","value":"Non"},{"code":"MEU'+
                                        'BLE_CUISINE","label":"Meubles de cuisine avec électroménager","value":"Non"}]},{"code":"CHAUFFAGE_VENTILATION","label":"Chauffage'+
                                        'et ventilation","items":[{"code":"SYSTEME_VENTILATION","label":"Système de ventilation","value":"Non"},{"code":"BALLON_EAU_CHAUDE"'+
                                        ',"label":"Ballon d\'eau chaude","value":"1"},{"code":"RADIATEUR_EAU","label":"Radiateur à eau chaude","value":"1"}]}]},{"code":"RAV'+
                                        'ALEMENT_FACADE","label":"Ravalement de façade","items":[{"code":"PEINTURE_EXTERIEURE","label":"Peinture extérieure","value":"3 m²"'+
                                        '},{"code":"BARDAGE","label":"Bardage","value":"1 m²"},{"code":"ENDUIT_CREPI","label":"Enduit / Crépi","value":"2 m²"}]},{"code":"ELE'+
                                        'CTRICITE","label":"Électricité","items":[{"code":"ELECTRICITE_NORME","label":"Mise aux normes de l’électricité","value":"non"}]}]},"'+
                                        'tva":{"minimum":150,"maximum":180},"total":{"minimum":1600,"maximum":2000},"postalCode":{"postalCode":"94500","inseeCode":"94017","n'+
                                        'ame":"CHAMPIGNY SUR MARNE"},"parameters":{"nb_renover_cuisine":"0","s_cuisine":null,"nb_renover_sdb":"0","s_sdb":null,"nb_renover_wc'+
                                        '":"0","s_wc":null,"nb_renover_buanderie":"1","s_buanderie":"44","nb_renover_chambre":"0","s_chbre":null,"nb_renover_salon":"0","s_sa'+
                                        'lon":null,"nb_renover_entree":"1","s_couloir":"5","nb_renover_combles":"0","s_combles":null,"liste_travaux":[{"label":"Ravalement de '+
                                        'façade","name":"NB_FUNNEL_MAISON_TRAVAUX_RAVAL_FACADE","categorie":"rvt","quantity":1},{"label":"Chauffage","name":"NB_FUNNEL_MAISON_'+
                                        'TRAVAUX_CHAUFFAGE","categorie":"ecv","quantity":1}],"equipement_sdb":"","equip_cuisine":"","rvt_cuisine":"","rvt_sdb":"","rvt_wc":"",'+
                                        '"rvt_buanderie":"","rvt_salon":"","rvt_chbre":"","rvt_entree":"","rvt_comble":"","longueur_a_creer_verriere":"0","longueur_a_creer_ve'+
                                        'rriere_muret":"0","longueur_a_creer_cloison":"0","longueur_a_sup_mur":"0","longueur_a_sup_cloison":"0","longueur_a_sup_jnsp":"0","nb_'+
                                        'funnel_maison_type_fenetre_fenetre":"0","nb_funnel_maison_type_fenetre_porte_fenetre":"0","nb_funnel_maison_type_fenetre_baie_vitree"'+
                                        ':"0","nb_funnel_maison_type_fenetre_fenetre_toit":"0","nb_funnel_maison_type_porte_battante":"0","nb_funnel_maison_type_porte_couliss'+
                                        'ante":"0","nb_funnel_maison_type_porte_entree":"0","nb_funnel_maison_type_escalier_droit":"0","nb_funnel_maison_type_escalier_colimac'+
                                        'on":"0","nb_funnel_maison_type_escalier_echelle_meunier":"0","surface_bardage":"01","surface_enduit":"2","surface_peinture":"3","s_mur'+
                                        '_iso_int":"0","s_mur_iso_ext":"0","type_iso_comble":"","nb_funnel_maison_equip_chauffage_chaudiere":"0","nb_funnel_maison_equip_chauff'+
                                        'age_ballon_eau_chaude":"1","nb_funnel_maison_equip_chauffage_radiateur_eau":"1","nb_funnel_maison_equip_chauffage_radiateur_elec":"0",'+
                                        '"geographic_question_insee":{"postalCode":"94500","inseeCode":"94017","name":"CHAMPIGNY SUR MARNE"}},"prestations":[{"id_prestation":"'+
                                        'P0403","id":1953,"name":"PRESTA : Application d\'une peinture extérieure","code":"ELEM_PRESTA_APPLICATION_PEINTURE_EXT","total":{"minim'+
                                        'um":70,"maximum":90}},{"id_prestation":"P1407","id":1983,"name":"PRESTA : Réalisation d\'un enduit de façade","code":"ELEM_PRESTA_REALI'+
                                        'SATION_ENDUIT_FACADE","total":{"minimum":70,"maximum":90}},{"id_prestation":"P1406","id":1982,"name":"PRESTA : Pose d\'un bardage","cod'+
                                        'e":"ELEM_PRESTA_POSE_BARDAGE","total":{"minimum":120,"maximum":150}},{"id_prestation":"P0101","id":1932,"name":"PRESTA :  Installation'+
                                        'd\'un chauffe-eau","code":"ELEM_PRESTA_INSTAL_CHAUFFE_EAU","total":{"minimum":850,"maximum":1000}},{"id_prestation":"P0105","id":1933,"'+
                                        'name":"PRESTA :  Installation d\'un radiateur à eau chaude","code":"ELEM_PRESTA_INSTAL_RADIA_EAU_CHAUDE","total":{"minimum":280,"maximu'+
                                        'm":350}},{"id_prestation":"P0501","id":1954,"name":"PRESTA : Alimentation et évacuation des eaux","code":"ELEM_PRESTA_ALIMENTATION_EVA'+
                                        'CUATION_EAUX","total":{"minimum":240,"maximum":290}}]}';

            update projet;

            pList = [ SELECT id, Projet_LMSG__c FROM Prestation_Projet__c];
            projet = [ SELECT id, Chiffrage_bsku__c, Chiffrage_maximum__c, 
                              Chiffrage_minimum__c, TaroId__c, Code_postal__r.key__c, Besoin_Travaux__c, Besoin_Travaux__r.key__c
                       FROM Projet_LMSG__c WHERE id =:projet.id];
            
            System.assertEquals(6, pList.size(), '6 prestations projet doivent etre generées' );
            System.assertEquals('B1101', projet.Chiffrage_bsku__c, 'BSKU' );
            System.assertEquals(2000, projet.Chiffrage_maximum__c, 'Chiffrage maximum' );
            System.assertEquals(1600, projet.Chiffrage_minimum__c, 'chiffrage minimum' );
            System.assertEquals(null, projet.TaroId__c, 'taroId doit etre vide' );
            System.assertEquals('94500_94017', projet.Code_postal__r.key__c, 'Code postal insee' );
            System.assertEquals('B1101', projet.Besoin_Travaux__r.key__c, 'clé besoin travaux' );
        }      
        Test.stopTest();
    }

    @isTest
    static void affectation_CA_Projet_Qualifie() {
        Projet_LMSG__c newProjet =  new Projet_LMSG__c (    Chiffrage_bsku__c = 'B1001',
                                                            Chiffrage_maximum__c = 38500,
                                                            Date_de_debut_de_chantier__c = system.today() + 10,
                                                            Date_de_fin_de_chantier__c = system.today() + 35,
                                                            Particulier__c = [SELECT id FROM ACCOUNT WHERE isPersonAccount=true LIMIT 1].id,
                                                            Statut__c = 'DRAFT');
        insert newProjet;
      
        Profile CA = TestFactory.getProfilByName('Service Client');
        User userCA = new User( Alias='myAlias2', Email='CA@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='CA@testclasssgdbf.com',ProfileId=CA.Id,
                                FederationIdentifier='1234512367890', Title = 'TC Service Client PRO');
        insert userCA;

        Test.startTest();
        newProjet.Statut__c = 'VALIDATING';
        update newProjet;

        User uCA = [SELECT id, UserName FROM User WHERE UserName='CA@testclasssgdbf.com'];
        Projet_LMSG__c projet = [SELECT id, ownerId, Sous_statut__c FROM Projet_LMSG__c WHERE id = :newProjet.id];

        System.assertNotEquals(projet.ownerId, uCA.id, 'OWNER MUST NOT BE THE BD' );
    
        System.runAs(uCA) {
            projet.Sous_statut__c = 'Qualifie_PP';
            update projet;
        }
        
        projet = [SELECT id, ownerId FROM Projet_LMSG__c WHERE id = :newProjet.id];

        System.assertEquals(projet.ownerId, uCA.id, 'OWNER MUST BE THE BD' );

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

        Projet__c projetHY = new Projet__c(Titre__c = 'projet test',
                                         Particulier__c= PART.Id,
                                         Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                         Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                         Description__c='description test youhou');
        
        insert projetHY;

        insert new Tracking__c ( parentId__c = projetHY.id, idLead__c = idLeadCst);

        insert new Projet_LMSG__c ( Chiffrage_bsku__c = 'B1001',
                                    Chiffrage_maximum__c = 38500,
                                    Date_de_debut_de_chantier__c = system.today() + 10,
                                    Date_de_fin_de_chantier__c = system.today() + 35,
                                    Particulier__c = PART.id,
                                    Projet_Parent__c = projetHY.id,
                                     Statut__c = 'DRAFT');

 
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