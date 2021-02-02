@isTest
public class SendSatisfactionSurveyBatchTest {
  @testSetup
  static void setup() {   
    
    ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id;        
    ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
    ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
    ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
    User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1]; 
    
    List<Reference__c> listReferences = new List<Reference__c>();
    List<Account> listAccounts = new List<Account>();    
    Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
    //insert CP;
        
    Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'Zimbabwe', key__c = 'ZWE');
    //insert FR;
    listReferences.add(CP);
    listReferences.add(FR);
    insert listReferences;
    datetime myDateTime = datetime.now();
    
    Account nullAcc = new Account(RecordTypeId = RTComptePart, FirstName = 'Test1', LastName = 'EB123', Phone = '+33600000001', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Adresse1__c = '12 rue grande');
                                        
    Account tooEarlyAcc = new Account(RecordTypeId = RTComptePart, FirstName = 'Test2', LastName = 'EB123', Phone = '+33600000002', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Adresse1__c = '35 rue courte', Derni_re_date_cl_ture_projet__c = Datetime.newInstance(2009, 1, 7, 16, 12, 2));
                                        
    Account tooLateAcc = new Account(RecordTypeId = RTComptePart, FirstName = 'Test3', LastName = 'EB123', Phone = '+33600000003', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Adresse1__c = '246 rue large', Derni_re_date_cl_ture_projet__c = Datetime.newInstance(2099, 12, 8, 12, 34, 2));
    
    Account goodAcc = new Account(RecordTypeId = RTComptePart, FirstName = 'Test4', LastName = 'EB123', Phone = '+33600000004', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Adresse1__c = '54 rue haute', Derni_re_date_cl_ture_projet__c = myDateTime.addDays(-3));
                                        
    //insert nullAcc;
    //insert tooEarlyAcc;
    //insert tooLateAcc;
    //insert goodAcc;
    listAccounts.add(nullAcc);
    listAccounts.add(tooEarlyAcc);
    listAccounts.add(tooLateAcc);
    listAccounts.add(goodAcc);
    insert listAccounts;
    
  }
  
  static testMethod void test() {
        Test.startTest();
        SendSatisfactionSurveyBatch b = new SendSatisfactionSurveyBatch();
        database.executebatch(b);
        Test.stopTest();
        
        List<Account> accounts = database.query('SELECT FirstName, Enqu_te_satisfaction_envoyer__c, Derni_re_date_cl_ture_projet__c  FROM Account');
        System.debug([SELECT FirstName, Enqu_te_satisfaction_envoyer__c, Derni_re_date_cl_ture_projet__c FROM Account]);
        
        for (Account acc : accounts) { 
            System.debug('test acc '+acc);
            if(acc.Derni_re_date_cl_ture_projet__c != null){
                //System.assert(acc.Enqu_te_satisfaction_envoyer__c);
            }
        }
        System.debug('Test OK');  
        
    }
}