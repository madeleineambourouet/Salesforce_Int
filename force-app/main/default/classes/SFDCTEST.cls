global class SFDCTEST implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
       String query = ('SELECT id, lastmodifieddate FROM account WHERE IsDeleted = true ALL ROWS');
        return Database.getQueryLocator (query);
        
       
        
       
    }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
         List <Account> DeletedAccounts = [SELECT id, lastmodifieddate FROM account WHERE IsDeleted = true ALL ROWS ];
         for(Account a : scope)
         {
             a.Name = a.Name + 'insert';            
         }
         insert scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}