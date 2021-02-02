public without sharing class resignationQuote {
	public zqu__Quote__c quote {get;set;}
	public Integer code {get;set;}
	public String message {get;set;}

	public resignationQuote(ApexPages.StandardController std) {
		this.quote = [SELECT Id, Name, zqu__SoldToContact__c, zqu__SoldToContact__r.FirstName, zqu__SoldToContact__r.LastName, zqu__SoldToContact__r.Email, zqu__StartDate__c FROM zqu__Quote__c WHERE Id = :std.getId() LIMIT 1];
	}

	public PageReference resignation() {

		String endpoint = System.Label.URL_DOMAIN_BUS + '/rest/service/subscriptionUpdate/byQuoteNumber/revokeSubscription/' + this.quote.Name;
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('GET');

		Blob headerValue = Blob.valueOf(System.Label.HY_BUS_INVOICE_USER + ':' + System.Label.HY_BUS_INVOICE_PASS);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);

		Http http = new Http();
	    HTTPResponse res = http.send(req);
	    this.code = res.getStatusCode();
	    
	    if (this.code == 404 || res.getBody().contains('"status":"failed"')) {
	    	this.message = 'La renonciation n\'est pas possible. Vérifiez le statut de la proposition commerciale et de l\'éventuelle souscription associée.';
	    	return null;
	    } else if (this.code == 200) {
	    	if (this.quote.zqu__SoldToContact__c != null) {

	    		emailSend();
	    	}
	    	this.quote.zqu__Status__c = 'Abandonnée';
	    	this.quote.Motif_d_abandon__c = 'Renonciation avant activation';
	    	update this.quote;
	    	this.message = 'La renonciation a bien été prise en compte, un mail de confirmation a été envoyé au contact principal.';
	    	return null;
	    }  else {
	    	this.message = 'Une erreur technique s\'est produite, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.';
	    	return null;
	    }
	}

	private void emailSend()
	{
		EmailTemplate et;
		OrgWideEmailAddress oa;
		for (EmailTemplate e : [SELECT Name, DeveloperName, Id FROM EmailTemplate WHERE DeveloperName = 'PRO_Proposition_resiliee']) {
			et = e;
		}

		for (OrgWideEmailAddress owea : [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%']) {
			oa = owea;
		}

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {this.quote.zqu__SoldToContact__r.Email});
		mail.setTargetObjectId(this.quote.zqu__SoldToContact__c);
		mail.setWhatId(this.quote.Id);
		mail.setTemplateId(et.Id);
		mail.setSaveAsActivity(false);
		mail.setOrgWideEmailAddressId(oa.Id);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}
}