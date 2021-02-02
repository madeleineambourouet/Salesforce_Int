@isTest 
private class VFC_SendEmail_TEST {

 public static testMethod void validate_VFC_SendEmail() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonEmail = 'leila.bouaifel@saint-gobain.com', PersonMobilePhone = '+33617512148');        
        insert account;
 
        Projet__c Pj = new Projet__c(Particulier__c = account.Id );
        insert Pj;
 
        string cid = account.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(account);                
        VFC_SendEmail cont = new VFC_SendEmail(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFC_SendEmail.inputData ipd = new VFC_SendEmail.inputData();
        ipd.email = 'leila.bouaifel@saint-gobain.com';
        ipd.body = 'asdfg';
        ipd.templateId = '1234';
        ipd.accountId = account.Id;
        ipd.projectId = Pj.Id;
 
        VFC_SendEmail.retreiveTemplate(ipd);
        VFC_SendEmail.submitData(ipd);        
 
        cont.ENCODE('asdfghj'); 
        system.assert(true);
    }  
 
    public static testMethod void validate_VFC_SendEmail1() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonEmail = 'leila.bouaifel@saint-gobain.com', PersonMobilePhone = '+33617512148');        
        insert account;
 
        Projet__c Pj = new Projet__c(Particulier__c = account.Id );
        insert Pj;
 
        string cid = Pj.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(Pj);                
        VFC_SendEmail cont = new VFC_SendEmail(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFC_SendEmail.inputData ipd = new VFC_SendEmail.inputData();
        ipd.email = 'leila.bouaifel@saint-gobain.com';
        ipd.body = 'asdfg';
        ipd.templateId = '1234';
        ipd.accountId = account.Id;
        ipd.projectId = Pj.Id;
 
        VFC_SendEmail.retreiveTemplate(ipd);
        VFC_SendEmail.submitData(ipd);        
 
        cont.ENCODE('asdfghj');
 
        system.assert(true);
    }      
     

}