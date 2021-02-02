/**
* @author Clement Musabimana
* @date 09/07/2019
* @description Batch permettant de calculer les indicateurs sur le compte
* @22/06/2020 : Le flag "Default assurance" est commenté pour ne plus le remplir.
**/
public class Batch_compte_indicateurs implements Database.Batchable<sObject>, Schedulable  {
  	//public static final String QUERY = 'Select Id,Statut_de_la_souscription__c from account where Statut_de_la_souscription__c = \'Active\' and Id= \'0014E000014E6QB\'';
  	public static final String QUERY = 'Select Id from account where Id in (Select Zuora__Account__c  from Zuora__Subscription__c where Zuora__Status__c = \'Active\' or Zuora__Account__r.Statut_de_la_souscription__c = \'Active\' or Zuora__Account__r.offre_intermediation_active__c = true or Zuora__Account__r.Defaut_Assurance__c = true)';
  	
   
   	public Database.QUERYLocator start(Database.BatchableContext BC){
    	return Database.getQUERYLocator(QUERY);
   	}


   	public void execute(Database.BatchableContext BC, List<sObject> scope){
		List<String> listAccIdWithIntermediation = new List<String> ();
		//Pour le calcul du defaut d'assurance on ne regarde que les clients qui ont une offre d'intermédaition avec date d'effet à partir de 15/09/2019
		List<String> listAccIdWithIntermediationAfter15092019 = new List<String> ();
		List<Account> listAccountsToUpdate = new List<Account> ();
		List<String> listAccountsWithCi = new List<String> ();
		Map<Id,Account> mapAccounts = new Map<Id,Account>();
		Map<Id,Boolean> mapCiWithCompetenceActive = new Map<Id,Boolean>();
		Map<Id,Boolean> mapAccountsHasAssuranceValide = new Map<Id,Boolean>();
		Map<Id,Boolean> mapAccountsHasAssurance = new Map<Id,Boolean>();
		for (Account acc : (list<Account>)scope) {
			//if(acc.id =='0013E00000t39J6'){
			acc.offre_intermediation_active__c = false;
			acc.au_moins_un_ci_suspendu__c = false;
			acc.aucun_ci_actif__c = false;
			acc.Date_effet_offre_intermediation_active__c = null;
			acc.Defaut_Assurance__c = false;
			mapAccountsHasAssuranceValide.put(acc.Id, false);
			listAccountsToUpdate.add(acc);
			mapAccounts.put(acc.Id, acc);
			//}
		}
		
		// Mise à jour de l'indicateur: Pros à l’offre d’intermédiation active
		for (Zuora__SubscriptionProductCharge__c  zSubPrdCharg : [select id,Zuora__RatePlanName__c,Zuora__Account__c,Zuora__EffectiveStartDate__c from Zuora__SubscriptionProductCharge__c where Zuora__EffectiveEndDate__c = null and Name like 'Offre%' and Zuora__RatePlanName__c != 'Offre Homly Travaux' and Zuora__Subscription__r.Zuora__Status__c = 'Active']) {
			if(zSubPrdCharg.Zuora__Account__c != null && mapAccounts.get(zSubPrdCharg.Zuora__Account__c) != null){
         		Account temp = mapAccounts.get(zSubPrdCharg.Zuora__Account__c);
         		temp.offre_intermediation_active__c = true;
         		temp.aucun_ci_actif__c = true;
				listAccIdWithIntermediation.add(String.valueOf(temp.Id));
         	}
		}
		//Pour la gestion des suspensions defaut assurance/////////////////////////////////////////////////////////////////////////
		for (Zuora__SubscriptionProductCharge__c  zSubPrdCharg : [select id,Zuora__RatePlanName__c,Zuora__Account__c,Zuora__EffectiveStartDate__c from Zuora__SubscriptionProductCharge__c where Zuora__EffectiveEndDate__c = null and Name = 'Opportunités de chantier qualifiées' and Zuora__Subscription__r.Zuora__Status__c = 'Active']) {
			if(zSubPrdCharg.Zuora__Account__c != null && mapAccounts.get(zSubPrdCharg.Zuora__Account__c) != null){
         		Account temp = mapAccounts.get(zSubPrdCharg.Zuora__Account__c);
				String dateDebutSuspensionDefautAssuranceString = Label.Date_debut_suspension_defaut_assurance;
				Date dateDebutSuspensionDefautAssurance = Date.valueOf(dateDebutSuspensionDefautAssuranceString);
				
				//Pour le calcul du defaut d'assurance on ne regarde que les clients qui ont une offre d'intermédaition avec date d'effet à partir de 15/09/2019
				if(zSubPrdCharg.Zuora__EffectiveStartDate__c != null && zSubPrdCharg.Zuora__EffectiveStartDate__c >= dateDebutSuspensionDefautAssurance){
	         		temp.Date_effet_offre_intermediation_active__c = zSubPrdCharg.Zuora__EffectiveStartDate__c;
					Integer numberDaysDue = temp.Date_effet_offre_intermediation_active__c.daysBetween(Date.today());
					
	                if(numberDaysDue > 60){
	                    //temp.Defaut_Assurance__c = true;
						listAccIdWithIntermediationAfter15092019.add(String.valueOf(temp.Id));
	                    mapAccountsHasAssurance.put(temp.Id,false);
	                }
         		}
         	}
		}

		// Avant : Le group by n'est pas adapté pour l'environnement de prod, trop de données
		//
		//
		/*for (AggregateResult  aggregate_Result : [SELECT GeoCat__c FROM Competence__c where Active__c = true group by GeoCat__c]) {
			//system.debug('Batch_compte_indicateurs *** aggregate_Result '+aggregate_Result);
			//system.debug('Batch_compte_indicateurs *** GeoCat__c '+aggregate_Result.get('GeoCat__c'));
			String geocatId_string = String.valueof(aggregate_Result.get('GeoCat__c'));
			Id geocatId = Id.valueOf(geocatId_string);
			mapCiWithCompetenceActive.put(geocatId, true);
		}*/

		// Après: Enlevement du group by et ajout de filtre sur les account traités dans le scope
		//
		//
		for (Competence__c c : [SELECT GeoCat__c FROM Competence__c where Active__c = true  AND GeoCat__c IN (SELECT Id FROM GeoCat__c WHERE Account__c IN :listAccIdWithIntermediation) ORDER BY GeoCat__c]) {
			if(mapCiWithCompetenceActive.get(c.GeoCat__c) == null){
				mapCiWithCompetenceActive.put(c.GeoCat__c, true);
			}

		}

		system.debug('Batch_compte_indicateurs listAccIdWithIntermediation '+listAccIdWithIntermediation);
		system.debug('Batch_compte_indicateurs mapCiWithCompetenceActive '+mapCiWithCompetenceActive);
		Date dateToday = Date.today();
		// Mise à jour de l'indicateur: Au moins un Critère d’intervention suspendu
		// Mise à jour de l'indicateur: Tous les Critères d’intervention sont suspendus
		for (GeoCat__c  geocat : [Select Id,Account__r.Id,DDP__c,Zone_d_intervention__c,Date_de_debut__c,Date_de_fin__c from GeoCat__c where Account__c in: listAccIdWithIntermediation]) {
			
			//Le critere d'intervention a au moins une competence active
			
			if(mapCiWithCompetenceActive.get(geocat.Id) != null){
				// Au moins un Critère d’intervention suspendu
	         	if((geocat.Date_de_debut__c != null && geocat.Date_de_fin__c != null && dateToday>=geocat.Date_de_debut__c && dateToday<=geocat.Date_de_fin__c) ||
	         		(geocat.Date_de_debut__c != null && geocat.Date_de_fin__c == null && dateToday>=geocat.Date_de_debut__c ) ||
	         		(geocat.Date_de_fin__c != null && geocat.Date_de_debut__c == null && dateToday<=geocat.Date_de_fin__c ) ||
					(geocat.DDP__c == null || geocat.DDP__c <= 0 || geocat.Zone_d_intervention__c == null || geocat.Zone_d_intervention__c <= 0)){
	         		
	         		if(geocat.Account__r.Id != null && mapAccounts.get(geocat.Account__r.Id) != null){
	         			
		         		Account temp = mapAccounts.get(geocat.Account__r.Id);
		         		temp.au_moins_un_ci_suspendu__c = true;
	         		}	
	         	}
	         	// Tous les Critères d’intervention ne sont pas suspendus
	         	if((((geocat.Date_de_debut__c == null && geocat.Date_de_fin__c == null) || 
	         		(geocat.Date_de_debut__c != null  && dateToday<geocat.Date_de_debut__c) || 
	         		(geocat.Date_de_fin__c != null  && dateToday>geocat.Date_de_fin__c))) &&
					(geocat.DDP__c != null && geocat.DDP__c > 0 && geocat.Zone_d_intervention__c != null && geocat.Zone_d_intervention__c > 0)){
	         		
	         		if(geocat.Account__r.Id != null && mapAccounts.get(geocat.Account__r.Id) != null){
	         			
		         		Account temp = mapAccounts.get(geocat.Account__r.Id);
		         		temp.aucun_ci_actif__c = false;
	         		}	
	         	}
			}
			else{
				
				Account temp = mapAccounts.get(geocat.Account__r.Id);
		        temp.au_moins_un_ci_suspendu__c = true;
			}
			if(!listAccountsWithCi.contains(geocat.Account__r.Id)){
				listAccountsWithCi.add(String.valueOf(geocat.Account__r.Id));
			}
			
		}
		

		for (Account acc : listAccountsToUpdate) {
			if(!listAccountsWithCi.contains(acc.Id) && listAccIdWithIntermediation.contains(acc.Id)){
				acc.au_moins_un_ci_suspendu__c = true;
			}
		}
        
		// GESTION DU FLAG DEFAUt ASSURANCE
		
		for (Document_Assurance__c  Assu : [SELECT Id,Statut__c,Date_d_expiration__c,Compte__c FROM Document_Assurance__c where Compte__c in: listAccIdWithIntermediationAfter15092019 and (Statut__c = 'Expirée' or Statut__c = 'Validée')]) {
			
			mapAccountsHasAssurance.put(Assu.Compte__c,true);
            if(Assu.Statut__c =='Validée' && mapAccountsHasAssuranceValide.get(Assu.Compte__c) == false){
				mapAccountsHasAssuranceValide.put(Assu.Compte__c, true);
				mapAccounts.get(Assu.Compte__c).Defaut_Assurance__c = false;
			}
			else if(Assu.Statut__c =='Expirée' && Assu.Date_d_expiration__c != null && mapAccountsHasAssuranceValide.get(Assu.Compte__c) == false){
				if(Assu.Date_d_expiration__c != null){
					Integer numberDaysDue = Assu.Date_d_expiration__c.daysBetween(Date.today());
	                if(numberDaysDue <= 60){
	                    mapAccounts.get(Assu.Compte__c).Defaut_Assurance__c = false;
	                    mapAccountsHasAssuranceValide.put(Assu.Compte__c, true);
	                }
				}
			}
			
		}
        for (Id accId : listAccIdWithIntermediationAfter15092019) {
			
			if(mapAccountsHasAssuranceValide.get(accId) == false && mapAccountsHasAssurance.get(accId) == true){
				//mapAccounts.get(accId).Defaut_Assurance__c = true;
			}
		}

		//Mise à jour des comptes
		if(listAccountsToUpdate.size() > 0){
  			update listAccountsToUpdate;
  		}
    }    
   	public void finish(Database.BatchableContext BC){

   	}

    public void execute(SchedulableContext context) {
        Batch_compte_indicateurs  b = new  Batch_compte_indicateurs (); 
        database.executebatch(b);
    }
}