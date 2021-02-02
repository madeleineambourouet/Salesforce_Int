/**
* @author Clement Musabimana
* @date 31/05/2018
* @description Recuperation et envoie des projets ayant une MER pour notation. On envoi le projet une seule fois en se basant sur :
*			   - le type de projet: Artisan
*			   - le statut d'envoie (projet déjà envoyé ou non)
* 			   - la date de selection 
*			   Les données sont récupérées par le BUS (Intermédiation) pour être envoyé à Baazarvoice
**/
@RestResource(urlMapping='/projetsEligiblesNotation/')
global without sharing class NotationWS {
	
	@HttpPost	
  	global static void notation_data(String dateTraitement) {
		processData(dateTraitement);
	}

	// Données à envoyer à Baazarvoice
	public class Projet {
		public String date_creation;
		public String email; 
		public String civilite; 
		public String prenom; 
		public String nom; 		
		public String id; 
		public String categorie; 
	}


	// Récupération des données salesforce
	public static void processData(String dtTraitement) {
		System.debug('processData dtTraitement ' + dtTraitement);
		
		Date dateTraitement = Date.parse(dtTraitement);  
		System.debug('processData dateTraitement to Date ' + dateTraitement);
	
		RestContext.response.addHeader('Content-Type', 'application/json');
		RestResponse response = RestContext.response;
		List<Projet> projets = new List<Projet>(); 
		//1. Selection des MER ayant une date de selection et aggregation par projet
		//2. Récuperation par dans l'aggrégat de chaque projet de la plus petite date de matching
		//3. Si la plus petite date du projet est egale à la date de la veille, alors selection du projet pour notation
 		AggregateResult[] groupedResults = [SELECT projet__c,MIN(Date_de_s_lection__c) selectionDate, MIN(projet__r.CreatedDate) creationDate,MIN(projet__r.particulier__r.PersonEmail) email,
 											MIN(projet__r.particulier__r.Firstname) prenom,MIN(projet__r.particulier__r.Lastname) nom,MIN(projet__r.Categorie_lkp__r.name) categorie, MIN(projet__r.particulier__r.salutation) civilite 
 											FROM Intermediation__c where RecordType.DeveloperName = 'MER_Artisans_qualifies' AND projet__r.mer_auto__c = false AND projet__r.Is_sendToNotation__c = false AND Date_de_s_lection__c != null AND Date_de_s_lection__c >=: dateTraitement AND Date_de_s_lection__c <: dateTraitement.addDays(1) group by projet__c];
		for (AggregateResult ar : groupedResults)  {
		    System.debug('Projet ar' + ar);
			Projet projet = new Projet();
			Datetime myDT = Datetime.valueOf(ar.get('creationDate')); 
            String dateProjet = myDT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
			projet.date_creation = String.valueOf(dateProjet);
			projet.email = String.valueOf(ar.get('email'));
			projet.civilite = String.valueOf(ar.get('civilite'));
			projet.prenom = String.valueOf(ar.get('prenom'));
			projet.nom = String.valueOf(ar.get('nom'));
			projet.id = String.valueOf(ar.get('projet__c'));
			projet.categorie = String.valueOf(ar.get('categorie'));
			projets.add(projet);
		}
		System.debug('processData groupedResults ' + groupedResults);
	
		response.statusCode = 200;
 		response.responseBody = Blob.valueOf('{"projets":'+JSON.serialize(projets)+'}');
    }

}