global with sharing class VFC_SendEmail {

    public Account AccountX { get; set; }
    public Contact ContactX { get; set; }
    public Projet__c projetX { get; set; }
    public List<EmailTemplate> templates;
    
    public List<EmailTemplate> getTemplates(){
        
        String templateFoldertoRetreive='Template_manuel'; 
        templateFoldertoRetreive = String.escapeSingleQuotes(templateFoldertoRetreive);
        templates = [SELECT id,Name, body,Subject,Markup,HtmlValue, IsActive, Folder.Name, Folder.DeveloperName
              FROM EmailTemplate 
              WHERE IsActive = true And Folder.DeveloperName = :templateFoldertoRetreive Order by Name];
         //System.debug('et.HtmlValue ' + et.HtmlValue);
        return templates;
    }
    
    /*List<EmailTemplate> templates;
    public List<EmailTemplate> getTemplates() {        
        return templates;
    }*/
    
    public void setTemplates(List<EmailTemplate> templates) {
        this.templates=templates;
    }
 
    public VFC_SendEmail(ApexPages.StandardController controller) {
    
        System.debug('>>>>> VFC_SendEmail');
        String id=ApexPages.currentPage().getParameters().get('id');    
        System.debug('>>>>> VFC_SendEmail - Id brut: '+id);
        
            List<Projet__c> PrjList = [SELECT Name, Titre__c, Particulier__c, Particulier__r.Id, Particulier__r.Name, Particulier__r.PersonEmail FROM Projet__c WHERE Id = :id]; 
            if (PrjList!=null&&PrjList.size()>0) {
                projetX = PrjList.get(0);
                if(projetX!=null){
                    String conID  = ENCODE(PrjList.get(0).Particulier__r.Id);
 
                System.debug('>>>>> VFC_SendEmail - Project Found : '+projetX.Name);

                        Account accnt = new Account();
 
                        accnt.Id  = conID;
                        accnt.PersonEmail = projetX.Particulier__r.PersonEmail;
                        accnt.Name = projetX.Particulier__r.Name;
 
                        AccountX =  accnt ;
                    System.debug('>>>>> VFC_SendEmail - Account Found : '+AccountX.Name);
                    
                    ContactX = [Select Id, Name FROM Contact WHERE Name = :projetX.Particulier__r.Name];
                    
                }
            }   
 
        String templateFoldertoRetreive='Template_manuel';
        templateFoldertoRetreive = String.escapeSingleQuotes(templateFoldertoRetreive);
        templates = [Select Id, Name, Subject, Body,Markup,HtmlValue, IsActive, Folder.Name, Folder.DeveloperName
                        From EmailTemplate Where IsActive = true And Folder.DeveloperName = :templateFoldertoRetreive Order by Name];

        System.debug('>>>>> VFC_SendEmail - getTemplateItems - Templates.size(): '+Templates.size());
 
    }
 
    @RemoteAction
    global static String retreiveTemplate(inputData inputData) {
 
        String texte = '';        
        String templateId = inputData.templateId;
        String accountId = inputData.accountId;
        String projectId = inputData.projectId;
 
        System.debug('>>>>> VFC_SendEmail - retreiveTemplate() - templateId: '+templateId);
        try {    
            if (templateId!=null && !inputData.templateId.equals('No template selected')) {
            List<String> bodies = new List<String>();
            List<EmailTemplate> templates = [Select Id, Name, Subject, Body, Markup,HtmlValue
                                                    From EmailTemplate Where IsActive = true And Id = :templateId];
            if (templates[0].Id!=null && templates.size()>0) {
                bodies.add(templates[0].Body);
                List<Messaging.RenderEmailTemplateBodyResult> RenderResult = new List<Messaging.RenderEmailTemplateBodyResult>();
                RenderResult = Messaging.renderEmailTemplate(accountId, projectId, bodies);
                System.debug('>>>>> VFC_SendEmail email body = ' + RenderResult); 
                texte = RenderResult[0].getMergedBody();       
            }} 
            else {
               System.debug('>>>>> VFC_SendEmail - No Template Id: '+templateId);
               texte = '';       
            }
            return texte;
        } catch (Exception e) {
            texte='Sorry a error had occurred on template retreived: '+e;
            System.debug('>>>>> VFC_SendEmail - Error on template retreived: '+e);
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
 
        System.debug('>>>>> VFC_SendEmail - retreiveTemplate() - templateId: '+templateId);
        try {    
            if (templateId!=null && !inputData.templateId.equals('No template selected')) {
            List<EmailTemplate> templates = [Select Id, Name, Subject, Body
                                                    From EmailTemplate Where IsActive = true And Id = :templateId];
            if (templates[0].Id!=null && templates.size()>0) {
                texte = templates[0].Subject;       
            }} 
            else {
               System.debug('>>>>> VFC_SendEmail - No Template Id: '+templateId);
               texte = '';       
            }
            return texte;
        } catch (Exception e) {
            texte='Sorry a error had occurred on template retreived: '+e;
            System.debug('>>>>> VFC_SendEmail - Error on template retreived: '+e);
            return texte;
        }
        return null;
    }

    @RemoteAction
    global static String submitData(inputData inputData) {
 
        System.debug('>>>>> VFC_SendEmail - inputData: '+inputData);
 
        inputData input = new inputData();
        input.subject=inputData.subject;
        input.email=inputData.email;
        input.body=inputData.body;
        input.projectId=inputData.projectId;
        input.accountId=inputData.accountId;
        input.templateId=inputData.templateId;
       


        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = input.email.split(':', 0);
        
        // Sets the paramaters of the email
        email.setTemplateId(input.templateId);
        email.setSubject(input.subject);
        email.setToAddresses(toAddresses);
        email.setHtmlBody(input.body);
        //email.setBccSender(false);
        email.setTargetObjectId(inputData.contactId);
        email.setSaveAsActivity(true);
       

        //email.setOrgWideEmailAddressId(oa.Id);
        //System.debug('>>>>> VFC_SendEmail - email: '+email);
         
        // Sends the email
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        System.debug('>>>>> VFC_SendEmail - SendEmailResult: '+r);

        // si ok alors create and insert post
        if (r[0].isSuccess()) {
            FeedItem post = new FeedItem();
            post.Body = 'E-mail envoyé';
            //post.type = 'LinkPost'; 
            //post.ParentId = input.accountId;
            post.ParentId = input.projectId;
            //post.Title = input.subject;
            post.Title = 'E-mail envoyé' + input.body;
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
            insert NewTask;
            return 'OK';
           
        } else {
            return 'Error: '+r[0].getErrors()[0].getMessage();        
        }    
 
            return 'OK';
    }
 
    global class inputData {
        global String subject { get; set; }
        global String email { get; set; }
        global String body { get; set; }
        global String templateId { get; set; }
        global String accountId { get; set; }
        global String contactId { get; set; }
        global String projectId { get; set; }
        
    }
 
    public String ENCODE(String input) {
        String[] HTML_DECODED  = new String[]{ '&', '<', '>', '"', '\''};
        String[] HTML_ENCODED  = new String[]{ '&amp;', '&lt;', '&gt;', '&quot;', '&#39;' };
 
        if (input == null || input.length() == 0)
            return input;
 
        for (Integer i = 0; i < HTML_DECODED.size(); ++i) {
            input = input.replace(HTML_DECODED[i], HTML_ENCODED[i]);
        }
 
        return input;
    }
 
}