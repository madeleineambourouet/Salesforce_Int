@isTest(SeeAllData = true)
private class GetDeletedRecordsTest
{
    static testMethod void test_Zuora_SPCharge(){
    Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;



        Account a = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116',  Pays_LKP__c = FR.id, 
                                   Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                   Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest');
   
        insert a;
        ID accountID = [SELECT id from Account where Name = 'Test account' order by createddate desc LIMIT 1].id; 
        Zuora__SubscriptionProductCharge__c ZSPC = new Zuora__SubscriptionProductCharge__c(Name= 'Test Zuora', Zuora__Account__c=accountID);
        insert ZSPC; 
        
        ID deletedZuora = [SELECT Id FROM Zuora__SubscriptionProductCharge__c WHERE Name = 'Test Zuora'].id;
        System.debug ('>>>>>>> the account id deletedAccount : ' + deletedZuora + '<<<<<<<');
        try
            {
            delete ZSPC;
            ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Zuora__SubscriptionProductCharge__c' ORDER BY Deleted_Date__c  DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from account deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.debug ('>>>>>>> the deleted id from item deleted deletedRecord.id : ' + deletedRecord.id + '<<<<<<<');
       
            System.assertEquals(deletedZuora, deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This Account cannot be Deleted. please contact the Administration Department. Thank you.'));
        }

        Test.stopTest();
    }

    static testMethod void test_account(){
    Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;

         

        Account a = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116',  Pays_LKP__c = FR.id, 
                                   Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                   Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest');
   
        insert a;
        
        ID deletedAccount = [SELECT Id FROM Account WHERE Name = 'Test account'].id;
        System.debug ('>>>>>>> the account id deletedAccount : ' + deletedAccount + '<<<<<<<');
        try
            {
            delete a;
            ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'account' ORDER BY Deleted_Date__c  DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from account deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.debug ('>>>>>>> the deleted id from item deleted deletedRecord.id : ' + deletedRecord.id + '<<<<<<<');
       
            System.assertEquals(deletedAccount, deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This Account cannot be Deleted. please contact the Administration Department. Thank you.'));
        }

        Test.stopTest();
    }
    
    static testMethod void test_contact(){
        Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                    Pays_LKP__c = FR.id, Code_postal__c = CP.Id, Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact de suppression', LastName = 'Test de suppression', Contact_Principal_O_N__c = true,  Contact_de_facturation__c = true, AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
        ID deletedContact = [SELECT Id FROM Contact WHERE LastName = 'Test de suppression' AND FirstName = 'Contact de suppression'  LIMIT 1].id;
           System.debug ('>>>>>>> the contact id : ' + deletedContact );
       try
         {
          delete ctc;
          ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Contact' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from Contact deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.assertEquals(deletedContact , deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This contact cannot be Deleted. please contact the Administration Department. Thank you.'));
        }   
        Test.stopTest();
     }
       
    static testMethod void test_geocat(){
        Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                    Pays_LKP__c = FR.id, Code_postal__c = CP.Id, Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact de suppression', LastName = 'Test de suppression', Contact_Principal_O_N__c = true,  Contact_de_facturation__c = true, AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
                
        GeoCat__c GC = new GeoCat__c(Adresse__c = CP.id, Contact__c = ctc.Id, Zone_d_intervention__c = 20, Categorie_niveau__c = '',FaminePoids__c=10);
        insert GC; 
        ID id_Contact = [SELECT Id FROM Contact WHERE LastName = 'Test de suppression' AND FirstName = 'Contact de suppression'  LIMIT 1].id;
        
        ID deletedGC = [SELECT id FROM GeoCat__c WHERE Contact__c in (SELECT Id FROM Contact WHERE LastName = 'Test de suppression' AND FirstName = 'Contact de suppression') LIMIT 1].id;
        System.debug ('>>>>>>> the GeoCat id : ' + deletedGC );
        
       try
         {
          delete GC;
          ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'GeoCat__c' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from GeoCat deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.assertEquals(deletedGC , deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This GeoCat cannot be Deleted. please contact the Administration Department. Thank you.'));
        }   
        Test.stopTest();
     }

    static testMethod void test_certification(){
     Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTNomCertif = [SELECT Id FROM RecordType WHERE DeveloperName like 'Document_Certification' LIMIT 1].Id;
        
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c NomCertif = new Reference__c(RecordTypeId = RTNomCertif, Name ='CAAT', key__c ='C22');
        insert NomCertif; 
        
                
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Document_Certification__c dc = new Document_Certification__c( Compte__c=compte.Id, Name='TestCErtification' );
        System.debug ('>>>>>>> Compte__c=compte.Id =:'+dc.Compte__c);
        System.debug ('>>>>>>> Nom__c=NomCertif.id =:'+dc.Nom__c);
        System.debug ('>>>>>>> Date_d_expiration__c=:'+dc.Date_d_expiration__c);
        System.debug ('>>>>>>> Name =:'+dc.Name);
        
        insert dc;
        
        ID deletedDC = [SELECT id FROM Document_Certification__c WHERE compte__c in (SELECT Id FROM Account WHERE Name = 'Test Account' AND SIRET_texte__c = '32212091600208' ) LIMIT 1].id;
        System.debug ('>>>>>>> the Document_Certification id : ' + deletedDC );
        
       try
         {
          delete dc;
          ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Document_Certification__c' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from Document_Certification deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.assertEquals(deletedDC , deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This Document_Certification cannot be Deleted. please contact the Administration Department. Thank you.'));
        }   
        Test.stopTest();
     }

    static testMethod void test_assurance(){
     Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTNomAssurance = [SELECT Id FROM RecordType WHERE DeveloperName = 'Document_Assurance' LIMIT 1].Id;
        
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c NomAssurance = new Reference__c(RecordTypeId = RTNomAssurance, Name ='SAA', key__c ='B2');
        insert NomAssurance ; 
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                      Pays_LKP__c = FR.id, Code_postal__c = CP.Id, Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Document_Assurance__c da = new Document_Assurance__c(Compte__c=compte.Id, Nom__c=NomAssurance.id );
        System.debug ('>>>>>>> Compte__c=compte.Id =:'+da.Compte__c);
        System.debug ('>>>>>>> Nom__c=NomAssurance.id =:'+da.Nom__c);
        insert da;
        
        ID deletedDA = [SELECT id FROM Document_Assurance__c WHERE compte__c in (SELECT Id FROM Account WHERE Name = 'Test Account' AND SIRET_texte__c = '32212091600208' ) LIMIT 1].id;
        System.debug ('>>>>>>> the Document_Assurance__c id : ' + deletedDA );
        
       try
         {
          delete da;
          ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Document_Assurance__c' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from Document_Assurance__c deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.assertEquals(deletedDA , deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This Document_Assurance__c cannot be Deleted. please contact the Administration Department. Thank you.'));
        }   
        Test.stopTest();
     }


    static testMethod void test_competence(){
        Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                    Pays_LKP__c = FR.id, Code_postal__c = CP.Id, Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact de suppression', LastName = 'Test de suppression', Contact_Principal_O_N__c = true,    Contact_de_facturation__c = true, AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
        
        System.debug ('>>>>>>> CREATION GeoCat <<<<<<<');        
        GeoCat__c GC = new GeoCat__c(Adresse__c = CP.id, Contact__c = ctc.Id, Zone_d_intervention__c = 20, Categorie_niveau__c = '',FaminePoids__c=10);
        insert GC; 
        
        ID id_Contact = [SELECT Id FROM Contact WHERE LastName = 'Test de suppression' AND FirstName = 'Contact de suppression'  LIMIT 1].id;
        
        ID deletedGC = [SELECT id FROM GeoCat__c WHERE Contact__c in (SELECT Id FROM Contact WHERE LastName = 'Test de suppression' AND FirstName = 'Contact de suppression') LIMIT 1].id;
        System.debug ('>>>>>>> the GeoCat id : ' + deletedGC );
         
        System.debug ('>>>>>>> CREATION COMPETENCE <<<<<<<');
        
        Competence__c competence = new Competence__c(Name = 'TEST_Competence', GeoCat__c = GC.id);
        insert competence;
         Competence__c competence1 = new Competence__c(Name = 'TEST_Competence1', GeoCat__c = GC.id);
        insert competence1;
        
        ID deletedCompetence = [SELECT id FROM Competence__c  WHERE name ='TEST_Competence1' LIMIT 1].id;
             System.debug ('>>>>>>> deletedCompetence.id : '+ deletedCompetence );

       try{
         delete competence1;
         ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Competence__c' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from Competence__c deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');

        System.assertEquals(deletedCompetence , deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This Competence cannot be Deleted. please contact the Administration Department. Thank you.'));
        } 
        Test.stopTest();
     }
     
    static testMethod void test_projet(){
    Test.startTest();
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;

        
        Account atc = new Account(Salutation = 'M', FirstName = 'Contact de suppression', LastName = 'Test de suppression',  Contact_Principal_O_N__pc = false, Contact_de_facturation__pc = false, Phone = '+33111111111');
        insert atc;
         System.debug ('>>>>>>> atc :'+ atc);
        ID ContactID = [SELECT id from Account where FirstName = 'Contact de suppression' AND LastName = 'Test de suppression' LIMIT 1].id ; 
         System.debug ('>>>>>>>ContactID :' + ContactID); 
        Projet__c projet = new  Projet__c ( Particulier__c = ContactID , Code_postal__c = CP.id, Pays_LKP__c = FR.id,
                        DIMENSION1__c=11.00, DIMENSION1_2__c=1.0, DIMENSION2__c=1.0, DIMENSION2_2__c=1.0, DIMENSION3__c=1.0, QUANTITE__c=1, LISTE__c='1', LISTE_2__c='1', LISTE_3__c='1', QUESTION_OUINON__c='oui', QUESTION_OUINON_2__c='oui', QUESTION_OUINON_3__c='oui', LISTE_QUAND__c='dans un mois', BUDGET__c=1220, TEXTELIBRE__c='Ceci est pour les besoins techniques');
        insert projet;
        
        ID deletedProject = [SELECT Id FROM Projet__c order by createddate desc LIMIT 1 ].id;
        System.debug ('>>>>>>> the account id deletedProject : ' + deletedProject + '<<<<<<<');
        try
            {
            delete projet;
            ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Projet__c' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from account deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.debug ('>>>>>>> the deleted id from item deleted deletedRecord.id : ' + deletedRecord.id + '<<<<<<<');
       
            //System.assertEquals(deletedProject, deletedRecord.Deleted_ID__c );
        }catch (exception e){
             //system.assert(e.getMessage().contains('This Account cannot be Deleted. please contact the Administration Department. Thank you.'));
        }

        Test.stopTest();
    }
    
    static testMethod void test_Intermediation(){
    Test.startTest();
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
  
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        //Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        
        insert pays; 
        insert CP; 
        insert competence; 
        insert NAF; 
        insert enseigne; 
        //insert TV;
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        insert particulier;
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        insert professionnel;
        Contact contactPro = TestFactory.createContact(professionnel);
        insert contactPro;
        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        insert project;
        Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
        insert miseEnRelation;

         System.debug ('>>>>>>> miseEnRelation :'+ miseEnRelation);
        
        
        ID deletedmiseEnRelation = [SELECT Id FROM Intermediation__c order by createddate desc LIMIT 1 ].id;
        System.debug ('>>>>>>> id deletedmiseEnRelation : ' + deletedmiseEnRelation + '<<<<<<<');
        try
            {
            delete miseEnRelation;
            ItemDeleted__c deletedRecord = [SELECT id, Deleted_ID__c FROM ItemDeleted__c WHERE Name = 'Intermediation__c' ORDER BY Deleted_Date__c DESC LIMIT 1];
            System.debug ('>>>>>>> the deleted id from account deletedRecord.Deleted_ID__c : ' + deletedRecord.Deleted_ID__c + '<<<<<<<');
            System.debug ('>>>>>>> the deleted id from item deleted deletedRecord.id : ' + deletedRecord.id + '<<<<<<<');
       
            System.assertEquals(deletedmiseEnRelation, deletedRecord.Deleted_ID__c );
        }catch (exception e){
             system.assert(e.getMessage().contains('This Account cannot be Deleted. please contact the Administration Department. Thank you.'));
        }

        Test.stopTest();
    }

}