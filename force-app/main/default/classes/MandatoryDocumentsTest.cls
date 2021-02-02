/**
* @author Hassan Dakhcha
* @date 30/12/2019
* @description : MandatoryDocumentsTest : Test methods for Mandatory Documents Elements
**/   

@isTest
private class MandatoryDocumentsTest {
    
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

        List<String> listDocTypes = TestFactory.getListDocTypesFromReference();
        listRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Isolation du sol', '001', 'P100', 0 /* Pas de Doc Obligatoire*/, listDocTypes));
        listRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Peinture - facade', '002', 'P200', 1 /* Un Doc Obligatoire*/, listDocTypes));
        listRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Chauffage', '003', 'P300', 2 /* Deux Doc Obligatoire*/, listDocTypes));
        listRef.add(TestFactory.createAndAddMandatoryDocTypeToPresta('Gros oeuvre', '004', 'P400', 3 /* Trois Doc Obligatoire*/, listDocTypes));
        insert listRef;

        // ComptePro attaché contains 2 contacts
        Account comptePro = createAccount('mail1@testorg.com', '1111', '1111', 'Test account', '32212091600208' );
        
        Contact ctcPrincipal = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
                                           email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = comptePro.id);
        Contact newContact = new Contact(Salutation = 'M.', FirstName = 'Test11', LastName = 'Test11', Contact_Principal_O_N__c = false,
                                         Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
                                         email = 'mail2@testorg.com', Email__c = 'mail2@testorg.com', AccountId = comptePro.id);
        insert ctcPrincipal;
        insert newContact; 
        
        // ComptePro attaché contains 1 contact
        Account comptePro2 = createAccount('mail3@testorg.com', '2222', '2222', 'Test account2', '32212091600108');
        Contact ctcp = new Contact(Salutation = 'M.', FirstName = 'Test3', LastName = 'Test3', Contact_Principal_O_N__c = true,
                                   
                                   email = 'mail3@testorg.com', Email__c = 'mail3@testorg.com', AccountId = comptePro2.id);
        insert ctcp;
        

    }     
    
    ////////////////////////////////////////////////////////////////////////
    ///// TEST BRIQUE 1 : Calcul est MAJ Doc Obligatoire sur le compte /////
    // Test Insert/Update sur la Prestation Contact                    /////
    // Test : la modification du compte sur le Contact                 /////
    ////////////////////////////////////////////////////////////////////////
    
    @isTest static void mandatoryDocsTest() {
        
        Account acc = [SELECT id FROM Account Where Login__c='mail1@testorg.com'];
        Contact ctc = [SELECT id, Email__c FROM Contact Where Email__c = 'mail1@testorg.com' ];

        List<Reference__c> refList = [SELECT id, key__c, Document_obligatoire__c FROM reference__c];
        Map<String, Reference__c> mapRef = new Map<String, Reference__c>();
        for(Reference__c ref : refList) {
            mapRef.put(ref.key__c, ref);
        }
        reference__c presta0 = mapRef.get('001');
        reference__c presta1 = mapRef.get('002');
        reference__c presta2 = mapRef.get('003');
        reference__c presta3 = mapRef.get('004');

        System.debug('#### HDAK presta Docs P1 = ' + presta0.Document_obligatoire__c + ' P2 = ' + presta1.Document_obligatoire__c 
                     + ' P3 =  ' +presta2.Document_obligatoire__c+  ' P4 =  ' + presta3.Document_obligatoire__c );
        
        Test.startTest();
 
        List<Jointure_Documents_Prestations__c> jctList = [ SELECT id, Tech_Liste_Doc_Obligatoires__c,Prestation__c 
                                                            FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];
        System.debug('#### HDAK Pas de jointure : 0 -> ' + jctList.size() );
        System.assertEquals(0, jctList.size(), 'Before PC insert ; None jonction object created' );
        
        Prestation_Contact__c newPresCt = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
                                                                    + presta0.Key__c, Prestation__c = presta0.id);   
        insert newPresCt;

        jctList = [ SELECT id, Tech_Liste_Doc_Obligatoires__c,Prestation__c 
                    FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];

        System.debug('#### HDAK Pas de Jointure La PC n\'a pas de doc obligatoire -> ' + jctList.size() );
        System.assertEquals(0, jctList.size(), 'Pas de Jointure La PC n\'a pas de doc obligatoire' );
        
        newPresCt = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' + presta1.Key__c, Prestation__c = presta1.id);   
        insert newPresCt;
        
        jctList = [ SELECT id, Tech_Liste_Doc_Obligatoires__c,Prestation__c, Statut_prestations__c, Statut_Document__c,  Type_de_document__c 
                    FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];
        System.debug('#### HDAK 1 jointure -> ' + jctList.size());
        System.assertEquals(1, jctList.size(), '1 jointures');
        
        Jointure_Documents_Prestations__c jct = jctList[0];
        System.debug('#### HDAK 1 jointure -> ' + jct.Tech_Liste_Doc_Obligatoires__c + ' ' + jct.Prestation__c + ' ' + jct.Statut_prestations__c + ' ' + jct.Statut_Document__c + ' ' + jct.Type_de_document__c);
        System.assertEquals('insurance ' + newPresCt.id + ' Non positionnable Manquant insurance',
                    jct.Tech_Liste_Doc_Obligatoires__c + ' ' + jct.Prestation__c + ' ' + jct.Statut_prestations__c + ' ' + jct.Statut_Document__c + ' ' + jct.Type_de_document__c,
                    'ListDoc + PrestId + Statut Prest + Doc Status + Doc Type');
        
        newPresCt.Prestation__c = presta3.id;
        update newPresCt;
        
        jctList = [ SELECT id, Tech_Liste_Doc_Obligatoires__c,Prestation__c, Statut_prestations__c, Statut_Document__c,  Type_de_document__c
                    FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];
        System.debug('#### HDAK 3 docs obligatoires : insurance;insurance_rc;insurance_dc -> ' + jctList[0].Tech_Liste_Doc_Obligatoires__c );
        System.assertEquals('insurance;insurance_dc;insurance_rc', jctList[0].Tech_Liste_Doc_Obligatoires__c, 'changement de presta doit avoir 3 doc obligatoire' );
        
        // tester le changement des documents obligatoires dans la reference :
        update (new Reference__c(id = presta3.id, Document_obligatoire__c='insurance;insurance_rc;insurance_dc;rib'));

        jctList = [ SELECT id, Tech_Liste_Doc_Obligatoires__c 
                    FROM Jointure_Documents_Prestations__c 
                    WHERE Compte_Pro__c = :acc.id ];

        System.debug('#### HDAK 4 docs obligatoires : insurance;insurance_rc;insurance_dc -> ' + jctList[0].Tech_Liste_Doc_Obligatoires__c );
        System.debug('#### HDAK nombre de jonction pour 4 doc obligatoire et 1 prestation -> ' + jctList.size());
        System.assertEquals('insurance;insurance_dc;insurance_rc;rib', jctList[0].Tech_Liste_Doc_Obligatoires__c, 'changement de reference doit avoir 4 docs obligatoires');
         
        // Changement du contact principal sur le compte
        Contact ctc2 = [SELECT id, Email__c,Contact_Principal_O_N__c FROM Contact Where Email__c = 'mail2@testorg.com' ];
        ctc2.Contact_Principal_O_N__c = true;
        update ctc2;
      
        List<Jointure_Documents_Prestations__c> jctListAcc  = [ SELECT id, Tech_Liste_Doc_Obligatoires__c 
                                                                FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];

        System.debug('#### HDAK nombre de jonction ? -> ' + jctListAcc.size());
        for(Jointure_Documents_Prestations__c jctu : jctListAcc)
            System.debug('#### HDAK pas de docs obligatoires -> ' + jctu.Tech_Liste_Doc_Obligatoires__c );

        Test.stopTest();
    }
    
    @isTest 
    static void injectPrestationContactTest() {
        
        Test.startTest();
        Contact ctc = [SELECT id, Email__c FROM Contact Where Email__c = 'mail1@testorg.com' ];
         // Test injectPrestationContact
         String str = ctc.Id;
        for(Integer i = 1 ; i < 10 ; i++)
            str += '; 00' + i;
        for(Integer i = 10 ; i < 89 ; i++)
            str += '; 0' + i;

        List<String> inputList = new List<String> ();
        inputList.add(str);
        System.debug('#### HDAK : argument' + str);
        System.assertEquals('Success', MandatoryDocs_Synthesizer.injectPrestationContact(inputList)[0], ' Erreur lors de l inject de la prestation en masse');

        inputList.clear();
        System.assertEquals('Error', MandatoryDocs_Synthesizer.injectPrestationContact(inputList)[0], ' Erreur lors de l inject de la prestation en masse');

        Test.stopTest();
    }

    @isTest 
    static void documentChangeTest() {
    
        Account acc = [SELECT id, Statut_activation__c FROM Account Where Login__c='mail1@testorg.com'];
        Contact ctc = [SELECT id, Email__c FROM Contact Where Email__c = 'mail1@testorg.com' ];
        // check if the acc is positionnable
        acc.Statut_activation__c = 'Pro_Actif';
        update acc;

        delete [SELECT id FROM Prestation_Contact__c WHERE Contact__c =:ctc.id];
        delete [SELECT id FROM Document__c WHERE Compte_Pro__c = :acc.id];

        List<Reference__c> refList = [SELECT id, key__c, Document_obligatoire__c FROM reference__c];
        Map<String, Reference__c> mapRef = new Map<String, Reference__c>();
        for(Reference__c ref : refList) {
            mapRef.put(ref.key__c, ref);
        }
        reference__c presta2 = mapRef.get('003');
        reference__c presta3 = mapRef.get('004');
        reference__c expire = mapRef.get('EXPIRED');
        reference__c valid = mapRef.get('VALIDATED');
        reference__c mcAssu = mapRef.get('mc_insurrance');

        System.debug('#### HDAK presta2' + presta2.Document_obligatoire__c);
        System.debug('#### HDAK presta3' + presta3.Document_obligatoire__c);
        
        List<Prestation_Contact__c> pList = new List<Prestation_Contact__c>();
        Prestation_Contact__c newPresCt1 = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
        + presta2.Key__c, Prestation__c = presta2.id); 
        pList.add(newPresCt1);
        Prestation_Contact__c newPresCt2 = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
        + presta3.Key__c, Prestation__c = presta3.id);   
        pList.add(newPresCt2);

        insert pList;
       
        // Doc Expires
        List<Document__c> docList = [SELECT id, Statut__c, Statut__r.Key__c, Type_de_document__c, idDocument__c FROM Document__c WHERE Compte_Pro__c = :acc.id];

        // change doc status to VALIDATED : 
        acc = [SELECT id, Statut_activation__c FROM Account WHERE id=:acc.id];
     

        System.assertEquals(3, docList.size() , 'number of created documents must be 3');
        for(Document__c doc : docList) {
            //System.debug('##### HDAK doc -->' + doc);
            System.assertEquals('MISSING', doc.Statut__r.key__c, 'Doc status must be MISSING');
        }

        Datetime local = Datetime.now(); 

        System.assertEquals('Pro_actif', acc.Statut_activation__c , 'Compte pro Actif');
        integer i = 3444;
        for(Document__c doc : docList) {
            doc.Statut__c = valid.id;
            doc.Date_de_validite__c = system.today() + 15;
            doc.idDocument__c = '2221-'+i;
            i++;
            if(doc.type_de_document__c == 'insurance_dc')
                doc.Nom_Assureur__c = mcAssu.id;
        }
        update docList;

        List<Jointure_Documents_Prestations__c> jctListAcc  = [ SELECT id, Statut_prestations__c , Document__c, Prestation__c, Prestation_Name__c, Type_de_document__c
                                                                FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];

        System.assertEquals(5, jctListAcc.size() , '5 jonctions');
        
        Test.startTest(); 
        
        for(Jointure_Documents_Prestations__c jctu : jctListAcc)
            System.assertEquals('Positionnable', jctu.Statut_prestations__c , 'Toutes les prestations sont Positionnable');

        acc = [SELECT id, Statut_activation__c, Date_client_positionnable__c FROM Account WHERE id=:acc.id];
        System.assertEquals('Pro_actif_positionnable', acc.Statut_activation__c , 'Compte positionnable');
        Datetime nowPos = acc.Date_client_positionnable__c;
        System.assertEquals( true, nowPos.addSeconds(1)>local, acc.Date_client_positionnable__c + ' VS '+ local);

        docList[0].Statut__c = expire.id;
        docList[0].Date_de_validite__c = system.today() -10;
        update docList[0];

        jctListAcc  = [ SELECT id, Statut_prestations__c 
                        FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];

        Integer delay = Integer.valueOf(Label.DocTolerateExpired);
        for(Jointure_Documents_Prestations__c jctu : jctListAcc)
            System.assertEquals(delay==0 ? 'Non positionnable' : 'Positionnable', jctu.Statut_prestations__c, 'Aucune des prestations n\'est Positionnable');

        acc = [SELECT id, Statut_activation__c,Tech_ModifyBySalesforceTrigger__c FROM Account WHERE id=:acc.id];
        System.assertEquals(delay==0 ? 'Pro_actif' : 'Pro_actif_positionnable', acc.Statut_activation__c , 'Compte NON positionnable');
        System.assertEquals(delay==0 ? true : false, acc.Tech_ModifyBySalesforceTrigger__c);
        acc.Statut_activation__c = 'En_attente_activation';
        update acc;

        docList[0].Statut__c = valid.id;
        docList[0].idDocument__c = '2221-22323';
        docList[0].Date_de_validite__c = system.today() + 10;
        update docList[0];

        jctListAcc  = [ SELECT id, Statut_prestations__c 
                        FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];

        for(Jointure_Documents_Prestations__c jctu : jctListAcc)
            System.assertEquals('Positionnable', jctu.Statut_prestations__c , 'Toutes les prestations sont Positionnable');

           
        acc = [SELECT id, Statut_activation__c FROM Account WHERE id=:acc.id];
        System.assertEquals('En_attente_activation', acc.Statut_activation__c , 'Compte En_attente_activation');

        acc.Statut_activation__c = 'Pro_actif';
        update acc;    

        acc = [SELECT id, Statut_activation__c FROM Account WHERE id=:acc.id];
        System.assertEquals('Pro_actif_positionnable', acc.Statut_activation__c , 'Compte positionnable');
        

        // Delete document
        Document__c docToInsert = new Document__c();
        docToInsert = docList[1];
      
        delete docList[1];
        
        System.debug('### HDAK doc deleted : ' + docList[1] + ' ' + docList[1].Type_de_document__c);
        
       jctListAcc  = [SELECT id , name, Prestation__c, Document__r.Type_de_document__c , Statut_prestations__c, Document__r.Statut__r.name  FROM Jointure_Documents_Prestations__c 
                       WHERE Compte_Pro__c = :acc.id ];


        for(Jointure_Documents_Prestations__c jctu : jctListAcc) {
            jctu.Document__c = null;
            if(docList[1].Type_de_document__c == jctu.Document__r.Type_de_document__c) {
         	 System.debug('### HDAK jct doc type '+ jctu.Document__r.Type_de_document__c);
              System.debug('### HDAK jct dbg '+ jctu);
               System.assertEquals('Non positionnable', jctu.Statut_prestations__c, 'La prestations n\'est Positionnable');
            }
        }
         update jctListAcc;
         docList = [SELECT id, Statut__c, Statut__r.Key__c, Type_de_document__c 
                    FROM Document__c WHERE Type_de_document__c = :docToInsert.Type_de_document__c];
        System.assertEquals(1, docList.size() , 'Deleted doc type created');
        System.assertEquals('MISSING', docList[0].Statut__r.Key__c , 'Deleted doc type created with MISSING status');
        //System.assertEquals('MISSING', docList[1].Statut__r.Key__c , 'Deleted doc type created with MISSING status');

        Test.stopTest();
    }

    @isTest
    static void checkDocStatus() {

        Test.startTest();

        Account acc = [SELECT id, Statut_activation__c FROM Account Where Login__c='mail1@testorg.com'];
        Contact ctc = [SELECT id, Email__c FROM Contact Where Email__c = 'mail1@testorg.com' ];
        // check if the acc is positionnable
        acc.Statut_activation__c = 'Pro_Actif';
        update acc;

        delete [SELECT id FROM Prestation_Contact__c WHERE Contact__c =:ctc.id];
        delete [SELECT id FROM Document__c WHERE Compte_Pro__c = :acc.id];

        List<Reference__c> refList = [SELECT id, key__c, Document_obligatoire__c FROM reference__c];
        Map<String, Reference__c> mapRef = new Map<String, Reference__c>();
        for(Reference__c ref : refList) {
            mapRef.put(ref.key__c, ref);
        }
        reference__c presta2 = mapRef.get('003');
        reference__c presta3 = mapRef.get('004');
        reference__c expire = mapRef.get('EXPIRED');
        reference__c valid = mapRef.get('VALIDATED');
        reference__c mcAssu = mapRef.get('mc_insurrance');

        System.debug('#### HDAK presta2' + presta2.Document_obligatoire__c);
        System.debug('#### HDAK presta3' + presta3.Document_obligatoire__c);
    
        Prestation_Contact__c newPresCt1 = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
        + presta2.Key__c, Prestation__c = presta2.id);   
        Prestation_Contact__c newPresCt2 = new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' 
        + presta3.Key__c, Prestation__c = presta3.id);   
        
        insert newPresCt1;
        insert newPresCt2;

        List<Document__c> docList = [SELECT id, Statut__c, Statut__r.Key__c, Type_de_document__c, idDocument__c FROM Document__c WHERE Compte_Pro__c = :acc.id];   
        System.assertEquals(3, docList.size() , 'number of created documents must be 3');
       
        Datetime local = Datetime.now(); 

        integer i = 3444;
        for(Document__c doc : docList) {
            doc.Statut__c = valid.id;
            doc.Date_de_validite__c = system.today() + 15;
            doc.idDocument__c = '2221-'+i;
            i++;
            if(doc.type_de_document__c == 'insurance_dc')
                doc.Nom_Assureur__c = mcAssu.id;
        }
        update docList;

        List<Jointure_Documents_Prestations__c> jctListAcc  = [SELECT id , name, Prestation__c, document__c, Compte_Pro_Name__c, Document__r.Statut__r.name , 
                                                                Document__r.Obligatoire_Presta__c , Document__r.Type_de_document__c , Statut_prestations__c 
                                                                FROM Jointure_Documents_Prestations__c 
                                                                WHERE Compte_Pro__c = :acc.id ];

        for(Jointure_Documents_Prestations__c jctu : jctListAcc) 
            System.debug('Positionnable'+ jctu.Statut_prestations__c + 'Toutes les prestations sont Positionnable');

        // change doc type 
        docList = [SELECT id, Statut__c, Statut__r.Key__c, Type_de_document__c FROM Document__c WHERE Compte_Pro__c = :acc.id];
        docList[0].Type_de_document__c = 'rib';
        //docList[0].details__c = '{"bank_country": "**","bank_name": "***","bank_address": "*********","bank_zip_code": "63434","bank_city": "****","iban": "FR5017569000307597831749K45","swift": "******"}';
        update docList[0];

        jctListAcc  = [ SELECT id, Statut_prestations__c, Type_de_document__c
                        FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];
        for(Jointure_Documents_Prestations__c jctu : jctListAcc)
            System.assertEquals('Non positionnable', jctu.Statut_prestations__c, 'Aucune des prestations n\'est Positionnable');
       
        // delete PC : 
        delete newPresCt1;
        delete newPresCt2;
        jctListAcc  = [ SELECT id, Statut_prestations__c, Type_de_document__c
                        FROM Jointure_Documents_Prestations__c WHERE Compte_Pro__c = :acc.id ];
        System.assertEquals(0, jctListAcc.size(), 'Toutes les jonctions sont deletées');

        // Doc flag reseted  
        docList = [SELECT id, Obligatoire_Presta__c, Type_de_document__c FROM Document__c WHERE Compte_Pro__c = :acc.id];
        for(Document__c doc : docList)
            System.assertEquals(false, doc.Obligatoire_Presta__c ,' Aucun doc obligatoire pour Presta');

        Test.stopTest();
    }

    @isTest
    static void testDocDuplicates() {

        Account acc = [SELECT id, Statut_activation__c FROM Account Where Login__c='mail1@testorg.com'];
        Contact ctc = [SELECT id, Email__c FROM Contact Where Email__c = 'mail1@testorg.com' ];
        List<Reference__c> refList = [SELECT id, key__c, Document_obligatoire__c FROM reference__c];
        Map<String, Reference__c> mapRef = new Map<String, Reference__c>();
        for(Reference__c ref : refList) {
            mapRef.put(ref.key__c, ref);
        }
        reference__c presta2 = mapRef.get('003');
        reference__c presta3 = mapRef.get('004');

        List<Prestation_Contact__c> pcToDelete = [SELECT id FROM Prestation_Contact__c WHERE Contact__c =:ctc.id];
        delete pcToDelete;
    
       // delete Documents :
       List<Document__c> docToDelete = [SELECT id, Obligatoire_Presta__c, Type_de_document__c FROM Document__c WHERE Compte_Pro__c = :acc.id OR Contact_principal__c = :ctc.id];
       delete docToDelete;

       Test.startTest();

       reference__c presta0 = mapRef.get('001');
       List<Prestation_Contact__c> lprst = new List<Prestation_Contact__c>();
       lprst.add(new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' + presta0.Key__c, Prestation__c = presta0.id));   
       lprst.add(new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' + presta3.Key__c, Prestation__c = presta3.id));   
       lprst.add(new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' + presta2.Key__c, Prestation__c = presta2.id));   
       insert lprst;
       List<Document__c>  docList = [SELECT id, Obligatoire_Presta__c, Type_de_document__c FROM Document__c WHERE Compte_Pro__c = :acc.id];
       System.debug('### HDAK doc oblig = ' + presta3.Document_obligatoire__c);
       System.debug('### HDAK doc oblig = ' + presta2.Document_obligatoire__c);
       System.debug('### HDAK doc number' + docList.size());
       
       // Check error on the insert doc 
       insert(new Document__c(Compte_pro__c=acc.id, Type_de_document__c='rib'));

       System.assertEquals(3, docList.size(), 'Check si pas de duplicate lors de la creation des documents' );
       
       Test.stopTest();

    }


    @isTest
    static void testProPiloteResilieActiveParPartnership() {

        Account acc = [SELECT id, Statut_activation__c, Compte_Nouvelles_Offres__c FROM Account Where Login__c='mail1@testorg.com'];
        acc.Statut_activation__c = 'Pro_resilie';
        acc.Compte_Nouvelles_Offres__c = true;
        update acc;

        Profile admin = TestFactory.getProfilByName('Administrateur système');
        User SW = new User( Alias='myAlias1', Email='PlaceProject@testclasssgdbf.com', EmailEncodingKey='UTF-8', FirstName= '', LastName='Service Web',
                                LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='HKProject@testclasssgdbf.com',
                                ProfileId=admin.Id, FederationIdentifier='12344223567890', Title = 'Admin');
        insert SW;

       Test.startTest();
       
       System.runAs(SW) {
            acc = [SELECT id, Statut_activation__c, Compte_Nouvelles_Offres__c FROM Account Where Login__c='mail1@testorg.com'];
            System.assertEquals('Pro_resilie', acc.Statut_activation__c, 'Compte resilié' );
            System.assertEquals(true, acc.Compte_Nouvelles_Offres__c, 'Compte resilié' );

            acc.Statut_activation__c = 'Pro_actif';
            update acc;

            acc = [SELECT id, Statut_activation__c, Compte_Nouvelles_Offres__c FROM Account Where Login__c='mail1@testorg.com'];
            System.assertEquals('Pro_resilie', acc.Statut_activation__c, 'Compte resilié' );
            System.assertEquals(true, acc.Compte_Nouvelles_Offres__c, 'Compte resilié' );

            acc.Statut_activation__c = 'En_attente_activation';
            update acc;

            acc = [SELECT id, Statut_activation__c, Compte_Nouvelles_Offres__c FROM Account Where Login__c='mail1@testorg.com'];
            System.assertEquals('Pro_resilie', acc.Statut_activation__c, 'Compte resilié' );
            System.assertEquals(true, acc.Compte_Nouvelles_Offres__c, 'Compte resilié' );
       }
        
       Test.stopTest();

    }


}