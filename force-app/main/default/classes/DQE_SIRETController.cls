global class DQE_SIRETController 
{    
    public String error_SIRET {get;set;}
    public String error_message_SIRET {get;set;}    
    public String SIRETToCheck {get;set;}
    public Object sourceField {get;set;}
    
   // public VFC_Account_Details controller {get;set;}
    public Object controller {get;set;}
    public String  SIRETAPIName {get;set;}
    public String   fieldSiretLabel
    {
        get
        {
            if (objectType  == 'Account')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Account');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(SIRETAPIName).getDescribe().getLabel());
            } else if (objectType  == 'Lead')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(SIRETAPIName).getDescribe().getLabel());
            } else if (objectType  == 'Contact')
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Contact');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(SIRETAPIName).getDescribe().getLabel());
            }
            return ('');
        }
        set;
    }
    public String   objectType {get;set;}
    
    public DQE_SIRETController()
    {
        system.debug('>>>> constructor BEGIN');
        SIRETToCheck = '';
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
    public PageReference checkSIRETField()
    {
        system.debug('>>>> checkSIRETField BEGIN');
        
        system.debug('>>>>>>>>>><< SIRETToCheck: ' + SIRETToCheck);
        DQEHandler.DQEHandlerResult result = DQEHandler.validateSIRET(SIRETToCheck);
        
        if (result.success == true)
        {
            error_SIRET = 'true';
            error_message_SIRET = result.message;
            if (objectType == 'Account')
                ((VFC_Account_Edit)controller).acc.put(SIRETAPIName, SIRETToCheck);
            if (objectType == 'Contact')
                ((VFC_Contact_Edit)controller).ctc.put(SIRETAPIName, SIRETToCheck);
            if (objectType == 'Lead')
                ((VFC_Lead_Edit)controller).ld.put(SIRETAPIName, SIRETToCheck);
        }
        else
        {
            error_SIRET = 'false';
            //acc.Email__c.addError(result.message);
            error_message_SIRET = result.message;
        }
        
    system.debug('>>>> checkSIRETField END');
    return (null);        
    }
}