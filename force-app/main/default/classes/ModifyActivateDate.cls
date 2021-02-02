public without sharing class ModifyActivateDate {
	public zqu__Quote__c quote {get;set;}
	public String dateChanged {get;set;}
	public Integer code {get;set;}



	public ModifyActivateDate(ApexPages.StandardController std) {
		this.quote = [SELECT Id, Name, zqu__SoldToContact__c, zqu__SoldToContact__r.FirstName, zqu__SoldToContact__r.LastName, zqu__SoldToContact__r.Email, zqu__StartDate__c FROM zqu__Quote__c WHERE Id = :std.getId() LIMIT 1];
		this.dateChanged = this.quote.zqu__StartDate__c.format();
		//System.debug('TEST : ModifyActivateDate : std.getRecord() = ' + std.getRecord());
		//zqu_number__c
	}

	public PageReference changeDate()
	{
		pattern myPattern = pattern.compile('^([0-9]{2})/([0-9]{2})/([0-9]{4})$');
		matcher myMatcher = myPattern.matcher(this.dateChanged);

		if (!myMatcher.matches()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date renseignée n\'est pas au format !'));
			return null;
		} else {
			System.debug('TEST : myMatcher group 0 = ' + myMatcher.group(0));
			Integer jj = Integer.valueOf(myMatcher.group(1));
			Integer mm = Integer.valueOf(myMatcher.group(2));
			Integer aaaa = Integer.valueOf(myMatcher.group(3));

			try {
				if (Date.today() > Date.parse(this.dateChanged)) {
			    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date renseignée est inférieure a la date du jour !'));
			    	return null;
			    }
			} catch(exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date renseignée n\'est pas conforme à la réglementation !'));
			    return null;
			}
		}

		String endpoint = System.Label.URL_DOMAIN_BUS + '/rest/service/subscriptionUpdate/byQuoteNumber/date?date=' + this.dateChanged + '&quoteNumber=' + this.quote.Name;
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
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La souscription n\'est pas disponible dans Zuora, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.'));
	    	return null;
	    } else if (this.code == 200) {
	    	Date d = date.parse(this.dateChanged);
	    	this.quote.zqu__StartDate__c = d;
	    	update this.quote;
	    	if (this.quote.zqu__SoldToContact__c != null)
	    		emailSend();

	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'La date d\'activation des services a bien été modifiée au ' + this.dateChanged));
	    	return null;
	    }  else {
	    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Une erreur technique s\'est produite, réessayez dans 15 minutes. Si l\'erreur persiste contactez l\'équipe technique.'));
	    	return null;
	    }
	}

	public PageReference goBack() {
		return new PageReference('/'+this.quote.Id);
	}
	
	private void emailSend()
	{
		OrgWideEmailAddress oa;
		EmailTemplate et;

		for (EmailTemplate e : [SELECT Name, DeveloperName, Id FROM EmailTemplate WHERE DeveloperName = 'PRO_Proposition_date_modifiee']) {
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