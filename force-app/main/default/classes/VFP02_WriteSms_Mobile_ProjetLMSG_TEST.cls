@isTest 
private class VFP02_WriteSms_Mobile_ProjetLMSG_TEST {
 
    public static testMethod void validate_VFP02_WriteSms_Mobile_ProjetLMSG_Contrl() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonMobilePhone = '+33617512148');        
        insert account;
 
        Projet_LMSG__c Pj = new Projet_LMSG__c(Particulier__c = account.Id );
        insert Pj;
 
        string cid = account.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(account);                
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl cont = new VFP02_WriteSms_Mobile_ProjetLMSG_Contrl(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.inputData ipd = new VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.inputData();
        ipd.phoneNumber = '1234';
        ipd.textMessage = 'asdfg';
        ipd.templateId = '1234';
        ipd.ParticulierId = account.Id;
        ipd.ProjetId = Pj.Id;
 
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.retreiveTemplate(ipd);
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.submitData(ipd);        
    }  
 
    public static testMethod void validate_VFP02_WriteSms_Mobile_Contact_Controller1() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonMobilePhone = '+33617512148');        
        insert account;
 
        Projet_LMSG__c Pj = new Projet_LMSG__c(Particulier__c = account.Id );
        insert Pj;
 
        string cid = Pj.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(Pj);                
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl cont = new VFP02_WriteSms_Mobile_ProjetLMSG_Contrl(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.inputData ipd = new VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.inputData();
        ipd.phoneNumber = '1234';
        ipd.textMessage = 'asdfg';
        ipd.templateId = '1234';
        ipd.ParticulierId = account.Id;
        ipd.ProjetId = Pj.Id;
 
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.retreiveTemplate(ipd);
        VFP02_WriteSms_Mobile_ProjetLMSG_Contrl.submitData(ipd);        
    }      
 
}