//This class is tested with LeadManagementTrigger in Test_LeadManagement.apxc
global class SearchDuplicates {
    
    public static void search(List<Lead> newLeads) { 
        
        List<String> lSIRET = new List<String>();
        List<String> lName = new List<String>();
        List<String> lEmail = new List<String>();
        List<String> lPhone = new List<String>();
        List<String> lMobilePhone = new List<String>();
        for (Lead piste : newLeads){
            if (piste.SIRET__c != null && piste.SIRET__c != '') { lSIRET.add(piste.SIRET__c); }
            if (piste.Company != null && piste.Company != '') { lName.add(piste.Company); }
            if (piste.Email != null && piste.Email != '') { lEmail.add(piste.Email); }
            if (piste.Phone != null && piste.Phone != '') { lPhone.add(piste.Phone); }
            if (piste.MobilePhone != null && piste.MobilePhone != '') { lMobilePhone.add(piste.MobilePhone); }
        }
    
        System.debug('Framboise lSIRET : ' + lSIRET);
        List<Account> lSimilarAccount = [SELECT id, Name, SIRET_texte__c, Contact_principal__r.Email, Contact_principal__r.Phone, Contact_principal__r.MobilePhone FROM Account WHERE Name IN :lName OR SIRET_texte__c IN :lSIRET OR Contact_principal__r.Email IN :lEmail OR Contact_principal__r.Phone IN :lPhone OR Contact_principal__r.MobilePhone IN :lMobilePhone];
        System.debug('Framboise lSimilarAccount : ' + lSimilarAccount);
        
        Map<Lead, List<Account>> leadAccounts = new Map<Lead, List<Account>>();
        for (Lead piste : newLeads){
            List<Account> accounts = new List<Account>();
            for (Account acc : lSimilarAccount){
                if (acc.SIRET_texte__c != null && acc.SIRET_texte__c.equals(piste.SIRET__c))  {
                    System.debug('Framboise Doublon SIRET id = ' + acc.id);
                    piste.Type_de_doublon__c = 'SIRET';
                    piste.Doublon__c = acc.id;
                    accounts.add(acc); 
                }
                //test si au moins 2 des champs sont égaux parmi : adresse mail, téléphone, téléphone mobile, nom de la société (sauf tel + tel mobile)
                else if (piste.Email!=null && piste.Email.equals(acc.Contact_principal__r.Email) && (piste.Phone==null || acc.Contact_principal__r.Phone==null || piste.Phone.equals(acc.Contact_principal__r.Phone))) {
                    piste.Type_de_doublon__c = 'Email&Tel';
                    piste.Doublon__c = acc.id;
                    accounts.add(acc); 
                }
                else if (piste.Email!=null && piste.Email.equals(acc.Contact_principal__r.Email) && (piste.MobilePhone==null || acc.Contact_principal__r.MobilePhone==null || piste.MobilePhone.equals(acc.Contact_principal__r.MobilePhone))) {
                    piste.Type_de_doublon__c = 'Email&Mobile';
                    piste.Doublon__c = acc.id;
                    accounts.add(acc); 
                }
                else if (piste.Company!=null && piste.Company.equals(acc.Name) && (piste.Phone==null || acc.Contact_principal__r.Phone==null || piste.Phone.equals(acc.Contact_principal__r.Phone))) {
                    piste.Type_de_doublon__c = 'Société&Tel';
                    piste.Doublon__c = acc.id;
                    accounts.add(acc); 
                }
                else if (piste.Company!=null && piste.Company.equals(acc.Name) && (piste.MobilePhone==null || acc.Contact_principal__r.MobilePhone==null || piste.MobilePhone.equals(acc.Contact_principal__r.MobilePhone))) {
                    piste.Type_de_doublon__c = 'Société&Mobile';
                    piste.Doublon__c = acc.id;
                    accounts.add(acc); 
                }
                else if (piste.Email!=null && piste.Company!=null && piste.Email.equals(acc.Contact_principal__r.Email) && piste.Company.equals(acc.Name)) {
                    piste.Type_de_doublon__c = 'Email&Société';
                    piste.Doublon__c = acc.id;
                    accounts.add(acc); 
                }
            }
            leadAccounts.put(piste, accounts);
        }
    
        for (Lead piste : newLeads){
            piste.Nombre_de_comptes_existants__c = leadAccounts.get(piste).size();
            if (piste.Nombre_de_comptes_existants__c == 0)
                piste.Doublon__c = null;
        }
        
       // AccountMethods.setListeEnseignes(null, Trigger.new, true);

    }
    
}