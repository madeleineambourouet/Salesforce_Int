global with sharing class VFC_SendEmail_leila {
    
    public Account AccountX { get; set; }
    public Contact ContactX { get; set; }
    public Projet__c projetX { get; set; }
    public string body { get; set;}
    List<SelectOption> templates;
    public String selectedvalue{get; set;}
    public String accountId { get; set; }
    public String projectId { get; set; }
    public String selecteduserId {get; set;}
    public String selectedOwaId {get; set;}
    public String EmailTemplateValue{get; set;}
    public String texte{get; set;}
    public String Subject{get; set;}
    public List<SelectOption> getTemplates() {
        return templates;
    }
    public void setTemplates(List<SelectOption> templates) {
        this.templates=templates;
    }
    
    public VFC_SendEmail_leila(ApexPages.StandardController controller) {
        
        String id=ApexPages.currentPage().getParameters().get('id');
        
        List<Projet__c> PrjList = [SELECT Name, Titre__c, Particulier__c, Particulier__r.Id, Particulier__r.Name, Particulier__r.PersonEmail FROM Projet__c WHERE Id = :id]; 
            if (PrjList!=null&&PrjList.size()>0) {
                projetX = PrjList.get(0);
                if(projetX!=null){
                    String conID  = PrjList.get(0).Particulier__r.Id;
 
                        Account accnt = new Account();
                        accnt.Id  = conID;
                        accnt.PersonEmail = projetX.Particulier__r.PersonEmail;
                        accnt.Name = projetX.Particulier__r.Name;
                        AccountX =  accnt ;
                    
                    ContactX = [Select Id, Name FROM Contact WHERE Name = :projetX.Particulier__r.Name];
                    
                }
            } 
      
        
        String templateFoldertoRetreive='Template_manuel';
        templateFoldertoRetreive = String.escapeSingleQuotes(templateFoldertoRetreive);
        templates = new List<SelectOption>(); 
        templates.add(New SelectOption('Aucun','Sélectionnez un modèle:'));
        for (EmailTemplate et : [Select Id, Name, Subject, Body,Markup,HtmlValue, IsActive, Folder.Name, Folder.DeveloperName From EmailTemplate Where IsActive = true And Folder.DeveloperName = :templateFoldertoRetreive Order by Name]) {
            templates.add(New SelectOption(et.Id,et.Name));
        }
    }
    
    public List<SelectOption> getListOfUser() {
               List<User> Users = [select id ,Username,name,IsActive from user];
            	
               List<SelectOption> UserOptionList = new List<SelectOption>();

               UserOptionList.add(new SelectOption( ' ' ,'---Sélectionner---'));
               for(User u : Users ) {
                          UserOptionList.add(new SelectOption(u.Id , u.Name));
               		}
               return UserOptionList ;
   			 } 
    
    public List<selectoption> getOrgWideEmailAddress(){
        List<SelectOption> lstEmailIds = new List<SelectOption>();

        // Use Organization Wide Address
       lstEmailIds.add(new SelectOption( ' ' ,'---Sélectionner---')); 
       for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
             lstEmailIds.add(new SelectOption(owa.id,owa.address));          
       }
       return lstEmailIds;
    }

    public void retreiveTemplate() {
        
        System.debug('selectedvalue ' + selectedvalue);
        List<EmailTemplate> temps = [Select Id, Name, Subject, Body, Markup,HtmlValue
                                         From EmailTemplate Where IsActive = true And Id = :selectedvalue];        
        if (temps.size()>0 && temps[0].Id!=null) {
            //bodies.add(templates[0].Body);
             List<String> bodies = new List<String>();
            bodies.add(temps[0].HtmlValue);
            List<Messaging.RenderEmailTemplateBodyResult> RenderResult = new List<Messaging.RenderEmailTemplateBodyResult>();
            RenderResult = Messaging.renderEmailTemplate(accountId, projectId, bodies);
            System.debug('>>>>> VFC_SendEmail_leila email body = ' + RenderResult); 
            EmailTemplateValue = RenderResult[0].getMergedBody(); 
            texte = temps[0].Subject;
           
        }
    }
    
    @RemoteAction
    global static String retreiveTemplate(inputData inputData) {
        String texte = '';  
        String templateId = inputData.templateId;
        String accountId = inputData.accountId;
        String projectId = inputData.projectId;
 
        System.debug('>>>>> VFC_SendEmail_leila - retreiveTemplate() - templateId: '+templateId);
        try {    
            if (templateId!=null && !inputData.templateId.equals('No template selected')) {
            List<String> bodies = new List<String>();
            List<EmailTemplate> templates = [Select Id, Name, Subject, Body, Markup,HtmlValue, Description
                                                    From EmailTemplate Where IsActive = true And Id = :templateId];
            if (templates.size()>0 && templates[0].Id!=null) {
                //bodies.add(templates[0].Body);
                bodies.add(templates[0].HtmlValue);
                List<Messaging.RenderEmailTemplateBodyResult> RenderResult = new List<Messaging.RenderEmailTemplateBodyResult>();
                RenderResult = Messaging.renderEmailTemplate(accountId, projectId, bodies);
                System.debug('>>>>> VFC_SendEmail_leila email body = ' + RenderResult); 
                texte = RenderResult[0].getMergedBody();  
                
            }} 
            else {
               System.debug('>>>>> VFC_SendEmail_leila - No Template Id: '+templateId);
               texte = '';   
                
            }
            return texte;
        } catch (Exception e) {
            texte='Sorry a error had occurred on template retreived: '+e;
            return texte;
        }
        return null;
    }
    
    
    @RemoteAction
    global static String retreiveSubject(inputData inputData) {
 
        String texte = '';
        String templateId = inputData.templateId;
        String accountId = inputData.accountId;
        String projectId = inputData.projectId;
 
        try {    
            if (templateId!=null && !inputData.templateId.equals('No template selected')) {
            List<EmailTemplate> templates = [Select Id, Name, Subject, Body, HtmlValue, Description
                                                    From EmailTemplate Where IsActive = true And Id = :templateId];
            if (templates[0].Id!=null && templates.size()>0) {
                texte = templates[0].Subject;       
            }} 
            else {
              texte = '';       
            }
            return texte;
        } catch (Exception e) {
            texte='Sorry a error had occurred on template retreived: '+e;
            return texte;
        }
        return null;
    }
    
      @RemoteAction
    global static String submitData(inputData inputData) {
 		System.debug('submitData begins');
        inputData input = new inputData();
        input.subject=inputData.subject;
        input.email=inputData.email;
        input.body=inputData.body;
        input.HtmlValue=inputData.HtmlValue;        
        input.projectId=inputData.projectId;
        input.accountId=inputData.accountId;
        input.templateId=inputData.templateId;
        input.plainTextBody=inputData.plainTextBody;
       
		        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                
        String[] toAddresses = input.email.split(':', 0);
        
        // Sets the paramaters of the email
        
      /*  email.setTemplateId(input.templateId);
        email.setSubject(input.subject);
        email.setToAddresses(toAddresses);
        email.setHtmlBody(input.body);
        //email.setHtmlBody(input.HtmlValue);
        email.setPlainTextBody(input.body);
        //email.setBccSender(false);
        email.setTargetObjectId(input.contactId);
        email.setSaveAsActivity(true);
       // email.setSenderDisplayName(input.FromAddressUser);
       //email.setSenderDisplayName(input.FromAddressOwa);*/
             
        // send e-mail if owa is selected or send e-mail if user is selected
        List<User> Us = [select id ,Username,name,IsActive from user];
        List<OrgWideEmailAddress> ORG = [select id, Address from OrgWideEmailAddress];
        
        if (Us.size()>0 && Us[0].Id!=null) {
			email.setTemplateId(input.templateId);
        	email.setSubject(input.subject);
        	email.setToAddresses(toAddresses);
        	email.setHtmlBody(input.body);      
        	email.setPlainTextBody(input.body);      
        	email.setTargetObjectId(input.contactId);
        	email.setSaveAsActivity(true);
            email.setSenderDisplayName(input.FromAddressUser);
            Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
			}
        return 'OK';

	 if (ORG.size()>0 && ORG[0].Id!=null) {
			email.setTemplateId(input.templateId);
        	email.setSubject(input.subject);
        	email.setToAddresses(toAddresses);
        	email.setHtmlBody(input.body);      
        	email.setPlainTextBody(input.body);      
        	email.setTargetObjectId(input.contactId);
       		email.setSaveAsActivity(true);
            email.setSenderDisplayName(input.FromAddressOwa);
            Messaging.SendEmailResult [] rst = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  			
        }          
        return 'OK';
               
        // Sends the email
       /* Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        System.debug('r[0].isSuccess() ' + r[0].isSuccess());
        // si ok alors create and insert post
        if (r[0].isSuccess()) {
            
            //create and insert post
            
            FeedItem post = new FeedItem();
            system.debug('input.body ' + input.body);
            post.Body =  input.body; //'<p><b>FeedItem</b> supports <i>rich text</i> but not @ mentions:</p> ';
            post.IsRichText  = true;
            post.ParentId = inputData.projectId;
            post.Title = 'send email';
            insert post;
            System.debug('new post ' + post);
            
            FeedItem post = new FeedItem();
            post.Body = inputData.HtmlValue;
            System.debug('inputData.HtmlValue ' + inputData.HtmlValue);
            //post.type = 'LinkPost'; 
            //post.ParentId = input.accountId;
            post.ParentId = inputData.projectId;
            System.debug('feeditem projet'+inputData.projectId);
            //post.Title = input.subject;
            post.Title = 'E-mail envoyé' ; //input.body
            System.debug('input.body ' + input.body);
            System.debug('input.subject ' + input.subject);
            post.isRichText = true;            
            Database.insert(post,false);
            System.debug('>>>>> VFC_SendEmail - post: '+post);

            // Creation de la tache 
            Task NewTask = new Task();
            //WhoId, OwnerId, Description, ActivityDate, Type, Motif
            //if (inputData.accountId!=null) NewTask.AccountId=inputData.accountId;
            if (inputData.projectId!=null) NewTask.WhatId=inputData.projectId;
            if (inputData.contactId!=null) NewTask.WhoId=inputData.contactId;
            if (inputData.subject!=null) NewTask.Subject=inputData.subject;
            //if (inputData.templateId!=null&&!inputData.templateId.equals('Aucun modèle sélectionné')) inputData.templateId=inputData.templateId;
            NewTask.Status = 'Achevée';
            //NewTask.Description = inputData.HtmlValue;
            insert NewTask; 
            return 'OK';
            
            // Création de l'email dans l'objet projet
            
            /*EmailMessage[] newEmail = new EmailMessage[0]; 
			newEmail.FromAddress = inputData.
            newEmail.FromName = inputData.
			newEmail.ToAddress = inputData.email;
			newEmail.Subject = inputData.subject;
			newEmail.TextBody = inputData.plainTextBody;
			newEmail.HtmlBody = inputData.body;
			newEmail.ParentId = inputData.projectId;   
 
			insert newEmail;      
           	return 'OK';*/
            
       /* } else {
            return 'Error: '+r[0].getErrors()[0].getMessage();        
        }    
 
            return 'OK';*/
    
    }
     global class inputData {
        global String subject { get; set; }
        global String plainTextBody { get; set; } 
        global String email { get; set; }
        global String body { get; set; }
        global String HtmlValue { get; set; }
        global String templateId { get; set; }
        global String accountId { get; set; }
        global String contactId { get; set; }
        global String projectId { get; set; }
        global String FromAddressUser { get; set; } 
        global String FromAddressOwa { get; set; }  
        
        
    }   

}