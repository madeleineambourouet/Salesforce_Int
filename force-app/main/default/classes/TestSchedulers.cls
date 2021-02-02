@isTest
private class TestSchedulers {

  private static testMethod void testBatchIntermediationSchedulable() {
      
      Test.startTest();
      Intermediation_Schedulable sche = new Intermediation_Schedulable();
      String chrn = '0 0 23 * * ?';
      System.schedule('test intermediation', chrn, sche);
      Test.stopTest();

  }
  
  private static testMethod void testUncheckProjetsSchedulable() {
      
      Test.startTest();
      UncheckProjets_Schedulable sche = new UncheckProjets_Schedulable();
      String chrn = '0 0 23 * * ?';
      System.schedule('test uncheck projets', chrn, sche);
      Test.stopTest();

  }
  
 
}