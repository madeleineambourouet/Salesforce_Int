/**
 * @Author             : Clement Musabimana 23/03/2020
 * @Description        : Copie/collé de la classe: VFP02_WriteSms_Mobile_Projet_Controller
 *                       Permet d'avoir la même fonctionnalité d'envoi de SMS sur un compte particulier
 *                       Similaire au fonctionnement sur le projet
**/
global with sharing class VFP02_WriteSms_Mobile_Account_Controller {
 
    public Account AccountX { get; set; }
 
    List<EmailTemplate> templates;
    public List<EmailTemplate> getTemplates() {
        return templates;
    }
    public void setTemplates(List<EmailTemplate> templates) {
        this.templates=templates;
    }
 
    public VFP02_WriteSms_Mobile_Account_Controller(ApexPages.StandardController controller) {
        System.debug('VFP02_WriteSms_Mobile_Account_Controller');
        String id=ApexPages.currentPage().getParameters().get('id');  
        
                
        System.debug('VFP02_WriteSms_Mobile_Account_Controller - Id brut: '+id);
        
         //if (id!=null&&id.substring(0,3).equals('001')) {
        id = String.escapeSingleQuotes(id); 
        List<Account> accounts = [SELECT  Id, Name, Phone, PersonMobilePhone, PersonHomePhone, PersonOtherPhone, PersonAssistantPhone FROM Account WHERE IsPersonAccount = true and Id = :id];
        if (accounts!=null&&accounts.size()>0) {
            String phone = '';
            String PersonMobilePhone = '';
            String PersonHomePhone = '';
            String PersonOtherPhone = '';
                                 

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
             
            Account con = new Account();

            con  = accounts.get(0);
            con.phone = phone;
            con.PersonMobilePhone = PersonMobilePhone;
            con.PersonHomePhone = PersonHomePhone;
            con.PersonOtherPhone = PersonOtherPhone;
             
            AccountX=  con ;
            System.debug('VFP02_WriteSms_Mobile_Account_Controller - Account  Found : '+account.Name);
            
        } 
 
        String templateFoldertoRetreive='TP_FO_OdigoSms';
        templateFoldertoRetreive = String.escapeSingleQuotes(templateFoldertoRetreive);
        Templates = [Select Id, Name, IsActive, Folder.Name, Folder.DeveloperName
                                          From EmailTemplate
                                          Where IsActive = true
                                          And Folder.DeveloperName = :templateFoldertoRetreive
                                          Order by Name];
        System.debug('VFP02_WriteSms_Mobile_Account_Controller - getTemplateItems - Templates.size(): '+Templates.size());
 
    }
 
    @RemoteAction
    global static String retreiveTemplate(inputData inputData) {
        String texte ='';
        String templateId=inputData.templateId;
        String ParticulierId=inputData.ParticulierId;
        //String ParticulierId;
        String ProjetId='';
 
        System.debug('VFP02_WriteSms_Mobile_Account_Controller - retreiveTemplate() - templateId: '+templateId);
        try {    
            if (templateId!=null&&!inputData.templateId.equals('Aucun modèle sélectionné')) {
                //texte = OdigoSms.WS01_OdigoSms.getTemplateParseBody(templateId, ParticulierId, ProjetId);
                texte = '';
                System.debug('VFP02_WriteSms_Mobile_Account_Controller - Template Found '+texte);
            } else {
               System.debug('VFP02_WriteSms_Mobile_Account_Controller - No Template Id: '+templateId);
               texte = '';       
            }
            return texte;
        } catch (Exception e) {
            texte='Sorry a error had occurred on template retreived: '+e;
            System.debug('VFP02_WriteSms_Mobile_Account_Controller - Error on template retreived: '+e);
            return texte;
        }
    }
 
 
    @RemoteAction
    global static String submitData(inputData inputData) {
 
        System.debug('VFP02_WriteSms_Mobile_Account_Controller - inputData: '+inputData);
        /*
        OdigoSms.WS01_OdigoSms.Input input = new OdigoSms.WS01_OdigoSms.Input();
        input.phoneNumber=inputData.phoneNumber;
        input.textMessage=inputData.textMessage;
        
        OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(input);
 
        if (result.isSuccess()) {
            if (inputData.templateId!=null&&!inputData.templateId.equals('No template selected')) input.templateId=inputData.templateId;
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