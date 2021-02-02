public without sharing class GetInvoice {

	public Zuora__ZInvoice__c currentInvoice {get;set;}
	public Contact contactMail {get;set;}
	public Blob pdf {get;set;}
	public Integer code {get;set;}
	public String statut {get;set;}
	public String errorPdf {get;set;}

	public GetInvoice (ApexPages.StandardController std)
	{
		this.currentInvoice = [SELECT Id, Name, Zuora__Account__c,Zuora__GeneratedDate__c  FROM Zuora__ZInvoice__c WHERE Id = :std.getId() LIMIT 1];

		invoice('/rest/service/invoice/getInvoice/');
	}

	public void invoice(String logicPath)
	{
		String endpoint = System.Label.URL_DOMAIN_BUS + logicPath + this.currentInvoice.Name;
	    System.debug('Invoice retour WS endpoint '+endpoint);
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('GET');

		Blob headerValue = Blob.valueOf(System.Label.HY_BUS_INVOICE_USER + ':' + System.Label.HY_BUS_INVOICE_PASS);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	    System.debug('Invoice retour WS authorizationHeader '+authorizationHeader);
		req.setHeader('Authorization', authorizationHeader);

		Http http = new Http();
	    HTTPResponse res = http.send(req);
	    this.statut = res.getStatus();
	    this.code = res.getStatusCode();
	    this.pdf = res.getBodyAsBlob();
	    System.debug('Invoice retour WS this.statut '+this.statut);
	    System.debug('Invoice retour WS this.code '+this.code);
	    System.debug('Invoice retour WS res '+res);
	    
	}

	public PageReference saveInv()
	{
		List<Attachment> oldFact = [SELECT Id FROM Attachment WHERE ParentId = :this.currentInvoice.Id];
		
		if (oldFact.size() > 0)
			delete oldFact;

		if(this.code == 200) {
			Attachment a = new Attachment();
		    a.ParentId = this.currentInvoice.Id;
		    a.Name = this.currentInvoice.Name + '.pdf';
		    a.Body = this.pdf;
		    insert a;
		    
	    	return new PageReference('https://' + URL.getSalesforceBaseUrl().getHost() + '/servlet/servlet.FileDownload?file=' + a.Id);
	    } else if(this.code == 404) {
	    	this.errorPdf = System.Label.LABEL_ERREUR_404;
	    	return null;
	    } else {
	    	this.errorPdf = System.Label.LABEL_ERREUR_503;
	    	return null;
	    }
	}

	public PageReference emailToContact() {
		List<Attachment> oldFact = [SELECT Id, Body FROM Attachment WHERE ParentId = :this.currentInvoice.Id];
		List<Contact> cont = [SELECT Id, Name, Email FROM Contact WHERE AccountId = :this.currentInvoice.Zuora__Account__c AND Contact_de_facturation__c = true LIMIT 1];
		EmailTemplate et;
		OrgWideEmailAddress oa;
		
		for (EmailTemplate e : [SELECT Name, DeveloperName, Id FROM EmailTemplate WHERE DeveloperName = 'PRO_facture_en_PJ_Zuora']) {
			et = e;
		}

		for (OrgWideEmailAddress owea : [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%']) {
			oa = owea;
		}

		for (Contact c : cont) {
			this.contactMail = c;
		}

		Attachment a;
		Blob b;

		if (oldFact.size() == 0 && this.code == 200) {
			a = new Attachment();
		    a.ParentId = this.currentInvoice.Id;
		    a.Name = this.currentInvoice.Name + '.pdf';
		    a.Body = this.pdf;
		    insert a;

		}
		if (a != null) {
			b = a.Body;
		} else {
			for (Attachment att : oldFact) {
				b = att.Body;
			}

		}

		if (this.contactMail != null && contactMail.Email != null)
		{
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		    efa.setFileName(this.currentInvoice.Name + '.pdf');
		    efa.setBody(b);

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] {this.contactMail.Email});
			mail.setTargetObjectId(this.contactMail.Id);
			mail.setWhatId(this.currentInvoice.Id);
			mail.setTemplateId(et.Id);
			mail.setSaveAsActivity(false);
			mail.setOrgWideEmailAddressId(oa.Id);
			mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
			this.errorPdf = 'Le mail à bien été envoyé !\nVous pouvez fermer la page !';
		} else {
			this.errorPdf = 'Vérifiez le contact principal du contact !';
		}
		return null;
	}
}