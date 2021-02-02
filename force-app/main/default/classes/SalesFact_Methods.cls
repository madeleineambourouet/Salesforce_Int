// 
// Class to manage sales facts for sales incentives
// 22/01/2018, xavier templet, création   
// hard coded for Offre « Essentiel », Offre « Energie », Offre « Gestion », Offre « Intégral » 
//

global class SalesFact_Methods 
{

    public static void InsertSF_UpSell(List<zqu__Quote__c> lQuote) {

      	System.debug('SalesFact_Methods >>>>> lQuote :' + lQuote);
	    List<id> lQuoteId = new List<Id>();
	    List<id> lAccntId = new List<Id>();
	    for (zqu__Quote__c quo : lQuote) {
	    	lQuoteId.add(quo.Id);
	    	lAccntId.add(quo.zqu__account__c);
	    }

		//select id, Name, zqu__Quantity__c, zqu__EffectivePrice__c, zqu__MRR__c, zqu__TCV__c, zqu__QuoteRatePlan__r.Name, zqu__QuoteRatePlan__r.zqu__AmendmentType__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__r.zqu__Quote__c='a104E00000137K0'
    	List<zqu__QuoteChargeSummary__c> lQuoteChargeSummary = [SELECT zqu__QuoteRatePlan__r.Name, zqu__QuoteRatePlan__r.zqu__Quote__c,zqu__QuoteRatePlan__r.zqu__AmendmentType__c,
    		id,Name,zqu__EffectivePrice__c,zqu__Type__c,zqu__Quantity__c,zqu__Model__c,zqu__TotalPrice__c,IsDeleted, zqu__ChangeLog__c 
    			FROM zqu__QuoteChargeSummary__c WHERE IsDeleted = false AND zqu__QuoteRatePlan__r.zqu__Quote__c in: lQuoteId AND zqu__Type__c = 'Recurring'];
      	System.debug('SalesFact_Methods >>>>> lQuoteChargeSummary :' + lQuoteChargeSummary);

	    if (lQuoteChargeSummary != null && lQuoteChargeSummary.size() > 0) {

		List<String> Offre_et_Service = new List<String> {'Service \"Vitrine web\"', 'Service \"Simulateur d’efficacité énergétique Cap Renov+\"', 
			'Service \"Logiciel de gestion devis & factures Tolteck\"', 'Offre \"Essentiel\"', 'Offre \"Energie\"', 'Offre \"Gestion\"', 'Offre \"Intégral\"'};

		List<Account> ls = [select Id,Name from Account where Id in :lAccntId];
		Map<Id, Account> mAccnt = new Map<Id, Account>(ls);

		List<Zuora__Subscription__c> lzuoSub = [select Id, Zuora__Account__c from Zuora__Subscription__c where Zuora__Status__c = 'Active' AND Zuora__Account__c in :lAccntId];
		Map<Id, Zuora__Subscription__c> Accnt2Sub = new Map<Id, Zuora__Subscription__c>(); 
		if (lzuoSub != null && lzuoSub.size()>0 ) for (Zuora__Subscription__c z : lzuoSub) Accnt2Sub.put(z.Zuora__Account__c, z); 		
		
		List<Sales_Facts__c> sfactLst = new List<Sales_Facts__c>();

        	// Go through the quotes
        	for (zqu__Quote__c quo : lQuote) {

				String accntName; 
				//Decimal PriceTag = 0;
				Decimal newPrice = 0;
				Decimal removePrice = 0;
            	for (zqu__QuoteChargeSummary__c ChargeSummary : lQuoteChargeSummary) {

					if (ChargeSummary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.Id  && Offre_et_Service.contains(ChargeSummary.Name)) {
								// ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'NewProduct'
								// ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'RemoveProduct'
						if (ChargeSummary.zqu__ChangeLog__c.split(' ')[0] == 'Removed') {
							removePrice += (Decimal) ChargeSummary.zqu__TotalPrice__c.abs();
						}
						if (ChargeSummary.zqu__ChangeLog__c.split(' ')[0] == 'New') {
							newPrice += (Decimal) ChargeSummary.zqu__TotalPrice__c.abs();
						}
					}
            	}
				if (newPrice > removePrice) {
					Sales_Facts__c sfact = new Sales_Facts__c();
					sfact.Customer__c = quo.zqu__account__c; //Client concerné => Compte pro associé à la souscription
					sfact.Date__c = Date.today();
					sfact.Sales_fact_type__c= 'Vente complémentaire';
					if (Accnt2Sub.containsKey(quo.zqu__account__c)) sfact.Subscription__c = Accnt2Sub.get(quo.zqu__account__c).Id;  
					sfact.Subscription_activation_date__c = Date.today(); //Date d’activation de la souscription => Date du jour
					//sfact.Subscription_termination_date__c;
					sfact.Value_Date_for_Salesman__c = firstday_of_next_month();
					sfact.Value_Date_for_Manager__c = firstday_of_next_quarter();  
					sfact.Comment__c = 'Vente complémentaire sur le client ' + mAccnt.get(quo.zqu__account__c).Name + ' activée le ' + Date.today().format(); // !!!!!!!!!!!!!!!!!!!!!! quo.zqu__account__r.Name !!!!!!!!!!!!!!!!!!!!!!!!
					sfact.Quote__c = quo.Id; //Proposition commerciale => Proposition commerciale ayant conduit à la création de la souscription
					sfact.Salesman__c = quo.ownerID; // Commercial => Propriétaire de la proposition commerciale ayant conduit à la création de la souscription
					//sfact.ownerID = sfact.Salesman__c; 
					//sfact.Manager__c = Owner2Manager.get(q.ownerID);
					if (quo.Manager__c != null) {
						sfact.Manager__c = quo.Manager__c;// Manager => Manager du commercial au moment où la proposition commerciale a été validée
					} else {
						sfact.Manager__c = sfact.Salesman__c;
					}
					//sfact.Manager__c = get_manager(RefITC, q.Date_de_validation__c, q.ownerID);// Manager => Manager du commercial au moment où la proposition commerciale a été validée
					sfact.Quote_Validation_Date__c = quo.Date_de_validation__c; // Date de validation de la proposition commerciale => Date à laquelle cette proposition a été validée
					sfactLst.add(sfact);
								
				}
	        }//for (zqu__Quote__c quo : lQuote)
	        
			insert(sfactLst);
      		System.debug('SalesFact_Methods >>>>> sfactLst :' + sfactLst);
    	}
    }

    public static void Transaction_Salesfact(List<Zuora__Refund__c> NewRefund) {
    	List<Sales_Facts__c> sfactLst = new List<Sales_Facts__c>();
    	Map<Id, User> userMap = new Map<Id, User>([select Id, ManagerID, UserRole.Name from User where (Profile.Name = 'Administrateur fonctionnel' OR Profile.Name = 'Administrateur système' OR Profile.Name = 'Service Client' OR Profile.Name = 'Service Commercial' OR Profile.Name = 'Service Commercial ITCS' OR Profile.Name = 'Service Consommateur')]);
    	Map<Id, Zuora__Refund__c> owner = new Map<Id, Zuora__Refund__c>([SELECT Id, Zuora__Account__r.Name, Zuora__Account__r.OwnerId FROM Zuora__Refund__c WHERE Id IN :NewRefund]);
    	for (Zuora__Refund__c nr : NewRefund) {

    		Sales_Facts__c sf = new Sales_Facts__c();
    		sf.Remboursement__c = nr.Id;
    		sf.Date__c = Date.today();
    		System.debug('nr.Zuora__Account__r.OwnerId = ' + nr.Zuora__Account__r.OwnerId);
    		sf.Salesman__c = owner.get(nr.Id).Zuora__Account__r.OwnerId;
    		if (userMap.containsKey(sf.Salesman__c) && userMap.get(sf.Salesman__c).UserRole.Name != 'ITCS' && userMap.get(sf.Salesman__c).UserRole.Name != 'TC Service client pro' && userMap.get(sf.Salesman__c).UserRole.Name != 'TC Service commercial') {
				sf.Manager__c = sf.Salesman__c;
			} else if (userMap.containsKey(sf.Salesman__c)) {
				sf.Manager__c = userMap.get(sf.Salesman__c).ManagerID;
			}
    		sf.Value_Date_for_Salesman__c = firstday_of_next_month();
    		sf.Value_Date_for_Manager__c = firstday_of_next_quarter();
    		sf.Customer__c = nr.Zuora__Account__c;
    		sf.Montant__c = - nr.Zuora__Amount__c;
    		sf.Sales_fact_type__c = 'Règlement client';
    		sf.Comment__c = 'Impayé ou remboursement d’un montant de ' + nr.Zuora__Amount__c + ' sur le client ' + owner.get(nr.Id).Zuora__Account__r.Name  + ' constaté le ' + Date.today().format();
    		sfactLst.add(sf);

    	}
    	insert sfactLst;
    }

    public static void Transaction_Salesfact(List<Zuora__Payment__c> NewPayment) {

    	List<Sales_Facts__c> sfactLst = new List<Sales_Facts__c>();
    	Map<Id, User> userMap = new Map<Id, User>([select Id, ManagerID, UserRole.Name from User where (Profile.Name = 'Administrateur fonctionnel' OR Profile.Name = 'Administrateur système' OR Profile.Name = 'Service Client' OR Profile.Name = 'Service Commercial' OR Profile.Name = 'Service Commercial ITCS' OR Profile.Name = 'Service Consommateur')]);
    	Map<Id, Zuora__Payment__c> owner = new Map<Id, Zuora__Payment__c>([SELECT Id, Zuora__Account__r.Name, Zuora__Account__r.OwnerId FROM Zuora__Payment__c WHERE Id IN :NewPayment]);
    	for (Zuora__Payment__c np : NewPayment) {
    		Sales_Facts__c sf = new Sales_Facts__c();
    		sf.Paiement__c = np.Id;
    		sf.Date__c = Date.today();
    		sf.Salesman__c = owner.get(np.Id).Zuora__Account__r.OwnerId;

    		if (userMap.containsKey(sf.Salesman__c) && userMap.get(sf.Salesman__c).UserRole.Name != 'ITCS' && userMap.get(sf.Salesman__c).UserRole.Name != 'TC Service client pro' && userMap.get(sf.Salesman__c).UserRole.Name != 'TC Service commercial') {
				sf.Manager__c = sf.Salesman__c;
			} else if (userMap.containsKey(sf.Salesman__c)) {
				sf.Manager__c = userMap.get(sf.Salesman__c).ManagerID;
			}
    		sf.Value_Date_for_Salesman__c = firstday_of_next_month();
    		sf.Value_Date_for_Manager__c = firstday_of_next_quarter();
    		sf.Customer__c = np.Zuora__Account__c;
    		sf.Montant__c = np.Zuora__Amount__c;
    		sf.Sales_fact_type__c = 'Règlement client';
    		sf.Comment__c = 'Paiement d’un montant de ' + np.Zuora__Amount__c + ' sur le client ' + owner.get(np.Id).Zuora__Account__r.Name  + ' constaté le ' + Date.today().format();
    		sfactLst.add(sf);
    	}
    	insert sfactLst;
    }
    
    public static void InsertSF_ActiveSub(List<Zuora__Subscription__c> NewSubLst, Map<Id,Id> Sub2Quote, List<String> IdList, Map<Id, Zuora__Subscription__c> mapSub) {

      	System.debug('SalesFact_Methods >>>>> Sub2Quote :' + Sub2Quote);

		// il faut pouvoir récupérer les quotes associées aux souscriptions  
		List<zqu__Quote__c> ZuoQuoteList = [select Id, Name, ownerID, zqu__account__c, zqu__Status__c, Date_de_validation__c, Manager__c 
												from zqu__Quote__c where Id IN :IdList];
		Map<Id,zqu__Quote__c> QuoteMap = new Map<Id,zqu__Quote__c>(); 
		for (zqu__Quote__c q: ZuoQuoteList) QuoteMap.put(q.Id, q);
      	System.debug('SalesFact_Methods >>>>> QuoteMap :' + QuoteMap);
      	// a remettre
		List<zqu__QuoteRatePlan__c>  quoRatePlanList = [select Id, Name, zqu__Quote__c  from zqu__QuoteRatePlan__c 
			where zqu__Quote__c IN :IdList]; // AND zqu__AmendmentType__c = 'NewProduct'
		Map<Id,zqu__QuoteRatePlan__c> QuoteRatePlanMap = new Map<Id,zqu__QuoteRatePlan__c>(); 
		for (zqu__QuoteRatePlan__c qrp: quoRatePlanList) {
			if (qrp.name.contains('Offre') && (qrp.name.contains('Essentiel') || qrp.name.contains('Energie')|| qrp.name.contains('Gestion')|| qrp.name.contains('Intégral'))) {
				if(!QuoteRatePlanMap.containsKey(qrp.zqu__Quote__c)) QuoteRatePlanMap.put(qrp.zqu__Quote__c, qrp);
				else {
					if (qrp.name.contains('Intégral')) 	swap_map_value(QuoteRatePlanMap, qrp);
					else if (qrp.name.contains('Gestion') && (QuoteRatePlanMap.get(qrp.zqu__Quote__c).name.contains('Energie') || QuoteRatePlanMap.get(qrp.zqu__Quote__c).name.contains('Essentiel'))) 	swap_map_value(QuoteRatePlanMap, qrp); 
					else if (qrp.name.contains('Energie') && (QuoteRatePlanMap.get(qrp.zqu__Quote__c).name.contains('Essentiel'))) 	swap_map_value(QuoteRatePlanMap, qrp); 
				}
			}
		}
		

		/*List<Zuora__SubscriptionProductCharge__c> subChargeList = [SELECT Id, Name, Zuora__Subscription__c FROM Zuora__SubscriptionProductCharge__c WHERE Id IN :mapSub.keyset()];
		Map<Id, Zuora__SubscriptionProductCharge__c> subChargeMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
		for (Zuora__SubscriptionProductCharge__c spc : subChargeList) {
			if (spc.name.contains('Offre') && (spc.name.contains('Essentiel') || spc.name.contains('Energie')|| spc.name.contains('Gestion')|| spc.name.contains('Intégral'))) {
				subChargeMap.put(spc.Zuora__Subscription__c, spc);
			}
		}*/


      	//System.debug('SalesFact_Methods >>>>> QuoteRatePlanMap :' + QuoteRatePlanMap);

		List<user> userLst = [select Id, ManagerID, UserRole.Name from user where (Profile.Name = 'Administrateur fonctionnel' OR Profile.Name = 'Administrateur système' OR Profile.Name = 'Service Client' OR Profile.Name = 'Service Commercial' OR Profile.Name = 'Service Commercial ITCS' OR Profile.Name = 'Service Consommateur')];
		Map<Id,Id> ActiveUser = new Map<Id,Id>();
		Map<Id,Id> Owner2Manager = new Map<Id,Id>();
		Map<Id, User> userMap = new Map<Id, User>();
		for (user u : userLst) {
			ActiveUser.put(u.Id, u.Id);
			Owner2Manager.put(u.Id, u.ManagerID);
			userMap.put(u.Id, u);
		}
		//List<Reference_ITC__c> RefITC = [select ITC__c, Manager__c, Date_de_debut__c, Date_de_fin__c from Reference_ITC__c]; 

		List<Sales_Facts__c> sfactLst = new List<Sales_Facts__c>();
		
		for(Zuora__Subscription__c s : NewSubLst){
			if (s.Type_de_geste__c != 'Renonciation') {
				Sales_Facts__c sfact = new Sales_Facts__c();
				sfact.Customer__c = s.Zuora__Account__c; //Client concerné => Compte pro associé à la souscription
				sfact.Date__c = Date.today();
				sfact.Sales_fact_type__c= 'Activation de souscription';
				sfact.Subscription__c = s.Id; // Souscription concernée => Souscription concernée
				sfact.Subscription_activation_date__c = Date.today(); //Date d’activation de la souscription => Date du jour
				//sfact.Subscription_termination_date__c;
				sfact.Value_Date_for_Salesman__c = firstday_of_next_month();
				sfact.Value_Date_for_Manager__c = firstday_of_next_quarter();
				zqu__Quote__c q = new zqu__Quote__c();
				q = QuoteMap.get(Sub2Quote.get(s.Id));
				if (q != null) { 
					sfact.Comment__c = 'Activation de la souscription '+s.Name+ ' suite proposition commerciale '+q.Name;
				sfact.Quote__c = q.Id; //Proposition commerciale => Proposition commerciale ayant conduit à la création de la souscription
				sfact.Salesman__c = q.ownerID; // Commercial => Propriétaire de la proposition commerciale ayant conduit à la création de la souscription
				//if (ActiveUser.containsKey(sfact.Salesman__c))
				//	sfact.ownerID = sfact.Salesman__c;
				if (userMap.containsKey(sfact.Salesman__c) && userMap.get(sfact.Salesman__c).UserRole.Name != 'ITCS' && userMap.get(sfact.Salesman__c).UserRole.Name != 'TC Service client pro' && userMap.get(sfact.Salesman__c).UserRole.Name != 'TC Service commercial') {
						sfact.Manager__c = sfact.Salesman__c;
				} else if (Owner2Manager.containsKey(sfact.Salesman__c)) {
						sfact.Manager__c = q.Manager__c;
					}
				// Manager => Manager du commercial au moment où la proposition commerciale a été validée
				//sfact.Manager__c = get_manager(RefITC, q.Date_de_validation__c, q.ownerID);// Manager => Manager du commercial au moment où la proposition commerciale a été validée
				sfact.Quote_Validation_Date__c = q.Date_de_validation__c; // Date de validation de la proposition commerciale => Date à laquelle cette proposition a été validée
				
				zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
				qrp = QuoteRatePlanMap.get(q.Id);

				//Zuora__SubscriptionProductCharge__c scp = new Zuora__SubscriptionProductCharge__c();
				//scp = subChargeMap.get(s.Id);

				if (qrp != null) {
					Sales_Facts__c sfact2 = sfact.clone(false,false,false,false);
					sfact2.Sales_fact_type__c = 'Activation d\'un Pack';
					if (qrp.name.contains('Intégral')) sfact2.Pack_Type__c = 'Offre \"Intégral\"';
						else if (qrp.name.contains('Gestion')) sfact2.Pack_Type__c = 'Offre \"Gestion\"';
							else if (qrp.name.contains('Energie')) sfact2.Pack_Type__c = 'Offre \"Energie\"';
								else if (qrp.name.contains('Essentiel')) sfact2.Pack_Type__c = 'Offre \"Essentiel\"';
			
						sfactLst.add(sfact2);
					}
				}
				sfactLst.add(sfact);

				Sales_Facts__c sfact3 = sfact.clone(false,false,false,false);
				sfact3.Sales_fact_type__c= 'Client actif';
				if (userMap.containsKey(sfact.Salesman__c) && userMap.get(sfact.Salesman__c).UserRole.Name != 'ITCS' && userMap.get(sfact.Salesman__c).UserRole.Name != 'TC Service client pro' && userMap.get(sfact.Salesman__c).UserRole.Name != 'TC Service commercial') {
					sfact3.Manager__c = sfact3.Salesman__c;
				} else if (Owner2Manager.containsKey(sfact.Salesman__c)) {
					sfact3.Manager__c = q.Manager__c;
				} 
				sfactLst.add(sfact3);
			}
		}
		if (sfactLst.size() > 0)
			insert(sfactLst);
    }

	/*// retrouver le manager à une date donnée en utilisant Reference_ITC__c 
	private static Id get_manager(List<Reference_ITC__c> RefITC, Date jourJ, Id Owner){
		for (Reference_ITC__c r : RefITC){
			if (r.ITC__c == Owner) {
				if ( r.Date_de_fin__c == null ) 
					if (jourJ >= r.Date_de_debut__c) return r.Manager__c;
				else if (jourJ >= r.Date_de_debut__c && jourJ <= r.Date_de_fin__c) return r.Manager__c;
			}
		}
		return null;
	}*/	

	//considering a map: swap the value of a corresponding key
    private static String swap_map_value(Map<Id,zqu__QuoteRatePlan__c> QuoteRatePlanMap, zqu__QuoteRatePlan__c qrp)  {
		if (!QuoteRatePlanMap.containsKey(qrp.zqu__Quote__c)) return 'ERROR';
		QuoteRatePlanMap.remove(qrp.zqu__Quote__c);
		QuoteRatePlanMap.put(qrp.zqu__Quote__c, qrp);
		return 'OK';
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

}