global class DQE_PhoneController 
{    
    public String error_phone {get;set;}
    public String error_message_phone {get;set;}    
    public String phoneToCheck {get;set;}
    public String pays {get;set;}
    public Object sourceField {get;set;}
    
   // public VFC_Account_Details controller {get;set;}
    public Object controller {get;set;}
    public String  phoneAPIName {get;set;}
    public String   fieldPhoneLabel
    {
        get
        {
            if (objectType  == 'Account')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Account');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(phoneAPIName).getDescribe().getLabel());
            } else if (objectType  == 'Lead')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(phoneAPIName).getDescribe().getLabel());
            } else if (objectType  == 'Contact')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Contact');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(phoneAPIName).getDescribe().getLabel());
            }
            return ('');
        }
        set;
    }
    public String   objectType {get;set;}
    
    public DQE_PhoneController()
    {
        system.debug('>>>> constructor BEGIN');
        phoneToCheck = '';
        pays = 'FRA';
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
    public PageReference checkPhoneField()
    {
        system.debug('>>>> checkPhoneField BEGIN COMPOSANT');
        
        system.debug('>>>>>>>>>><< phoneToCheck: ' + phoneToCheck);
        DQEHandler.DQEHandlerResult result = DQEHandler.validatePhone(phoneToCheck, pays);
        system.debug('>>>>>> result ctrl:' + result);
        error_message_phone = 'test';
        if (result.success == true)
        {
            error_phone = 'true';
            error_message_phone = result.message;
            if (objectType == 'Account')
                ((VFC_Account_Edit)controller).acc.put(phoneAPIName, phoneToCheck);
            if (objectType == 'Contact')
                ((VFC_Contact_Edit)controller).ctc.put(phoneAPIName, phoneToCheck);
            if (objectType == 'Lead')
                ((VFC_Lead_Edit)controller).ld.put(phoneAPIName, phoneToCheck);
                system.debug('>>>>> error_message_phone true :' + error_message_phone );
        }
        else
        {
            error_phone = 'false';
            //acc.Email__c.addError(result.message);
            error_message_phone = result.message;
            system.debug('>>>>> error_message_phone false:' + error_message_phone );
        }
        
    system.debug('>>>> checkPhoneField END COMPOSANT');
    return (null);        
    }
}