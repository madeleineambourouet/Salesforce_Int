trigger Event_Trigger on Event (before insert, after insert, after update, before update) {
	
   	Set<Id> accountIds = new Set<Id>();
    Set<Id> ReferenceIds = new Set<Id>();
    

    for (Event event: Trigger.new) {
        accountIds.add(event.WhatId);
        ReferenceIds.add(event.Agence__c);  
    }
        
  if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
   
      Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, Name From Account Where Id in: accountIds]);
      Map<Id, Reference__c> RefMap = new Map<Id, Reference__c>([Select Id, Name From Reference__c Where Id in: ReferenceIds]);
      
      for (Event event: Trigger.new) {
         
          Account account = accountMap.get(event.WhatId);
		  Reference__c Ref = RefMap.get(event.Agence__c);
          
    	 	if (event.Agence__c != null && Ref != null) {        		   	
            		event.Location = Ref.Name;
             } 
      
			if (event.WhatId != null && account != null) {            	
                	event.Location = account.Name;
             } 
     } 
  }
 }