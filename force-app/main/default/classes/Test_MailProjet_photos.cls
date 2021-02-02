@isTest (SeeAllData = false)  
public class Test_MailProjet_photos
{
    public static final ID RTPhotoProjet = [SELECT Id FROM RecordType WHERE DeveloperName = 'Projet' AND SObjectType = 'Photo__c' LIMIT 1].Id;
    
	public static testMethod void ValidateMailProjet_Photos()
    { 
        // Créer un compte particulier et l'insert
        Account compte_test = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto01011900@gmail.com');
        System.debug('Le compte particulier ' + compte_test.FirstName + ' ' + compte_test.LastName  + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du compte part : ' + compte_test.PersonEmail);
        insert compte_test;
        
        //Créer un projet affilié à compte_test et l'insert
        Projet__c projet_test = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= compte_test.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                              Description__c='description test youhou');
        System.debug('Le projet ' + projet_test.Titre__c + ' a été crée avec succès.');
        System.debug('>>>>>>>>>>>> Mail du projet : ' + projet_test.email_projet__c);
        insert projet_test;
        
        //Créer une photo affiliée à projet_test et l'insert
        Photo__c photo_test = new Photo__c(Name= 'photo_test',
                                           Projet__c = projet_test.Id,
                                           Statut__c= 'A Valider',
                                           Type__c= 'Projet',
                                           URL__c = 'toto',
                                           RecordTypeId = RTPhotoProjet);
        System.debug('La photo ' + photo_test.Name + ' a été crée avec succès.');
        insert photo_test;
        
        //Récuperer le compte particulier, le projet et la photo crées précedemment
        compte_test = [SELECT PersonEmail from Account where Id =:compte_test.Id];
        System.debug('Adresse mail du part : ' + compte_test.PersonEmail);
        projet_test = [SELECT email_projet__c from Projet__c where Id =:projet_test.Id];
        System.debug('Adresse mail du projet : ' + projet_test.email_projet__c);
        photo_test = [SELECT Email_projet__c from Photo__c where Id =:photo_test.Id];
        System.debug('Adresse mail de la photo : ' + photo_test.Email_projet__c);
        
        //Vérifier que le trigger a bien copié les valeurs dans projet et photo
        System.assertEquals(compte_test.PersonEmail, projet_test.email_projet__c);
        //System.assertEquals(projet_test.email_projet__c, photo_test.email_projet__c);
        
        //update de l'adresse mail du compte part
        compte_test.PersonEmail = 'newmail@mail.com';
        update compte_test;
        
        //Récuperer le compte particulier, le projet et la photo after update
		compte_test = [SELECT PersonEmail from Account where Id =:compte_test.Id];
        System.debug('Adresse mail du part after update : ' + compte_test.PersonEmail);
        projet_test = [SELECT email_projet__c from Projet__c where Id =:projet_test.Id];
        System.debug('Adresse mail du projet after update : ' + projet_test.email_projet__c);
        photo_test = [SELECT Email_projet__c from Photo__c where Id =:photo_test.Id];
        System.debug('Adresse mail de la photo after update : ' + photo_test.Email_projet__c);
        
        //Vérifier que le trigger a bien copié les valeurs dans projet et photo after update
        System.assertEquals(compte_test.PersonEmail, projet_test.email_projet__c);
        //System.assertEquals(projet_test.email_projet__c, photo_test.email_projet__c);
    }
}