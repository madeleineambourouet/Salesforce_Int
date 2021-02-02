/**
* @author Clement Musabimana
* @date 13/06/2018
* @description Permet de flagger les projets récupérés par le BUS pour envoie à Baazarvoice (Ce service doit être appélé après le service NotationWS)
**/
@RestResource(urlMapping='/projetsEligiblesNotationAcquittement/')
global without sharing class NotationAcquittementWS { 
	
	@HttpPost	
  	global static void notation_acquittement(List<String> projetsId) {
		processData(projetsId);
	}


	// Récupération des données salesforce
	public static void processData(List<String> projetsId) {
		System.debug('processData projetsId ' + projetsId);

		RestContext.response.addHeader('Content-Type', 'application/json');
		RestResponse response = RestContext.response;
		List<Projet__c> projetsToUpdate =  new List<Projet__c>();
		Datetime dateAcquittement = Datetime.now();
		if(projetsId != null && projetsId.size() > 0){
			for ( String projetStringId : projetsId) {
				Projet__c proj = new Projet__c();
				Id projetId = Id.valueOf(projetStringId);
				proj.Id = projetId;
				proj.Is_sendToNotation__c = true;
				proj.Date_export_notation__c = dateAcquittement;
                projetsToUpdate.add(proj);
			}
		}
        
		update projetsToUpdate;	
		response.statusCode = 200;
 		//response.responseBody = Blob.valueOf('{"CodeRetour":"0"}');
    }

}