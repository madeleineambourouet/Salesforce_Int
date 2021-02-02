trigger Generate_Offre_et_frais_de_souscription_Token on Zuora__SubscriptionProductCharge__c (before insert, before update) {
/* ------------ Generete Offre et frais de souscription token -------------------------- */
// BEFORE UPDATE
    if (Trigger.isUpdate && Trigger.isbefore)
    {
        for (Zuora__SubscriptionProductCharge__c uOffre : Trigger.new){
            if ( Trigger.oldMap.get(uOffre.id).Declenchement_Token_Assurance_manquante__c != Trigger.newMap.get(uOffre.id).Declenchement_Token_Assurance_manquante__c
                && uOffre.Declenchement_Token_Assurance_manquante__c == true) {
                    Account cpt = [SELECT id, login__c FROM Account WHERE id = :uOffre.Zuora__Account__c LIMIT 1];
                    String qUrl = AccountMethods.generateToken(cpt.login__c,120,5, 'Assurance manquante');
                    uOffre.Token_Offre_et_frais_de_souscription__c  = qUrl.substringAfter(Label.URL_web_pour_email); 
                   
                }
                
       }
}
}