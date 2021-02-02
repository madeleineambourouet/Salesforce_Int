/**
* @author Clement Musabimana
* @date 17/10/2019
* @description Service permettant de faire appel au fournisseur Instaply pour l'envoi de messages
**/
public class CallServiceInstaply {

	/**
	* @author Clement Musabimana
	* @date 17/10/2019
	* @description fonction permettant d'envoyer un SMS à un numéro
	**/
	@future (callout=true)
    public static void sendMessageToNumber(String message,String phoneNumber,String firstName,String lastName) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.Label.URL_InstaplyWSEndpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cache-Control', 'no-cache');
        req.setHeader('token', System.Label.URL_InstaplyWSEndpointToken);
        req.setMethod('POST');
        String body = '{' +
        					'"message":"' + message + '",' +
                        	'"user": {' + 
		                        '"phoneNumber":"' + phoneNumber + '",' +
		                        '"firstName":"' + firstName + '",' +
		                        '"lastName":"' + lastName + '"' +
                        	'}' +
                       '}';
        req.setBody(body);
                    
        // Send the request, and return a response
        HttpResponse res;
		
		System.debug('CallServiceInstaply sendMessageToNumber  message ' + message);
        if (!Test.isRunningTest() && message != ''){
			System.debug('CallServiceInstaply sendMessageToNumber  envoi ok ');
            res = h.send(req);
        }
        else{
            // MOCK
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result": "ok" }');
            res.setStatusCode(200);
			System.debug('CallServiceInstaply sendMessageToNumber  envoi nok ');
        }
        
        //String result = res.getBody();

        // Checking result
		System.debug('CallServiceInstaply sendMessageToNumber  res.getStatusCode() ' + res.getStatusCode());
		System.debug('CallServiceInstaply sendMessageToNumber  res.getBody() ' + res.getBody());
        if (res.getStatusCode() == 200)
        {
			System.debug('CallServiceInstaply sendMessageToNumber  retour ok ');
        }

 
    }


    /**
    * @author Clement Musabimana
	* @date 17/10/2019
	* @description prepare les données à envoter à Instaply
    **/
    public static void prepareMessageToSend(Map<Id, Projet__c> oldMap, Map<Id, Projet__c>  newMap, List<Projet__c> newList) {

    	String isActiveService = System.Label.Instaply_IsActive;
    	Map<String, String> mapPartSousStatut = new Map<String, String>();
    	Map<String, String> mapPartProjetMobilePhone = new Map<String, String>();
    	List<String> listPartIdProjet = new List<String>();

    	if(isActiveService == '1'){
	        for (Projet__c proj : newList) {
	            Projet__c oldP = oldMap != null ? oldMap.get(proj.Id) : null;
	            Projet__c newP = newMap != null ? newMap.get(proj.Id) : null;
	            System.debug('prepareMessageToSend* oldP '+oldP);
	            System.debug('prepareMessageToSend* newP '+ newP);
	            //Si proprietaire vide alors on le renseigne si condition ok
	            if(proj.Demande_Part_Origine__c == 'Artisans qualifiés'){
	                if((oldP != null && newP != null) && (
	                	(oldP.Statut_Projet__c != newP.Statut_Projet__c && newP.Statut_Projet__c == 'Part NRP') ||
	                	(oldP.Statut_Projet__c == newP.Statut_Projet__c && newP.Statut_Projet__c == 'Part NRP' && oldP.Sous_statut__c != newP.Sous_statut__c)
	                ))
	                {              
	                	if(newP.Sous_statut__c == '1er appel' || newP.Sous_statut__c == '2ème appel' || newP.Sous_statut__c == '3ème appel'){
	                		mapPartSousStatut.put(newP.Particulier__c,newP.Sous_statut__c);
	                		mapPartProjetMobilePhone.put(newP.Particulier__c,newP.Mobile__c);
	                		listPartIdProjet.add(newP.Particulier__c);
	                	}
	                }
	            }
	        }
	        for (Account acc : [select id,FirstName,LastName,PersonMobilePhone from Account where IsPersonAccount = true and id in:listPartIdProjet]) {
	            if(mapPartSousStatut.get(acc.id) != null && mapPartProjetMobilePhone.get(acc.id) != null && mapPartProjetMobilePhone.get(acc.id) != ''){
	                String message = '';
	                String phoneNumber = mapPartProjetMobilePhone.get(acc.id);
	                String firstName = acc.FirstName;
	                String lastName = acc.LastName;
	                if(mapPartSousStatut.get(acc.id) == '1er appel'){
	            		message = System.Label.Instaply_Message_NRP1;
	            	}
	                else if(mapPartSousStatut.get(acc.id) == '2ème appel'){
	            		message = System.Label.Instaply_Message_NRP2;
	            	}
	                else if(mapPartSousStatut.get(acc.id) == '3ème appel'){
	            		message = System.Label.Instaply_Message_NRP3;
	            	}
	            	sendMessageToNumber(message,phoneNumber,firstName,lastName);
					System.debug('CallServiceInstaply prepareMessageToSend  message ' + message);
					System.debug('CallServiceInstaply prepareMessageToSend  phoneNumber ' + phoneNumber);
					System.debug('CallServiceInstaply prepareMessageToSend  firstName ' + firstName);
					System.debug('CallServiceInstaply prepareMessageToSend  lastName ' + lastName);
	            }
	        }
    	}
    }
}