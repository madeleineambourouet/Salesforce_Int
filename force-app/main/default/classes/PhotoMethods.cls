/**
* @author Qiuyan Liu
* @date 08/09/2017
*
* @description Created for EB136
*/
public with sharing class PhotoMethods { 

	//calculate the number of photos for pro
	public static void calculateNumberPhoto(List<Photo__c> oldList, List<Photo__c> newList) {
		Set<Id> accountIdSet = new Set<Id>(); 
    
	    if (oldList != null) {
	        for (Photo__c ph : oldList) {
	            accountIdSet.add(ph.Compte__c);
	        }
	    }
	    
	    if (newList != null) {
	        for (Photo__c ph : newList) {
	            accountIdSet.add(ph.Compte__c);
	        }
	    }
	    
	    List<Account> accUpdateList = new List<Account>();
	    
	    for (Account acc : [SELECT Id, Nombre_Photos__c, (SELECT Id FROM Photos__r) FROM Account WHERE Id IN:accountIdSet]) {
	        if (acc.Nombre_Photos__c != acc.Photos__r.size()) {
	            acc.Nombre_Photos__c = acc.Photos__r.size();
	            accUpdateList.add(acc);
	        }
	    } 
	    
	    if (accUpdateList.size() > 0) {
	        update accUpdateList;
	    }
	}
}