trigger Generate_token_project on Projet__c (before insert, before update)  {
/* ------------ Generete project token -------------------------- */
// BEFORE UPDATE
    if (Trigger.isUpdate && Trigger.isbefore)
    {
        for (Projet__c uProjet : Trigger.new){
            if (Trigger.oldMap.get(uProjet.id).Is_selected__c != Trigger.newMap.get(uProjet.id).Is_selected__c
                && uProjet.Is_selected__c == true) {
                    Account cpt = [SELECT id, login__c FROM Account WHERE id = :uProjet.Particulier__c LIMIT 1];
                    String qUrl = AccountMethods.generateToken(cpt.login__c,31,5, 'Projet');
                    uProjet.Token_Projet__c = qUrl.substringAfter(Label.URL_web_pour_email); 
                    //uProjet.Is_selected__c = false;
                }
                
       }
}
}