@isTest//(seealldata = true)
private class Test_BatchUncheckProjets {
    
    //public static String CRON_EXP = '0 0 15 * * ?';

    private static testMethod void testUncheck() {
        
      ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
  
      Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
      Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
      Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
      Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
      Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
      Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
      User us = TestFactory.createUser('0123456789', sysAdm);
      Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
      insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;
      Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      insert particulier;
      Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
      insert project;
      project.batch__c = true;
      update project;
      
      String query = 'SELECT id FROM Projet__c WHERE batch__c = true';
         
      Test.startTest();
      //Test.setMock(HTTPCalloutMock.class, new MockHTTP());
      
      //String jobId = System.schedule('ScheduleUncheckTest', CRON_EXP, new UncheckProjets_Schedulable());
      UncheckProjets_Batchable batch = new UncheckProjets_Batchable(query);
      Database.executeBatch(batch);

      Test.stopTest();
      
  }
  
}