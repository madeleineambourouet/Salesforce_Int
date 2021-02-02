/**
* @author Clement Musabimana
* @date 21/02/2019
* @description Gestion de l'activation et suspension des services de souscription par le biais du BUS
**/
public without sharing class ModifySouscription {
	/**
	* @author Clement Musabimana
	* @date 21/02/2019
	* @description Methode qui appelle le service BUS d'activation ou de suspension d'une souscription.
	*			   La méthode est appelé par le Trigger AccountTrigger qui est déclenché à la création ou modification d'un compte
	**/	
	public static void prepareTraitementSouscription(List<Account> newlist, Map<Id,Account> newMap, Map<Id,Account> oldMap)
	{

	    System.debug('prepareTraitementSouscription newlist '+newlist);
	    System.debug('prepareTraitementSouscription newMap '+newMap);
	    System.debug('prepareTraitementSouscription oldMap '+oldMap);
	    String urlEndpoint = '';
		if(newlist != null && newlist.size() > 0){
			Account customerAccount = newlist[0];

			Account customerAccountNew = null;
			Account customerAccountOld = null;

			if(newMap != null){
				customerAccountNew = newMap.get(customerAccount.Id);	
			}
			if(oldMap != null){
				customerAccountOld = oldMap.get(customerAccount.Id);
			}
			//Si le compte de facturation passe en impayé
			if(!Test.isRunningTest() && customerAccountNew != null && customerAccountNew.Desactivation_des_ODC_impaye_recurrent__c == true && customerAccountOld == null){
				System.debug('prepareTraitementSouscription NULL 1 ');
				changeClientActivationEtat(customerAccountNew.Id, true);
			}
			//Si le compte de facturation passe en impayé
			if(!Test.isRunningTest() && customerAccountNew != null && customerAccountNew.Desactivation_des_ODC_impaye_recurrent__c == true && customerAccountOld != null && customerAccountOld.Desactivation_des_ODC_impaye_recurrent__c == null){
				System.debug('prepareTraitementSouscription NULL 2 ');
				changeClientActivationEtat(customerAccountNew.Id, true);
			}
			else if(!Test.isRunningTest() && customerAccountNew != null && customerAccountNew.Desactivation_des_ODC_impaye_recurrent__c == true && customerAccountOld != null && customerAccountOld.Desactivation_des_ODC_impaye_recurrent__c == false){
				System.debug('prepareTraitementSouscription FALSE ');
				changeClientActivationEtat(customerAccountNew.Id, true);
			}
			//Si le compte de facturation était en impayé et redevient conforme
			else if(!Test.isRunningTest() && customerAccountNew != null && customerAccountNew.Desactivation_des_ODC_impaye_recurrent__c == false && customerAccountOld != null && customerAccountOld.Desactivation_des_ODC_impaye_recurrent__c == true){
				System.debug('prepareTraitementSouscription TRUE ');
				changeClientActivationEtat(customerAccountNew.Id, false);
			}
			else {
				System.debug('prepareTraitementSouscription PAS d appel');
			}
			
		}

	}	

	/**
	* @author Clement Musabimana
	* @date 21/02/2019
	* @description appelle du service BUS d'activation ou de suspension d'une souscription.
	*			   méthode appelé par la méthode prepareTraitementSouscription
	**/
	@future (callout=true)
	public static void changeClientActivationEtat(Id customerAccountId, boolean isImpaye)
	{

	    System.debug('changeClientActivationEtat customerAccountId '+customerAccountId);
	    System.debug('changeClientActivationEtat isImpaye '+isImpaye);
	    String urlEndpoint = '';
		if(isImpaye == true){
			System.debug('prepareTraitementSouscription suspend ');
			urlEndpoint = '/rest/service/subscription/suspend?idClient='+customerAccountId;
		}
		else {
			System.debug('prepareTraitementSouscription activate ');
			urlEndpoint = '/rest/service/subscription/activate?idClient='+customerAccountId;
		}

		String endpoint = System.Label.URL_DOMAIN_BUS +  urlEndpoint;
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('GET');

		Blob headerValue = Blob.valueOf(System.Label.HY_BUS_INVOICE_USER + ':' + System.Label.HY_BUS_INVOICE_PASS);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);

		Http http = new Http();
	    HTTPResponse res = http.send(req);
	    Integer code = res.getStatusCode();

	    if (code == 404 || res.getBody().contains('"status":"failed"')) {
	    	System.debug(new ApexPages.Message(ApexPages.Severity.ERROR, 'La souscription n\'est pas disponible dans Zuora, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.'));
	    }
	    else if (code == 200) {
	    	System.debug(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'L\'état de la souscription a bien été modifié '));
	    } 
	    else {
	    	System.debug('changeClientActivationEtat code '+code);
	    	System.debug(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur technique s\'est produite, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.'));
	    }
		

	}
}