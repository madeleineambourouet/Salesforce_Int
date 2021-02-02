/**
* @author Clement Musabimana
* @date 15/04/2019
* @description Mise à jour des information de la quote à partir des données récupérées de Zuora
**/
public class Batch_updateQuoteInfo implements Database.Batchable<sObject> {
	public String queryString = '';

   	public Database.QUERYLocator start(Database.BatchableContext BC){
		System.debug('Batch_updateQuoteInfo queryString '+queryString);
    	return Database.getQUERYLocator(queryString);
   	}

   	public Batch_updateQuoteInfo(){
   		queryString = 'select id,CreatedDate,zqu__SubscriptionTermStartDate__c,Type_de_geste__c,zqu__Account__r.Code_client__c  from zqu__Quote__c where Type_de_geste__c = \'Modification de souscription\' and zqu__SubscriptionTermStartDate__c = null and zqu__Account__c != null  order by CreatedDate desc';
   	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug('Batch_updateQuoteInfo scope '+scope);
		for (zqu__Quote__c zquote : (list<zqu__Quote__c>)scope) {
			System.debug('Batch_updateQuoteInfo zquote '+zquote);
            String billingAccountId = Zuora_Query.getBillingAccountId(zquote.zqu__Account__r.Code_client__c);
			System.debug('Batch_updateQuoteInfo billingAccountId '+billingAccountId);
        }

   	}

   	public void finish(Database.BatchableContext BC){

   	}

}