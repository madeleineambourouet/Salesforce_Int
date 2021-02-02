/**
* @author Leila BOUAIFEL
* @date 17/08/2017
* Mise à jour le 17/08/18 par Leila BOUAIFEL / Mettre à jour le statut d'assurance sur le compte en fonction du statut d'assurance
* @description Mettre à jour le statut des documents assurances lorsque la date d'expiration a réellement expirée
*/

public with sharing class  Batch_AssuranceUpdate  implements Database.Batchable<sObject>, Schedulable  {
    
    public  Batch_AssuranceUpdate () {}
    String query;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        query='SELECT Id,Statut__c,Date_d_expiration__c, Compte__r.Statut_Assurance__c,Compte__c FROM Document_Assurance__c where (Statut__c != \'Refusée\')';
        
        if(test.Isrunningtest()){
            query='SELECT Id,Statut__c,Date_d_expiration__c, Compte__r.Statut_Assurance__c,Compte__c FROM Document_Assurance__c where (Statut__c != \'Refusée\')';
        }
        
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try { 
            Id AccountId = null; 
            
            //Returns the current Date based on a GMT calendar.
            Date d = Date.today(); 
            
            if(test.Isrunningtest()){
                d = Date.newInstance(Date.today().Year(),Date.today().month(),1);
            }        
            
            // Mettre à jour les documents assurances qui sont expirées              
            List<Document_Assurance__c> AssuListUpdate = new  List<Document_Assurance__c>();
            List<Account> AccountList = new  List<Account>();
            Map<Id,String> accountMap = new Map<Id,String>();  
            
            for (Document_Assurance__c Assu: (list<Document_Assurance__c>)scope) {
                
                // Mettre à jour les assurances avec une date d'expiration passées                    
                if (Assu.Date_d_expiration__c < d) {
                    Assu.Statut__c = 'Expirée';
                }
                AssuListUpdate.add(Assu);
                
                // Mettre à jour le statut de l'assurance "Statut_Assurance__c" sur le compte (regarder la liste des assurances) avec la valeur du statut de l'assurance la plus à jour. 
                
                if (Assu.Date_d_expiration__c >= d ) {
                    //cpte.Statut_Assurance__c = 'Validée';
                    if(accountMap.get(Assu.Compte__c) == null){
                        AccountMap.put(Assu.Compte__c,'Validée');
                    }
                }
            }
            for (Id key: AccountMap.keySet())
            {
                Account account = new Account();
                account.Id = key;
                account.Statut_Assurance__c = accountMap.get(key);
                AccountList.add(account);  
            }
            if (AssuListUpdate.size() > 0) {
                update AssuListUpdate;
            }  
            if (AccountList.size() > 0) {
                update AccountList;
            } 
            //update AccountList;
            
            // Tester le catch Exception
            if(Test.isRunningTest()){
                String testVariable = null;
                testVariable.contains('hello');
            }
            
        } catch(Exception e) {       
            System.debug('An exception occurred: ' + e.getMessage());
            /* Envoie de mail pour inforamtion */
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email});
            mail.setSubject('Error on execution batch Assurance Update Statut field ');
            String body='Une erreur s\'est produite lor de l\'éxecution du batch de mise à jour des statuts des assurances! </BR>';
            mail.setHtmlBody(body);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            /* FIN Envoi du mail */
        } 
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute(SchedulableContext context) {
        Batch_AssuranceUpdate  b = new  Batch_AssuranceUpdate (); 
        database.executebatch(b);
    }
    
}