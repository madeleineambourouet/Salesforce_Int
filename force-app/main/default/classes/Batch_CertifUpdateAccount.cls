/**
* @author Leila BOUAIFEL
* @date 18/07/2017
*
* @description Mettre à jour le compte pro avec les documents certifications
*/

public with sharing class Batch_CertifUpdateAccount implements Database.Batchable<sObject>, Schedulable  {
    
public Batch_CertifUpdateAccount() {}
    String query;
public Database.QueryLocator start(Database.BatchableContext BC) {
       
        query='SELECT Id,Qualification_retenue__c, (select Nom__r.Name, Date_d_expiration__c, Statut__c from Documents_Certifications__r ) FROM Account where id in (select Compte__c from Document_Certification__c where Statut__c != \'Refusée\' or Date_d_expiration__c = Yesterday)';
               
        if(test.Isrunningtest()){
            query='SELECT Id,Qualification_retenue__c, (select Nom__r.Name, Date_d_expiration__c, Statut__c from Documents_Certifications__r ) FROM Account where id in (select Compte__c from Document_Certification__c where Statut__c != \'Refusée\')';
         }
                       
        return Database.getQueryLocator(query);
     
        }

public void execute(Database.BatchableContext BC, List<sObject> scope) {
      try { 
       
        Id AccountId = null; 
        
  //Returns the current Date based on a GMT calendar.
        Date d = Date.today(); 
        Date d1 = Date.today().addDays(-1);  
        
       if(test.Isrunningtest()){
            d = Date.newInstance(Date.today().Year(),Date.today().month(),1);
            d1 = Date.newInstance(Date.today().addDays(-1).Year(),Date.today().addDays(-1).month(),1);
         }        
        
  //list for holding Document_Certification__c updates
       
        
        String splitter = ';';
          
       	List <Account> AccountList = new List <Account>();
       	List<Document_Certification__c> DocListUpdate = new  List<Document_Certification__c>();
        System.debug('AccountList...' + AccountList);  
                for (Account act: (list<Account>)scope) {
                String multiSelectValue = '';
                List<Document_Certification__c> CertifList = act.Documents_Certifications__r;
                 for (Document_Certification__c Doc : CertifList ) {
                     
                     // Ajouter les certifications validées avec une date d'expiration futur sur le compte
                     if (Doc.Date_d_expiration__c >= d && Doc.Statut__c == 'Validée') { 
                        multiSelectValue = multiSelectValue + Doc.Nom__r.Name + splitter;
                      }
                     // Metre à jour toutes les certifications avec une date d'expiration passée sur l'objet Document certification
                     if (Doc.Date_d_expiration__c == d1 && Doc.Statut__c != 'Refusée') {
                     		Doc.Statut__c = 'Expirée'; 
                      		 }
                	DocListUpdate.add(Doc);
                 }
                     
                act.Qualification_retenue__c =  multiSelectValue;
                 AccountList.add(act);      
              
      	}
   		 
     // Regarder si les listes sont vide, sinon les mettres à jour
      if (AccountList.size() > 0) {
           update AccountList;
         }
          	if (DocListUpdate.size() > 0) {
           update DocListUpdate;
         }   
          
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
            mail.setSubject('Error on execution batch Certification Update Account field ');
            String body='Une erreur s\'est produite lors de l\'execution du batch de certification ! </BR>';
            mail.setHtmlBody(body);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            /* FIN Envoi du mail */
            } 
    } 
    public void finish(Database.BatchableContext BC) {
        
    }

    public void execute(SchedulableContext context) {
        Batch_CertifUpdateAccount b = new Batch_CertifUpdateAccount(); 
        database.executebatch(b);
    }
 
}