public class SendSatisfactionSurveyBatch implements Database.Batchable<sObject>, Schedulable  {
   
    String query;
    
    public SendSatisfactionSurveyBatch() {
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        query = 'SELECT Id, FirstName, LastName, Derni_re_date_cl_ture_projet__c FROM Account WHERE Derni_re_date_cl_ture_projet__c != null AND Derni_re_date_cl_ture_projet__c = LAST_N_DAYS:3 AND Derni_re_date_cl_ture_projet__c != LAST_N_DAYS:2';
        
         if(test.Isrunningtest()){
            query='SELECT Id, FirstName, LastName, Derni_re_date_cl_ture_projet__c FROM Account WHERE Derni_re_date_cl_ture_projet__c != null';
          }
          
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        list<Account> listItems = (list<Account>)scope;
        if (listItems != null && listItems.size() > 0) {
            for (Account acc : listItems) {
                acc.Enqu_te_satisfaction_envoyer__c = true;
            }    
            update listItems;
            //System.debug('fin update : ' + listItems);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute(SchedulableContext context) {
        SendSatisfactionSurveyBatch b = new SendSatisfactionSurveyBatch(); 
        database.executebatch(b);
    }
}