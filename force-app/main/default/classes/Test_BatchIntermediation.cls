@isTest //(seealldata = true)
private class Test_BatchIntermediation {
    
    //public static String CRON_EXP = '0 0 15 * * ?';

    private static testMethod void testBatchIntermediation() {
        
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
      Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      insert professionnel;
      Contact contactPro = TestFactory.createContact(professionnel);
      insert contactPro;
      Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
      insert project;
      Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
      insert miseEnRelation;
      
     
      String query = 'SELECT id, INSEE_formule__c, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, '
                            +     'LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c, TEXTELIBRE__c, Adresse_IP__c, '
                            +     'Numero_SGI__c, Source__c, Type_de_source__c, Code_postal__r.Name '
                            + 'FROM Projet__c '
                            + 'WHERE Etat__c != \'ODC close\' AND Etat__c != \'Contact part clos\' AND Filtre_batch_B__c = true '
                            + 'AND recevoir_pro__c = false AND batch__c = false LIMIT 50';
      
      //String jobId = System.schedule('ScheduleIntermediationTest', CRON_EXP, new Intermediation_Schedulable());
      Intermediation_Batchable batch = new Intermediation_Batchable(query);
      Database.executeBatch(batch);
      
  }
  
}