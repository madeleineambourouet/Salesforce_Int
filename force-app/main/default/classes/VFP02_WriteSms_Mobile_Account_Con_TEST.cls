@isTest 
public class VFP02_WriteSms_Mobile_Account_Con_TEST {

    public static testMethod void validate_VFP02_WriteSms_Mobile_Account_Controller() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonMobilePhone = '+33617512148');        
        insert account;

        string cid = account.id;
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController ssc = new ApexPages.StandardController(account);                
        VFP02_WriteSms_Mobile_Account_Controller cont = new VFP02_WriteSms_Mobile_Account_Controller(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFP02_WriteSms_Mobile_Account_Controller.inputData ipd = new VFP02_WriteSms_Mobile_Account_Controller.inputData();
        ipd.phoneNumber = '1234';
        ipd.textMessage = 'asdfg';
        ipd.templateId = '1234';
        ipd.ParticulierId = account.Id;
 
        VFP02_WriteSms_Mobile_Account_Controller.retreiveTemplate(ipd);
        VFP02_WriteSms_Mobile_Account_Controller.submitData(ipd);   
    }  
 
    public static testMethod void validate_VFP02_WriteSms_Mobile_Account_Controller1() {
        Account account = new Account(firstName = 'Leila', lastName = 'BOUAIFEL', PersonMobilePhone = '+33617512148');        
        insert account;

        ApexPages.currentPage().getParameters().put('id',account.id);
        ApexPages.StandardController ssc = new ApexPages.StandardController(account);                
        VFP02_WriteSms_Mobile_Account_Controller cont = new VFP02_WriteSms_Mobile_Account_Controller(ssc); 
 
        List<EmailTemplate> etLst = cont.getTemplates();
        cont.setTemplates(etLst);     
 
        VFP02_WriteSms_Mobile_Account_Controller.inputData ipd = new VFP02_WriteSms_Mobile_Account_Controller.inputData();
        ipd.phoneNumber = '1234';
        ipd.textMessage = 'asdfg';
        ipd.templateId = '1234';
        ipd.ParticulierId = account.Id;
 
        VFP02_WriteSms_Mobile_Account_Controller.retreiveTemplate(ipd);
        VFP02_WriteSms_Mobile_Account_Controller.submitData(ipd);        

    }   
}