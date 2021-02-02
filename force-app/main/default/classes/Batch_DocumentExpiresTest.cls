/**
* @author Hassan Dakhcha
* @date 06/01/2020
* @description Test Class of Batch_DocumentExpires : Controle date d'expiration des documents / MAJ Statut / Declanchement d'envoi mail rappel j-30
*/
@isTest
public class Batch_DocumentExpiresTest {
    
    @testSetup 
    static void setup() {
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
        
        // Create reference Prestation with mandatory documents
        List<reference__c> listRef = new List<reference__c> ();
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Nouveau','NEW','Nouveau'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Refusé','REFUSED','Refusé'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Doublon','DUPLICATED','Doublon'));
        listRef.add(new reference__c( RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Document_Nom_Assureur' LIMIT 1].Id, 
                                        key__c = 'mc_insurrance', name = 'Monceau Assurance', Libelle__c ='Monceau Assurance'));

        // Ajout de presta et les doc seront creer automatiquement.
        List<String> listDocTypes = TestFactory.getListDocTypesFromReference();
        reference__c presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Gros oeuvre', '004', 'P100', 4 /* Trois Doc Obligatoire*/, listDocTypes);
        listRef.add(presta);
        
        insert listRef;

        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = 'Test account';
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
        compte.Flux_code_Enseigne__c = enseigne.key__c;
        compte.SIRET_texte__c =  '32212091600208';
        compte.Code_NAF_APE_societe_declarante__c = NAF.id;
        compte.A_ne_jamais_rappeler__c = false;
        
        compte.Pays_LKP__c = pays.id;
        compte.Code_postal__c = CP.id;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = true; 
        compte.Statut_activation__c = 'Nouveau';
        compte.Login__c = 'mail1@testorg.com';
        compte.Code_client__c = '1111';
        compte.profile_id__c  = '1111';
        insert compte;
        
        Contact ctc =  new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                   Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
                                   email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = compte.id);
        insert ctc;
     
        insert new Prestation_Contact__c(Contact__c = ctc.id, Email_cle_prestation__c = ctc.Email__c  + '_' + presta.Key__c, Prestation__c = presta.id);   
    }
    
    static testmethod void testBatchDocumentExpires() {        
        
        Test.startTest();
        Prestation_Contact__c pc = [SELECT id, Contact__c,Contact__r.AccountId, Email_cle_prestation__c, prestation__c FROM Prestation_Contact__c ];   
        List<Document__c> listDoc = [SELECT id, Date_de_validite__c, Statut__c, type_de_document__c, idDocument__c,Compte_Pro__r.Id FROM Document__c];
        
        System.assertEquals(listDoc.size(), 4, 'testBatchDocumentExpires : on doit avoir 4 documents crées' );
        	
        id valid = [SELECT id, key__c FROM reference__c WHERE key__c = 'VALIDATED' AND recordType.developerName = 'Statut_Document'].id;
        id expired = [SELECT id, key__c FROM reference__c WHERE key__c = 'EXPIRED' AND recordType.developerName = 'Statut_Document'].id;

        id idAssureur = [SELECT id FROM reference__c Where recordType.developerName = 'Document_Nom_Assureur' LIMIT 1].id;

        listDoc[0].Statut__c = valid;
        listDoc[0].idDocument__c = '2221-4444';
        listDoc[0].Date_de_validite__c = system.today() -35;
        listDoc[0].Compte_Pro__r.Id = pc.Contact__r.AccountId;
        if(listDoc[0].type_de_document__c == 'insurance_dc')
            listDoc[0].Nom_Assureur__c = idAssureur;
        
        listDoc[1].Statut__c = valid;
        listDoc[1].idDocument__c = '2221-1111';
        listDoc[1].Date_de_validite__c = system.today() + 15;
        listDoc[1].Compte_Pro__r.Id =  pc.Contact__r.AccountId;
        listDoc[1].type_de_document__c = 'insurance_rc';
        listDoc[1].Nom_Assureur__c = idAssureur;

        listDoc[2].Statut__c = expired;
        listDoc[2].idDocument__c = '2221-2222';
        listDoc[2].Date_de_validite__c = system.today() - 7;
        listDoc[2].Compte_Pro__r.Id =  pc.Contact__r.AccountId;
        listDoc[2].type_de_document__c = 'insurance_rc';
        listDoc[2].Nom_Assureur__c = idAssureur;

        listDoc[3].Statut__c = valid;
        listDoc[3].idDocument__c = '2221-3333';
        listDoc[3].Compte_Pro__r.Id =  pc.Contact__r.AccountId;
        listDoc[3].type_de_document__c = 'insurance_dc';
        listDoc[3].Nom_Assureur__c = idAssureur;
        listDoc[3].Date_de_validite__c = system.today() + 40;

        String idPro = pc.Contact__r.AccountId;
        
        update listDoc;

        insert new Document__c( Statut__c = [SELECT id, key__c FROM reference__c WHERE key__c = 'EXPIRED' AND recordType.developerName = 'Statut_Document'].id,
                                idDocument__c ='34343534534', Date_de_validite__c=system.today()-2, type_de_document__c='id',Compte_Pro__c = idPro);
        
        insert new Document__c( Statut__c = [SELECT id, key__c FROM reference__c WHERE key__c = 'EXPIRED' AND recordType.developerName = 'Statut_Document'].id,
                                idDocument__c ='343434533534534', Date_de_validite__c=system.today()-Integer.valueOf(Label.DocTolerateExpired)-1, type_de_document__c='id',
                                Tolerate_Expired_Delay__c = system.today()-Integer.valueOf(Label.DocTolerateExpired), Evaluate_Expired__c=false,Compte_Pro__c = idPro);

        insert new Document__c( Statut__c = [SELECT id, key__c FROM reference__c WHERE key__c = 'EXPIRED' AND recordType.developerName = 'Statut_Document'].id,
                                idDocument__c ='343435345341', Date_de_validite__c=system.today() - 7, type_de_document__c='picture_profile',Compte_Pro__c = idPro);
        
        insert new Document__c( Statut__c = [SELECT id, key__c FROM reference__c WHERE key__c = 'VALIDATED' AND recordType.developerName = 'Statut_Document'].id,
                                idDocument__c ='343435345342', Date_de_validite__c=system.today()+15, type_de_document__c='insurance_dc',Compte_Pro__c = idPro,Nom_Assureur__c = idAssureur);
        
        

        Batch_DocumentExpires b = new Batch_DocumentExpires (); 
        database.executebatch(b);
        Integer delay = Integer.valueOf(Label.DocTolerateExpired);

        Test.stopTest();

        listDoc = [SELECT id, Statut__r.key__c, Email_rappel_expiration__c,Email_rappel_apres_expiration__c,
                   Evaluate_Expired__c,MC_Email_Expiration_Assurance__c,Date_de_validite__c, Tolerate_Expired_Delay__c,type_de_document__c FROM Document__c];
        for(Document__c doc : listDoc) {
                if(doc.Date_de_validite__c == system.today() + 40) {
                    System.assertEquals( doc.Email_rappel_expiration__c, false);
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, true);

                } else if(doc.Date_de_validite__c == system.today() - 7 && doc.type_de_document__c == 'insurance_rc') {
                    System.assertEquals( doc.Email_rappel_expiration__c, false);
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, true);
                    System.assertEquals( doc.Tolerate_Expired_Delay__c==null, delay==0? true : false);

                } else if(doc.Date_de_validite__c == system.today() - 7 && doc.type_de_document__c =='picture_profile') {
                    System.assertEquals( doc.Email_rappel_expiration__c, false);
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, true);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, false);
                    System.assertEquals( doc.Tolerate_Expired_Delay__c==null, delay==0? true : false);

                } else if(doc.Date_de_validite__c == system.today() + 15 && doc.type_de_document__c == 'insurance_rc') {
                    System.assertEquals( doc.Email_rappel_expiration__c, true); 
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, false); 
                
                } else if(doc.Date_de_validite__c == system.today() + 15 && doc.type_de_document__c == 'insurance_dc') {
                    System.assertEquals( doc.Email_rappel_expiration__c, false); 
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, true); 

                } else if(doc.Date_de_validite__c ==  system.today()-35) {
                    System.assertEquals( doc.Email_rappel_expiration__c, false);
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, true);
                    System.assertEquals( doc.Statut__r.key__c=='EXPIRED', true);
                } else if(doc.Date_de_validite__c ==  system.today()-2) {
                    System.assertEquals( doc.Email_rappel_expiration__c, false);
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c, false);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, true);
                    System.assertEquals( doc.Statut__r.key__c=='EXPIRED', true);
                    System.assertEquals( doc.Tolerate_Expired_Delay__c, delay==0? null : system.today()+Integer.valueOf(Label.DocTolerateExpired));
                } else if(doc.Date_de_validite__c == system.today()-Integer.valueOf(Label.DocTolerateExpired)-1) {
                    System.assertEquals( doc.Email_rappel_expiration__c, false);
                    System.assertEquals( doc.Email_rappel_apres_expiration__c, false);
                    System.assertEquals( doc.Evaluate_Expired__c,delay==0? false : true);
                    System.assertEquals( doc.MC_Email_Expiration_Assurance__c==null, true);
                    System.assertEquals( doc.Statut__r.key__c=='EXPIRED', true);
                    System.assertEquals( doc.Tolerate_Expired_Delay__c, delay==0? system.today() : null);
                } else {
                   System.assertEquals( true, true);
                }

            System.debug('*****  : ' + doc.Statut__r.key__c + '  ' + doc.Email_rappel_expiration__c);
            System.debug('*****  : ' + doc.Email_rappel_expiration__c + '  ' + doc.Email_rappel_apres_expiration__c);
            System.debug('*****  : ' + doc.Evaluate_Expired__c + '  ' + doc.MC_Email_Expiration_Assurance__c);
            System.debug('*****  : ' + doc.Tolerate_Expired_Delay__c );
        }
        //System.assertEquals( listDoc[0].Statut__r.key__c , 'VALIDATED', 'Doit etre en statut valide' );
        //System.assertEquals( listDoc[0].Email_rappel_expiration__c , false, 'Ne doit pas avoir de relance email' );
        
        //System.assertEquals( listDoc[1].Statut__r.key__c , 'VALIDATED', 'Doit etre en staut Valide' );
        //System.assertEquals( listDoc[1].Email_rappel_expiration__c , true, 'Doit avoir une relance email' );
        
        //System.assertEquals( listDoc[2].Statut__r.key__c , 'EXPIRED', 'Doit etre en statut Expiré' );
        //System.assertEquals( listDoc[2].Email_rappel_expiration__c , false, 'Ne Doit pas avoir de relance email' );

        //System.assertEquals( listDoc[3].Statut__r.key__c , 'VALIDATED', 'Doit etre en staut Valide' );
        //System.assertEquals( listDoc[3].Email_rappel_expiration__c , false, 'Batch a reseté l email de rappel' );
        
    }
}