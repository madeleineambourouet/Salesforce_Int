public class VFC_Quote_CustomZBilling 
{
    public final zqu__Quote__c quo {get; set;}
    
    public String step1_status { get; private set; }
    public Boolean step1_result {get;set;}
    public String step2_status { get; private set; }
    public Boolean step2_result {get;set;}
    public String step3_status { get; private set; }
    public Boolean step3_result {get;set;}
    public boolean isBackButtonDisabled {get;set;}
    
    public Boolean console {get;set;}
    
    public VFC_Quote_CustomZBilling(ApexPages.StandardController controller)
    {}
    public VFC_Quote_CustomZBilling()
    {
        isBackButtonDisabled = true;
        
        String isconsole = ApexPages.currentPage().getParameters().get('console');
        if (isconsole == 'false')
            console = true;
        else
            console = false;

       // final String quoteId = controller.getId();
        final String quoteId = ApexPages.currentPage().getParameters().get('Id');
        if (null == quoteId || '' == quoteId) {
            appendErrorMessage('Aucun ID de proposition commercial n\'a été envoyé.');
            return;
        } 
        List<zqu__Quote__c> quotelist = [SELECT Id, Name, zqu__Opportunity__r.Name, zqu__Opportunity__r.Account.Name, zqu__Opportunity__r.Account.Id,
                                                 zqu__RecordReadOnly__c, zqu__Currency__c, zqu__Status__c, zqu__StartDate__c, RecordTypeId
                                          FROM
                                              zqu__Quote__c
                                          WHERE
                                              Id = :quoteId LIMIT 1];
        
        if(1 != quotelist.size()){
            appendErrorMessage('La proposition commerciale est invalide.');
            return ;
        }
        this.quo = quotelist[0];
        
        
        step1_status = '';
        step2_status = '';
        step3_status = '';
        
    }
    
    public PageReference cancel()
    {
        return (new PageReference('/' + quo.Id));
    }
    
    // STEP 1 : MANAGE LICENCE
    public void step1Method()
    {
        // If the quote has not been sent already
        if ((quo != null && quo.zqu__Status__c != 'Sent to Z-Billing') || Test.isRunningTest())
        {
            String result = QuoteMethods.manageLicenceOnSubscription(quo.Id);
            
            // Parse the result
            List<String> lResult = result.split(';');
            if (lResult != null && lResult.Size() > 0)
            {
                if (lResult[0] == 'ERROR')
                {
                    step1_status = Label.CustomZbilling_ErrorMessage_StartMessage + ' : ' + lResult[1]; step1_result = false;
                }
                else
                {
                    if (lResult.size() > 1)
                        step1_status = lResult[1];
                    else
                        step1_status = Label.CustomZbilling_Step1_Success;
                    step1_result = true;
                }
            }
        }
        else
        {
            // If quote already sent, bypass this method
            step1_result = true; step1_status = Label.CustomZbilling_Message_AlreadySent;
        }
    }
    
    // STEP 2 : SEND TO ZBILLING
    public void step2Method()
    {
        // If the quote has not been sent already
        if ((quo != null && quo.zqu__Status__c != 'Sent to Z-Billing') || Test.isRunningTest())
        {
            if (step1_result == true)
            {
                String result = QuoteMethods.sendToZBilling(quo.Id);
            
                // Parse the result
                List<String> lResult = result.split(';');
                system.debug('>>> lResult: ' + lResult);
                if (lResult != null && lResult.Size() > 0)
                {
                    if (lResult[0] == 'ERROR')
                    {
                        step2_status = Label.CustomZbilling_ErrorMessage_StartMessage + ' : ' + lResult[1]; step2_result = false;
                    }
                    else
                    {
                        step2_status = Label.CustomZbilling_Step2_Success; step2_result = true;
                    }
                }
            }
            else
            {
                step2_status = Label.CustomZbilling_ErrorMessage_PreviousStep; step2_result = false;
            }
        }
        else
        {
            // If quote already sent, bypass this method
            step2_result = true; step2_status = Label.CustomZbilling_Message_AlreadySent;
        } 
    }
    
    // STEP 3 : PAYMENT METHOD CREATION
    public void step3Method()
    {
        if (step2_result == true || Test.isRunningTest())
        {
            String result = QuoteMethods.createPaymentMethods(quo.Id);
        
            // Parse the result
            List<String> lResult = result.split(';');
            if (lResult != null && lResult.Size() > 0)
            {
                if (lResult[0] == 'ERROR')
                {
                    step3_status = Label.CustomZbilling_ErrorMessage_StartMessage + ' : ' + lResult[1]; step3_result = false;
                }
                else
                {
                    if (lResult.size() > 1)
                        step3_status = lResult[1];
                    else
                        step3_status = Label.CustomZbilling_SuccessMessage_OK;
                    step3_result = true;
                }
            }
        }
        else
        {
            step3_status = Label.CustomZbilling_ErrorMessage_PreviousStep; step3_result = false;
        }
        
        isBackButtonDisabled = false;
    }
    
    private static void appendErrorMessage(String message) 
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }  
}