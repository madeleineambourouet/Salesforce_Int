/**
* @author Qiuyan Liu
* @CreatedDate 05 Juillet 2017
* @description EB-129, Test class for ProjetAffiliationWS
*/
@isTest(SeeAllData=false)
global class ProjetAffiliationWS_TEST {
  
  @isTest static void PostProjetEvolutionTest() {
    Profile p = TestFactory.getProfilByName('Administrateur système');
        User testUser = new User(Alias = 'uPATest', Email='uPATest@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='uPATest', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, Bypass_Function__c='',//MAJ_ProjetAffiliation
           TimeZoneSidKey='America/Los_Angeles', UserName='uPATest@testorg.com');

        System.runAs(testUser) {
          Id Code_postal = TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id;
      Id Pays_LKP = TestFactory.createReference('pays', 'France', 'FRA', 'France').Id;
      Id Categorie_lkp = TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id;
       Account compte_test = new Account(LastName= 'Test',
                                            FirstName= 'Compte',
                                            RecordTypeId = TestFactory.RTComptePart,
                                            Statut__c= 'Actif', 
                                            Code_postal__c= Code_postal,
                                            Pays_LKP__c= Pays_LKP,
                                            PersonMobilePhone= '+33240768765',
                                            PersonEmail='toto@gmail.com');
          insert compte_test;

          List<Projet__c> proList = new List<Projet__c>();
          Map<Id, Projet__c> testNewMap1 = new Map<Id, Projet__c>();
          Projet__c projet_test0 = new Projet__c(Titre__c = 'projet test0',
                                                Particulier__c= compte_test.Id,
                                                Categorie_lkp__c= Categorie_lkp,
                                                Code_postal__c= Code_postal,
                                                Description__c='description test youhou', 
                                                Statut_Projet__c='Nouveau',
                                                Sous_statut__c=null,
                                                Etat__c='Contact part ouvert',
                                                Motif_de_refus__c = 'Tout est ok',
                                                  Canal__c='Web');

          test.startTest();
          
          //Test.setMock(HttpCalloutMock.class, new ProjetAffiliationWSMock());
          insert projet_test0;
          testNewMap1.put(projet_test0.Id, projet_test0);
          
          //ProjetAffiliationWS.MAJ_ProjetAffiliation(testNewMap1, null);
          
          for (Integer i = 1; i < 5; i++) {
            Projet__c projet_test = new Projet__c(Titre__c = 'projet test' + i,
                                                Particulier__c= compte_test.Id,
                                                Categorie_lkp__c= Categorie_lkp,
                                                Code_postal__c= Code_postal,
                                                Description__c='description test youhou',
                                                Statut_Projet__c='Nouveau',
                                                Sous_statut__c=null,
                                                Etat__c='Contact part ouvert',
                                                Motif_de_refus__c = 'ok ok',  
                                                  Canal__c='Web');
            proList.add(projet_test);
          }
          insert proList;
          Map<Id, Projet__c> testOldMap2 = new Map<Id, Projet__c>(proList);
          Map<Id, Projet__c> testNewMap2 = testOldMap2.deepClone();

          for (Id proId : testNewMap2.keySet()) {
            testNewMap2.get(proId).Etat__c = 'ODC close';
          }
      ProjetAffiliationWS.MAJ_ProjetAffiliation(testNewMap2, testOldMap2);
            ProjetAffiliationWS updateJob = new ProjetAffiliationWS(new List<Id>(testOldMap2.keyset()));
      ID jobID = System.enqueueJob(updateJob);
      test.stopTest();
        }
  }

}