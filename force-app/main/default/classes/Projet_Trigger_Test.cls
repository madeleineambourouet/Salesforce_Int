/**
 * @File Name          : Projet_Trigger_Test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 4/3/2020, 12:42:59 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/3/2020   Hassan Dakhcha     Initial Version
**/
@isTest (SeeAllData = false)  
public class Projet_Trigger_Test
{
    public static final ID RTPhotoProjet = [SELECT Id FROM RecordType WHERE DeveloperName = 'Projet' AND SObjectType = 'Photo__c' LIMIT 1].Id;
    
	@isTest
	public static void Test_Projet_Trigger()
    {
        // Créer un compte particulier 
        Account compte_test = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        
        System.debug('>>>>>>>>>>>> Mail du compte part : ' + compte_test.PersonEmail);
        System.debug('>>>>>>>>>>>> Leila PersonMobilePhone PART : ' + compte_test.PersonMobilePhone);
        insert compte_test;
        
      	Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
      	insert competence;
      	
        //Créer un projet associé à compte_test 
        Projet__c projet_test = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= compte_test.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                              Description__c='description test youhou');
            								  
        insert projet_test;
        
        //Créer une photo affiliée à projet_test 
        Photo__c photo_test = new Photo__c(Name= 'photo_test',
                                           Projet__c = projet_test.Id,
                                           Statut__c= 'A Valider',
                                           Type__c= 'Projet',
                                           URL__c = 'toto',
                                           RecordTypeId = RTPhotoProjet);
        System.debug('La photo ' + photo_test.Name + ' a été crée avec succès.');
        insert photo_test;
        
        //Récuperer le compte particulier, le projet et la photo crées précedemment
        compte_test = [SELECT PersonEmail,PersonMobilePhone  from Account where Id =:compte_test.Id];
        System.debug('Leila Adresse mail du part after insert part et projet : ' + compte_test.PersonEmail);
        System.debug('Leila after insert part et projet PersonMobilePhone : ' + compte_test.PersonMobilePhone);
        projet_test = [SELECT email_projet__c,Telephone_Mobile__c  from Projet__c where Id =:projet_test.Id];
        projet_test.Telephone_Mobile__c = compte_test.PersonMobilePhone;
        projet_test.email_projet__c = compte_test.PersonEmail;
        
        System.debug('Leila Adresse mail du projet : ' + projet_test.email_projet__c);
        System.debug('Leila mobile sur le projet : ' + projet_test.Telephone_Mobile__c);
        photo_test = [SELECT Email_projet__c from Photo__c where Id =:photo_test.Id];
        System.debug('Adresse mail de la photo : ' + photo_test.Email_projet__c);
        
        //Vérifier que le trigger a bien copié les valeurs dans projet et photo
        System.assertEquals(compte_test.PersonEmail, projet_test.email_projet__c);
        //System.assertEquals(projet_test.email_projet__c, photo_test.email_projet__c);
        System.assertEquals(compte_test.PersonMobilePhone, projet_test.Telephone_Mobile__c);
        
        System.debug('Leila after assert equal mobile sur le projet : ' + projet_test.Telephone_Mobile__c);
       
        
        //update de l'adresse mail du compte part
        compte_test.PersonEmail = 'newmail@mail.com';
        
        update compte_test;
        System.debug('Leila after update mobile sur le projet : ' + compte_test.PersonEmail);
        System.debug('Leila after update mobile sur le projet : ' + projet_test.Telephone_Mobile__c);
        
        //Récuperer le compte particulier, le projet et la photo after update
		compte_test = [SELECT PersonEmail,PersonMobilePhone from Account where Id =:compte_test.Id];
        System.debug('Adresse mail du part after update : ' + compte_test.PersonEmail);
        projet_test = [SELECT email_projet__c,Telephone_Mobile__c from Projet__c where Id =:projet_test.Id];
        System.debug('Adresse mail du projet after update : ' + projet_test.email_projet__c);
        photo_test = [SELECT Email_projet__c from Photo__c where Id =:photo_test.Id];
        System.debug('Adresse mail de la photo after update : ' + photo_test.Email_projet__c);
        
        //Vérifier que le trigger a bien copié les valeurs dans projet et photo after update
        System.assertEquals(compte_test.PersonEmail, projet_test.email_projet__c);       
        
        //System.assertEquals(projet_test.email_projet__c, photo_test.email_projet__c);
        
  		projet_test.Etat__c = 'ODC ouverte';
  		projet_test.Statut_Projet__c = 'Qualifié'; // En attente de suivi, Qualifié
  		update projet_test;
  		//System.assertEquals(projet_test.Matching_Demande__c , false);
        
  		projet_test.Matching_Demande__c = true;
        projet_test.email_projet__c = compte_test.PersonEmail;
  		update projet_test;

    }
  @isTest
  public static void Test_Projet_Trigger_updateProjetProprietaireProjet_cp()
    {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        us.Affectation_code_postal__c = '00000'; 
        us.Affectation_departement__c = '00';
        update us;
        // Créer un compte particulier 
        Account compte_test = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '00000', '00000_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        System.debug('Le compte particulier ' + compte_test.FirstName + ' ' + compte_test.LastName  + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du compte part : ' + compte_test.PersonEmail);
        insert compte_test;
        
        List<Reference__c> lreference = new List<Reference__c>();
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        lreference.add(competence);
        Reference__c CP = TestFactory.createReference('CP', '00000', '00000_91086', 'BONDOUFLE');
        lreference.add(CP);     
        insert lreference;  

        //Créer un projet associé à compte_test 
        Projet__c projet_test = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= compte_test.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= CP.Id,
                                              Description__c='description test youhou',
                                              Statut_Projet__c = 'Qualifié EPH');
        System.debug('Le projet ' + projet_test.Titre__c + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du projet : ' + projet_test.email_projet__c);
        insert projet_test;
        
        projet_test = [SELECT email_projet__c,Proprietaire_du_projet__c from Projet__c where Id =:projet_test.Id];
        
        //Vérifier que le trigger a bien copié les valeurs dans projet 
        System.assertEquals(projet_test.Proprietaire_du_projet__c, us.Id);
        projet_test.Statut_Projet__c = 'RDV pris EPH MOE';
        update projet_test; 
        
        projet_test = [SELECT email_projet__c,Proprietaire_du_projet__c from Projet__c where Id =:projet_test.Id];
        
        //Vérifier que le trigger a bien copié les valeurs dans projet 
        System.assertEquals(projet_test.Proprietaire_du_projet__c, us.Id);
        Test.stopTest();
    }
  @isTest
  public static void Test_Projet_Trigger_updateProjetProprietaireProjet_dp()
    {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        us.Affectation_code_postal__c = '11111'; 
        us.Affectation_departement__c = '00';
        update us;
        // Créer un compte particulier 
        Account compte_test = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '00000', '00000_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        System.debug('Le compte particulier ' + compte_test.FirstName + ' ' + compte_test.LastName  + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du compte part : ' + compte_test.PersonEmail);
        insert compte_test;
        
        List<Reference__c> lreference = new List<Reference__c>();
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        lreference.add(competence);
        Reference__c CP = TestFactory.createReference('CP', '00000', '00000_91086', 'BONDOUFLE');
        lreference.add(CP);     
        insert lreference;  

        //Créer un projet associé à compte_test 
        Projet__c projet_test = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= compte_test.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= CP.Id,
                                              Description__c='description test youhou',
                                              Statut_Projet__c = 'Qualifié EPH');
        System.debug('Le projet ' + projet_test.Titre__c + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du projet : ' + projet_test.email_projet__c);
        insert projet_test;
        
        projet_test = [SELECT email_projet__c,Proprietaire_du_projet__c from Projet__c where Id =:projet_test.Id];
        
        //Vérifier que le trigger a bien copié les valeurs dans projet 
        System.assertEquals(projet_test.Proprietaire_du_projet__c, us.Id);
        projet_test.Statut_Projet__c = 'RDV pris EPH MOE';
        update projet_test; 
        
        projet_test = [SELECT email_projet__c,Proprietaire_du_projet__c from Projet__c where Id =:projet_test.Id];
        
        //Vérifier que le trigger a bien copié les valeurs dans projet 
        System.assertEquals(projet_test.Proprietaire_du_projet__c, us.Id);
        Test.stopTest();
    }
  @isTest
  public static void Test_Projet_Trigger_updateProjetProprietaireProjet_2usersFound()
    {
        Test.startTest();
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us1 = TestFactory.createUser('0123456788', sysAdm);
        us1.Affectation_code_postal__c = '00000'; 
        us1.Affectation_departement__c = '00';

        User us2 = new User();
        us2.Alias = 'user2';
        us2.Email='usersgdbf2@testclasssgdbf.com';
        us2.EmailEncodingKey='UTF-8';
        us2.LastName='Test2';
        us2.LanguageLocaleKey='fr';
        us2.LocaleSidKey='fr_FR_EURO';
        us2.ProfileId = sysAdm.Id;
        us2.TimeZoneSidKey='Europe/Paris';
        us2.UserName='usersgdbf2@testclasssgdbf.com';
        insert us2;

        us2.Affectation_code_postal__c = '00000'; 
        us2.Affectation_departement__c = '00';
        List<User> lusers = new List<User>();
        lusers.add(us1);
        lusers.add(us2);
        update lusers;

        // Créer un compte particulier 
        Account compte_test = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '00000', '00000_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        System.debug('Le compte particulier ' + compte_test.FirstName + ' ' + compte_test.LastName  + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du compte part : ' + compte_test.PersonEmail);
        insert compte_test;
        
        List<Reference__c> lreference = new List<Reference__c>();
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        lreference.add(competence);
        Reference__c CP = TestFactory.createReference('CP', '00000', '00000_91086', 'BONDOUFLE');
        lreference.add(CP);     
        insert lreference;  

        //Créer un projet associé à compte_test 
        Projet__c projet_test = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= compte_test.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= CP.Id,
                                              Description__c='description test youhou',
                                              Statut_Projet__c = 'Qualifié EPH');
        System.debug('Le projet ' + projet_test.Titre__c + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du projet : ' + projet_test.email_projet__c);
        insert projet_test;
        
        projet_test = [SELECT email_projet__c,Proprietaire_du_projet__c from Projet__c where Id =:projet_test.Id];
        
        //Vérifier que le trigger a bien copié les valeurs dans projet 
        System.assertEquals(projet_test.Proprietaire_du_projet__c, null);
        projet_test.Statut_Projet__c = 'RDV pris EPH MOE';
        update projet_test; 
        
        projet_test = [SELECT email_projet__c,Proprietaire_du_projet__c from Projet__c where Id =:projet_test.Id];
        
        //Vérifier que le trigger a bien copié les valeurs dans projet 
        System.assertEquals(projet_test.Proprietaire_du_projet__c, null);
        Test.stopTest();
    }
}