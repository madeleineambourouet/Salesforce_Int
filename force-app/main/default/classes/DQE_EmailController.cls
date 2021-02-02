global class DQE_EmailController 
{    
    public String error_email {get;set;}
    public String error_message_email {get;set;}    
    public String emailToCheck {get;set;}
    public Object sourceField {get;set;}
    
   // public VFC_Account_Details controller {get;set;}
    public Object controller {get;set;}
    public String  emailAPIName {get;set;}
    public String   fieldEmailLabel
    {
        get
        {
            if (objectType  == 'Account')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Account');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(emailAPIName).getDescribe().getLabel());
            }
            else if (objectType == 'Lead')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(emailAPIName).getDescribe().getLabel());
            }
            else if (objectType == 'Contact')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Contact');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(emailAPIName).getDescribe().getLabel());
            }
            return ('');
        }
        set;
    }
    public String   objectType {get;set;}
    
    public DQE_EmailController()
    {
        system.debug('>>>> constructor BEGIN');
        emailToCheck = '';
        system.debug('>>>>>><< sourceField: ' + sourceField);
        system.debug('>>>> constructor END');
    }
    
    /**
    @RemoteAction
    public static EmailResult checkEmailField(String email)
    {
        DQEHandler.DQEHandlerResult result = DQEHandler.validateEmail(email);
        
        if (result.success == true)
        {
            error_email = 'true';
            error_message_email = result.message;
        }
        else
        {
            error_email = 'false';
            //acc.Email__c.addError(result.message);
            error_message_email = result.message;
        }
        
        return (res);
    }
    **/
    public PageReference checkEmailField()
    {
        system.debug('>>>> checkEmailField BEGIN');
        
        system.debug('>>>>>>>>>><< emailToCheck: ' + emailToCheck);
        DQEHandler.DQEHandlerResult result = DQEHandler.validateEmail(emailToCheck);
        
        if (result.success == true)
        {
            error_email = 'true';
            error_message_email = result.message;
            if (objectType == 'Account')
                ((VFC_Account_Edit)controller).acc.put(emailAPIName, emailToCheck);
            if (objectType == 'Contact')
                ((VFC_Contact_Edit)controller).ctc.put(emailAPIName, emailToCheck);
            if (objectType == 'Lead')
                ((VFC_Lead_Edit)controller).ld.put(emailAPIName, emailToCheck);
        }
        else
        {
            error_email = 'false';
            //acc.Email__c.addError(result.message);
            error_message_email = result.message;
        }
        
    system.debug('>>>> checkEmailField END');
    return (null);        
    }
}