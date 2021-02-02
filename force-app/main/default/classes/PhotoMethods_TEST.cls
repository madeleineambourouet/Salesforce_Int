@isTest
private class PhotoMethods_TEST {
	public static final ID RTPhotoPro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_pro' AND SObjectType = 'Photo__c' LIMIT 1].Id;
	@isTest static void test_method_one() {
		Account compte_test = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        insert compte_test;

        List<Photo__c> pList = new List<Photo__c>();
        Photo__c photo_test1 = new Photo__c(Name= 'photo_test1',
                                           Compte__c = compte_test.Id,
                                           Statut__c= 'A Valider',
                                           Type__c= 'Compte PRO',
                                           URL__c = 'toto1.fr',
                                           RecordTypeId = RTPhotoPro);
        pList.add(photo_test1) ;
        Photo__c photo_test2 = new Photo__c(Name= 'photo_test2',
                                           Compte__c = compte_test.Id,
                                           Statut__c= 'A Valider',
                                           Type__c= 'Compte PRO',
                                           URL__c = 'toto2.fr',
                                           RecordTypeId = RTPhotoPro);
        pList.add(photo_test2) ;
        Photo__c photo_test3 = new Photo__c(Name= 'photo_test3',
                                           Compte__c = compte_test.Id,
                                           Statut__c= 'A Valider',
                                           Type__c= 'Compte PRO',
                                           URL__c = 'toto3.fr',
                                           RecordTypeId = RTPhotoPro);
        pList.add(photo_test3) ;

        insert pList;

        delete photo_test1;

	}

	
}