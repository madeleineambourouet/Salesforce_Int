global class BatchParrainnage implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable, Database.Stateful {
	
	String query;
	Map<String, Object> m;
	List<mailWrapper> mails;
	
	global BatchParrainnage() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Batch start');
		mails = new List<mailWrapper>();
		query = 'SELECT Id, Date_parrainnage__c, Remise_consommee__c, Premiere_souscription__c, Parrain__r.Contact_principal__r.Name, Parrain__r.Contact_principal__r.Email, Parrain__r.Contact_principal__c, Contact_principal__r.Name, Name FROM Account WHERE Parrain__c != null AND Remise_consommee__c != \'Consommée\' AND Remise_consommee__c != \'Invalide\'';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Date d3mois = Date.today().addMonths(-3);
		Date d2mois = Date.today().addMonths(-2);
		Date d1mois = Date.today().addMonths(-1);
		Date d15jour = Date.today().addDays(-15);
		System.debug('d3mois = ' + d3mois);
		System.debug('d2mois = ' + d2mois);
		System.debug('d1mois = ' + d1mois);

		List<Account> accScope = (List<Account>) scope;
		List<Account> accs = new List<Account>();
		

		if (accScope != null) {
			System.debug('TEST 1');
			OrgWideEmailAddress oa = [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%' LIMIT 1];
			// Proccessus apres 3 mois de souscription du filleul
			List<Account> accEliActive = [SELECT Id, Parrain__c, Contact_principal__r.Name, Name FROM Account WHERE Id IN :accScope AND Id IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__SubscriptionEndDate__c = null AND Zuora__SubscriptionStartDate__c <= :d1mois) ];
			List<Account> accEliCancelled = [SELECT Id, Parrain__c, Contact_principal__r.Name, Name, Date_parrainnage__c  FROM Account WHERE Id IN :accScope AND Premiere_souscription__c = 'OLD' AND Id IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Cancelled' AND Zuora__SubscriptionStartDate__c <= :d1mois)];
			Map<Id, Account> checkSouscrption = new Map<Id, Account>([SELECT Id, Parrain__c, Contact_principal__r.Name, Name FROM Account WHERE Id IN :accScope AND Id IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active')]);
			Set<Account> accEli = new Set<Account>();
			accEli.addAll(accEliActive);
			for (Account a : accEliCancelled) {
				if (!checkSouscrption.containsKey(a.Id)) {
					accEli.add(a);
				}
			}

			List<Id> idParr = new List<Id>();
			for (Account a : accEli) {
				idParr.add(a.Parrain__c);
			}
			System.debug('idParr = ' + idParr);
			
			System.debug('accEli = ' + accEli);
			Map<Id, Account> accParr = new Map<Id, Account>([SELECT Id , Contact_principal__c, Contact_principal__r.Name, Contact_principal__r.Email FROM Account WHERE Id IN :idParr AND Id IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__SubscriptionEndDate__c = null AND Zuora__Status__c = 'Active')]);

			if (accEli != null) {
				//List<Zuora__Subscription__c> subs = [SELECT Id, Zuora__Account__c, Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c IN :accEli AND Zuora__Status__c = 'Active'];
				for (Zuora__Subscription__c zsub : [SELECT Id, Zuora__Account__c, Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__BillCycleDay__c FROM Zuora__Subscription__c WHERE Zuora__Account__c IN :idParr AND Zuora__Status__c = 'Active']) {
					Decimal mrr = getSubcriptionFromZuora(zsub.Zuora__Zuora_Id__c);
					Date d;

					if (zsub.Zuora__CustomerAccount__r.Zuora__BillCycleDay__c == 'EOM(End of Month)') {
						d = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
					} else if (zsub.Zuora__CustomerAccount__r.Zuora__BillCycleDay__c == null) {
						d = Date.today();
					} else {
						List<String> ls = zsub.Zuora__CustomerAccount__r.Zuora__BillCycleDay__c.splitByCharacterType();
						if (Integer.valueOf(ls[0]) > Date.daysInMonth(Date.today().year(), Date.today().month()))
							d = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));
						else
							d = Date.newInstance(Date.today().year(), Date.today().month(),Integer.valueOf(ls[0]));
					}
					
					//Date dExmple = Date.newInstance(2018,03,31);

					//if (zsub.Zuora__CustomerAccount__r.Zuora__BillCycleDay__c == 'EOM(End of Month)') {
					//	d = Date.newInstance(dExmple.year(), dExmple.month(), Date.daysInMonth(dExmple.year(), dExmple.month()));
					//} else if (zsub.Zuora__CustomerAccount__r.Zuora__BillCycleDay__c == null) {
					//	d = dExmple;
					//} else {
					//	List<String> ls = zsub.Zuora__CustomerAccount__r.Zuora__BillCycleDay__c.splitByCharacterType();
					//	if (Integer.valueOf(ls[0]) > Date.daysInMonth(dExmple.year(),dExmple.month()))
					//		d = Date.newInstance(dExmple.year(), dExmple.month(), Date.daysInMonth(dExmple.year(), dExmple.month()));
					//	else
					//		d = Date.newInstance(dExmple.year(), dExmple.month(),Integer.valueOf(ls[0]));
					//}

					

					System.debug('TEST 1 ok');
					for (Account a : accEli) {
						Map<Id,Id> listPar = new Map<Id,Id>();

						//if (d == Date.newInstance(2018,02,28) && a.Parrain__c == zsub.Zuora__Account__c) {
						if (d == Date.today() && a.Parrain__c == zsub.Zuora__Account__c && mrr != 0) {
							System.debug('zsub.Zuora__Zuora_Id__c = ' + zsub.Zuora__Zuora_Id__c);
							System.debug('mrr = ' + mrr);

							Boolean ws = AppelRestRemise(zsub.Zuora__Zuora_Id__c, mrr);

							System.debug('id souscription zuora = ' + zsub.Zuora__Zuora_Id__c);
							System.debug('id souscription sf = ' + zsub.Id);
							System.debug('nom filleul = ' + a.Name);
							System.debug('ws = ' + ws);
							System.debug(listPar.containsKey(a.Parrain__c));
							System.debug('a.p = ' + a.Parrain__c + '| zsub.Z = ' + zsub.Zuora__Account__c);

							if (!listPar.containsKey(a.Parrain__c) && ws == true) {
								System.debug('TEST 2');

								System.debug('listPar = ' + listPar);
								listPar.put(a.Parrain__c,a.Parrain__c);
								// action sur parrain
								System.debug('accParr = ' + accParr);
								accs.add(accParr.get(a.Parrain__c));
								// action sur filleul
								a.remise_consommee__c = 'Consommée';

								accs.add(a);
				    			if (mrr != 0)
				                	mails.add(new mailWrapper(accParr.get(a.Parrain__c).Contact_principal__r.Email, 'Homly You : votre remise parrainage', MailHelper.PARRAINAGE_mailconfirm(accParr.get(a.Parrain__c).Contact_principal__r.Name, a.Contact_principal__r.Name, a.Name), accParr.get(a.Parrain__c).Contact_principal__c, oa.Id));
				            }

						}
					}

				}

			}
			// Fin du proccessus

			// Processus apres 2 mois d'inactivité
			//accInva = [SELECT Id FROM Account WHERE Id IN :accScope AND Premiere_souscription__c = 'NEW' AND Date_parrainnage__c >= :d2mois]
			
			for (Account a : accScope) {
				System.debug('a.Name = ' + a.Name);
				System.debug('a.Date_parrainnage__c = ' + a.Date_parrainnage__c + '| d15jour = ' + d15jour);

				
				if (a.Date_parrainnage__c <= d15jour && a.Premiere_souscription__c == 'NEW') {
					System.debug(a.Name + ' Invalide!!!');

					a.Remise_consommee__c = 'Invalide';
					a.Premiere_souscription__c = 'OLD';
					accs.add(a);

			        mails.add(new mailWrapper(a.Parrain__r.Contact_principal__r.Email,'Homly You : des nouvelles de votre parrainage', MailHelper.PARRAINAGE_mailnoninscrit(a.Parrain__r.Contact_principal__r.Name, a.Contact_principal__r.Name, a.Name), a.Parrain__r.Contact_principal__c,oa.Id));

				}
			}
			update accs;	
			// Fin du proccessus
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('Batch finish ');
		for (mailWrapper mail : mails) {
			System.debug('Batch finish : mail = ' + mail);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail.getMail()});
			
		}
	}

	global void execute(SchedulableContext context) {
       BatchParrainnage  b = new  BatchParrainnage(); 
       database.executebatch(b,5);
    }

    public class mailWrapper {
    	public String destinataire {get;set;}
    	public String subject {get;set;}
    	public String body {get;set;}
    	public String idContact {get;set;}
    	public String owe {get;set;}


    	public mailWrapper(String dest, String subj, String body, Id idCon, Id ow) {
    		this.destinataire = dest;
    		this.subject = subj;
    		this.body = body;
    		this.idContact = idCon;
    		this.owe = ow;
    	}

    	public Messaging.SingleEmailMessage getMail() {
    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] {this.destinataire});
			mail.setSubject(this.subject);
			mail.setBccSender(false);
			mail.setHtmlBody(this.body);
			mail.setTargetObjectId(this.idContact);
			mail.setSaveAsActivity(true);
			mail.setOrgWideEmailAddressId(this.owe);
			return mail;
    	}
    }

    public Decimal getSubcriptionFromZuora(String Idsub) {
    	String endpoint = System.Label.ZUORA_URL_REST_API + 'v1/subscriptions/' + Idsub;
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('GET');
		req.setHeader('apiAccessKeyId', System.Label.Zuora_TECH_Login);
		req.setHeader('apiSecretAccessKey', System.Label.Zuora_TECH_Password);
		req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
		Http http = new Http();
	    HTTPResponse res = http.send(req);
    	m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    	Decimal contractedmrr = (Decimal) m.get('contractedMrr');
    	return contractedmrr;
		System.debug('TEST 3');
		return 0;
    }

    public Boolean AppelRestRemise(String Idsub, Decimal mrr) {
    	String endpoint = System.Label.ZUORA_URL_REST_API + 'v1/subscriptions/' + Idsub;
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('PUT');
		req.setHeader('apiAccessKeyId', System.Label.Zuora_TECH_Login);
		req.setHeader('apiSecretAccessKey', System.Label.Zuora_TECH_Password);
		req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
		Decimal mrrHOM = 0;
		Decimal mrrCAP = 0;
		Decimal mrrALL = 0;
		Boolean part = false;
		Boolean boolHOM = false;
		Boolean boolCAP = false;
		String idPRODUCTRATEPLAN = '';
		String idPRODUCTRATEPLANCHARGE = '';

		List<Object> rateplanList = (List<Object>) m.get('ratePlans');
		for (Object rateplanMap : rateplanList) {

			String namePlan = (String) ((Map<String, Object>) rateplanMap).get('productName');
			String ratePlanName = (String) ((Map<String, Object>) rateplanMap).get('ratePlanName');
			String lastChangeType = (String) ((Map<String, Object>) rateplanMap).get('lastChangeType');
			for (Zuora_Id_parrainage__c zip  : Zuora_Id_parrainage__c.getall().values()) {
				if (namePlan == zip.ProductName__c && idPRODUCTRATEPLAN.length() == 0) {
					idPRODUCTRATEPLAN = zip.PRODUCTRATEPLAN_ID__c;
					idPRODUCTRATEPLANCHARGE = zip.PRODUCTRATEPLANCHARGE_ID__c;
				}

			}

			if (lastChangeType != 'remove' && (ratePlanName.contains('Lapeyre') || ratePlanName.contains('Menuiseries Françaises')) ) {
				part = true;
			}
			List<Object> rateplanchargeList = (List<Object>) ((Map<String, Object>) rateplanMap).get('ratePlanCharges');

			for (Object rateplanchargeMap : rateplanchargeList) {

				if (lastChangeType != 'remove' && namePlan.contains('Homly Travaux') && ((Map<String, Object>) rateplanchargeMap).get('mrr') != null) {
					mrrHOM += (Decimal) ((Map<String, Object>) rateplanchargeMap).get('mrr');
					boolHOM = true;
				}

				if (lastChangeType != 'remove' && namePlan.contains('CapRenov') && ((Map<String, Object>) rateplanchargeMap).get('mrr') != null) {
					mrrCAP += (Decimal) ((Map<String, Object>) rateplanchargeMap).get('mrr');
					boolCAP = true;
				}


				if (!boolHOM && !boolCAP && lastChangeType != 'remove') {
					System.debug('namePlan = ' + namePlan);
					System.debug('rateplanchargeMap = ' + rateplanchargeMap);
					System.debug('((Map<String, Object>) rateplanchargeMap).get(\'mrr\') = ' + ((Map<String, Object>) rateplanchargeMap).get('mrr'));

					if (namePlan.contains('annuelle') && !namePlan.contains('Remises') && (Decimal)((Map<String, Object>) rateplanchargeMap).get('mrr') != null) {
						mrrALL += ((Decimal) ((Map<String, Object>) rateplanchargeMap).get('mrr')).setscale(2,System.RoundingMode.DOWN);
					}

					if (namePlan.contains('mensuelle') && (Decimal)((Map<String, Object>) rateplanchargeMap).get('mrr') != null) {
						mrrALL += ((Decimal) ((Map<String, Object>) rateplanchargeMap).get('mrr')).setscale(2,System.RoundingMode.DOWN);
					}
					System.debug('TEST mrrALL ' + mrrALL);
				}

			}
		}

		
		String body = '{	"add":[';
		if (boolHOM == true && part == false) {

			body += '{"contractEffectiveDate":"' + Date.today().year() + '-'+ Date.today().month().format() +'-' + Date.today().day().format() + '",';
			body += '"productRatePlanId": "'+ System.Label.ZUORA_PRODUCTRATEPLAN_ID+ '","chargeOverrides":[{';
			body += '"productRatePlanChargeId":"' + System.Label.ZUORA_PRODUCTRATEPLANCHARGE_ID + '",';
			body += '"price":-'+ mrrHOM.toPlainString()+'}]}';
		}

		if (boolCAP == true) {

			if (boolHOM == true && part == false)
				body += ',';

			body += '{"contractEffectiveDate":"' + Date.today().year() + '-'+ Date.today().month().format() +'-' + Date.today().day().format() + '",';
			body += '"productRatePlanId": "'+ System.Label.ZUORA_PRODUCTRATEPLAN_ID_CAP+ '","chargeOverrides":[{';
			body += '"productRatePlanChargeId":"' + System.Label.ZUORA_PRODUCTRATEPLANCHARGE_ID_CAP + '",';
			body += '"price":-'+ mrrCAP.toPlainString()+'}]}';
		}

		if (boolHOM == false && boolCAP == false && idPRODUCTRATEPLAN.length() != 0) {

			body += '{"contractEffectiveDate":"' + Date.today().year() + '-'+ Date.today().month().format() +'-' + Date.today().day().format() + '",';
			body += '"productRatePlanId": "'+ idPRODUCTRATEPLAN + '","chargeOverrides":[{';
			body += '"productRatePlanChargeId":"' + idPRODUCTRATEPLANCHARGE + '",';
			body += '"price":-'+ mrrALL.toPlainString()+'}]}';
		}

		body += ']}';

		if (boolHOM == true || boolCAP == true || (idPRODUCTRATEPLAN.length() != 0 && mrrALL != 0)) {
			req.setBody(body);
			System.debug(body);
			Http http = new Http();
		    HTTPResponse res = http.send(req);
		    Map<String, Object> succ = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
		    Boolean success = (Boolean) succ.get('success');
		    if (success) {
				return true;
		    } else {
		    	System.debug('TEST res.getBody = ' + res.getBody());
				return false;
			}
		} else {
				return false;
			}
    }
	
}