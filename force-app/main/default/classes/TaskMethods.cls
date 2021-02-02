/**
* @author Qiuyan Liu
* @date 08/09/2017
*
* @description Created for EB136
*/
public with sharing class TaskMethods {
    public static void calculateNumberTask(List<Task> oldList, List<Task> newList) {
        Set<Id> accountIdSet = new Set<Id>(); 
    
        if (oldList != null) {
            for (Task t : oldList) {
                if (t.AccountId != null) {
                    accountIdSet.add(t.AccountId);
                }
            }
        }
        
        if (newList != null) {
            for (Task t : newList) {
                if (t.AccountId != null) {
                    accountIdSet.add(t.AccountId);
                }
            }
        }
        
        List<Account> accUpdateList = new List<Account>();
        
        //for (Account acc : [SELECT Id, Nombre_de_visite_ITC__c ,(SELECT Id,IsTask FROM OpenActivities WHERE IsTask = true),(SELECT Id,IsTask FROM ActivityHistories WHERE IsTask = true) FROM Account where id IN:accountIdSet]) {
       /* for (Account acc : [SELECT Id, Nombre_de_visite_ITC__c ,(SELECT Id,IsTask FROM ActivityHistories WHERE IsTask = true AND Status='Achevée' AND (CallType='Outbound' or CallType='Inbound') ) FROM Account where id IN:accountIdSet]) {
            if (acc.Nombre_de_visite_ITC__c != acc.ActivityHistories.size()) {
                acc.Nombre_de_visite_ITC__c = acc.ActivityHistories.size(); 
                accUpdateList.add(acc);
            }
        } */
        Map<Id, AggregateResult> arMap = new Map<Id, AggregateResult>([SELECT AccountId Id,  COUNT(Id) FROM Task WHERE (CallType='Outbound' OR CallType='Inbound') AND AccountId != null AND AccountId in: accountIdSet GROUP BY AccountId]);
        Map<Id, AggregateResult> arMap2 = new Map<Id, AggregateResult>([SELECT AccountId Id,  MAX(CreatedDate) FROM Task WHERE (CallType='Outbound' OR CallType='Inbound') AND AccountId != null AND AccountId in: accountIdSet GROUP BY AccountId]);
        for (Id accId : accountIdSet) {
            if (arMap.get(accId) == null) {
                accUpdateList.add(new Account(Id=accId, Nombre_de_visite_ITC__c=0, Dernier_visite_ITC__c = null));
            } else {
                accUpdateList.add(new Account(Id=accId, Nombre_de_visite_ITC__c=(Integer)arMap.get(accId).get('expr0'), Dernier_visite_ITC__c=(Datetime)arMap2.get(accId).get('expr0')));
            }
        }
        
        if (accUpdateList.size() > 0) {
            update accUpdateList;
        }
    }
}