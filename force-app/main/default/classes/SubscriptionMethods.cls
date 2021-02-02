// 28/07/2017, Modified by Qiuyan Liu, EB114, call Zuora to generate an invoice and cancel the new subscription is the current record is "post résiliation"
// 05/04/2018, Modified by Qiuyan Liu, limit DML, soql query, Apex CUP correction, on function ActivationServicesInsert and ActivationServicesUpdate
public class SubscriptionMethods 
{
    
    public static boolean isIntermediationSubscriptionActive(Id accId)
    {
        // Get the active subscription of the account in parameter
        List<Zuora__Subscription__c> lSubscriptions = [SELECT Id, Zuora__Status__c FROM Zuora__Subscription__c WHERE Zuora__Account__c =: accId AND Zuora__Status__c = 'Active'];
        
        // If the account does not have subscriptions active, return false
        if (lSubscriptions == null || (lSubscriptions != null && lSubscriptions.size() == 0))
            return (false);
        
        // Get the intermediation subscription charge of the subscriptions retrieved
        List<Zuora__SubscriptionProductCharge__c> lSubCharge = [SELECT Id, Zuora__Subscription__c, Zuora__RatePlanName__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c in: lSubscriptions AND Zuora__RatePlanName__c =: Label.OffreIntermediationRatePlanName];
        // If the list has one item, meens intermediation is in
        if (lSubCharge != null || lSubCharge.size() > 0)
            return (true);
        // Else it means no
        return (false);
    }
    
    
    
    //--------------------------- Activation services--------------------------
    
    public static void ActivationServicesInsert(List<Zuora__Subscription__c> lSubscription) {
        
        Map<Id, Zuora__Subscription__c> accIdSubsMap = new Map<Id, Zuora__Subscription__c>();

        for (Zuora__Subscription__c uSubscription : lSubscription) {     
            boolean IsFirstActivation =false;
            boolean IsAmendmentActivation = false;
            boolean IsCancellation= false;

            //check if is a first activation (use case : creating with status to Active and vesrion 1)
            if ( uSubscription.Zuora__Status__c == 'Active' && uSubscription.Zuora__Version__c == 1) {   
                //Activation of a new subscription
                IsFirstActivation = true;
            }

            //check if is a amendment activation
            if ( uSubscription.Zuora__Status__c == 'Active' &&  uSubscription.Zuora__Version__c >1 ) {   
                //activation of an existing subscription "Amendment" (use case : creating with Active status and version diffrent to 1)
                IsAmendmentActivation = true;  
            }
            
            if (IsFirstActivation  || IsAmendmentActivation || IsCancellation) {
                accIdSubsMap.put(uSubscription.Zuora__Account__c, uSubscription);                
            }
        }
        List<Token__c> tokens = new List<Token__c>();
        Map<Id, Account> accContacts = new Map<Id, Account>();
        if (accIdSubsMap.size() > 0) {
            accContacts = new Map<Id, Account>([SELECT id, login__c, (SELECT Id FROM Contacts WHERE Contact_Principal_O_N__c = true) FROM Account WHERE id in: accIdSubsMap.keyset()]);
            List<String> logins = new List<String>();
            for (Account acc : accContacts.values()) {
                logins.add(acc.login__c);
            }
            tokens = AccountMethods.generateToken(logins, 31,5, 'Subscription');
        }
        if (tokens.size() > 0) {
            Map<Id, Token__c> accIdTokensMap = new Map<Id, Token__c>();
            for (Token__c tok : tokens) {
                accIdTokensMap.put(tok.Compte__c, tok);
            }
            
            for (Zuora__Subscription__c uSubscription : lSubscription) {
                //store the token in a custom subscription field (to be used in the mail template )
                uSubscription.Last_generated_token__c = accIdTokensMap.get(uSubscription.Zuora__Account__c) != null ? accIdTokensMap.get(uSubscription.Zuora__Account__c).Name : null; 
                //store the current Sold to contact (contact principal) in the custom subscription field (to be used in the mail template )
                uSubscription.Contact_Principal__c = accContacts.get(uSubscription.Zuora__Account__c) != null && accContacts.get(uSubscription.Zuora__Account__c).Contacts.size() > 0? accContacts.get(uSubscription.Zuora__Account__c).Contacts[0].Id : null;  
            }
        }
    }

    public static void ActivationServicesUpdate(List<Zuora__Subscription__c> lSubscription, Map<ID, Zuora__Subscription__c> oldSubscriptionMap)
    {
        Map<Id, Zuora__Subscription__c> accIdSubsMap = new Map<Id, Zuora__Subscription__c>();
        for (Zuora__Subscription__c uSubscription : lSubscription)
        {     
            boolean IsFirstActivation =false;
            boolean IsAmendmentActivation = false;
            boolean IsCancellation= false;

            //check if is a first activation (use case : updating the status to Active with version 1)
            if ((oldSubscriptionMap.get(uSubscription.id).Zuora__Status__c != uSubscription.Zuora__Status__c)
                && (uSubscription.Zuora__Status__c == 'Active' && uSubscription.Zuora__Version__c == 1)) {   
                //Activation of a new subscription
                IsFirstActivation = true;
            }
            
            
            //check if is a amendment activation (use case : upgrading the version)
            if ((oldSubscriptionMap.get(uSubscription.id).Zuora__Status__c != uSubscription.Zuora__Status__c && uSubscription.Zuora__Status__c == 'Active') || (oldSubscriptionMap.get(uSubscription.id).Zuora__Version__c < uSubscription.Zuora__Version__c  && uSubscription.Zuora__Status__c == 'Active')){   
                //activation of an existing subscription "Amendment"
                IsAmendmentActivation = true;    
            }

            if (IsFirstActivation  || IsAmendmentActivation || IsCancellation) {
                accIdSubsMap.put(uSubscription.Zuora__Account__c, uSubscription);
            }
        }
        
        List<Token__c> tokens = new List<Token__c>();
        Map<Id, Account> accContacts = new Map<Id, Account>();
        if (accIdSubsMap.size() > 0) {
            accContacts = new Map<Id, Account>([SELECT id, login__c, (SELECT Id FROM Contacts WHERE Contact_Principal_O_N__c = true) FROM Account WHERE id in: accIdSubsMap.keyset()]);
            List<String> logins = new List<String>();
            for (Account acc : accContacts.values()) {
                if (acc.login__c != null) {
                    logins.add(acc.login__c);
                }
            }
            tokens = AccountMethods.generateToken(logins, 31,5, 'Subscription');
        }
        if (tokens.size() > 0) {
            Map<Id, Token__c> accIdTokensMap = new Map<Id, Token__c>();
            for (Token__c tok : tokens) {
                accIdTokensMap.put(tok.Compte__c, tok);
            }
            
            for (Zuora__Subscription__c uSubscription : lSubscription) {
                //store the token in a custom subscription field (to be used in the mail template )
                uSubscription.Last_generated_token__c = accIdTokensMap.get(uSubscription.Zuora__Account__c) != null ? accIdTokensMap.get(uSubscription.Zuora__Account__c).Name : null; 
                //store the current Sold to contact (contact principal) in the custom subscription field (to be used in the mail template )
                uSubscription.Contact_Principal__c = accContacts.get(uSubscription.Zuora__Account__c) != null && accContacts.get(uSubscription.Zuora__Account__c).Contacts.size() > 0? accContacts.get(uSubscription.Zuora__Account__c).Contacts[0].Id : null;  
            }
        }
        
        /*
         if (IsFirstActivation  || IsAmendmentActivation || IsCancellation) {
                
                List<Contact> SoldToContact = [SELECT Account.id, Account.login__c, Id FROM Contact WHERE (Contact_Principal_O_N__c = true AND Account.id = :uSubscription.Zuora__Account__c) LIMIT 1];
                
                if(SoldToContact.size()==1)
                {
                    // generate the token
                    String qUrl = AccountMethods.generateToken(SoldToContact[0].Account.login__c,31,5, 'Subscription');
                    //store the token in a custom subscription field (to be used in the mail template )
                    uSubscription.Last_generated_token__c = qUrl.substringAfter(Label.URL_web_pour_email); 
                    //store the current Sold to contact (contact principal) in the custom subscription field (to be used in the mail template )
                    uSubscription.Contact_Principal__c = SoldToContact[0].Id;  
                }
                
            }
		*/  
    }
}