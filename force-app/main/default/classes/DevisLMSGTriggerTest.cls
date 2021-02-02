/**
 * @File Name          : DevisLMSGTriggerTest.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-26-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0      3/16/2020      Hassan Dakhcha          Initial Version
**/

@isTest
private class DevisLMSGTriggerTest {

    @isTest
    static void DevisLMSGTriggerTest() {

        Test.startTest();
        Devis_LMSG__c quote = [SELECT id, Statut__c, Montant_HT__c FROM Devis_LMSG__c];
        System.debug('#### HDAK Devis ' +  quote);
        System.assertEquals('PENDING', quote.Statut__c, 'Devis cree en statut Transmis' );
        
        Projet_LMSG__c projet = [SELECT id, Bd_associe__c FROM Projet_LMSG__c];
        System.debug('#### HDAK Projet ' +  projet);
        System.assertEquals(true, String.isEmpty(projet.Bd_associe__c), 'Pas de BD associé au projet' );            

        Account acc = [SELECT id, ownerId, login__c FROM Account WHERE Login__C = 'mail1@testorg.com'];
        System.debug('#### HDAK PRO ' +  acc);
        System.assertEquals(false, String.isEmpty(acc.ownerId), 'le compte doit avoir un BD' );                

        quote.Montant_HT__c = 123.45;
        quote.Statut__c = 'SIGNED';
        update quote;

        projet = [SELECT id, Bd_associe__c, montant_HT_devis_signe__c FROM Projet_LMSG__c];
        System.debug('#### HDAK BD projet ' +  projet);
        System.assertEquals(acc.ownerId, projet.Bd_associe__c ,'Meme BD sur le projet que le compte' );                
        System.assertEquals(123.45, projet.montant_HT_devis_signe__c ,'Montant HT doit remonter sur le projet' );                

        Test.stopTest();
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
     
        System.debug('#### HDAK accMem ' +  accMem);

        Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail2@testorg.com' );
        insert PART;

        Projet_LMSG__c projet = new Projet_LMSG__c( Chiffrage_bsku__c = 'B1001',
                                                    Chiffrage_maximum__c = 38500,
                                                    Date_de_debut_de_chantier__c = system.today() + 10,
                                                    Date_de_fin_de_chantier__c = system.today() + 35,
                                                    Particulier__c = PART.id,
                                                    Statut__c = 'PUBLISHED');
        insert projet;

        Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = PRO.id , Projet_LMSG__c = projet.id);
        insert MER;

        Devis_LMSG__c quote = new Devis_LMSG__c(Date_demarrage_chantier_theorique__c = system.today() + 10,
                                                Date_emission_du_devis__c = system.today(),
                                                Description__c = 'Devis tres raisonable',
                                                Mise_en_relation_LMSG__c = MER.id,
                                                Montant_HT__c = 5000,
                                                Montant_TTC__c = 5500,
                                                Statut__c = 'PENDING', 
                                                Pourcentage_accompte__c = 25,
                                                Type_de_devis__c = 'INITIAL');
        insert quote;

   }
}