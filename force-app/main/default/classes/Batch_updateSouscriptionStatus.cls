/**
* @author Leila BOUAIFEL
* @date 16/03/2017
*
* @description update each Account with souscription status on Account object 
*/

public with sharing class Batch_updateSouscriptionStatus implements Database.Batchable<sObject>, Schedulable  {
    
    public Batch_updateSouscriptionStatus() {}
    String query;
    public Database.QueryLocator start(Database.BatchableContext BC) {

        query='SELECT Id, Statut_de_la_souscription__c from Account where id IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c where Type_de_geste__c !=  \'Geste commercial post-résiliation \')';
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('## scope' + scope);
        
        //Returns the current Date based on a GMT calendar.
        Date d1 = Date.today();       
        
        //list for holding Accounts updates
        List<Account> AccListToUpdate = new List<Account>();
        List<Account> accList = [SELECT Id, Statut_de_la_souscription__c, (SELECT ID, Zuora__Status__c, Zuora__SubscriptionEndDate__c FROM ZUORA__Subscriptions__r ORDER BY Zuora__SubscriptionEndDate__c DESC NULLS FIRST LIMIT 1 ) from Account where id IN :scope];
        System.debug('## accList' + accList);         
        for (Account Acc : accList) {
            System.debug('## ACC ID: '+Acc.Id + ' acc.ZUORA__Subscriptions__r: ' + acc.ZUORA__Subscriptions__r); 
            if (Acc.ZUORA__Subscriptions__r[0].Zuora__Status__c == 'Cancelled' && Acc.ZUORA__Subscriptions__r[0].Zuora__SubscriptionEndDate__c != null && Acc.ZUORA__Subscriptions__r[0].Zuora__SubscriptionEndDate__c <= d1)   
            {
                Acc.Statut_de_la_souscription__c = 'Cancelled';
                AccListToUpdate.add(Acc);
            }
        }
        update AccListToUpdate;
        System.debug('## AccListToUpdate' + AccListToUpdate);
    }
        
    public void finish(Database.BatchableContext BC) {
        
    }

    public void execute(SchedulableContext context) {
        Batch_updateSouscriptionStatus b = new Batch_updateSouscriptionStatus(); 
        database.executebatch(b);
    }
    
}