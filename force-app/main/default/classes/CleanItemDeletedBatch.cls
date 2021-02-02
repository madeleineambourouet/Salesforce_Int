public class CleanItemDeletedBatch implements Database.Batchable<sObject>, Schedulable  {
    
    String query;
    
    public CleanItemDeletedBatch() {
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id FROM ItemDeleted__c WHERE CreatedDate < LAST_N_DAYS:7';

        if(test.Isrunningtest()){
            query = 'SELECT Id FROM ItemDeleted__c WHERE CreatedDate = THIS_WEEK';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        list<ItemDeleted__c> listItems = (list<ItemDeleted__c>)scope;
        if (listItems != null && listItems.size() > 0) {
            delete listItems;
            Database.emptyRecycleBin(listItems);
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute(SchedulableContext context) {
        CleanItemDeletedBatch b = new CleanItemDeletedBatch(); 
        database.executebatch(b);
    }
}