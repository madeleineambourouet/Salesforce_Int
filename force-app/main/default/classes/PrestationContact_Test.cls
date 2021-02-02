/**
 * @File Name          : PrestationContact_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 5/20/2020, 9:59:15 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/20/2020   Hassan Dakhcha     Initial Version
**/
@isTest
public class PrestationContact_Test {
        
    // Test si le delete manuel des prestations, supprime aussi les autres PC
    @isTest
    public static void deleteSamePSKU() {
        
        Test.startTest();
        List<Prestation_Contact__c> existantPC = [SELECT id, prestation__r.SKU__c FROM Prestation_Contact__c];
        System.assertEquals(200, existantPC.size(), 'Must have 400 Prestation contact');

        // On a deux pro avec 100 presta chacun:
        delete [SELECT id, prestation__r.SKU__c FROM Prestation_Contact__c 
                WHERE prestation__r.SKU__c ='P100' LIMIT 1];

        existantPC = [SELECT id, prestation__r.SKU__c FROM Prestation_Contact__c];
        System.assertEquals(175, existantPC.size(), 'Must have 175 Prestation contact');
        try {
            delete [SELECT id, prestation__r.SKU__c FROM Prestation_Contact__c];
        } catch (Exception e) {
            System.assert(false, 'Test deleteSamePSKU Exception : ' + e.getMessage());
        }
        Test.stopTest();
    }

    ////// DATA GENERATION ////////
    @testSetup static void setupData() {
                // Create reference Prestation with mandatory documents
        List<reference__c> listRef = new List<reference__c> ();
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Refusé','REFUSED','Refusé'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Doublon','DUPLICATED','Doublon'));
        listRef.add(new reference__c( RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Document_Nom_Assureur' LIMIT 1].Id, 
                                      key__c = 'mc_insurrance', name = 'Monceau Assurance', Libelle__c ='Monceau Assurance'));
        insert listRef;

        List<String> listDocTypes = TestFactory.getListDocTypesFromReference();     
        List<reference__c> listPRef = new List<reference__c> ();
        for(Integer numDup=0; numDup < 25; numDup++) {
            listPRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Isolation du sol', 'UID010'+numDup, 'P100', 0 /* Pas de Doc Obligatoire*/, listDocTypes));
            listPRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Peinture - facade', 'UID020'+numDup, 'P200', 1 /* Un Doc Obligatoire*/, listDocTypes));
            listPRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Chauffage', 'UID030'+numDup, 'P300', 2 /* Deux Doc Obligatoire*/, listDocTypes));
            listPRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Gros oeuvre','UID040'+numDup, 'P400', 3 /* Trois Doc Obligatoire*/, listDocTypes));
        }
        insert listPRef;

        // ComptePro attaché contains 2 contacts
        Account comptePro = createAccount('mail1@testorg.com', '1111', '1111', 'Test account', '32212091600208' );
        Contact ctcPrincipal = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
                                           email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = comptePro.id);

        insert ctcPrincipal;
        // Create multiple PC with same PSKU
        List<Prestation_Contact__c> ListPC = new List<Prestation_Contact__c>();
        for(Integer i=0 ; i<listPRef.size(); i++) {
            ListPC.add(new Prestation_Contact__c(Contact__c = ctcPrincipal.id, 
                                                    Email_cle_prestation__c = ctcPrincipal.Email__c  + '_' + listPRef[i].Key__c, 
                                                    Prestation__c = listPRef[i].id));   
        }

        // ComptePro attaché contains 1 contact
        Account comptePro2 = createAccount('mail3@testorg.com', '2222', '2222', 'Test account2', '32212091600108');
        Contact ctcp = new Contact(Salutation = 'M.', FirstName = 'Test3', LastName = 'Test3', Contact_Principal_O_N__c = true,
                                   
                                   email = 'mail3@testorg.com', Email__c = 'mail3@testorg.com', AccountId = comptePro2.id);
        insert ctcp;

        // Create multiple PC with same PSKU
        for(Integer i=0 ; i<listPRef.size(); i++) {
            ListPC.add(new Prestation_Contact__c(Contact__c = ctcp.id, 
                                                    Email_cle_prestation__c = ctcp.Email__c  + '_' + listPRef[i].Key__c, 
                                                    Prestation__c = listPRef[i].id));   
        }

        insert ListPC;
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
        compte.Compte_Nouvelles_Offres__c = false;
        compte.Statut_activation__c = 'Nouveau';
        compte.Login__c = email;
        compte.Code_client__c = codeClient;
        compte.profile_id__c  = profileId;
        insert compte;
        return compte;
    }
}