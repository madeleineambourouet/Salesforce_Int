/**
 * @File Name          : DocumentSDS_Checker_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/27/2020, 12:07:16 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/27/2020   Hassan Dakhcha     Initial Version
**/
@isTest
private class DocumentSDS_Checker_Test {
  
    @isTest
    static void noAttachedFile() {
        String body = '{"idDocument": "5030be50-6f15-4fc2-a5e4-fbca63ae3162","idVersion": "f3d98957-d28b-48de-8dc1-c5578bee4c37","versionNumber": 1,"objectCount": 1,'+
        '"documentCreatedDate": "2020-06-17T15:45:01.377361Z","versionCreatedDate": "2020-06-17T15:45:01.377368Z","docType": "kbis","objectType": "pdf",'+
        '"objectMimeType": "application/pdf","objects": [],'+
        '"deleted": false,'+
        '"deletedAt": null,'+
        '"createdBy": "wbe",'+
        '"hasValidity": false,'+
        '"validity": null,'+
        '"name": "KBIS"'+
        '}';

        DocumentSDS_Checker_TestMockHttp mock = new DocumentSDS_Checker_TestMockHttp(body, 200);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String query = 'select id, Statut__r.name, Type_de_document__c,  idDocument__c, Compte_Pro__c,' + 
                        ' Compte_Pro__r.Statut_activation__c, Compte_Pro__r.Pro_Pilote__c from Document__c '
                        + 'Where iddocument__c!=\'\'';

        DocumentSDS_Checker.run(query, 1, true);
        List<Piece_Jointe_SDS__c> PJlist = [select id, Name, Response_Code__c, Check_Message__c, cree_par__c, Compte_Pro__c,
                                    Document__c, Document__r.Type_de_document__c, Document__r.idDocument__c,
                                    versionNumber__c, objectCount__c  from Piece_Jointe_SDS__c ];
        for(Piece_Jointe_SDS__c pj : PJlist)
        System.debug('#### HDAK : ' + pj);

        Test.stopTest();

    }

    @isTest
    static void withAttachement() {

            String body = '{"idDocument": "5030be50-6f15-4fc2-a5e4-fbca63ae3162","idVersion": "f3d98957-d28b-48de-8dc1-c5578bee4c37","versionNumber": 1,"objectCount": 1,'+
                        '"documentCreatedDate": "2020-06-17T15:45:01.377361Z","versionCreatedDate": "2020-06-17T15:45:01.377368Z","docType": "kbis","objectType": "pdf",'+
                        '"objectMimeType": "application/pdf","objects": [{'+
                        '"idObject": "04569955-29fe-4193-b3eb-bcb3092c356b",'+
                        '"uri": "https://lmsgdevsdsstoragea.blob.core.windows.net/04569955-29fe-4193-b3eb-bcb3092c356b/kbis.pdf?sig=eCoE5hR6Q2uGZHaZMBsbUcC8BWghxJInJWLmYiK1UjM%3D&st=2020-06-27T07%3A52%3A05Z&se=2020-06-27T09%3A52%3A05Z&sv=2019-02-02&sp=r&sr=b",'+
                        '"size": 151041,'+
                        '"hrSize": "151.0 kB",'+
                        '"order": 1,'+
                        '"name": "KBIS",'+
                        '"filename": "kbis.pdf",'+
                        '"deleted": false,'+
                        '"deletedAt": null,'+
                        '"createdBy": "wbe",'+
                        '"thumbAvailable": false,'+
                        '"thumbUri": "https://lmsgdevsdsstoragea.blob.core.windows.net/04569955-29fe-4193-b3eb-bcb3092c356b/kbis.pdf?sig=eCoE5hR6Q2uGZHaZMBsbUcC8BWghxJInJWLmYiK1UjM%3D&st=2020-06-27T07%3A52%3A05Z&se=2020-06-27T09%3A52%3A05Z&sv=2019-02-02&sp=r&sr=b",'+
                        '"webVersionAvailable": false,'+
                        '"webVersionUri": "https://lmsgdevsdsstoragea.blob.core.windows.net/04569955-29fe-4193-b3eb-bcb3092c356b/kbis.pdf?sig=eCoE5hR6Q2uGZHaZMBsbUcC8BWghxJInJWLmYiK1UjM%3D&st=2020-06-27T07%3A52%3A05Z&se=2020-06-27T09%3A52%3A05Z&sv=2019-02-02&sp=r&sr=b",'+
                        '"width": 0,'+
                        '"heigth": 0,'+
                        '"ratio": null,'+
                        '"orientation": null'+
                            '}'+
                        '],'+
                        '"deleted": false,'+
                        '"deletedAt": null,'+
                        '"createdBy": "wbe",'+
                        '"hasValidity": false,'+
                        '"validity": null,'+
                        '"name": "KBIS"'+
                        '}';

        DocumentSDS_Checker_TestMockHttp mock = new DocumentSDS_Checker_TestMockHttp(body, 200);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String query = 'select id, Statut__r.name, Type_de_document__c,  idDocument__c, Compte_Pro__c,' + 
                        ' Compte_Pro__r.Statut_activation__c, Compte_Pro__r.Pro_Pilote__c from Document__c '
                             + 'Where iddocument__c!=\'\'';

        DocumentSDS_Checker.run(query, 20, true);
        List<Piece_Jointe_SDS__c> PJlist = [select id, Name, Response_Code__c, Check_Message__c, cree_par__c, Compte_Pro__c,
                                             Document__c, Document__r.Type_de_document__c, Document__r.idDocument__c,
                                             versionNumber__c, objectCount__c  from Piece_Jointe_SDS__c ];
        for(Piece_Jointe_SDS__c pj : PJlist)
            System.debug('#### HDAK : ' + pj);

        Test.stopTest();
	}
       
    @testSetup static void setupData() {
        // Create reference Prestation with mandatory documents
        List<reference__c> listRef = new List<reference__c> ();
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
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

        insert new Document__c( email_cle_document__c ='mail1@testorg.com_null', Obligatoire_Presta__c=false, type_de_document__c = 'rib',
                                 idDocument__c='5030be50-6f15-4fc2-a5e4-fbca63ae3164',
                                        Statut__c = [SELECT id FROM reference__c WHERE key__c ='NEW'].id);
        
        insert new Document__c(email_cle_document__c ='mail1@testorg.com_null', Obligatoire_Presta__c=false, type_de_document__c = 'rib',
                                 iddocument__c='5030be50-6f15-4fc2-a5e4-fbca63ae3162',
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