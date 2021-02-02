/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-28-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-19-2020   Hassan Dakhcha   Initial Version
**/
@isTest
public class Notation_LMSG_Methods_Test {
    
	@isTest static void Notation_Pro_rating() {
        // code_block	
        Test.startTest();

        id pro = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id;
        id projet = [SELECT id, particulier__c FROM Projet_LMSG__c].id;
        Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = pro, Projet_LMSG__c = projet);
        insert MER;
     
        User PP = [SELECT id FROM User WHERE Email='ProjectPlace@testclasssgdbf.com' LIMIT 1];
        System.runAs(PP) {
            Notation_LMSG__c rating = new Notation_LMSG__c(Compte_Pro__c = pro, MER__c = MER.id, Projet_LMSG__c = projet,
                                                            Status__c = 'PENDING', 
                                                            rate__c = 3,
                                                            relationships_quality__c = 2 ,
                                                            works_quality__c = 2,
                                                            deadlines_respect__c = 5,
                                                            message__c= 'Pro Moyen, pas toujours fiable');
            insert rating;
            rating = [SELECT id, particulier__c FROM Notation_LMSG__c LIMIT 1];

            System.assertNotEquals(null, rating.Particulier__c);
            System.assertEquals(null, [SELECT id, rating__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].rating__c);

            insert new Notation_LMSG__c(Compte_Pro__c = pro, MER__c = MER.id, Projet_LMSG__c = projet,
                                        Status__c = 'PUBLISHED', 
                                        rate__c = 2,
                                        relationships_quality__c = 2 ,
                                        works_quality__c = 2,
                                        deadlines_respect__c = 5,
                                        message__c= 'Pro Moyen, pas toujours fiable');

            System.assertEquals(2.00, [SELECT id, rating__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].rating__c);

            insert new Notation_LMSG__c(Compte_Pro__c = pro, MER__c = MER.id, Projet_LMSG__c = projet,
                                        Status__c = 'PUBLISHED', 
                                        rate__c = 5,
                                        relationships_quality__c = 2 ,
                                        works_quality__c = 2,
                                        deadlines_respect__c = 5,
                                        message__c= 'Pro Moyen, pas toujours fiable');
           
            System.assertEquals(3.50, [SELECT id, rating__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].rating__c);
            
            insert new Notation_LMSG__c(Compte_Pro__c = pro, MER__c = MER.id, Projet_LMSG__c = projet,
                                        Status__c = 'PUBLISHED', 
                                        rate__c = null,
                                        relationships_quality__c = 2 ,
                                        works_quality__c = 2,
                                        deadlines_respect__c = 5,
                                        message__c= 'Pro Moyen, pas toujours fiable');

            System.assertEquals(2.33, [SELECT id, rating__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].rating__c);

            Test.stopTest();

        }
    }

    @TestSetup
    static void makeData() {

        Profile CRC = TestFactory.getProfilByName('Service Commercial ITCS');
        User userCRC = new User( Alias='myAlias', Email='usersgCRCf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='CRC',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgCRCf@testclasssgdbf.com',ProfileId=CRC.Id,
                                FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userCRC;

        Profile admin = TestFactory.getProfilByName('Administrateur système');
        User PP = new User( Alias='myAlias', Email='ProjectPlace@testclasssgdbf.com', EmailEncodingKey='UTF-8', FirstName= 'Project', LastName='Place',LanguageLocaleKey='fr',
                                LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='ProjectPlace@testclasssgdbf.com',ProfileId=admin.Id,
                                FederationIdentifier='123442567890', Title = 'TC Service Client PRO');
        insert PP;

        Account PRO;
        System.runAs(userCRC) {
            PRO = createAccount('mail1@testorg.com', '1111', '1111', 'PRO', '32212091600208' );
        }
        AccountTeamMember accMem = [SELECT id, AccountId, TeamMemberRole, userId FROM AccountTeamMember WHERE AccountId =:PRO.id];
       
        Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail2@testorg.com',
                                 PersonMobilePhone='+33623232323', Compte_Nouvelles_Offres__c = true);
        insert PART;
        PART.Statut_activation__c = 'Part_actif';
        update PART;

        insert new Projet_LMSG__c ( Chiffrage_bsku__c = 'B1001',
                                    Chiffrage_maximum__c = 38500,
                                    Date_de_debut_de_chantier__c = system.today() + 10,
                                    Date_de_fin_de_chantier__c = system.today() + 35,
                                    Particulier__c = PART.id,
                                    Statut__c = 'FINISHED');

 
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