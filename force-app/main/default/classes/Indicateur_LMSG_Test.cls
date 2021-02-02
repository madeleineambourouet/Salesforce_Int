/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-27-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-11-2020   Hassan Dakhcha   Initial Version
**/
@isTest
private class Indicateur_LMSG_Test{

    @isTest 
    static void indicateurProjet() {
        /*
        'Date_modification_statut__c ' => 'Statut__c' => 'ALL'
        'Date_Dernier_Statut_Depose__c' => 'Statut__c' => 'VALIDATING'
        'Date_qualification_PP__c' => 'Statut__c;Sous_statut__c' => 'VALIDATING;Qualifie_PP,Differe,Non_publiable'
        'Date_publication_PP' => 'Statut__c' => 'PUBLISHED'  
        */
        Test.startTest();
        Projet_LMSG__c projet = [ SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                   Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        System.assertNotEquals(null, projet.Date_modification_statut__c, 'A la creation la Date_modification_statut__c doit etre remplie');
        System.assertEquals(null, projet.Date_dernier_statut_depose__c);
        System.assertEquals(null, projet.Date_qualification_PP__c);
        System.assertEquals(null, projet.Date_publication_PP__c);
        System.assertEquals(null, projet.Date_signature_devis__c);

        System.assertEquals('DRAFT', projet.Statut__c);
        
        User PP = [SELECT id FROM User WHERE Email='ProjectPlace@testclasssgdbf.com'];
        System.runAs(PP) {
            projet.Statut__c = 'VALIDATING';
            update projet;
        }
        projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                  Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        System.assertEquals('VALIDATING', projet.Statut__c);
        System.assertNotEquals(null, projet.Date_dernier_statut_depose__c);
        System.assertEquals(null, projet.Date_signature_devis__c);
        System.assertEquals(null, projet.Date_qualification_PP__c);

        User CRC = [SELECT id FROM User WHERE Email='usersgCRCf@testclasssgdbf.com'];
        System.runAs(CRC) {
            projet.Sous_Statut__c = 'Qualifie_PP';
            update projet;
        }

        projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                  Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        Integer qualifTime = dateTime.now().millisecond();
        System.assertEquals('PUBLISHED', projet.Statut__c);
        System.assertEquals(null, projet.Sous_Statut__c);

        System.assertNotEquals(null, projet.Date_dernier_statut_depose__c);
        System.assertNotEquals(null, projet.Date_qualification_PP__c);
        System.assertEquals(null, projet.Date_signature_devis__c);


        projet.Date_dernier_statut_depose__c = null;
        projet.Date_qualification_PP__c = null;
        projet.Statut__c = 'VALIDATING';
        update projet;

        projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                  Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        System.assertEquals(null, projet.Date_qualification_PP__c);
        System.assertNotEquals(null, projet.Date_dernier_statut_depose__c);
        System.runAs(CRC) {
            projet.Sous_Statut__c = 'Differe';
            projet.Motif__c = 'Autorisation_manquante';
            update projet;
        }
        projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
        Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        System.assertNotEquals(null, projet.Date_qualification_PP__c);
        System.assertEquals(null, projet.Date_signature_devis__c);

        projet.Date_dernier_statut_depose__c = null;
        projet.Date_qualification_PP__c = null;
        projet.Statut__c = 'VALIDATING';
        projet.Motif__c = '';
        update projet;
        projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                            Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        System.assertNotEquals(null, projet.Date_dernier_statut_depose__c);
        System.assertEquals(null, projet.Date_qualification_PP__c);
        System.runAs(CRC) {
            projet.Sous_Statut__c = 'Non_publiable';
            projet.Motif__c = 'Doublon';
            update projet;
        }
        projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                  Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

        System.assertNotEquals(null, projet.Date_qualification_PP__c);
        System.assertEquals(null, projet.Date_signature_devis__c);

        System.runAs(PP) {
            Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id ,
                                                              Projet_LMSG__c = projet.id);
            insert MER;
    
            Devis_LMSG__c quote = new Devis_LMSG__c(Date_demarrage_chantier_theorique__c = system.today() + 10,
                                                    Date_emission_du_devis__c = system.today(),
                                                    Description__c = 'Devis tres raisonable',
                                                    Mise_en_relation_LMSG__c = MER.id,
                                                    Montant_HT__c = 5000,
                                                    Montant_TTC__c = 5500,
                                                    Statut__c = 'PENDING', 
                                                    Pourcentage_accompte__c = 25,
                                                    Type_de_devis__c = 'INITIAL'
                                                    );
            insert quote;


            projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
                  Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

            quote = [SELECT id, Date_modification_statut__c, Date_signature_devis__c FROM Devis_LMSG__c];

            System.assertEquals(null, projet.Date_signature_devis__c);
            System.assertEquals(null, quote.Date_signature_devis__c);
            System.assertNotEquals(null, quote.Date_modification_statut__c);
            quote.Statut__c = 'SIGNED';
            update quote;

            projet = [SELECT id, Statut__c, Sous_Statut__c, Date_dernier_statut_depose__c, Date_modification_statut__c, Date_publication_PP__c, 
            Date_qualification_PP__c, Date_signature_devis__c FROM Projet_LMSG__c];

            quote = [SELECT id, Date_modification_statut__c, Date_signature_devis__c FROM Devis_LMSG__c];
            
            System.assertNotEquals(null, projet.Date_signature_devis__c);
            System.assertNotEquals(null, quote.Date_signature_devis__c);
            System.assertNotEquals(null, quote.Date_modification_statut__c);
        }
        Test.stopTest();
    }

     /*
    MER 
            'Date_modification_statut__c' => 'Statut__c' => 'ALL'
            'Date_modification_statut_RDV__c' => 'statut_RDV__c' => 'ALL'
            'Date_positionnement__c' => 'Statut__c' => 'Pro_positionne'
            'Date_selection__c' => 'Statut__c' => 'Pro_selectionne'
   */
    @isTest 
    static void indicateurMer() {
        Test.startTest();

        User PP = [SELECT id FROM User WHERE Email='ProjectPlace@testclasssgdbf.com'];
        System.runAs(PP) {
            Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id ,
                                                              Projet_LMSG__c = [SELECT id FROM Projet_LMSG__c].id,
                                                              Statut__c = '',
                                                              statut_RDV__c = null);
            insert MER;
            MER = [SELECT  id, Statut__c, statut_RDV__c, Date_modification_statut__c,
                   Date_modification_statut_RDV__c, Date_positionnement__c, Date_selection__c 
                   FROM Mise_en_relation__c];

            System.assertNotEquals(null, MER.Date_modification_statut__c);
            System.assertNotEquals(null, MER.Date_modification_statut_RDV__c);

            System.assertEquals(null, MER.Date_positionnement__c);
            System.assertEquals(null, MER.Date_selection__c);

            MER.Date_modification_statut__c = null;
            MER.Date_modification_statut_RDV__c = null;
            update MER;
            MER = [SELECT  id, Statut__c, statut_RDV__c, Date_modification_statut__c,
                   Date_modification_statut_RDV__c, Date_positionnement__c, Date_selection__c 
                   FROM Mise_en_relation__c];
            System.assertEquals(null, MER.Date_modification_statut__c);
            System.assertEquals(null, MER.Date_modification_statut_RDV__c);

            MER.Statut__c = 'Pro_positionne';
            update MER;

            MER = [SELECT  id, Statut__c, statut_RDV__c, Date_modification_statut__c,
                   Date_modification_statut_RDV__c, Date_positionnement__c, Date_selection__c 
                   FROM Mise_en_relation__c];
            System.assertNotEquals(null, MER.Date_modification_statut__c);
            System.assertEquals(null, MER.Date_modification_statut_RDV__c);

            System.assertNotEquals(null, MER.Date_positionnement__c);
            System.assertEquals(null, MER.Date_selection__c);

            MER.Date_modification_statut__c = null;
            MER.Date_selection__c = null;
            update MER;
            MER = [SELECT  id, Statut__c, statut_RDV__c, Date_modification_statut__c,
                   Date_modification_statut_RDV__c, Date_positionnement__c, Date_selection__c 
                   FROM Mise_en_relation__c];

            System.assertEquals(null, MER.Date_modification_statut__c);
            System.assertEquals(null, MER.Date_selection__c);
            System.assertNotEquals(null, MER.Date_positionnement__c);

            MER.Statut__c = 'Pro_selectionne';
            update MER;
            MER = [SELECT  id, Statut__c, statut_RDV__c, Date_modification_statut__c,
                   Date_modification_statut_RDV__c, Date_positionnement__c, Date_selection__c 
                   FROM Mise_en_relation__c];

            System.assertNotEquals(null, MER.Date_modification_statut__c);
            System.assertNotEquals(null, MER.Date_selection__c);
            System.assertNotEquals(null, MER.Date_positionnement__c);

            MER.Date_modification_statut__c = null;
            MER.Date_selection__c = null;
            MER.Date_positionnement__c = null;
            MER.Statut__c = 'Pro_rencontre';
            update MER;
            MER = [SELECT  id, Statut__c, statut_RDV__c, Date_modification_statut__c,
            Date_modification_statut_RDV__c, Date_positionnement__c, Date_selection__c 
            FROM Mise_en_relation__c];

            System.assertNotEquals(null, MER.Date_modification_statut__c);
            System.assertEquals(null, MER.Date_selection__c);
            System.assertEquals(null, MER.Date_positionnement__c);
        }
        Test.stopTest();
    }
    
     /*
    Devis LMSG
    'Date_modification_statut__c' => 'Statut__c' => 'ALL'
    'Date_signature_devis' => 'Statut__c' => 'SIGNED'
    */
    @isTest 
    static void indicateurDevis() {

        User PP = [SELECT id FROM User WHERE Email='ProjectPlace@testclasssgdbf.com' LIMIT 1];
        System.runAs(PP) {
            Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id ,
                                                              Projet_LMSG__c = [SELECT id FROM Projet_LMSG__c].id);
            insert MER;
    
            Devis_LMSG__c quote = new Devis_LMSG__c(Date_demarrage_chantier_theorique__c = system.today() + 10,
                                                    Date_emission_du_devis__c = system.today(),
                                                    Description__c = 'Devis tres raisonable',
                                                    Mise_en_relation_LMSG__c = MER.id,
                                                    Montant_HT__c = 5000,
                                                    Montant_TTC__c = 5500,
                                                    Statut__c = 'PENDING', 
                                                    Pourcentage_accompte__c = 25);
            insert quote;

            quote = [SELECT id, Date_modification_statut__c, Date_signature_devis__c FROM Devis_LMSG__c];
            System.assertNotEquals(null, quote.Date_modification_statut__c);
            System.assertEquals(null, quote.Date_signature_devis__c);

            quote.Date_modification_statut__c = null;
            quote.Date_signature_devis__c = null;
            update quote;

            quote = [SELECT id, Date_modification_statut__c, Date_signature_devis__c FROM Devis_LMSG__c];

            System.assertEquals(null, quote.Date_modification_statut__c);
            System.assertEquals(null, quote.Date_signature_devis__c);

            quote.Statut__c = 'SIGNED';
            update quote;
            
            quote = [SELECT id, Date_modification_statut__c, Date_signature_devis__c FROM Devis_LMSG__c];

            System.assertNotEquals(null, quote.Date_modification_statut__c);
            System.assertNotEquals(null, quote.Date_signature_devis__c);

        }

    }

	@isTest static void indicateurFacture() {
        // code_block	
        Test.startTest();

        Mise_en_relation__c MER = new Mise_en_relation__c(Compte_Pro__c = [SELECT id FROM ACCOUNT WHERE login__c ='mail1@testorg.com'].id ,
                                                            Projet_LMSG__c = [SELECT id FROM Projet_LMSG__c].id);
        insert MER;
        Facture__c fac = new Facture__c(Mise_en_relation__c= MER.id, Identifiant_PP__c='dzedezezfezfzefe');
        insert fac;

        fac = [SELECT id , Statut__c, Date_modification_statut__c FROM Facture__c];

        System.assertNotEquals(null, fac.Date_modification_statut__c);

        fac.Date_modification_statut__c = null;
        update fac;

        fac = [SELECT id , Statut__c, Date_modification_statut__c FROM Facture__c];
        System.assertEquals(null, fac.Date_modification_statut__c);

        fac.Statut__c = 'PAID';
        update fac;

        fac = [SELECT id , Statut__c, Date_modification_statut__c FROM Facture__c];
        System.assertNotEquals(null, fac.Date_modification_statut__c);

        Projet_LMSG__c project = [SELECT id, Date_facture_acompte_emise__c, Date_facture_commission__c FROM Projet_LMSG__c];
        System.assertEquals(null, project.Date_facture_acompte_emise__c);
        System.assertEquals(null, project.Date_facture_commission__c);

        fac = new Facture__c(Mise_en_relation__c= MER.id, Identifiant_PP__c='dzededezezfezfzefe', Type_facture__c ='DOWN_PAYMENT');
        insert fac;
        project = [SELECT id, Date_facture_acompte_emise__c, Date_facture_commission__c FROM Projet_LMSG__c];
        System.assertEquals(Date.today(), project.Date_facture_acompte_emise__c);
        System.assertEquals(null, project.Date_facture_commission__c);

        fac = new Facture__c(Mise_en_relation__c= MER.id, Identifiant_PP__c='dzedeaaezezfezfzefe', Type_facture__c ='FEE_PAYMENT');
        insert fac;
        project = [SELECT id, Date_facture_acompte_emise__c, Date_facture_commission__c FROM Projet_LMSG__c];
        System.assertEquals(Date.today(), project.Date_facture_acompte_emise__c);
        System.assertEquals(Date.today(), project.Date_facture_commission__c);

        List<Facture__c> facList = new List<Facture__c>();
        facList.add(new Facture__c(Mise_en_relation__c= MER.id, Identifiant_PP__c='dzedezretcscsezfezfzefe', 
                                        Date_creation_facture__c=date.today()-2, Type_facture__c ='DOWN_PAYMENT'));
        facList.add(new Facture__c(Mise_en_relation__c= MER.id, Identifiant_PP__c='dzedefsfstgrgtzezfezfzefe', 
                                        Date_creation_facture__c=date.today()-1, Type_facture__c ='FEE_PAYMENT'));
        insert facList;

        project = [SELECT id, Date_facture_acompte_emise__c, Date_facture_commission__c FROM Projet_LMSG__c];
        System.assertEquals(Date.today()-2, project.Date_facture_acompte_emise__c);
        System.assertEquals(Date.today()-1, project.Date_facture_commission__c);

        Test.stopTest();

    }
    
    @isTest static void indicateurPaiement() {

        Test.startTest();
        // Create KYB Documents:
        List<Reference__c> statusRef = [SELECT id, key__c FROM Reference__c WHERE recordType.DeveloperName = 'Statut_Document'];
        System.assertNotEquals(true, statusRef.isEmpty());
        Map<String, id> statusMap = new Map<String, id> ();
        for(Reference__c ref : statusRef) {
            statusMap.put(ref.key__c, ref.id);
        }

        Account pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' || pro.id_status__c=='VALIDATED' || pro.rib_status__c=='VALIDATED' || pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE par defaut');
        List<Document__c> docList = new List<Document__c>();
		Document__c idDoc = new Document__c(Compte_Pro__c = pro.id,
									Type_de_document__c = 'id',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = statusMap.get('NEW'));
		Document__c statusDoc = new Document__c(Compte_Pro__c = pro.id,
									Type_de_document__c = 'company_status',
									idDocument__c = String.valueOf(Math.random() * 100),
                                    Statut__c = statusMap.get('NEW'));
        docList.add(idDoc);
        docList.add(statusDoc);
		insert docList;

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' || pro.id_status__c=='VALIDATED' || pro.rib_status__c=='VALIDATED' || pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');

        // ID  TESTS : 
        docList[0].statut__c = statusMap.get('VALIDABLE');
        docList[0].Date_de_validite__c = System.Today();
        update docList[0];

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' || pro.id_status__c=='VALIDATED' || pro.rib_status__c=='VALIDATED' || pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');

        // ID  TESTS : 
        docList[0].statut__c = statusMap.get('VALIDATED');
        docList[1].Date_de_validite__c = System.Today();
        docList[1].statut__c = statusMap.get('VALIDATED');
        update docList;

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'PAS Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');

        Document__c kbisDoc = new Document__c( Compte_Pro__c = pro.id,
                                                    Type_de_document__c = 'kbis',
                                                    idDocument__c = String.valueOf(Math.random() * 100),
                                                    Statut__c = statusMap.get('VALIDATED'));
        insert kbisDoc;
        docList.add(kbisDoc);

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'PAS Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED', 'kbis OK');

        Document__c ribDoc = new Document__c( Compte_Pro__c = pro.id,
                                                Type_de_document__c = 'rib',
                                                idDocument__c = String.valueOf(Math.random() * 100),
                                                Statut__c = statusMap.get('NEW'));
        insert ribDoc;
        docList.add(ribDoc);

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED', 'kbis OK');
        System.assertEquals(false, pro.rib_status__c=='VALIDATED', 'rib KO');

        ribDoc.Statut__c = statusMap.get('VALIDATED');
        update ribDoc;

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a TRUE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED', 'kbis OK');
        System.assertEquals(true, pro.rib_status__c=='VALIDATED', 'rib OK');

        kbisDoc.Statut__c = statusMap.get('REFUSED');
        update kbisDoc;
        
        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED', 'kbis Refused');
        System.assertEquals(true, pro.rib_status__c=='VALIDATED', 'rib OK');

        idDoc.Statut__c = statusMap.get('EXPIRED');
        update idDoc;

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(false, pro.id_status__c=='VALIDATED', 'ID EXPIRED');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED', 'kbis REFUSED');
        System.assertEquals(true, pro.rib_status__c=='VALIDATED', 'rib OK');

        statusDoc.statut__c = statusMap.get('REFUSED');
        ribDoc.statut__c    = statusMap.get('REFUSED');
        update statusDoc;
        update ribDoc;

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(false, pro.id_status__c=='VALIDATED', 'ID EXPIRED');
        System.assertEquals(false, pro.statut_status__c=='VALIDATED', 'Status REFUSED');
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED', 'kbis REFUSED');
        System.assertEquals(false, pro.rib_status__c=='VALIDATED', 'rib REFUSED');

        statusDoc.statut__c = statusMap.get('VALIDATED');
        ribDoc.statut__c    = statusMap.get('VALIDATED');
        idDoc.statut__c = statusMap.get('VALIDATED');
        kbisDoc.statut__c    = statusMap.get('VALIDATED');
        update docList;

        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED', 'kbis OK');
        System.assertEquals(true, pro.rib_status__c=='VALIDATED', 'rib OK');

        // Delete
        delete ribDoc;
        pro = [SELECT id, kbis_status__c, id_status__c, rib_status__c, statut_status__c FROM ACCOUNT WHERE login__c ='mail1@testorg.com'];
        System.assertEquals(false, pro.kbis_status__c=='VALIDATED' && pro.id_status__c=='VALIDATED' && pro.rib_status__c=='VALIDATED' && pro.statut_status__c=='VALIDATED', 'Tous les indicateurs paiement doivent etre a FALSE');
        System.assertEquals(true, pro.id_status__c=='VALIDATED', 'ID OK');
        System.assertEquals(true, pro.statut_status__c=='VALIDATED', 'Status OK');
        System.assertEquals(true, pro.kbis_status__c=='VALIDATED', 'kbis OK');
        System.assertEquals(false, pro.rib_status__c=='VALIDATED', 'rib DELETED');

        Test.stopTest();

    }


    @TestSetup
    static void makeData() {
        insertRefs();
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
                                    Statut__c = 'DRAFT');

 
   }

    static void insertRefs() {
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
        
        listReferences.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
		listReferences.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
		listReferences.add(TestFactory.createReference('StatutDocument', 'A valider','VALIDABLE','A valider'));
        listReferences.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));
        listReferences.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listReferences.add(TestFactory.createReference('StatutDocument', 'Refusé','REFUSED','Refusé'));
        listReferences.add(TestFactory.createReference('StatutDocument', 'Doublon','DUPLICATED','Doublon'));

        insert listReferences;
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