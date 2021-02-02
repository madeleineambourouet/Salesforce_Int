public class VFC_Contact_Edit 
{
    
    public class FieldSetRecordContact
    {
        public String label {get;set;}
        public String apiName {get;set;}
        public List<Schema.FieldSetMember> lFieldMembers {get;set;}
        
        public FieldSetRecordContact(){}
        public FieldSetRecordContact(String apiName)
        {
            this.apiName = apiName;
            // get the fieldset information
            Schema.FieldSet fieldSetObj = SObjectType.Contact.FieldSets.getMap().get(apiName);
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
    
    // Contact
    public Contact ctc {get;set;}
    public List<FieldSetRecordContact> lFieldSetToDisplay {get;set;}
    public Layout_Configuration__c layout {get;set;}
    public String   lEmailFields {get;set;}
    public String   lPhoneFields {get;set;}
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
    
    public VFC_Contact_Edit(ApexPages.StandardController controller)
    {
        // Get the fieldsets to display
        List<Layout_Configuration__c> lLayout = [SELECT Id, Name, Email_to_validate__c, Champs_telephone_a_valider__c, Fieldset_to_display__c, Champs_addresse_valider_1__c, Champs_addresse_valider_2__c, Champs_addresse_valider_3__c FROM Layout_Configuration__c WHERE Name ='Contact'];
        if (lLayout != null && lLayout.size() > 0)
        {
            lFieldSetToDisplay = new List<FieldSetRecordContact>();
            layout = lLayout[0];
            // Get the email fields to control
            lEmailFields = layout.Email_to_validate__c;
            lPhoneFields = layout.Champs_telephone_a_valider__c;
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
            system.debug('>>>>>>><< mAddress1Fields:' + mAddress1Fields);
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
                    FieldSetRecordContact record = new FieldSetRecordContact(fieldsetname);
                    lFieldSetToDisplay.add(record);
                }
            }
            System.debug('>>>> FIELD SETS = ' + lFieldsets);
        }
        
        // Get the current account or initiate one
        ctc = (Contact)controller.getRecord(); 
        if (ctc != null && ctc.Id != null)
        {
            mode = 'EDIT';
            String query = 'SELECT ' + getFieldsOnFieldSets() + ' FROM CONTACT WHERE Id = \'' + ctc.Id + '\'';
            System.debug('>>>> QUERY = ' + query);
            List<sObject> sobjList = Database.query(query);
            ctc = (Contact)sobjList[0];//[SELECT Id, Name, Email__c, Phone FROM Account WHERE Id =: acc.Id];
        }
        else
        {
            mode = 'CREATE';
            ctc = new Contact();
        }
    }
    
    public String getFieldsOnFieldSets()
    {
        String fields = '';
        for (FieldSetRecordContact record : lFieldSetToDisplay)
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
        system.debug('>>>>>>> fields: ' + fields);
        return (fields);
    }
    
    
    public string error_email {get;set;}
    public String error_message_email {get;set;}
    public String emailField {get;set;}
    public PageReference checkEmailField()
    {
        system.debug('>>>>>>>>>< emailField: ' + emailField);
        DQEHandler.DQEHandlerResult result = DQEHandler.validateEmail((String)ctc.get(emailField));
        
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
  
    public VFC_Contact_Edit getPageCont()
    {
        return this;
    }
    
    
    public PageReference save()
    {
        system.debug('>>>>>>>>>>>>>> my save');
        try
        {
            if (ctc.id != null)
                update ctc;
            else
                insert ctc;
        } catch (Exception e)
        {
            ApexPages.addMessages(e);
            return (null);
        }
        return (new PageReference('/' + ctc.Id));
    }
    
    public PageReference cancel()
    {
        String urlreturn = '';
        if (ctc.id != null)
            urlreturn = '/' + ctc.Id;
        else
            urlreturn = '/';
        return (new PageReference(urlreturn));
    }
}