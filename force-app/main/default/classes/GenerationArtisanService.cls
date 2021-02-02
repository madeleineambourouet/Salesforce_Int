/**
* @author Clement Musabimana
* @date 29/06/2018
* @description Service de récupération des données fidélités unitairement depuis generation artisan
**/
global  class GenerationArtisanService {

    public static final String ENSEIGNE_PARTENAIRE = 'POINT P';
    public static final String SERVICE_GA = 'GA';
	public static final String URL_OAUTH = System.Label.URL_GenerationArtisanOauth;
	public static final String URL_OAUTH_CLIENTID = System.Label.URL_GenerationArtisanOauth_ClientId;
	public static final String URL_OAUTH_CLIENTSECRET = System.Label.URL_GenerationArtisanOauth_ClientSecret;
	public static final String URL_ENDPOINT = System.Label.URL_GenerationArtisanEndPoint;
	public static final String URL_ENDPOINT_PARAMS = System.Label.URL_GenerationArtisanEndPoint_Params;
    public static final Integer HTTP_RESPONSE_200 = 200;
    public static final Integer HTTP_RESPONSE_400 = 400;
    public static final Integer HTTP_RESPONSE_404 = 404;
    public static final Integer HTTP_RESPONSE_422 = 422;
    public static final Integer HTTP_RESPONSE_204 = 204;
    public static final String HTTP_RESPONSE_400_MSG = System.Label.WS_GenerationArtisanWsMsg400;
    public static final String HTTP_RESPONSE_404_MSG = System.Label.WS_GenerationArtisanWsMsg404;
    public static final String HTTP_RESPONSE_422_MSG = System.Label.WS_GenerationArtisanWsMsg422;
    public static final String HTTP_RESPONSE_204_MSG = System.Label.WS_GenerationArtisanWsMsg204;
    public Id accountId {get;set;}
	Map<String, Reference__c> agence_SF = new Map<String, Reference__c>();
	Map<String, String> referenceContactsPrincipaux = new Map<String, String>();
	List<String> listAgenceGaKey = new List<String>();

    public GenerationArtisanService(String accountId) {
    	if(accountId != ''){
        	this.accountId = Id.valueOf(accountId);
    	}
    }

	/**
	* @author Clement Musabimana
	* @date 02/07/2018
	* @description Modele de données à récupérer dans le flux JSON retourné par le WS Generation Artisan
	**/
	public class AccountItem {
	    public String customerCode {get; set;}
	    public String companyName {get; set;}
	    public String id {get; set;}
	    public String customerId {get; set;}
	    public String siren {get; set;}
	    public String siret {get; set;}
	}

	public class AddressItem {
	    public String city {get; set;}
	    public String countryCode  {get; set;}
	    public String[] streets {get; set;}
	}

	public class MainAgencyItem {
	    public String id {get; set;}
	    public String name {get; set;}
	}

	public class ServicesItem {
	    public String id {get; set;}
	    public Boolean subscription {get; set;}
	    public String startDate {get; set;}
	}

	public class ContactWrapper {
	    //public String Limit {get; set;}
	    public String id {get; set;}
	    public String contactCode {get; set;}
	    public String civility {get; set;}
	    public String firstName {get; set;}
	    public String lastName {get; set;}
	    public String professionCode {get; set;}
	    public String phoneNumber {get; set;}
	    public String mobileNumber {get; set;}
	    public String email {get; set;}
	    public AddressItem address {get; set;}
	    public AccountItem account {get; set;}
	    public MainAgencyItem mainAgency {get; set;}
	    public ServicesItem[] services {get; set;}
	    public Boolean active {get; set;}
	}

	RecordType rtAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1];
	RecordType rtpro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1];

	/**
	* @author Clement Musabimana
	* @date 29/06/2018
	* @description recuperation du token d'authentification pour se connecter a génération artisan
	**/
   	public  String getTokenAccess(){
		HttpRequest req = new HttpRequest();
		req.setEndpoint(URL_OAUTH);
		req.setHeader('Content-Type','application/x-www-form-urlencoded');        
		req.setMethod('POST');

		String client_id=URL_OAUTH_CLIENTID;
		String client_secret=URL_OAUTH_CLIENTSECRET;
		String scope='openid';
		String grant_type='client_credentials';

		String content = 'client_id='+EncodingUtil.urlEncode(client_id, 'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(client_secret, 'UTF-8')+'&:scope='+EncodingUtil.urlEncode('scope', 'UTF-8')+'&grant_type='+EncodingUtil.urlEncode(grant_type, 'UTF-8');

		//System.debug('bodyResults access_token '+bodyResults.get('access_token'));
		req.setBody(content);
		Http m_http = new Http();
		httpResponse response = null;
		if (Test.isRunningTest()) {
			response = new httpResponse();
			response.setBody('{"access_token": "1234abcd","token_type": "Bearer","expires_in": 3600,"scope": "openid"}');
		}
		else {
			response = m_http.send(req);
		}
		Map<String,Object> bodyResults = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
		System.debug('response '+response.getBody());
		String access_token=(String)bodyResults.get('access_token');
		System.debug('access_token '+access_token);

		return access_token;
   	}

	/**
	* @author Clement Musabimana
	* @date 29/06/2018
	* @description recuperation des données en lien avec un code point p
	**/
   	public  Map<String,Object[]> getContactsGenerationArtisan(String codeClientPointP){
		HttpRequest req = new HttpRequest();
		Map<String,Object[]> retour = new Map<String,Object[]>();
		List<String> listErreurs = new List<String>();
		String urlEndPoint = URL_ENDPOINT + codeClientPointP + URL_ENDPOINT_PARAMS;
		ContactWrapper[] contactsGa = null;
		List<Account> compteAvecMemeCodeClientPointP =  [SELECT Id,Name, SIRET_texte__c, Code_client_Point_P__c FROM Account WHERE Code_client_Point_P__c =:codeClientPointP];
		if(compteAvecMemeCodeClientPointP.size() > 1){
			listErreurs.add('Le code client P '+codeClientPointP+' existe sur '+compteAvecMemeCodeClientPointP.size()+' comptes:');
			for(Account a: compteAvecMemeCodeClientPointP){
				listErreurs.add('Compte: '+a.name);
			}
			listErreurs.add('Veuillez corriger le problème et relancer le service');
		}
		else {
			//req.setEndpoint(urlEndPoint);
			req.setEndpoint(urlEndPoint);
			req.setHeader('Content-Type','application/x-www-form-urlencoded');  
			req.setHeader('authorization','Bearer '+getTokenAccess());        
			req.setMethod('GET');
			System.debug('getContactsGenerationArtisan urlEndPoint:' + urlEndPoint);
			Http m_http = new Http();
			httpResponse response = null;
			if (Test.isRunningTest()) {
				response = new httpResponse();
				response.setStatusCode(200);
				response.setBody('[{"id":"VI_456412","contactCode":null,"civility":"M","firstName":"LESGIL","lastName":"LLAULTRAVAI","professionCode":"049","email":"RAVAILLAULT-D3R2@YOPMAIL.COM","phoneNumber":null,"mobileNumber":"+33601010102","faxNumber":null,"address":{"city":"PARIS","countryCode":"FR","streets":["LES PETITS CHAMPS","LES PETITS CHAMPS BIS TER"],"zipCode":"75019","postalName":"PARIS"},"account":{"id":"110ccpp1234","customerId":"1000170547","customerCode":"ccpp1234","siret":"49836242500015","siren":"498362425","companyName":"RAVAILLAULT GILLES"},"mainAgency":{"id":"1907","name":"DINARD POINT P"},"services":[{"id":"GA","subscription":true,"startDate":"2018-07-18","endDate":"2018-07-16"}],"active":true},{"id":"VI_456412","contactCode":null,"civility":"M","firstName":"GILLES","lastName":"RAVAILLAULT","professionCode":"049","email":"RAVAILLAULT-D3R@YOPMAIL.COM","phoneNumber":null,"mobileNumber":"+33601010101","faxNumber":null,"address":{"city":"PARIS","countryCode":"FR","streets":["LES PETITS CHAMPS","LES PETITS CHAMPS BIS TER"],"zipCode":"75019","postalName":"PARIS"},"account":{"id":"110ccpp1234","customerId":"1000170547","customerCode":"ccpp1234","siret":"49836242500015","siren":"498362425","companyName":"RAVAILLAULT GILLES"},"mainAgency":{"id":"1907","name":"DINARD POINT P"},"services":[{"id":"GA","subscription":true,"startDate":"2018-07-16","endDate":"2018-07-16"}],"active":true}]');
			}
			else {
				response = m_http.send(req);
			}


			System.debug('getContactsGenerationArtisan response '+response);
			System.debug('getContactsGenerationArtisan response.getBody() '+response.getBody());
			if(response.getStatusCode() == HTTP_RESPONSE_200){
				contactsGa = (ContactWrapper[]) JSON.deserialize(response.getBody(), ContactWrapper[].class);
			}
			else if(response.getStatusCode() == HTTP_RESPONSE_400){
				listErreurs.add(HTTP_RESPONSE_400_MSG);
			}
			else if(response.getStatusCode() == HTTP_RESPONSE_404){
				listErreurs.add(HTTP_RESPONSE_404_MSG);
			}
			else if(response.getStatusCode() == HTTP_RESPONSE_422){
				listErreurs.add(HTTP_RESPONSE_422_MSG);
			}
			else if(response.getStatusCode() == HTTP_RESPONSE_204){
				listErreurs.add(HTTP_RESPONSE_204_MSG);
			}
			//Si c'est une autre erreur non défini dans la spec, on l'affiche telle quelle
			else {
				listErreurs.add(response.getBody());
			}
		}
		
		retour.put('contactsGa',contactsGa);
		retour.put('erreur',listErreurs);
		System.debug('getContactsGenerationArtisan contactsGa:' + contactsGa);
		//return contactsGa;
		return retour;

   	}

	global String getDateStringFormatee(String date_param){
		String d = null;
		if (date_param != null) {
			String[] param = date_param.split('-');
			if (param.size() == 3) {
				d = param[2]+'/'+param[1]+'/'+param[0];
			}
		}
		return d;

	}

   /**
	* @author Clement Musabimana
	* @date 11/07/2018
	* @description verifie les donnees contacts en retour du service GA: siret, customerId, code client groupe+enseigne 
	**/
   	public  List<String> verificationContactsGa(String codeClientPointP, ContactWrapper[] contactsGa){
   		List<String> listErreurs = new List<String>();
   		Set<String> listSiret = new Set<String>();
   		Set<String> listCustomerId = new Set<String>();
   		Set<String> listCodeClientGroupe = new Set<String>();
   		Map<String,String> listEnseigneParCodeClientGroupe = new Map<String,String>();
		for (ContactWrapper contactGa : contactsGa) {
			if(contactGa.account != null){
				listSiret.add(contactGa.account.siret);
				listCustomerId.add(contactGa.account.customerId);
				listCodeClientGroupe.add(contactGa.account.id);
				if(contactGa.mainAgency != null){
					listEnseigneParCodeClientGroupe.put(contactGa.account.id,contactGa.mainAgency.name);
					listAgenceGaKey.add(contactGa.mainAgency.id);
				}
				//VERIFIE LA VALIDITE DU SIRET
				if (!AccountMethods.checkSiret(contactGa.account.siret)){
					listErreurs.add('Le siret '+contactGa.account.siret+' n\'est pas valide');
				}
			}
		}
		//VERIFICATION SIRET: le siret ne doit pas exister sur un compte different du compte actuel
		for (Account a : [SELECT Id,Name, SIRET_texte__c, Code_client_Point_P__c FROM Account WHERE SIRET_texte__c IN :listSiret AND Code_client_Point_P__c !=:codeClientPointP]) {
			listErreurs.add('Le siret '+a.SIRET_texte__c+' existe déjà sur le compte '+a.Name+' ayant pour reference '+a.Id);
		}
		//VERIFICATION CustomerId et code client groupe: le CustomerId et le code client groupe ne doivent pas exister sur un PF d'un compte different du compte actuel
		for (ProgrammeFidelite__c pf : [SELECT Id, Name, CustomerId__c, Code_client_groupe__c, Enseigne_partenaire__c, Compte__r.Code_client_Point_P__c, Compte__r.Id, Compte__r.Name FROM ProgrammeFidelite__c WHERE (CustomerId__c IN :listCustomerId OR Code_client_groupe__c IN :listCodeClientGroupe) AND Compte__r.Code_client_Point_P__c !=:codeClientPointP]) {
			if(listCustomerId.contains(pf.CustomerId__c)){
				listErreurs.add('Le customerId '+pf.CustomerId__c+' existe déjà sur le PF '+PF.Name+' ayant pour reference '+PF.Id);
			}
			if(listEnseigneParCodeClientGroupe.get(pf.Code_client_groupe__c) != null && listEnseigneParCodeClientGroupe.get(pf.Code_client_groupe__c) == pf.Enseigne_partenaire__c) {
				listErreurs.add('Le Code client groupe '+pf.Code_client_groupe__c+' et l\'enseigne '+pf.Enseigne_partenaire__c+' existent déjà sur le PF '+PF.Name+' ayant pour reference '+PF.Id);
			}
		}

   		for ( Reference__c r : [SELECT Id, Key__c FROM Reference__c WHERE Key__c IN :listAgenceGaKey AND RecordTypeId = :rtAgence.Id]) {
			agence_SF.put(r.Key__c, r);
		}
		System.debug('verificationContactsGa listErreurs:' + listErreurs);
		return listErreurs;
   	}

   /**
	* @author Clement Musabimana
	* @date 16/07/2018
	* @description récupération du compte 
	**/
   	public  Account getAccount(ContactWrapper[] contactsGa){
   		Account account = new Account();
   		ContactWrapper contact0 = null;
   		String siretGa = '';
   		System.debug('getAccount contactsGa:' + contactsGa);
   		if(contactsGa.size() > 0){
   			contact0 = contactsGa[0];
   			siretGa = contact0.account.siret;
   		}
   		if(this.accountId != null){
   			//account.id = this.accountId;
   			account = [SELECT Id, Name, SIRET_texte__c, Enseignes_de_gestion_Client__c, (SELECT Id FROM zqu__Accounts__r) FROM Account WHERE Id =:this.accountId];
   		}
   		else if(siretGa != ''){
   			//account.id = this.accountId;
	   		for (Account a : [SELECT Id, Name, SIRET_texte__c, Enseignes_de_gestion_Client__c, (SELECT Id FROM zqu__Accounts__r) FROM Account WHERE SIRET_texte__c =: siretGa LIMIT 1]) {
				account = a;
			}
   		}
   		//Si le compte existe et sans proposition commercial ou le compte n'existe pas
   		if ((account.zqu__Accounts__r != null && account.zqu__Accounts__r.size() == 0) || (account.Id == null && contact0 != null)) {
			account.Name = contact0.account.companyName;
			account.SIRET_texte__c = contact0.account.siret;
			account.Code_client_Point_P__c = contact0.account.customerCode;
			//account.Code_postal__r.Key__c = pso.insee_cp;
			//account.putSObject('Code_postal__r', new Reference__c(Key__c = pso.insee_cp));
			if(contact0.address != null && contact0.address.streets != null){
				if(contact0.address.streets.size() >= 2){
					account.Adresse1__c = contact0.address.streets[0];
					account.Adresse2__c = contact0.address.streets[1];
				}
				else if(contact0.address.streets.size() >= 1){
					account.Adresse1__c = contact0.address.streets[0];
				}
			}

			// PAYS par défaut
			if (!Test.isRunningTest()) {
				account.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'FRA')));
			} 
			else {
				account.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'ZWE')));
			}
			
			if(contact0.mainAgency != null && agence_SF.get(contact0.mainAgency.id) != null){
				account.Agence_User__c = (agence_SF.get(contact0.mainAgency.id)).Id;
			}

			account.RecordTypeId = rtpro.Id;
   		}
   		account.Enseignes_de_gestion_Client__c = ENSEIGNE_PARTENAIRE;
   		return account;
   	}

   /**
	* @author Clement Musabimana
	* @date 16/07/2018
	* @description récupération des contacts
	**/
   	public  List<Contact> getContacts(ContactWrapper[] contactsGa, Account compte){
		System.debug('getContacts compte:' + compte);
   		List<Contact> listContacts = new List<Contact>();
   		Map<String,Contact> mapContactsExistants = new Map<String,Contact>();
   		for (Contact c : [SELECT Id, Email FROM Contact WHERE Account.Id =:compte.Id]) {
			mapContactsExistants.put(c.Email, c);
		}
		System.debug('getContacts mapContactsExistants:' + mapContactsExistants);
		for (ContactWrapper cw : contactsGa) {
			//On recupere le contact principal par rapport au PF unique récupéré (dans le cas où le compte possède plusieurs contacts)
			String referenceContactPrincipal = '';
			if(cw.account != null){
				referenceContactPrincipal = referenceContactsPrincipaux.get(cw.account.customerId+'_'+cw.account.id);
			}
			//Si contact principal, on enregistre les données si le compte n'a pas de proposition commercial 
			if(cw.id == referenceContactPrincipal){
				String email = (cw.email).toLowerCase();
				System.debug('getContacts email:' + email);
				if(compte.zqu__Accounts__r.size() == 0){
					if(mapContactsExistants.get(email) != null){
						//Le compte n'a pas de proposition commercial. On peut mettre à jour les contacts existants
						Contact contact =  mapContactsExistants.get(email);
						System.debug('getContacts contact:' + contact);
						contact.Phone = cw.phoneNumber;
						contact.MobilePhone = cw.mobileNumber;
						contact.Salutation = cw.civility;
						//contact.Contact_Principal_O_N__c = true;
						contact.LastName = cw.lastName;
						contact.FirstName = cw.firstName;
						listContacts.add(contact);
					}
					else {
						System.debug('getContacts new contact cw:' + cw);
						Contact contact =  new Contact();
						contact.AccountId = compte.Id;
						contact.Email = cw.email;
						contact.Phone = cw.phoneNumber;
						contact.MobilePhone = cw.mobileNumber;
						contact.Salutation = cw.civility;
						//contact.Contact_Principal_O_N__c = true;
						contact.LastName = cw.lastName;
						contact.FirstName = cw.firstName;
						listContacts.add(contact);
					}
				}
			}
		}
		return listContacts;
   	}

   /**
	* @author Clement Musabimana
	* @date 16/07/2018
	* @description récupération des programmes de fidélités. 
	* Deux contacts peuvent avoir le même programme de fidélité (meme customerId et meme Code client groue)
	* On prend alors celui qui est actif et qui a la date d'entree la plus petite.
	**/
   	public  List<ProgrammeFidelite__c> getProgrammesFidelite(ContactWrapper[] contactsGa, Account compte){
   		List<ProgrammeFidelite__c> listProgrammesFidelite = new List<ProgrammeFidelite__c>();
   		Map<String,ProgrammeFidelite__c> mapProgrammesFideliteExistantsByCustomerId = new Map<String,ProgrammeFidelite__c>();
   		Map<String,ProgrammeFidelite__c> mapProgrammesFideliteExistantsByCodeClientGroupeEnseigne = new Map<String,ProgrammeFidelite__c>();
   		//Map pour stocker un unique PF si le compte a plusieurs contacts avec le même point fidélité
   		Map<String,ProgrammeFidelite__c> mapProgrammesFideliteUniques = new Map<String,ProgrammeFidelite__c>();

   		//recupération des PF existant sur le compte
   		for (ProgrammeFidelite__c pf : [SELECT Id, Name, CustomerId__c, Code_client_groupe__c, Enseigne_partenaire__c, Compte__r.Id FROM ProgrammeFidelite__c WHERE Compte__r.Id =:compte.Id]) {
			mapProgrammesFideliteExistantsByCustomerId.put(pf.CustomerId__c, pf);
			mapProgrammesFideliteExistantsByCodeClientGroupeEnseigne.put(pf.Code_client_groupe__c+'_'+pf.Enseigne_partenaire__c, pf);
		}
		System.debug('getProgrammesFidelite mapProgrammesFideliteExistantsByCustomerId:' + mapProgrammesFideliteExistantsByCustomerId);
		System.debug('getProgrammesFidelite mapProgrammesFideliteExistantsByCodeClientGroupeEnseigne:' + mapProgrammesFideliteExistantsByCodeClientGroupeEnseigne);
		
		for (ContactWrapper cw : contactsGa) {
			ProgrammeFidelite__c pf = new ProgrammeFidelite__c();
			Boolean isContactGaActif = false;
			Date dateEntree = null;
			// On ne prend en compte que les services de type GA et avec une souscription actif
			System.debug('getProgrammesFidelite cw.services:' + cw.services);

			System.debug('getProgrammesFidelite mapProgrammesFideliteUniques before 1*:' + mapProgrammesFideliteUniques);
			for(ServicesItem service: cw.services){
				if(service.subscription == true && service.id == SERVICE_GA && service.startDate != null && service.startDate != ''){
					dateEntree = Date.parse(getDateStringFormatee(service.startDate));  
					isContactGaActif = true;
				}
			}
			System.debug('getProgrammesFidelite mapProgrammesFideliteUniques before 2*:' + mapProgrammesFideliteUniques);
			System.debug('getProgrammesFidelite isContactGaActif:' + isContactGaActif);
			//si le contact est GA avec une souscription, on le prend en compte
			if(isContactGaActif == true){
				if(mapProgrammesFideliteExistantsByCustomerId.get(cw.account.customerId) != null){
					pf = mapProgrammesFideliteExistantsByCustomerId.get(cw.account.customerId);
				}
				else if(mapProgrammesFideliteExistantsByCustomerId.get(cw.account.id+'_'+ENSEIGNE_PARTENAIRE) != null){
					pf = mapProgrammesFideliteExistantsByCustomerId.get(cw.account.id+'_'+ENSEIGNE_PARTENAIRE);				
				}
				else {
					pf = new ProgrammeFidelite__c();
					pf.Compte__c = compte.Id;	
				}
				System.debug('getProgrammesFidelite mapProgrammesFideliteUniques before 3*:' + mapProgrammesFideliteUniques);
				System.debug('getProgrammesFidelite cw:' + cw);
				pf.CustomerId__c = cw.account.customerId;
				pf.Code_client_groupe__c = cw.account.id;		
				pf.Enseigne_partenaire__c = ENSEIGNE_PARTENAIRE;
				if(cw.mainAgency != null && agence_SF.get(cw.mainAgency.id) != null){
					pf.Agence_Pilote__c = (agence_SF.get(cw.mainAgency.id)).Id;
				}
				System.debug('getProgrammesFidelite mapProgrammesFideliteUniques before 4*:' + mapProgrammesFideliteUniques);
				if(mapProgrammesFideliteUniques.get(cw.account.customerId+'_'+cw.account.id) != null){
					ProgrammeFidelite__c temp = mapProgrammesFideliteUniques.get(cw.account.customerId+'_'+cw.account.id);
					System.debug('getProgrammesFidelite mapProgrammesFideliteUniques temp.DateEntree__c:' + temp.DateEntree__c);
					if(temp.DateEntree__c > dateEntree){
						pf.DateEntree__c = dateEntree;
						mapProgrammesFideliteUniques.put(cw.account.customerId+'_'+cw.account.id,pf);
						referenceContactsPrincipaux.put(cw.account.customerId+'_'+cw.account.id,cw.id);
					}
				}
				else {
					pf.DateEntree__c = dateEntree;
					mapProgrammesFideliteUniques.put(cw.account.customerId+'_'+cw.account.id,pf);
					referenceContactsPrincipaux.put(cw.account.customerId+'_'+cw.account.id,cw.id);
				}
				System.debug('getProgrammesFidelite mapProgrammesFideliteUniques after:' + mapProgrammesFideliteUniques);
			}
		}
		for (String indexMap : mapProgrammesFideliteUniques.keyset()) {
			listProgrammesFidelite.add(mapProgrammesFideliteUniques.get(indexMap));
		}
		System.debug('getProgrammesFidelite listProgrammesFidelite:' + listProgrammesFidelite);
		
		return listProgrammesFidelite; 
   	}

   /**
	* @author Clement Musabimana
	* @date 16/07/2018
	* @description enregistrement des données comptes, contacts et programmes de fidélité 
	**/
   	public  List<String> miseAJourProgrammesFidelite(String codeClientPointP, ContactWrapper[] contactsGa){
   		List<String> listErreurs = new List<String>();
   		Account compte = getAccount(contactsGa);
   		List<ProgrammeFidelite__c> programmesFidelite = getProgrammesFidelite(contactsGa, compte);
   		List<Contact> contacts = getContacts(contactsGa, compte);
   		List<SObject> listObjectToInsert =  new List<SObject>();
   		List<SObject> listObjectToUpdate =  new List<SObject>();
		System.debug('miseAJourProgrammesFidelite compte:' + compte);
		try {
	   		if(compte.Id != null){
	   			listObjectToUpdate.add(compte);
	   		}
	   		else {
	   			insert compte;
	   			this.accountId = compte.Id;
	   		}
			for(Contact contact: contacts){
				if(Contact.Id != null){
		   			listObjectToUpdate.add(contact);
		   		}
		   		else {
		   			contact.AccountId = compte.Id;
		   			listObjectToInsert.add(contact);
		   		}
			}
			for(ProgrammeFidelite__c pf: programmesFidelite){
				if(pf.Id != null){
		   			listObjectToUpdate.add(pf);
		   		}
		   		else {
		   			pf.Compte__c = compte.Id;
		   			listObjectToInsert.add(pf);
		   		}
			}

			System.debug('miseAJourProgrammesFidelite listObjectToInsert:' + listObjectToInsert);
			System.debug('miseAJourProgrammesFidelite listObjectToUpdate:' + listObjectToUpdate);


			if (listObjectToUpdate.size() > 0) {
				update listObjectToUpdate;
			}

			if (listObjectToInsert.size() > 0){
				insert listObjectToInsert;
			}   		
   		
   		}
   		catch(Exception e) {
   			listErreurs.add('Une erreur s\'est produite');
   			listErreurs.add(e.getCause()+ ' '+e.getMessage());

   		}
		System.debug('miseAJourProgrammesFidelite listErreurs:' + listErreurs);
		return listErreurs;
   	}
   	// Appel a partir du bouton sur la fiche du compte
   	webservice static List<String> serviceGenerationArtisan(String accountId,String codeClientPointP) {
   		List<String> listErreurs =  new List<String>();
   		if(codeClientPointP != null && codeClientPointP.trim() != ''){
	   		GenerationArtisanService ga = new GenerationArtisanService(accountId);
			//GenerationArtisanService.ContactWrapper[] contactsGa = ga.getContactsGenerationArtisan(codeClientPointP);
			Map<String,Object[]> objectsContactsGa = ga.getContactsGenerationArtisan(codeClientPointP);
			List<String> listErreursConnexion = (List<String>)objectsContactsGa.get('erreur');
			GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');

			if(listErreursConnexion.size() > 0){
				listErreurs.addAll(listErreursConnexion);
			}else{
				listErreurs.addAll(ga.verificationContactsGa(codeClientPointP,contactsGa));
		        listErreurs.addAll(ga.miseAJourProgrammesFidelite(codeClientPointP, contactsGa));
			}
		}
   		else {
   			listErreurs.add(System.Label.WS_GenerationArtisanWsMsg404);
   		}

        return listErreurs;
    }

   	// Appel a partir de la page visualforce page (page recherche des comptes)
   	webservice static List<String> serviceGenerationArtisanVFP(String accountId,String codeClientPointP) {
   		List<String> listErreurs =  new List<String>();
   		
		System.debug('serviceGenerationArtisanVFP codeClientPointP:' + codeClientPointP);
   		if(codeClientPointP != null && codeClientPointP.deleteWhitespace() != ''){
   			codeClientPointP = codeClientPointP.deleteWhitespace();
			System.debug('serviceGenerationArtisanVFP codeClientPointP**deleteWhitespace:' + codeClientPointP);
	   		GenerationArtisanService ga = new GenerationArtisanService(accountId);
			//GenerationArtisanService.ContactWrapper[] contactsGa = ga.getContactsGenerationArtisan(codeClientPointP);
			Map<String,Object[]> objectsContactsGa = ga.getContactsGenerationArtisan(codeClientPointP);
			List<String> listErreursConnexion = (List<String>)objectsContactsGa.get('erreur');
			GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');

			if(listErreursConnexion.size() > 0){
				listErreurs.addAll(listErreursConnexion);
			}else{
				listErreurs.addAll(ga.verificationContactsGa(codeClientPointP,contactsGa));
		        listErreurs.addAll(ga.miseAJourProgrammesFidelite(codeClientPointP, contactsGa));
			}
   		}
   		else {
   			listErreurs.add(System.Label.WS_GenerationArtisanWsMsg404);
   		}
		System.debug('serviceGenerationArtisanVFP listErreurs:' + listErreurs);
        return listErreurs;
    }

}