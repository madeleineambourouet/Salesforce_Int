// 
// Batch mensuel pour créer les faits de vente pour le calcul des incentives
// 24/01/2018, xavier templet, version initiale   

public with sharing class Batch_Monthly_SalesFact implements Database.Batchable<sObject>, Schedulable {
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
		Date Date_j = Date.today();
			
		if (test.isRunningTest())
		return Database.getQueryLocator(  	
		'SELECT Id, Name, Zuora__Account__c, TECH_QuoteID__c, Zuora__Status__c, Type_de_geste__c ' +
			'FROM Zuora__Subscription__c where Type_de_geste__c != \'Geste commercial post-résiliation\' AND (Zuora__Status__c = \'Active\' OR (Zuora__Status__c = \'Cancelled\' AND Zuora__SubscriptionEndDate__c >= :Date_j)) ' +
				'ORDER BY Zuora__SubscriptionStartDate__c ASC LIMIT 20');
		
		else return Database.getQueryLocator(  	
		'SELECT Id, Name, Zuora__Account__c, TECH_QuoteID__c, Zuora__Status__c, Type_de_geste__c ' +
			'FROM Zuora__Subscription__c where Type_de_geste__c != \'Geste commercial post-résiliation\' AND Zuora__ServiceActivationDate__c != null AND ((Zuora__Status__c = \'Active\'  AND Zuora__ServiceActivationDate__c < :Date_j)OR (Zuora__Status__c = \'Cancelled\' AND Zuora__SubscriptionEndDate__c >= :Date_j)) ' +
				'ORDER BY Zuora__SubscriptionStartDate__c ASC');

    }
	
    public void execute(Database.BatchableContext BC, List<Zuora__Subscription__c> scope) {
    	
      	System.debug('Batch_Monthly_SalesFact >>>>> scope :' + scope);
		if (scope == null || scope.size() == 0) return;
		
		Date Date_j = Date.today();

		List<user> userLst = [select Id, ManagerID, UserRole.Name, IsActive from user where (Profile.Name = 'Administrateur fonctionnel' OR Profile.Name = 'Administrateur système' OR Profile.Name = 'Service Client' OR Profile.Name = 'Service Commercial' OR Profile.Name = 'Service Commercial ITCS' OR Profile.Name = 'Service Consommateur')];
		Map<Id,Id> ActiveUser = new Map<Id,Id>();
		Map<Id,Id> Owner2Manager = new Map<Id,Id>();
		Map<Id, User> userMap = new Map<Id, User>();
		for (user u : userLst) {
			ActiveUser.put(u.Id, u.Id);
			Owner2Manager.put(u.Id, u.ManagerID);
			userMap.put(u.Id, u);
		}
		
		Map<Id, Id> accntID = new Map<Id, Id>();
		List<Id> accntIDlst = new List<Id>();
		List<Zuora__Subscription__c> zsubLst = new List<Zuora__Subscription__c>();
		for (Zuora__Subscription__c zsub : scope){
			if (!accntID.containsKey(zsub.Zuora__Account__c)) {
				accntID.put(zsub.Zuora__Account__c, zsub.Zuora__Account__c);
				zsubLst.add(zsub);
				accntIDlst.add(zsub.Zuora__Account__c);
			}
		}

      	System.debug('Batch_Monthly_SalesFact >>>>> accntIDlst :' + accntIDlst);
		List<Account> accntLst = [select Id, Name, OwnerId from Account where Id in :accntIDlst];
      	System.debug('Batch_Monthly_SalesFact >>>>> accntLst :' + accntLst);
		Map<Id, Account> accntMap = new Map<Id, Account>();
		for (Account a : accntLst) accntMap.put(a.Id, a);
		 
		List<Sales_Facts__c> sfactLst = new List<Sales_Facts__c>();
		for (Zuora__Subscription__c zsub : zsubLst){
			if (accntMap.containsKey(zsub.Zuora__Account__c) && userMap.containsKey(accntMap.get(zsub.Zuora__Account__c).ownerID)) {
				Sales_Facts__c sfact = new Sales_Facts__c();
				sfact.Customer__c = zsub.Zuora__Account__c; //Client concerné => Compte pro associé à la souscription
				sfact.Date__c = Date_j;
				sfact.Comment__c = 'Client ' + accntMap.get(zsub.Zuora__Account__c).Name + ' actif en ' + String.ValueOf(Date_j.month()) + '/' + String.ValueOf(Date_j.year());
				sfact.Salesman__c = accntMap.get(zsub.Zuora__Account__c).ownerID; // Commercial => Propriétaire de la proposition commerciale ayant conduit à la création de la souscription
				//if (ActiveUser.containsKey(sfact.Salesman__c)) sfact.ownerID = sfact.Salesman__c;

				if (userMap.containsKey(sfact.Salesman__c) && userMap.get(sfact.Salesman__c).UserRole.Name != 'ITCS' && userMap.get(sfact.Salesman__c).UserRole.Name != 'TC Service client pro' && userMap.get(sfact.Salesman__c).UserRole.Name != 'TC Service commercial') {
					sfact.Manager__c = sfact.Salesman__c;
				}

				else if (Owner2Manager.containsKey(sfact.Salesman__c)) {
					sfact.Manager__c = Owner2Manager.get(sfact.Salesman__c); 
				}
				//sfact.Quote_Validation_Date__c; // Date de validation de la proposition commerciale => Date à laquelle cette proposition a été validée
				sfact.Sales_fact_type__c= 'Client actif';
				sfact.Subscription__c = zsub.Id; // Souscription concernée => Souscription concernée
				//sfact.Subscription_activation_date__c = Date.today(); //Date d’activation de la souscription => Date du jour
				//sfact.Subscription_termination_date__c;
				sfact.Value_Date_for_Salesman__c = firstday_of_next_month();
				sfact.Value_Date_for_Manager__c = firstday_of_next_quarter();  
		
				sfactLst.add(sfact);
			}
		}
		if (sfactLst.size() > 0)
			insert(sfactLst);
      	System.debug('Batch_Monthly_SalesFact >>>>> sfactLst :' + sfactLst);
    }
    	
	//Date de valeur du manager => 1er jour du trimestre à suivre (par exemple le 15/02 on enregistre ici le 01/04)
    private static date firstday_of_next_quarter()  {
		Date d = Date.today();
		return Date.newInstance(
			d.year() + (d.month() <= 9 ? 0 : 1), 
			d.month() <= 3 ? 4 : d.month() <= 6 ? 7 : d.month() <= 9 ? 10 : 1,
			1);
   	
    }

	//Date de valeur du commercial => 1er jour du mois à suivre (par exemple le 15/02 on enregistre ici le 01/03)
    private static date firstday_of_next_month()  {
		Date d = Date.today();
   		return Date.newInstance(
   			d.addMonths(1).year(), 
   			d.addMonths(1).month(), 
   			1); 
    }

    public void finish(Database.BatchableContext BC) {
/*
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()];

		System.debug('Batch_Monthly_SalesFact >>>>> job :' + job);
*/        
    }
    
    public void execute(SchedulableContext context) {
        Batch_Monthly_SalesFact b = new Batch_Monthly_SalesFact(); 
        database.executebatch(b);
    }
    
}