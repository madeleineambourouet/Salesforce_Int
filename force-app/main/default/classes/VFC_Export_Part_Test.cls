/**
* @author Leila BOUAIFEL
* @date 17/07/2017
*
* @description test class for  VFC_Export_Part
*/
@isTest (SeeAllData=false)
private class VFC_Export_Part_Test {

     @testSetup
      static void setup() {
      ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
      
      Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
      Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
      Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
      User us = TestFactory.createUser('0123456789', sysAdm);
        
      Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      insert particulier;
     }   
       private static testMethod void test() {
        
        Account part = [SELECT Id FROM Account where IsPersonAccount = true LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
       VFC_Export_Part  ExportPart= new VFC_Export_Part();
       ExportPart.VFC_Export_Part();
           
       ExportPart.isCsv = true; 
       ExportPart.isExcel = true;     
        
      }
 }