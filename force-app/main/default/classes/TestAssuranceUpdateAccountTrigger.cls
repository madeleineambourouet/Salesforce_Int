@isTest (SeeAllData=true)
private class TestAssuranceUpdateAccountTrigger {

    private static testMethod void test(){
  
      
  // READ DOCUMENTS ASSURANCES...
        ID RTComptePro = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' and id != NULL LIMIT 1].Id; 
         ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
               
        ID ASSURANCES = [select Id, Date_d_expiration__c from Document_Assurance__c WHERE Date_d_expiration__c != null ORDER BY Date_d_expiration__c asc LIMIT 1 ].Id;
        
       
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        Account A = new Account(RecordTypeId = RTComptePro, Name ='Homly' );
        insert A;


  // TEST UPDATING Account... 
        Account C = new Account(Id = A.id, RecordTypeId = RTComptePro, Name = 'TEST', Last_date_expiration_assurances__c  = date.today(), Adresse1__c='12 rue du Merechal Foch', Code_postal__c = CP.Id
 );
                                       
        update C;
        C.Last_date_expiration_assurances__c   = date.today();
       

        update C;
        
 system.debug('----->>> END UPDATE C: ' + C.Id + 'a été inséré avec succès.');
       
}
}