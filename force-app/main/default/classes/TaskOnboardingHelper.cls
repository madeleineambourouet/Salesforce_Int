global class TaskOnboardingHelper {
    
    global static void EcheanceAssurance(List<sObject> scope, String subject) {
        List<Task> tasks = new List<Task>();
        Date dateJour = Date.today(); 
        Date dateJour30 = dateJour.addDays(30);
        Date dateEcheance = dateJour30.addDays(-7);

        for (Document_Assurance__c doc : (List<Document_Assurance__c>)scope) {
            Task t = new Task();
            
            if (doc.Compte__r.TC_Referent__c != null)
                t.OwnerId = doc.Compte__r.TC_Referent__c;
            else
                t.OwnerId = doc.Compte__r.OwnerId;
            
            t.WhatId = doc.Id;
            t.Subject = subject;
            t.Status = 'A faire';
            t.Priority = 'Moyenne';
            t.ActivityDate = dateEcheance;
            tasks.add(t);
        }
        
        if (tasks.size() > 0)
      		insert tasks;
    }
    
    global static void EcheanceCB(List<sObject> scope, String subject) {
        String year = String.valueOf(Date.today().year());
        String month = String.valueOf(Date.today().month());
        Map<Id,Task> tasks = new Map<Id,Task>();
        List<Id> Ids = new List<Id>();
       
        Date dateJour = Date.today(); 
        Date dateEcheance = dateJour.addDays(23);
        for (Zuora__CustomerAccount__c billAcc : (List<Zuora__CustomerAccount__c>) scope) {
            system.debug('bill == ' + billAcc.ExpirationCB__c);
            List<String> parts = billAcc.ExpirationCB__c.split('/');
            if(parts.size() == 2) {
   					system.debug('parts ' + parts);
                    if (parts[0].length() < 3 && parts[1] == year) {
                        
                        if(parts[0] == month){
                            Task t = new Task();
                            
                    		if (billAcc.Zuora__Account__r.TC_Referent__c != null)
    							t.OwnerId = billAcc.Zuora__Account__r.TC_Referent__c;
                        	else
                        		t.OwnerId = billAcc.Zuora__Account__r.OwnerId;
                            
                            t.WhatId = billAcc.Id;
                            t.Subject = subject;
                            t.Status = 'A faire';
                            t.Priority = 'Moyenne';
                            t.ActivityDate = dateEcheance;
                            tasks.put(billAcc.Id,t);
	                        Ids.add(billAcc.Id);
                            
                        }
                    }
            }  
        }
        
        system.debug('1 tasks.size() == ' + tasks.size());
        if (tasks.size() > 0 ) {
        	for (Task t : [SELECT Id, WhatId, CreatedDate FROM Task WHERE WhatId In :Ids AND Subject = :subject AND CreatedDate = THIS_MONTH]) {
            	if (tasks.containsKey(t.WhatId)) {
                	tasks.remove(t.WhatId);
                }
            }
            
            system.debug('2 tasks.size() == ' + tasks.size());
            if (tasks.size() > 0) {
                    insert tasks.values();
                }
            }
    }
    
    global static void ProImpaye(List<Zuora__CustomerAccount__c> newList, Map<Id,Zuora__CustomerAccount__c> oldMap, String subject) {
        List<Task> tasks =  new List<Task>();
        List<Id> accIds = new List<Id>();
        Date dateJour = Date.today(); 
        Date dateEcheance = dateJour.addDays(7);
        
        for (Zuora__CustomerAccount__c bill : newList) {
            accIds.add(bill.Zuora__Account__c);
        }
        Map<ID, Account> accMap = new Map<ID, Account>([SELECT Id, TC_Referent__c,OwnerId FROM Account WHERE Id IN :accIds]);
        
        for (Zuora__CustomerAccount__c bill : newList) {
            if ((oldMap.get(bill.Id).EchecsPaiementConsecutifs__c == '0' || oldMap.get(bill.Id).EchecsPaiementConsecutifs__c == null) &&
                bill.EchecsPaiementConsecutifs__c != '0' && bill.EchecsPaiementConsecutifs__c != null) {
                Task t = new Task();
                if (accMap.get(bill.Zuora__Account__c).TC_Referent__c != null)
                    t.OwnerId = accMap.get(bill.Zuora__Account__c).TC_Referent__c;
                else
                    t.OwnerId = accMap.get(bill.Zuora__Account__c).OwnerId;         
                t.WhatId = bill.Id;
                t.Subject = subject;
                t.Status = 'A faire';
                t.Priority = 'Moyenne';
                t.ActivityDate = dateEcheance;
                tasks.add(t);
            }
        }
        
        if (tasks.size() > 0)
        	insert tasks;
    }
 }