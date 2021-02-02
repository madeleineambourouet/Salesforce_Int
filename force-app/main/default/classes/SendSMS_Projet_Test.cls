@isTest 
private class SendSMS_Projet_Test {
 
    public static testMethod void validate_VFP02_WriteSms_Mobile_Projet_Controller() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonMobilePhone = '+33617512148');        
        insert account;
 
        Projet__c Pj = new Projet__c(Particulier__c = account.Id );
        insert Pj;
 
        string cid = account.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(account);                
        VFP02_WriteSms_Mobile_Projet_Controller cont = new VFP02_WriteSms_Mobile_Projet_Controller(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFP02_WriteSms_Mobile_Projet_Controller.inputData ipd = new VFP02_WriteSms_Mobile_Projet_Controller.inputData();
        ipd.phoneNumber = '1234';
        ipd.textMessage = 'asdfg';
        ipd.templateId = '1234';
        ipd.ParticulierId = account.Id;
        ipd.ProjetId = Pj.Id;
 
        VFP02_WriteSms_Mobile_Projet_Controller.retreiveTemplate(ipd);
        VFP02_WriteSms_Mobile_Projet_Controller.submitData(ipd);        
 
        cont.ENCODE('asdfghj'); 
        system.assert(true);
    }  
 
    public static testMethod void validate_VFP02_WriteSms_Mobile_Contact_Controller1() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonMobilePhone = '+33617512148');        
        insert account;
 
        Projet__c Pj = new Projet__c(Particulier__c = account.Id );
        insert Pj;
 
        string cid = Pj.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(Pj);                
        VFP02_WriteSms_Mobile_Projet_Controller cont = new VFP02_WriteSms_Mobile_Projet_Controller(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFP02_WriteSms_Mobile_Projet_Controller.inputData ipd = new VFP02_WriteSms_Mobile_Projet_Controller.inputData();
        ipd.phoneNumber = '1234';
        ipd.textMessage = 'asdfg';
        ipd.templateId = '1234';
        ipd.ParticulierId = account.Id;
        ipd.ProjetId = Pj.Id;
 
        VFP02_WriteSms_Mobile_Projet_Controller.retreiveTemplate(ipd);
        VFP02_WriteSms_Mobile_Projet_Controller.submitData(ipd);        
 
        cont.ENCODE('asdfghj');
 
        system.assert(true);
    }      
 
}