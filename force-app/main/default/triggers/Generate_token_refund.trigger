trigger Generate_token_refund on Zuora__Refund__c (before insert, before update, after insert) {

/* ------------ récupérer la liste des id comptes pro -------------------------- */
    if (Trigger.isBefore && Trigger.isInsert) {
        Set<Id> accIdSet = new Set<Id>();
        for (Zuora__Refund__c zRe: Trigger.new) {
            accIdSet.add(zRe.Zuora__Account__c);
        }
/* ------------ récupérer la liste le login du compte pro -------------------------- */
        
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, login__c FROM Account WHERE Id in:accIdSet]);
        
        for (Zuora__Refund__c ZRefund : Trigger.new){
            System.debug('ZRefund.Zuora__Account__c' + ZRefund.Zuora__Account__c);
            ZRefund.Login_du_contact_principal__c =  accMap.get(ZRefund.Zuora__Account__c).login__c;
           // ZRefund.Declenchement_Token__c = true; 
        }
   
    }
    
     
/* ------------ Generete refund token -------------------------- */
// BEFORE UPDATE
    if (Trigger.isUpdate && Trigger.isbefore)
    {
        for (Zuora__Refund__c ZRefund : Trigger.new){
            if (Trigger.oldMap.get(ZRefund.id).Declenchement_Token__c != Trigger.newMap.get(ZRefund.id).Declenchement_Token__c
                && ZRefund.Declenchement_Token__c == true) {
                    Account cpt = [SELECT id, login__c FROM Account WHERE id = :ZRefund.Zuora__Account__c LIMIT 1];
                    String qUrl = AccountMethods.generateToken(cpt.login__c,31,5, 'Annulation');
                    ZRefund.Token__c = qUrl.substringAfter(Label.URL_web_pour_email); 
                }
                
       }
}

    
}