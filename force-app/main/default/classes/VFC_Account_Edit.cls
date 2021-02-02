public class VFC_Account_Edit 
{
    
    public class FieldSetRecord
    {
        public String label {get;set;}
        public String apiName {get;set;}
        public List<Schema.FieldSetMember> lFieldMembers {get;set;}
        
        public FieldSetRecord(){}
        public FieldSetRecord(String apiName)
        {
            this.apiName = apiName;
            // get the fieldset information
            Schema.FieldSet fieldSetObj = SObjectType.Account.FieldSets.getMap().get(apiName);
            if (fieldSetObj != null)
            {
                this.lFieldMembers = fieldSetObj.getFields();
                this.label = fieldSetObj.getLabel();
            }
            else
            {
                this.lFieldMembers = null;
                this.label = '';
            }
        }
    }
    
    // Account
    public Account acc {get;set;}
    public List<FieldSetRecord> lFieldSetToDisplay  {get;set;}
    public Layout_Configuration__c layout           {get;set;}
    public String   lEmailFields                    {get;set;}
    public String   lPhoneFields                    {get;set;}
    public String   lSIRETFields                    {get;set;}
    public String   lAddressFields                  {get;set;}
    public String   lAddress1Fields                 {get;set;}
    public Map<String, String>  mAddress1Fields     {get;set;}
    public String   lAddress1FieldDisplayComponent  {get;set;}
    public String   lAddress2Fields                 {get;set;}
    public Map<String, String>  mAddress2Fields     {get;set;}
    public String   lAddress2FieldDisplayComponent  {get;set;}
    public String   lAddress3Fields                 {get;set;}
    public Map<String, String>  mAddress3Fields     {get;set;}
    public String   lAddress3FieldDisplayComponent  {get;set;}
    public String   mode {get;set;} // EDIT, CREATE
    
    public VFC_Account_Edit(ApexPages.StandardController controller)
    {
        List<Layout_Configuration__c> lLayout = null;
        
        // Get if it is a person account or a business account
        acc = (Account)controller.getRecord(); 
        if (acc != null && acc.Id != null)
        {
            acc = [SELECT Id, isPersonAccount FROM Account WHERE Id =: acc.Id];
            if (acc.isPersonAccount == true)
                lLayout= [SELECT Id, Name, Email_to_validate__c, Champs_telephone_a_valider__c, Champs_SIRET_a_valider__c,Fieldset_to_display__c, Champs_addresse_valider_1__c, Champs_addresse_valider_2__c, Champs_addresse_valider_3__c
                                                    FROM Layout_Configuration__c WHERE Name ='AccountP'];
            else
                lLayout= [SELECT Id, Name, Email_to_validate__c, Champs_telephone_a_valider__c, Champs_SIRET_a_valider__c,Fieldset_to_display__c, Champs_addresse_valider_1__c, Champs_addresse_valider_2__c, Champs_addresse_valider_3__c
                                                    FROM Layout_Configuration__c WHERE Name ='Account'];
        }

        // Get the fieldsets to display
        if (lLayout != null && lLayout.size() > 0)
        {
            lFieldSetToDisplay = new List<FieldSetRecord>();
            layout = lLayout[0];
            // Get the email fields to control
            lEmailFields = layout.Email_to_validate__c;
            lPhoneFields = layout.Champs_telephone_a_valider__c;
            lSIRETFields = layout.Champs_SIRET_a_valider__c;
            // Manage address 1
            lAddress1Fields = layout.Champs_addresse_valider_1__c;
            lAddress1FieldDisplayComponent = (lAddress1Fields != null ? lAddress1Fields.split(';')[1] : '');
            if (lAddress1Fields != null && lAddress1Fields != '')
            {
                mAddress1Fields = new Map<String, String>();
                for (String field : lAddress1Fields.split(';'))
                {
                    List<String> fieldSplit = field.split('=');
                    if (fieldSplit != null && fieldSplit.size() > 1)
                        mAddress1Fields.put(fieldSplit[0], fieldSplit[1]);
                }
            }
            // Manage address 2
            lAddress2Fields = layout.Champs_addresse_valider_2__c;
            lAddress2FieldDisplayComponent = (lAddress2Fields != null ? lAddress2Fields.split(';')[1] : '');
            if (lAddress2Fields != null && lAddress2Fields != '')
            {
                mAddress2Fields = new Map<String, String>();
                for (String field : lAddress2Fields.split(';'))
                {
                    List<String> fieldSplit = field.split('=');
                    if (fieldSplit != null && fieldSplit.size() > 1)
                        mAddress2Fields.put(fieldSplit[0], fieldSplit[1]);
                }
            }
            // Manage address 3
            lAddress3Fields = layout.Champs_addresse_valider_3__c;
            lAddress3FieldDisplayComponent = (lAddress3Fields != null ? lAddress3Fields.split(';')[1] : '');
            if (lAddress3Fields != null && lAddress3Fields != '')
            {
                mAddress3Fields = new Map<String, String>();
                for (String field : lAddress3Fields.split(';'))
                {
                    List<String> fieldSplit = field.split('=');
                    if (fieldSplit != null && fieldSplit.size() > 1)
                        mAddress3Fields.put(fieldSplit[0], fieldSplit[1]);
                }
            }
            lAddressFields = lAddress1Fields + ':' + lAddress2Fields + ':' + lAddress3Fields;
            // Get the fields from the fieldset
            List<String> lFieldsets = (layout.Fieldset_to_display__c != null ? layout.Fieldset_to_display__c.split(';') : null);
            if (lFieldsets != null && lFieldsets.size() > 0)
            {
                for (String fieldsetname : lFieldsets)
                {
                    FieldSetRecord record = new FieldSetRecord(fieldsetname);
                    lFieldSetToDisplay.add(record);
                }
            }
        }
        
        // Get the current account or initiate one
        acc = (Account)controller.getRecord(); 
        if (acc != null && acc.Id != null)
        {
            mode = 'EDIT';
            system.debug('>>>>>>>>>>>> getFieldsOnFieldSets(): ' + getFieldsOnFieldSets());
            String query = 'SELECT ' + getFieldsOnFieldSets() + ' FROM ACCOUNT WHERE Id = \'' + acc.Id + '\'';
            List<sObject> sobjList = Database.query(query);
            acc = (Account)sobjList[0];//[SELECT Id, Name, Email__c, Phone FROM Account WHERE Id =: acc.Id];
        }
        else
        {
            mode = 'CREATE';
            acc = new Account();
        }
    }
    
    public String getFieldsOnFieldSets()
    {
        String fields = '';
        for (FieldSetRecord record : lFieldSetToDisplay)
        {
            if (record.lFieldMembers != null)
            {
                for(Schema.FieldSetMember fieldSetMemberObj : record.lFieldMembers)
                {
                    if (!fields.contains(fieldSetMemberObj.getFieldPath()))
                    {
                        if (fields != '')
                            fields += ', ';
                        fields += fieldSetMemberObj.getFieldPath();
                    }
                }
            }
        }
        if (fields != '' && fields.contains('isPersonAccount') == false)
            fields += ', isPersonAccount';
        system.debug('>>>>>>> fields: ' + fields);
        return (fields);
    }

    /**
    public string error_email {get;set;}
    public String error_message_email {get;set;}
    public String emailField {get;set;}
    
    public PageReference checkMailField()
    {
        system.debug('>>>>>>>>>< emailField: ' + emailField);
        DQEHandler.DQEHandlerResult result = DQEHandler.validateEmail((String)acc.get(emailField));
        
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
        return (null);
    }
  **/
    public VFC_Account_Edit getPageCont()
    {
        return this;
    }
    
    
    public PageReference save()
    {
        try
        {
            if (acc.id != null)
                update acc;
            else
                insert acc;
        } catch (Exception e)
        {
            ApexPages.addMessages(e);
            return (null);
        }
        return (new PageReference('/' + acc.Id));
    }
    
    public PageReference cancel()
    {
        String urlreturn = '';
        if (acc.id != null)
            urlreturn = '/' + acc.Id;
        else
            urlreturn = '/';
        return (new PageReference(urlreturn));
    }
}