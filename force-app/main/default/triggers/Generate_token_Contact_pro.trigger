trigger Generate_token_Contact_pro on Contact (before insert,before update) 
 {
   /* ------------ Generete Token Contact Pro  -------------------------- */
    
   /* ------------ Check recursion -------------------------- */ 
   if(checkRecursiveSFDC.runOnce())
    {
         /* ------------ IsUpdate condition -------------------------- */ 
        if (Trigger.isUpdate && Trigger.isbefore)
        {  
            for (Contact TContact : Trigger.new)
             {
                 if (Trigger.oldMap.get(TContact.id).Check_Token_Oneshot__c != Trigger.newMap.get(TContact.id).Check_Token_Oneshot__c && TContact.Check_Token_Oneshot__c == true) 
                   {
                                               
                       /* ------------ Find the Account Value -------------------------- */
                       Account cpt = [SELECT id, Login__c FROM Account WHERE id =: TContact.AccountId LIMIT 1];
                       
                       /* ------------Generate the token -------------------------- */
                       String qUrl = AccountMethods.generateToken(cpt.Login__c,31,5, 'Campagne Oneshot');
                       
                       /* ------------Assign the Varaiable -------------------------- */
                       TContact.Token_campagne_oneshot__c = qUrl.substringAfter(Label.URL_web_pour_email);  
                    }
                 }        
           }
        }
}