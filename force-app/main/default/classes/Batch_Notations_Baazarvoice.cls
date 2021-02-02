/**
* @author Clement Musabimana
* @date 20/06/2018
* @description Batch a lancer tous les soirs pour récuperer les notations liés aux projets
**/
global class Batch_Notations_Baazarvoice implements Database.Batchable<sObject>, Database.AllowsCallouts{
	global static final String QUERY = 'SELECT Id From account LIMIT 1';//Pas utile. utilisee juste pour declencher le batch
	global String dateDebut = '';
	global String dateFin = '';
	global static final Integer LIMIT_RESULTS = 100;
	global static final String NOTATION_TYPE_EXP_HY = 'Notation_Experience_Homly_You';
	global Integer offsetSizeCallout = 0;
	global Integer totalResultsCallout = -1;
	global Boolean hasErrorCallout = false;
	Map<Integer,NotationsBaazarvoiceWrapper.DataNotations> mapProjetsNotations;

   	global Database.QUERYLocator start(Database.BatchableContext BC){
    	return Database.getQUERYLocator(QUERY);
   	}

   	global Batch_Notations_Baazarvoice(String date_Debut, String date_Fin){
   		dateDebut = date_Debut;
   		dateFin = date_Fin;
		offsetSizeCallout = 0;
		totalResultsCallout = -1;
   		mapProjetsNotations = new Map<Integer,NotationsBaazarvoiceWrapper.DataNotations>();
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
      	deserialize();
   	}

   	global void finish(Database.BatchableContext BC){

   	}

    public void deserialize() {
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        String url_callout_baazavoirce = System.Label.URL_BaazarvoiceNotationsWSEndpoint;
		System.debug('dateDebut  '+dateDebut);
		System.debug('dateFin  '+dateFin);
		Integer nbCallout = 0;
		//la date de debut et de fin doivent être calculés en nombre de secondes depuis le 1 Janvier 1970, 00:00:00 UTC
		//Ce calcul est obtenu avec le champ epochDateDebut et epochDateFin
        if(dateDebut != ''){
        	String dateDebutString = dateDebut+' 00:00:00.000Z';
			DateTime dt = DateTime.ValueofGmt(dateDebutString.replace('T', ' ')); 
			Long l = dt.getTime();
			Long epochDateDebut = dt.getTime()/1000;
			epochDateDebut = epochDateDebut - 1;//on enleve une seconde pour la plage horaire 00:00:00.000: 
			//si date debut == 02/01/2018 00:00:00 la comparaison on fera une comparaison strictement supérieur à 01/01/2018 23:59:59
			System.debug('dateDebut dt '+dt);
			System.debug('dateDebut epochDateDebut '+epochDateDebut);
			url_callout_baazavoirce = url_callout_baazavoirce+'&filter=LastModificationTime:gt:'+epochDateDebut;
			System.debug('dateDebut url_callout_baazavoirce '+url_callout_baazavoirce);
        }
        if(dateFin != ''){
        	String dateFinString = dateFin+' 00:00:00.000Z';
			DateTime dt = DateTime.ValueofGmt(dateFinString.replace('T', ' ')); 
			Long l = dt.getTime();
			Long epochDateFin = dt.getTime()/1000;
			System.debug('dateFin dt '+dt);
			System.debug('dateFin epochDateFin '+epochDateFin);
			url_callout_baazavoirce = url_callout_baazavoirce+'&filter=LastModificationTime:lt:'+epochDateFin;
			System.debug('dateFin url_callout_baazavoirce '+url_callout_baazavoirce);
        }
        url_callout_baazavoirce = url_callout_baazavoirce + '&Limit='+LIMIT_RESULTS;
		//Le nombre d'elements à récupérer est limité. Si le nombre total dépasse la limite, alors il faut effectuer plusieurs appels pour tout récuperer
		do {
		    NotationsBaazarvoiceWrapper.DataNotations projetsNotations = projetsNotationsData(url_callout_baazavoirce, offsetSizeCallout);
		    mapProjetsNotations.put(nbCallout, projetsNotations);
		    offsetSizeCallout = offsetSizeCallout+LIMIT_RESULTS;
		    totalResultsCallout = projetsNotations.TotalResults;
		    nbCallout = nbCallout+1;
		} while ((offsetSizeCallout <= totalResultsCallout && hasErrorCallout == false) || (totalResultsCallout == -1  && hasErrorCallout == false));
		System.debug('mapProjetsNotations '+mapProjetsNotations);    
		enregistrerNotations(mapProjetsNotations, nbCallout);   
    }

	/**
	* @author Clement Musabimana
	* @date 22/06/2018
	* @description Permet de lancer un appel a Http. 
	* @param url_callout : url d'appel
	* @param offset : index (dans la liste des données) à partir de laquelle il faut recuperer les elements
	**/
    public NotationsBaazarvoiceWrapper.DataNotations projetsNotationsData(String url_callout, Integer offset) {

		if (Test.isRunningTest()) {
			//Pour le cas de test
			Projet__c projet = [SELECT Id FROM Projet__c LIMIT 1];
			String strTest = '{"Limit":1,"Offset":0,"TotalResults":1,"Locale":"en_US","Results":[{"Id":"11618643","CID":"2fcae2d0-d821-56fe-a443-8b4592724001","SourceClient":"homly-fr","LastModeratedTime":"2018-06-25T07:15:00.000+00:00","LastModificationTime":"2018-06-25T07:16:02.000+00:00","ProductId":"homly","CampaignId":"BV_PIE","ContextDataValuesOrder":["ContactPro","DateDutilisation"],"UserLocation":"Qiuyan","AuthorId":"kzkttg2bnfnngvfa15i844ifa","ContentLocale":"fr_FR","IsFeatured":false,"TotalClientResponseCount":0,"TotalCommentCount":0,"Rating":5,"SecondaryRatingsOrder":["RespectDuCreneauHoraire","QualiteDeLappel"],"IsRatingsOnly":false,"IsRecommended":true,"TotalFeedbackCount":0,"TotalNegativeFeedbackCount":0,"TotalPositiveFeedbackCount":0,"ModerationStatus":"APPROVED","SubmissionId":"ebcigj4ruehiytpdof9c8e8yr","SubmissionTime":"2018-06-25T07:09:24.000+00:00","ReviewText":"blabla fdsfdddddddddddddddddddddddddddddddddddd ddddddddddddddddddddd","Title":"Reponse Qiuyan","UserNickname":"Qiuyan","SecondaryRatings":{"QualiteDeLappel":{"Value":5,"Id":"QualiteDeLappel","DisplayType":"NORMAL","MaxLabel":null,"MinLabel":null,"Label":"Qualite de lappel","ValueRange":5,"ValueLabel":null},"RespectDuCreneauHoraire":{"Value":5,"Id":"RespectDuCreneauHoraire","DisplayType":"NORMAL","MaxLabel":null,"MinLabel":null,"Label":"Avez-vous ete rappele par le Centre de Relations Clients sous 48h ?","ValueRange":5,"ValueLabel":null}},"AdditionalFields":{"ProjectId":{"Value":"'+projet.Id+'","Id":"ProjectId","Label":"Project ID"}},"AdditionalFieldsOrder":["ProjectId"],"ContextDataValues":{"ContactPro":{"Value":"Oui","Id":"ContactPro","ValueLabel":"Oui","DimensionLabel":"Etes-vous en contact avec tous les artisans recommandes par Homly You ?"},"DateDutilisation":{"Value":"MoinsDuneSemaine","Id":"DateDutilisation","ValueLabel":"Moins dune semaine","DimensionLabel":"Quand avez-vous utilise le service de mise en relation ?"}},"Badges":{},"CommentIds":[],"Photos":[],"TagDimensions":{},"IsSyndicated":false,"ProductRecommendationIds":[],"Helpfulness":null,"ClientResponses":[],"Pros":null,"RatingRange":5,"TagDimensionsOrder":[],"Cons":null,"BadgesOrder":[],"Videos":[]},{"Id":"11618644","CID":"2fcae2d0-d821-56fe-a443-8b4592724001","SourceClient":"homly-fr","LastModeratedTime":"2018-06-25T07:15:00.000+00:00","LastModificationTime":"2018-06-25T07:16:02.000+00:00","ProductId":"homly","CampaignId":"BV_PIE","ContextDataValuesOrder":["ContactPro","DateDutilisation"],"UserLocation":"Qiuyan","AuthorId":"kzkttg2bnfnngvfa15i844ifa","ContentLocale":"fr_FR","IsFeatured":false,"TotalClientResponseCount":0,"TotalCommentCount":0,"Rating":5,"SecondaryRatingsOrder":["RespectDuCreneauHoraire","QualiteDeLappel"],"IsRatingsOnly":false,"IsRecommended":true,"TotalFeedbackCount":0,"TotalNegativeFeedbackCount":0,"TotalPositiveFeedbackCount":0,"ModerationStatus":"APPROVED","SubmissionId":"ebcigj4ruehiytpdof9c8e8yr","SubmissionTime":"2018-06-25T07:09:24.000+00:00","ReviewText":"blabla fdsfdddddddddddddddddddddddddddddddddddd ddddddddddddddddddddd","Title":"Reponse Qiuyan","UserNickname":"Qiuyan","SecondaryRatings":{"QualiteDeLappel":{"Value":5,"Id":"QualiteDeLappel","DisplayType":"NORMAL","MaxLabel":null,"MinLabel":null,"Label":"Qualite de lappel","ValueRange":5,"ValueLabel":null},"RespectDuCreneauHoraire":{"Value":5,"Id":"RespectDuCreneauHoraire","DisplayType":"NORMAL","MaxLabel":null,"MinLabel":null,"Label":"Avez-vous ete rappele par le Centre de Relations Clients sous 48h ?","ValueRange":5,"ValueLabel":null}},"AdditionalFields":{"ProjectId":{"Value":"123toto","Id":"ProjectId","Label":"Project ID"}},"AdditionalFieldsOrder":["ProjectId"],"ContextDataValues":{"ContactPro":{"Value":"Oui","Id":"ContactPro","ValueLabel":"Oui","DimensionLabel":"Etes-vous en contact avec tous les artisans recommandes par Homly You ?"},"DateDutilisation":{"Value":"MoinsDuneSemaine","Id":"DateDutilisation","ValueLabel":"Moins dune semaine","DimensionLabel":"Quand avez-vous utilise le service de mise en relation ?"}},"Badges":{},"CommentIds":[],"Photos":[],"TagDimensions":{},"IsSyndicated":false,"ProductRecommendationIds":[],"Helpfulness":null,"ClientResponses":[],"Pros":null,"RatingRange":5,"TagDimensionsOrder":[],"Cons":null,"BadgesOrder":[],"Videos":[]},{"Id":"11618645","CID":"2fcae2d0-d821-56fe-a443-8b4592724001","SourceClient":"homly-fr","LastModeratedTime":"2018-06-25T07:15:00.000+00:00","LastModificationTime":"2018-06-25T07:16:02.000+00:00","ProductId":"homly","CampaignId":"BV_PIE","ContextDataValuesOrder":["ContactPro","DateDutilisation"],"UserLocation":"Qiuyan","AuthorId":"kzkttg2bnfnngvfa15i844ifa","ContentLocale":"fr_FR","IsFeatured":false,"TotalClientResponseCount":0,"TotalCommentCount":0,"Rating":5,"SecondaryRatingsOrder":["RespectDuCreneauHoraire","QualiteDeLappel"],"IsRatingsOnly":false,"IsRecommended":true,"TotalFeedbackCount":0,"TotalNegativeFeedbackCount":0,"TotalPositiveFeedbackCount":0,"ModerationStatus":"APPROVED","SubmissionId":"ebcigj4ruehiytpdof9c8e8yr","SubmissionTime":"2018-06-25T07:09:24.000+00:00","ReviewText":"blabla fdsfdddddddddddddddddddddddddddddddddddd ddddddddddddddddddddd","Title":"Reponse Qiuyan","UserNickname":"Qiuyan","SecondaryRatings":{"QualiteDeLappel":{"Value":5,"Id":"QualiteDeLappel","DisplayType":"NORMAL","MaxLabel":null,"MinLabel":null,"Label":"Qualite de lappel","ValueRange":5,"ValueLabel":null},"RespectDuCreneauHoraire":{"Value":5,"Id":"RespectDuCreneauHoraire","DisplayType":"NORMAL","MaxLabel":null,"MinLabel":null,"Label":"Avez-vous ete rappele par le Centre de Relations Clients sous 48h ?","ValueRange":5,"ValueLabel":null}},"AdditionalFields":{"ProjectId":{"Value":"a1M4E000005NN60UAG","Id":"ProjectId","Label":"Project ID"}},"AdditionalFieldsOrder":["ProjectId"],"ContextDataValues":{"ContactPro":{"Value":"Oui","Id":"ContactPro","ValueLabel":"Oui","DimensionLabel":"Etes-vous en contact avec tous les artisans recommandes par Homly You ?"},"DateDutilisation":{"Value":"MoinsDuneSemaine","Id":"DateDutilisation","ValueLabel":"Moins dune semaine","DimensionLabel":"Quand avez-vous utilise le service de mise en relation ?"}},"Badges":{},"CommentIds":[],"Photos":[],"TagDimensions":{},"IsSyndicated":false,"ProductRecommendationIds":[],"Helpfulness":null,"ClientResponses":[],"Pros":null,"RatingRange":5,"TagDimensionsOrder":[],"Cons":null,"BadgesOrder":[],"Videos":[]}],"Includes":{},"HasErrors":false,"Errors":[]}';
			NotationsBaazarvoiceWrapper.DataNotations projetsNotations = (NotationsBaazarvoiceWrapper.DataNotations) JSON.deserialize(strTest, NotationsBaazarvoiceWrapper.DataNotations.class);
	        return projetsNotations;
		}
		else {
			Http h = new Http();
	        HttpRequest request = new HttpRequest();
	        url_callout = url_callout + '&Offset='+offset;
	        request.setEndPoint(url_callout);
	        request.setHeader('Content-type', 'application/json');
	        request.setMethod('GET');

	        HttpResponse response = h.send(request);

	        NotationsBaazarvoiceWrapper.DataNotations projetsNotations = (NotationsBaazarvoiceWrapper.DataNotations) JSON.deserialize(response.getBody(), NotationsBaazarvoiceWrapper.DataNotations.class);
	        System.debug('Batch_Notations_Baazarvoice response.getBody() '+response.getBody());
	        System.debug('Batch_Notations_Baazarvoice projetsNotations '+projetsNotations);
	        System.debug('Batch_Notations_Baazarvoice size '+projetsNotations.Results.size());
	        return projetsNotations;
		}
    }

	/**
	* @author Clement Musabimana
	* @date 22/06/2018
	* @description Permet de verifier si un autre appel doit être lancé. c'est a dire qu'il reste des données
	* @param projetsNotations : liste des notations
	**/
    public Boolean rappelerService( NotationsBaazarvoiceWrapper.DataNotations projetsNotations) {
    	Boolean totalResultsAtteint = false;
        if(projetsNotations != null && projetsNotations.TotalResults != null && projetsNotations.TotalResults> 0){
        	if((projetsNotations.Offset + LIMIT_RESULTS) >= projetsNotations.TotalResults){
        		totalResultsAtteint = true;
        	}
        }
        return !totalResultsAtteint;
    }

	/**
	* @author Clement Musabimana
	* @date 22/06/2018
	* @description Permet de verifier si un autre appel doit être lancé. c'est a dire qu'il reste des données
	* @param projetsNotations : liste des notations
	**/
    public void enregistrerNotations(Map<Integer,NotationsBaazarvoiceWrapper.DataNotations> mapProjetsNotations, Integer mapSize) {
    	List<Notation__c> notations = new List<Notation__c>();
    	List<Decimal> identifiants_baazarvoice = new List<Decimal>();
    	Map<Decimal,Notation__c> mapNotations = new Map<Decimal,Notation__c>(); 
    	List<Id> identifiants_projets = new List<Id>();
    	String  mailBody = '';

    	if (mapProjetsNotations != null){
    		for(Integer i = 0; i<mapSize;i++){
    			NotationsBaazarvoiceWrapper.DataNotations projetsNotations = mapProjetsNotations.get(i);
        		System.debug('enregistrerNotations projetsNotations '+projetsNotations);
        		if(projetsNotations.TotalResults > 0){
					
        			for(NotationsBaazarvoiceWrapper.Notation notationItem: projetsNotations.Results){
        				if(notationItem.AdditionalFields != null && notationItem.AdditionalFields.ProjectId != null){
        					//On va envoyer les erreurs sur les mauvais ID ou les ID ne correspondant pas au bon org (sandbox)
        					try {
				    			Notation__c notation = new Notation__c();
				    			notation.Avis__c = notationItem.ReviewText;
				    			if(notationItem.ContextDataValues != null && notationItem.ContextDataValues.ContactPro != null && notationItem.ContextDataValues.ContactPro.Value != null){
				    				notation.Contact_Pro__c = notationItem.ContextDataValues.ContactPro.Value;
				    			}
				    			notation.Note__c = Decimal.valueOf(notationItem.Rating);
				    			notation.Projet__c = notationItem.AdditionalFields.ProjectId.Value;
				    			notation.Tech_Id_Externe_Baazarvoice__c = Decimal.valueOf(notationItem.Id);
				    			notation.Titre__c = notationItem.Title;
				    			notation.Tech_Date_Soumission__c = Datetime.valueOf(dateStringRemplace(notationItem.SubmissionTime));
				    			notation.Tech_Date_Modification__c = Datetime.valueOf(dateStringRemplace(notationItem.LastModificationTime));
				    			notation.Tech_Date_Moderation__c = Datetime.valueOf(dateStringRemplace(notationItem.LastModeratedTime));
				    			notation.Statut__c = notationItem.ModerationStatus;
                                String moderatorCodesString = '';
                                if(notationItem.ModeratorCodes != null){
                                    moderatorCodesString = String.join(notationItem.ModeratorCodes, ',');
                                }
                                System.debug('enregistrerNotations notationItem.ModeratorCodes '+notationItem.ModeratorCodes);
                                System.debug('enregistrerNotations moderatorCodesString '+moderatorCodesString);
				    			notation.Tech_Moderation_Code__c = moderatorCodesString;
				    			notation.Type__c = NOTATION_TYPE_EXP_HY;
				    			//notations.add(notation);
				    			mapNotations.put(Decimal.valueOf(notationItem.Id), notation);
				    			//Permet de verifier si la notation existe deja dans salesforce
				    			identifiants_baazarvoice.add(Decimal.valueOf(notationItem.Id));
				    			//Permet de verifier si l'Id salesforce existe (cas ou on fait des tests en staging avec INT et REC)
				    			identifiants_projets.add(notationItem.AdditionalFields.ProjectId.Value);
				    		} catch(Exception e){
				    			System.debug('enregistrerNotations **** erreur '+e.getMessage());
        						mailBody = mailBody + '--------------------------------------------------<br/>'; 
					            mailBody = mailBody + 'An error occurred during the Notations_Baazarvoice_Batchable execution. Message: ' + e.getMessage() + '; Cause: ' + e.getCause() + '; LineNumber: ' + e.getLineNumber() + '; StackTraceString: ' + e.getStackTraceString() +'<br/><br/>'; 
					        }
        				}

		    		}
			    	
        		}
    		}
    	}
    	System.debug('enregistrerNotations **** mapNotations '+mapNotations);
    	if (mapNotations != null && mapNotations.size() > 0){
    		//On verifie si la notation existe deja dans Salesforce. Dans ce cas, on fait une mise à jour
    		List<Notation__c> notationsExistantes = getNotationFromIdentifiantsBaazarvoice( identifiants_baazarvoice);
    		List<Projet__c> projetList = [select id, name from Projet__c where id in :identifiants_projets];  
    		Map<Id, Projet__c> mapProjets = new Map<Id, Projet__c>(projetList);
    		System.debug('enregistrerNotations **** notationsExistantes '+notationsExistantes);
    		System.debug('enregistrerNotations **** mapProjets '+mapProjets);
    		for(Notation__c notationsExistanteItem: notationsExistantes){
    			mapNotations.get(notationsExistanteItem.Tech_Id_Externe_Baazarvoice__c);
    			if(mapNotations.get(notationsExistanteItem.Tech_Id_Externe_Baazarvoice__c) != null){
    				mapNotations.get(notationsExistanteItem.Tech_Id_Externe_Baazarvoice__c).Id = notationsExistanteItem.Id;
    			}
    		}
        	for (Decimal key : mapNotations.keySet()) {
        		//On vérifie que l'Id sur lequel rajouter des notations existe bien
        		//Sinon la transaction insert/update tombera en echec sur tous les projets a mettre a jour
        		Id idTemp = (mapNotations.get(key)).Projet__c;
        		if (mapProjets.containsKey(idTemp) == true ) {
			    	notations.add(mapNotations.get(key));
        		}
        		else {
        			mailBody = mailBody + '--------------------------------------------------<br/>';  
        			mailBody = mailBody + 'An error occurred during the Notations_Baazarvoice_Batchable execution. This projet Id: '+idTemp +' does not exist on this organization: '+Userinfo.getOrganizationId() +'<br/><br/>';  
        		}
			}
    		System.debug('enregistrerNotations **** notations Update '+notations);
    		//SI une erreur est presente dans mise a jour, la transaction ne sera pas faite
    		try {
    			upsert notations;
    		} catch(Exception e){
    			System.debug('enregistrerNotations **** Upsert failed '+e.getMessage());
        		mailBody = mailBody + '--------------------------------------------------<br/>'; 
	            mailBody = mailBody + 'An error occurred during the Notations_Baazarvoice_Batchable execution. Message: ' + e.getMessage() + '; Cause: ' + e.getCause() + '; LineNumber: ' + e.getLineNumber() + '; StackTraceString: ' + e.getStackTraceString() +'<br/><br/>';  
	            
        	}
    	}
    	//Si des erreurs ont été récupérés, on envoie un mail a la supervision
    	if(mailBody != null && mailBody != ''){
    		System.debug('enregistrerNotations **** envoi mail ');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            //String email = 'Clement.Musabimana@ext.saint-gobain.com';
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email}); 
            mail.setSubject('Le batch de Notations_Baazarvoice a rencontré un ou plusieurs problème(s)');
            mailBody = '<html><body>' + mailBody + '</body></html>';
            mail.setHtmlBody(mailBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			System.debug('enregistrerNotations **** envoi mail ok');
    	}
    }

	/**
	* @author Clement Musabimana
	* @date 25/06/2018
	* @description Permet de récupérer les notations dans Salesforce avec la clé de liaison correspondant aux identifiants Baazarvoice
	* @param identifiants_baazarvoice : identifiants notations Baazarvoice
	**/
    public List<Notation__c> getNotationFromIdentifiantsBaazarvoice(List<Decimal> identifiants_baazarvoice){
    	List<Notation__c> notations = new List<Notation__c>();
    	if(identifiants_baazarvoice != null && identifiants_baazarvoice.size() > 0){
    		notations = [SELECT Id,Tech_Id_Externe_Baazarvoice__c FROM Notation__c Where Tech_Id_Externe_Baazarvoice__c in: identifiants_baazarvoice];
    	}
    	return notations;
    }

    public String dateStringRemplace(String dateT){
    	String regExp = '[+T]';
    	return (dateT.replaceAll(regExp, ' '));
    }
}