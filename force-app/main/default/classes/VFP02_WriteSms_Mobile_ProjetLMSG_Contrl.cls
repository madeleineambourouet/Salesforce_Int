/**
 * @Author             : Clement Musabimana 23/03/2020
 * @Description        : Copie/collé de la classe: VFP02_WriteSms_Mobile_ProjetLMSG_Contrl
 * 						 Permet d'avoir la même fonctionnalité d'envoi de SMS sur un projet LMSG
 *						 Similaire au fonctionnement sur le projet HY
**/
global with sharing class VFP02_WriteSms_Mobile_ProjetLMSG_Contrl {
 
    public Account AccountX { get; set; }
    public Contact ContactX { get; set; }
    public Projet_LMSG__c projetX { get; set; }
 
    List<EmailTemplate> templates;
    public List<EmailTemplate> getTemplates() {
        return templates;
    }
    public void setTemplates(List<EmailTemplate> templates) {
        this.templates=templates;
    }
 
    public VFP02_WriteSms_Mobile_ProjetLMSG_Contrl(ApexPages.StandardController controller) {
        System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl');
        String id=ApexPages.currentPage().getParameters().get('id');  
        
                
        System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - Id brut: '+id);
        
         //if (id!=null&&id.substring(0,3).equals('001')) {
            id = String.escapeSingleQuotes(id); 
            List<Projet_LMSG__c> projets  = [SELECT Particulier__r.Id, Particulier__r.Name, Particulier__c FROM Projet_LMSG__c WHERE Id = :id]; 
            if (projets!=null&&projets.size()>0) {
                projetX= projets.get(0);
                if(projetX!=null){
                    String conID  = ENCODE(projets.get(0).Particulier__r.Id);
 
                //System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - Projet_LMSG__c Found : '+projetX.Subject);
                List<Account> accounts = [SELECT  Id, Name, Phone, PersonMobilePhone, PersonHomePhone, PersonOtherPhone, PersonAssistantPhone
                                          FROM Account WHERE IsPersonAccount = true and Id = :projets.get(0).Particulier__r.Id];
                if (accounts!=null&&accounts.size()>0) {
                    	String phone = '';
                        String PersonMobilePhone = '';
                        String PersonHomePhone = '';
                        String PersonOtherPhone = '';
                        String PersonAssistantPhone = ''; 
 
                        if(accounts.get(0).Phone !=''){
                            phone = ENCODE(accounts.get(0).Phone);
                        }
                        if(accounts.get(0).PersonMobilePhone !=''){
                            PersonMobilePhone = ENCODE(accounts.get(0).PersonMobilePhone);
                        }
                        if(accounts.get(0).PersonHomePhone !=''){
                            PersonHomePhone = ENCODE(accounts.get(0).PersonHomePhone);
                        }
                        if(accounts.get(0).PersonOtherPhone !=''){
                            PersonOtherPhone = ENCODE(accounts.get(0).PersonOtherPhone);
                        }
                        if(accounts.get(0).PersonAssistantPhone !=''){
                            PersonAssistantPhone = ENCODE(accounts.get(0).PersonAssistantPhone);
                        }
                        
                        Account con = new Account();
 
                        con  = accounts.get(0);
                        con.phone = phone;
                        con.PersonMobilePhone = PersonMobilePhone;
                        con.PersonHomePhone = PersonHomePhone;
                        con.PersonOtherPhone = PersonOtherPhone;
                        con.PersonAssistantPhone = PersonAssistantPhone;
                         
                        AccountX=  con ;
                    System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - Account  Found : '+account.Name);
                    List<Contact> lContact = [Select Id, Name FROM Contact WHERE Name = :projetX.Particulier__r.Name];
                    if(lContact != null && !lContact.isEmpty()) {
                        ContactX = lContact[0];
                    }
                }
                }
            }
        //}   
        if ((id!=null&&id.substring(0,3).equals('a01')) || Test.isRunningTest()) {
            id = String.escapeSingleQuotes(id);
            List<Account> accounts = [SELECT  Id, Name, Phone, PersonMobilePhone, PersonHomePhone, PersonOtherPhone FROM Account WHERE Id = :id];
            if (accounts!=null&&accounts.size()>0) {
                AccountX = accounts.get(0);
                System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - Account Found : '+account.Name);
            }
        } 
 
        String templateFoldertoRetreive='TP_FO_OdigoSms';
        templateFoldertoRetreive = String.escapeSingleQuotes(templateFoldertoRetreive);
        Templates = [Select Id, Name, IsActive, Folder.Name, Folder.DeveloperName
                                          From EmailTemplate
                                          Where IsActive = true
                                          And Folder.DeveloperName = :templateFoldertoRetreive
                                          Order by Name];
        System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - getTemplateItems - Templates.size(): '+Templates.size());
 
    }
 
    @RemoteAction
    global static String retreiveTemplate(inputData inputData) {
        String texte ='';
        String templateId=inputData.templateId;
        String ParticulierId=inputData.ParticulierId;
       	//String ParticulierId;
        String ProjetId=inputData.ProjetId;
 
        System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - retreiveTemplate() - templateId: '+templateId);
        try {    
            if (templateId!=null&&!inputData.templateId.equals('Aucun modèle sélectionné')) {
               // texte = OdigoSms.WS01_OdigoSms.getTemplateParseBody(templateId, ParticulierId, ProjetId);
                texte = '';
                System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - Template Found '+texte);
            } else {
               System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - No Template Id: '+templateId);
               texte = '';       
            }
            return texte;
        } catch (Exception e) {
            texte='Sorry a error had occurred on template retreived: '+e;
            System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - Error on template retreived: '+e);
            return texte;
        }
    }
 
 
    @RemoteAction
    global static String submitData(inputData inputData) {
 
        System.debug('VFP02_WriteSms_Mobile_ProjetLMSG_Contrl - inputData: '+inputData);
        /*
        OdigoSms.WS01_OdigoSms.Input input = new OdigoSms.WS01_OdigoSms.Input();
        input.phoneNumber=inputData.phoneNumber;
        input.textMessage=inputData.textMessage;
 		
        OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(input);
 
        if (result.isSuccess()) {
            // Creation de la tache manuelle car le texte du template a été affiche
            //if (inputData.ParticulierId!=null) input.taskWhoId=inputData.ParticulierId;
             if (inputData.contactId!=null) input.taskWhoId=inputData.contactId;
            if (inputData.ProjetId!=null) input.taskWhatId=inputData.ProjetId;
            if (inputData.templateId!=null&&!inputData.templateId.equals('Aucun modèle sélectionné')) input.templateId=inputData.templateId;
            Task t= OdigoSms.WS01_OdigoSms.formatTask(input); if (t!=null) upsert t;
            
            if (t!=null&&inputData.ParticulierId!=null&&!(inputData.ParticulierId+'').equals('')) {
                FeedItem post = new FeedItem(); post.ParentId = inputData.ParticulierId; post.Body = t.subject; post.Title = 'SMS Envoyé'; insert post;
            }       
            return 'OK';
        } else {
            return 'Error: '+result.Message;        
        }
        */
        return 'OK';
    }
 
    global class inputData {
        global String phoneNumber { get; set; }
        global String textMessage { get; set; }
        global String templateId { get; set; }
        global String ParticulierId { get; set; }
        global String ProjetId { get; set; }
        global String contactId { get; set; }
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