public with sharing class QuoteLoyaltyProgram implements Queueable, Database.AllowsCallouts  {

    private Id qId ;

	public QuoteLoyaltyProgram(Id curId) {
		this.qId = curId;
	}

	public void execute(QueueableContext context) {
        try {
        	//String completedResult =  CompleteLoyaltyProgramInfo(qId); 


        	List<zqu__Quote__c> qList = [SELECT Id, zqu__ZuoraSubscriptionID__c, RecordTypeName__c, zqu__ExistSubscriptionID__c, DateEntree__c, DateSortie__c, Code_client_groupe__c, Agence_Pilote__c, EnseigneFacturation__c, LoyaltyProgramID__c FROM zqu__Quote__c where id =:qId];
        	if (qList == null || qList.isEmpty()) return;
        	zqu__Quote__c curQ = qList[0];
        	System.debug('my curQ ' + curQ);
        	if (curQ.LoyaltyProgramID__c == null && curQ.RecordTypeName__c == 'Cancellation') return;
	        Zuora.zApi zApi = ZuoraUtilities.zuoraApiAccess();
			List<Zuora.zObject> objs = new List<Zuora.zObject>();

	 		Zuora.zObject invoiceUpdate = new Zuora.zObject('Subscription');
	        
	        String subId = (curQ.RecordTypeName__c == 'Default' || curQ.RecordTypeName__c == 'Cancellation') ? curQ.zqu__ZuoraSubscriptionID__c : curQ.zqu__ExistSubscriptionID__c;
	        invoiceUpdate.setValue('Id', subId);
	        invoiceUpdate.setValue('Code_client_groupe__c', (curQ.Code_client_groupe__c == null ? '' : curQ.Code_client_groupe__c));
	        invoiceUpdate.setValue('DateEntree__c', (curQ.DateEntree__c == null ? '' : curQ.DateEntree__c));
	        invoiceUpdate.setValue('DateSortie__c', (curQ.DateSortie__c == null? '' : curQ.DateSortie__c));
	        invoiceUpdate.setValue('Agence_Pilote__c', (curQ.Agence_Pilote__c == null? '' : curQ.Agence_Pilote__c));
	        invoiceUpdate.setValue('EnseigneFacturation__c', (curQ.EnseigneFacturation__c == null ? '' : curQ.EnseigneFacturation__c));
	        invoiceUpdate.setValue('LoyaltyProgramID__c', (curQ.LoyaltyProgramID__c == null? '': curQ.LoyaltyProgramID__c));
	        objs.add(invoiceUpdate);
	        System.debug('my objs ' + objs);
	        List<Zuora.zApi.SaveResult> updateInvoiceResults = ZuoraUtilities.updateZuoraObjects(zApi, objs);
	        System.debug('my updateInvoiceResults ' + updateInvoiceResults);
	        Zuora.zApi.SaveResult iUpdateResult = updateInvoiceResults.size() > 0 ? updateInvoiceResults[0] : null;
	        List<String> msgList =  ZuoraUtilities.analyzeSaveResult(iUpdateResult);
	        String errorMSG = null;
	        if (msgList.isEmpty()) {
	            //WS success
	            errorMSG += 'update custom field OK';
	        } else {
	            //error
	            errorMSG += 'update custom field failed';
	            errorMSG += String.join(msgList, ' ');
	        }
	        System.debug(errorMSG);

	        
        } catch (Exception e) {
            System.debug(e);
        }
    }

    

}