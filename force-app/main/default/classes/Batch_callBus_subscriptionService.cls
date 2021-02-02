/**
* @author Clement Musabimana
* @date 11/03/2019
* @description Gestion de l'activation et suspension des services de souscription par le biais du BUS
**/
public class  Batch_callBus_subscriptionService implements Database.Batchable<sObject>, Database.AllowsCallouts  {
	public String queryString = '';

   	public Database.QUERYLocator start(Database.BatchableContext BC){
		System.debug('Batch_callBus_subscriptionService queryString '+queryString);
    	return Database.getQUERYLocator(queryString);
   	}

   	public Batch_callBus_subscriptionService(String dateDebutParam){
		System.debug('Batch_callBus_subscriptionService dateDebutParam init '+dateDebutParam);
		String dateDebutString = dateDebutParam+'T00:00:00.000+0000';
		String dateFinString = dateDebutParam+'T23:59:59.000+0000';
   		queryString = 'SELECT Id,Field, OldValue, NewValue, CreatedDate, AccountId,Account.Desactivation_des_ODC_impaye_recurrent__c from AccountHistory where  field = \'Desactivation_des_ODC_impaye_recurrent__c\' and CreatedDate >='+dateDebutString+' and CreatedDate <='+dateFinString;
   	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug('Batch_callBus_subscriptionService scope '+scope);
		for (AccountHistory accountHistory : (list<AccountHistory>)scope) {
            if (accountHistory.OldValue == false && accountHistory.NewValue == true && accountHistory.NewValue == accountHistory.Account.Desactivation_des_ODC_impaye_recurrent__c) {
            	changeClientActivationEtat(accountHistory.AccountId, true);
            }
            if (accountHistory.OldValue == true && accountHistory.NewValue == false && accountHistory.NewValue == accountHistory.Account.Desactivation_des_ODC_impaye_recurrent__c) {
            	changeClientActivationEtat(accountHistory.AccountId, false);
            }
        }

   	}

   	public void finish(Database.BatchableContext BC){

   	}


	/**
	* @author Clement Musabimana
	* @date 21/02/2019
	* @description appelle du service BUS d'activation ou de suspension d'une souscription.
	*			   méthode appelé par la méthode prepareTraitementSouscription
	**/
	public static void changeClientActivationEtat(Id customerAccountId, boolean isImpaye)
	{
       	try {
			
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
			req.setTimeout(120000);
			req.setEndpoint(endpoint);
			req.setMethod('GET');

			Blob headerValue = Blob.valueOf(System.Label.HY_BUS_INVOICE_USER + ':' + System.Label.HY_BUS_INVOICE_PASS);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			req.setHeader('Authorization', authorizationHeader);

			Http http = new Http();
		    HTTPResponse res = Test.isRunningTest() ? new HttpResponse() : http.send(req);
		    Integer code = res.getStatusCode();
		    string msg = '';
		    if (code == 404 || res.getBody().contains('"status":"failed"')) {
		    	System.debug(new ApexPages.Message(ApexPages.Severity.ERROR, 'La souscription n\'est pas disponible dans Zuora, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.'));
		    	msg = 'La souscription n\'est pas disponible dans Zuora, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.</br>';
		    	msg = msg + 'code: 404 Id: '+customerAccountId+' isImpaye: '+ isImpaye+ '</br>';
		    }
		    else if (code == 200) {
		    	System.debug(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'L\'état de la souscription a bien été modifié '));
		    	msg = 'La souscription n\'est pas disponible dans Zuora, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.</br>';
		    	msg = msg + 'code: 200 Id: '+customerAccountId+' isImpaye: '+ isImpaye+ '</br>';
		    } 
		    else {
		    	System.debug('changeClientActivationEtat code '+code);
		    	System.debug(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur technique s\'est produite, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.'));
		    	msg = 'La souscription n\'est pas disponible dans Zuora, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.</br>';
		    	msg = msg + 'code: '+code+' Id: '+customerAccountId+' isImpaye: '+ isImpaye+ '</br>';
		    }
		}catch(Exception e) {       
			System.debug('An exception occurred: ' + e.getMessage());
		    sendAlertMail(e.getMessage());
		    
		} 
	}

    public static void sendAlertMail(String msg) {
		/* Envoie de mail pour inforamtion */
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String email ='Clement.Musabimana@ext.saint-gobain.com';
		//String email = System.Label.DL_SGDBF_supervision_processus;
		mail.setUseSignature(false);
		mail.setToAddresses(new String[] {email});
		mail.setSubject('Error on execution batch Batch_callBus_subscriptionService');
		String body='Une ereur s\'est produite lor de l\'execution du batch Batch_callBus_subscriptionService! </br>';
		body=body+msg+'</br>';
		mail.setHtmlBody(body);

		// Send the email
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		/* FIN Envoi du mail */       
    }
}