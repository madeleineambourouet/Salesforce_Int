public without sharing class CompteProSection {
	public OfferWrapper lOffrew {get;set;}
	public InteractionWrapper int15 {get;set;}
	public InteractionWrapper int1mois {get;set;}
	public InteractionWrapper int3mois {get;set;}
	public InteractionWrapper int6mois {get;set;}
	public InteractionWrapper int1an {get;set;}
	public GeocatListWrapper geo15 {get;set;}
	public GeocatListWrapper geo1mois {get;set;}
	public GeocatListWrapper geo3mois {get;set;}
	public GeocatListWrapper geo6mois{get;set;}
	public GeocatListWrapper geo1an {get;set;}
	public Boolean offreDisplay {get;set;}

	public CompteProSection(ApexPages.StandardController std) {
		traitementOffre((Account)std.getRecord());
		traitementInteraction((Account)std.getRecord());
		traitementCI((Account)std.getRecord());

	}

	public void traitementOffre(Account acc)
	{
		offreDisplay = true;
		Account currentAccount = acc;
		lOffrew = new OfferWrapper();

		//List<Zuora__SubscriptionProductCharge__c> Offrehom = [SELECT Id, Name, Zuora__EffectiveEndDate__c, Zuora__EffectiveStartDate__c, CreatedDate
		//			FROM Zuora__SubscriptionProductCharge__c
		//			WHERE Zuora__Account__c = :currentAccount.Id
		//			AND Name = :System.Label.LABEL_OFFRE_HOMLY
		//			AND Zuora__Product__c IN (
		//							SELECT Id
		//							FROM Zuora__Product__c
		//							WHERE Zuora__SKU__c = :System.Label.LABEL_OFFRE_HOMLY_SKU)
		//			ORDER BY CreatedDate DESC LIMIT 1];

		List<Zuora__SubscriptionProductCharge__c> Offrehom = [SELECT Id, Name, Zuora__EffectiveEndDate__c, Zuora__EffectiveStartDate__c, CreatedDate
					FROM Zuora__SubscriptionProductCharge__c
					WHERE Zuora__Account__c = :currentAccount.Id
					AND Name LIKE 'Offre%' LIMIT 1];
		

		List<Zuora__SubscriptionProductCharge__c> Offrecap = [SELECT Id, Name, Zuora__EffectiveEndDate__c, Zuora__EffectiveStartDate__c, CreatedDate
					FROM Zuora__SubscriptionProductCharge__c
					WHERE Zuora__Account__c = :currentAccount.Id
					AND Name LIKE 'Service%'];
		System.debug('TEST : Offrecap = ' + Offrecap);

		if (Offrehom.size() > 0)
			for (Zuora__SubscriptionProductCharge__c zspc : Offrehom)
				lOffrew.offreHOM = zspc;

		if (Offrecap.size() > 0)
			for (Zuora__SubscriptionProductCharge__c zspc : Offrecap)
				//lOffrew.offreCAP = zspc;

		if ([SELECT Id FROM Geocat__c WHERE Account__c = :currentAccount.Id AND (Date_de_debut__c != null OR Date_de_fin__c != null)].size() > 0)
			lOffrew.geosuspension = true;
		else
			lOffrew.geosuspension = false;
		lOffrew.init();
	}
	//SELECT Account.Name, CreatedDate, CreatedBy.Name, What.Name, Id, Who.Name, Subject, Owner.Name  FROM Task WHERE Subject  LIKE 'appel%'
	public void traitementInteraction(Account acc)
	{
		// PARTIE evenement
		this.int15 = new InteractionWrapper();
		this.int1mois = new InteractionWrapper();
		this.int3mois = new InteractionWrapper();
		this.int6mois = new InteractionWrapper();
		this.int1an = new InteractionWrapper();

		Date dat15 = Date.today().addDays(-15);
		Date dat1mois = Date.today().addMonths(-1);
		Date dat3mois = Date.today().addMonths(-3);
		Date dat6mois = Date.today().addMonths(-6);
		Date dat1an = Date.today().addYears(-1);

		

		List<Event> eventList = new List<Event>();
		List<Event> eventList2 = new List<Event>();
		List<Event> eventList3 = new List<Event>();
		List<Event> eventList4 = new List<Event>();

		List<Event> eventList5 = [SELECT Id, CreatedDate, CreatedBy.Name
								FROM Event
								WHERE AccountId = :acc.Id
								AND Subject = 'visite client'
								AND CreatedDate >= LAST_YEAR
								ORDER BY CreatedDate DESC];

		for (Event e : eventList5) {
			if (e.CreatedDate >= dat15)
				eventList.add(e);

			if (e.CreatedDate >= dat1mois)
				eventList2.add(e);

			if (e.CreatedDate >= dat3mois)
				eventList3.add(e);

			if (e.CreatedDate >= dat6mois)
				eventList4.add(e);
		}

		eventUtil(this.int15, eventList);
		eventUtil(this.int1mois, eventList2);
		eventUtil(this.int3mois, eventList3);
		eventUtil(this.int6mois, eventList4);
		eventUtil(this.int1an, eventList5);


		// Fin de la partie evenement

		// PARTIE Tache

		

		List<Task> taskList = new List<Task>();
		List<Task> taskList2 = new List<Task>();
		List<Task> taskList3 = new List<Task>();
		List<Task> taskList4 = new List<Task>();

		List<Task> taskList5 = [SELECT Id, CreatedDate, Owner.Name
								FROM Task
								WHERE AccountId = :acc.Id
								AND Subject  LIKE 'appel%'
								AND CreatedDate >= LAST_YEAR
								ORDER BY CreatedDate DESC ];

		for(Task t : taskList5) {
			if (t.CreatedDate >= dat15)
				taskList.add(t);

			if (t.CreatedDate >= dat1mois)
				taskList2.add(t);

			if (t.CreatedDate >= dat3mois)
				taskList3.add(t);

			if (t.CreatedDate >= dat6mois)
				taskList4.add(t);
		}

		taskUtil(this.int15, taskList);
		taskUtil(this.int1mois, taskList2);
		taskUtil(this.int3mois, taskList3);
		taskUtil(this.int6mois, taskList4);
		taskUtil(this.int1an, taskList5);
	}

	public void traitementCI(Account acc) {
		// nombre recredit
		this.geo15 = new GeocatListWrapper();
		this.geo1mois = new GeocatListWrapper();
		this.geo3mois = new GeocatListWrapper();
		this.geo6mois = new GeocatListWrapper();
		this.geo1an = new GeocatListWrapper();

		Date dat15 = Date.today().addDays(-15);
		Date dat1mois = Date.today().addMonths(-1);
		Date dat3mois = Date.today().addMonths(-3);
		Date dat6mois = Date.today().addMonths(-6);
		Date dat1an = Date.today().addYears(-1);

		RecordType rtm = [SELECT Id, DeveloperName
							FROM RecordType
							WHERE DeveloperName = 'Matching_rejet' LIMIT 1];

		//matching rejeté par compte
		AggregateResult[] mat_rejet = [SELECT Count (Id)counts
										FROM Intermediation__c
										WHERE Professionnel__c = :acc.Id
										AND Matching_rejete__c IN (SELECT Id
																	FROM Reference__c
																	WHERE RecordTypeId = :rtm.Id
																	AND Name LIKE 'Recrédit%')];

		Integer rej = 0;
		for (AggregateResult ar : mat_rejet) {
			rej = (integer)ar.get('counts');
		}

		
		

		// liste des critères d'intervention periodique
		
		//matching rejeté par compte

		// liste des critères d'intervention periodique

		//matching rejeté par compte
		
		// liste des critères d'intervention periodique


		List<Geocat__c> listGeocat = new List<Geocat__c>();
		List<Geocat__c> listGeocat2 = new List<Geocat__c>();
		List<Geocat__c> listGeocat3 = new List<Geocat__c>();
		List<Geocat__c> listGeocat4 = new List<Geocat__c>();
		List<Geocat__c> listGeocat5bis = new List<Geocat__c>();
		List<Geocat__c> listGeocat5 = [SELECT Id, Name, DDP__c, CreatedDate
										FROM Geocat__c
										WHERE Account__c = :acc.Id
										AND CreatedDate >= LAST_YEAR
										ORDER BY CreatedDate DESC];

		List<Intermediation__c> tri_mer_ci = [SELECT Id, Criteres_d_intervention__c, Date_de_s_lection__c
											FROM Intermediation__c
											WHERE Professionnel__c = :acc.Id
											AND Criteres_d_intervention__c IN :listGeocat5
											AND Is_selectionne__c = true
											AND Date_de_s_lection__c >= LAST_YEAR
											ORDER BY Date_de_s_lection__c DESC];

		Map<Id, helperCI> helps = new Map<Id, helperCI>();
		for (Intermediation__c i : tri_mer_ci) {
			if (!helps.containsKey(i.Criteres_d_intervention__c)) {
				helps.put(i.Criteres_d_intervention__c, new helperCI(i.Criteres_d_intervention__c, i.Date_de_s_lection__c));
			}
		}

		for (Geocat__c g : listGeocat5) {
			if (helps.containsKey(g.Id) && helps.get(g.id).dateMer >= dat15)
				listGeocat.add(g);

			if (helps.containsKey(g.Id) && helps.get(g.id).dateMer >= dat1mois)
				listGeocat2.add(g);

			if (helps.containsKey(g.Id) && helps.get(g.id).dateMer >= dat3mois)
				listGeocat3.add(g);

			if (helps.containsKey(g.Id) && helps.get(g.id).dateMer >= dat6mois)
				listGeocat4.add(g);

			if (helps.containsKey(g.Id) && helps.get(g.id).dateMer >= dat1an)
				listGeocat5bis.add(g);
		}


		List<Intermediation__c> listMatch = new List<Intermediation__c>();
		List<Intermediation__c> listMatch2 = new List<Intermediation__c>();
		List<Intermediation__c> listMatch3 = new List<Intermediation__c>();
		List<Intermediation__c> listMatch4 = new List<Intermediation__c>();
		List<Intermediation__c> listMatch5 = [SELECT Id, Criteres_d_intervention__c, CreatedDate
											FROM Intermediation__c
											WHERE Professionnel__c = :acc.Id
											AND Criteres_d_intervention__c IN :listGeocat5
											AND CreatedDate >= LAST_YEAR
											ORDER BY CreatedDate DESC];
		for (Intermediation__c i : listMatch5) {
			if (i.CreatedDate >= dat15)
				listMatch.add(i);

			if (i.CreatedDate >= dat1mois)
				listMatch2.add(i);

			if (i.CreatedDate >= dat3mois)
				listMatch3.add(i);

			if (i.CreatedDate >= dat6mois)
				listMatch4.add(i);
		}

		List<Intermediation__c> listMer = new List<Intermediation__c>();
		List<Intermediation__c> listMer2 = new List<Intermediation__c>();
		List<Intermediation__c> listMer3 = new List<Intermediation__c>();
		List<Intermediation__c> listMer4 = new List<Intermediation__c>();
		List<Intermediation__c> listMer5 = [SELECT Id, Criteres_d_intervention__c, CreatedDate
											FROM Intermediation__c
											WHERE Professionnel__c = :acc.Id
											AND Criteres_d_intervention__c IN :listGeocat5
											AND Is_selectionne__c = true
											AND CreatedDate >= LAST_YEAR
											ORDER BY CreatedDate DESC];
		for(Intermediation__c i : listMer5) {
			if (i.CreatedDate >= dat15)
				listMer.add(i);

			if (i.CreatedDate >= dat1mois)
				listMer2.add(i);

			if (i.CreatedDate >= dat3mois)
				listMer3.add(i);

			if (i.CreatedDate >= dat6mois)
				listMer4.add(i);
		}
		
		geoUtil(this.geo15, listGeocat, listMatch, listMer, rej, 1);
		geoUtil(this.geo1mois, listGeocat2, listMatch2, listMer2, rej, 1);
		geoUtil(this.geo3mois, listGeocat3, listMatch3, listMer3, rej, 3);
		geoUtil(this.geo6mois, listGeocat4, listMatch4, listMer4, rej, 6);
		geoUtil(this.geo1an, listGeocat5bis, listMatch5, listMer5, rej, 12);
	}

	public class helperCI {
		public Id idGeocat {get;set;}
		public Date dateMer {get;set;}

		public helperCI (Id geo, Date dSelect) {
			this.idGeocat = geo;
			this.datemer = dSelect;
		}
	}

	public void eventUtil(InteractionWrapper ints, List<Event> events)
	{
		for (Event e : events)
		{
			ints.eve = e;
			ints.countEvent = events.size();
			ints.init();
			break;
		}
	}

	public void taskUtil(InteractionWrapper ints, List<Task> tasks)
	{
		for (Task t : tasks)
		{
			ints.task = t;
			ints.countTask = tasks.size();
			ints.init();
			break;
		}
	}

	public void geoUtil(GeocatListWrapper geos, List<Geocat__c> listGeocat, List<Intermediation__c> listMatch, List<Intermediation__c> listMer, Integer rejet, Integer multiple)
	{
		Map<Id, Integer> match = new Map<Id, Integer>();
		Map<Id, Integer> mer = new Map<Id, Integer>();

		for (Intermediation__c i :listMatch)
		{
			if (match.containsKey(i.Criteres_d_intervention__c))
				match.put(i.Criteres_d_intervention__c, match.get(i.Criteres_d_intervention__c) + 1);
			else
				match.put(i.Criteres_d_intervention__c, 1);
		}

		for (Intermediation__c i :listMer)
		{
			if (mer.containsKey(i.Criteres_d_intervention__c))
				mer.put(i.Criteres_d_intervention__c, mer.get(i.Criteres_d_intervention__c) + 1);
			else
				mer.put(i.Criteres_d_intervention__c, 1);
		}

		geos.geocats = listGeocat;
		geos.match = match;
		geos.mer = mer;
		geos.rejet = rejet;
		geos.initGeo(multiple);
	}
}