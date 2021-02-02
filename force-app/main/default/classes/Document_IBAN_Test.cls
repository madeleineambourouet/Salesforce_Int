/**
 * @File Name          : Document_IBAN_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 07-17-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/2/2020   Hassan Dakhcha     Initial Version
**/
@isTest
public class Document_IBAN_Test {
   
    @isTest static void fillIn_iban() {

        Profile BD = TestFactory.getProfilByName('Service Commercial ITCS');
        User userBD = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=BD.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userBD;
        
        Test.startTest();
        System.runAs(userBD) {
            List<Reference__c> refStatut = [SELECT id, key__c FROM Reference__c WHERE RecordType.developerName = 'Statut_Document'];
            Map<String, id> mapStatut = new Map<String, id>();
            for(Reference__c ref : refStatut) {
                mapStatut.put(ref.key__c, ref.id);
            }

            // check VR : mettre le rib a validé sans id SDS :
            Document__c doc = [SELECT id , type_de_document__c, Statut__c, idDocument__c, details__c FROM Document__c WHERE Type_de_document__c ='rib'];
        
            doc.Statut__c = mapStatut.get('VALIDABLE');
            String VR_Error='';
            try {
                update doc;
            } catch (DmlException e) {
                VR_Error = e.getDmlMessage(0);
            }
            System.assertEquals('Merci d\'ajouter le fichier (bouton Ajouter un fichier) avant de mettre le statut Validé/A valider sur le document', VR_Error);
            
            doc.idDocument__c ='02f69eb2-c170-4750-beb3-487bafce9f5c';
            doc.Statut__c = mapStatut.get('NEW');
            VR_Error='';
            try {
                update doc;
            } catch (DmlException e) {
                System.assertEquals(null, VR_Error);
            }

            doc.Statut__c = mapStatut.get('VALIDABLE');
            doc.idDocument__c = '23234324';
            VR_Error='';
            try {
                update doc;
            } catch (DmlException e) {
                VR_Error = e.getDmlMessage(0);
            }
            System.assertEquals('Merci d\'ajouter les détails du RIB via le bouton (Remplir les données du RIB)', VR_Error);

            doc.Statut__c = mapStatut.get('VALIDABLE');
            doc.idDocument__c = '23234324';
            doc.details__c = 'JSON DETAILS';
            VR_Error='';
            try {
                update doc;
            } catch (DmlException e) {
                System.assert(false, e.getDmlMessage(0));
            }

            // Add information
            String invalidIban = 'FR 50 175693443307 597831749K 45';
            List<String> strList = new List<String> ();
            strList.add('FR 50 175693443307 597831749K 45'); // Invalid iban
            List<String> results = DocumentMethods.checkIban(strList);

            System.assertEquals('FALSE', results[0], 'IBAN Not Valid!!');

            strList.clear();
            strList.add('FR 50 17569000307597831749K 45');
            results = DocumentMethods.checkIban(strList);

            System.assertEquals('FR', results[0], 'IBAN Valid!!');
        }
        Test.stopTest();
    }

    
    @testSetup static void setupData() {
                // Create reference Prestation with mandatory documents
        List<reference__c> listRef = new List<reference__c> ();
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
        listRef.add(TestFactory.createReference('StatutDocument', 'A valider','VALIDABLE','A valider'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Refusé','REFUSED','Refusé'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Doublon','DUPLICATED','Doublon'));
        insert listRef;
        // ComptePro attaché contains 2 contacts
        Account comptePro = createAccount('mail1@testorg.com', '1111', '1111', 'Test account', '32212091600208' );
        
        Contact ctcPrincipal = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
                                           email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = comptePro.id);

        insert ctcPrincipal;
        
        insert new Document__c(email_cle_document__c ='mail1@testorg.com_null', Obligatoire_Presta__c=false, type_de_document__c = 'rib',
                                          Statut__c = [SELECT id FROM reference__c WHERE key__c ='NEW'].id);


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