/**
* @author Leila BOUAIFEL
* @date 17/02/2017
* @description Send emails in mass to each Account with "facture impayé" on Billing Account object
* @Revue avec simplification des envois impayés se basant uniquement sur un solde client positif et pro non suspendu
* @date 20/09/2019
*/

public with sharing class Batch_RelanceImpaye implements Database.Batchable<sObject>, Schedulable  {
    
   public Batch_RelanceImpaye() {}
    String query;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Returns the current Date based on a GMT calendar.
        /*Date d1 = Date.today(); 
        Date d2 = Date.today();
        Date d3 = Date.today();
        Date d4 = Date.today();
       
       Integer NDays = Integer.valueOf(System.Label.Date_d_envoi_impaye);
       Integer MDays = Integer.valueOf(System.Label.Date_relance_impaye);
        
        d1 = d1.addDays(0-NDays);
        //d2 = d2.addDays(0-NDays); 
        //d3 = d3.addDays(0-NDays);
        //d4 = d4.addDays(0-MDays); // Relance email impayé à la date de dernière facture + 25 jours 
        System.debug('Batch_RelanceImpaye d1: ' + d1);*/
        
        
        //query='SELECT id, EchecsPaiementConsecutifs__c, Email_de_relance_impayes__c, Exclu_relance_impaye__c, Token__c, Zuora__Balance__c, Zuora__LastInvoiceDate__c, Zuora__Account__c, Zuora__Account__r.Login__c from Zuora__CustomerAccount__c where id=\'a0E3E000002I035\' and Zuora__Balance__c > 0 AND EchecsPaiementConsecutifs__c > \'0\' AND (Zuora__LastInvoiceDate__c =:d1 OR Zuora__LastInvoiceDate__c =:d2 OR Zuora__LastInvoiceDate__c =:d3 OR Zuora__LastInvoiceDate__c =:d4) AND  Exclu_relance_impaye__c = false AND Zuora__Account__c IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Type_de_geste__c !=  \'Geste commercial post-résiliation \' AND ((Zuora__Status__c != \'Cancelled\' ) OR (Zuora__SubscriptionEndDate__c > Today)))';
        
        query='SELECT id, EchecsPaiementConsecutifs__c, Relances_Impayes__c, Exclu_relance_impaye__c, Token__c, Zuora__Balance__c, Zuora__LastInvoiceDate__c, Zuora__Account__c, Zuora__Account__r.Login__c from Zuora__CustomerAccount__c where  Zuora__Balance__c > 0 AND  Exclu_relance_impaye__c = false AND Zuora__Account__c IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Type_de_geste__c !=  \'Geste commercial post-résiliation \' AND ((Zuora__Status__c != \'Cancelled\' ) OR (Zuora__SubscriptionEndDate__c > Today)))';
        
        System.debug('Batch_RelanceImpaye query: ' + query);
         if(test.Isrunningtest()){
            query = 'SELECT id, EchecsPaiementConsecutifs__c, Relances_Impayes__c, Exclu_relance_impaye__c, Token__c, Zuora__Balance__c, Zuora__LastInvoiceDate__c, Zuora__Account__c, Zuora__Account__r.Login__c from Zuora__CustomerAccount__c where Zuora__Balance__c > 0 AND Exclu_relance_impaye__c = false and Zuora__Account__r.Client_suspendu__c = null AND Zuora__Account__c IN (SELECT Zuora__Account__c FROM Zuora__Subscription__c WHERE Type_de_geste__c !=  \'Geste commercial post-résiliation \' AND ((Zuora__Status__c != \'Cancelled\' ) OR (Zuora__SubscriptionEndDate__c > Today)))';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
            System.debug('scope' + scope);
        try {
        
   List<Zuora__CustomerAccount__c> BillAccList = new List<Zuora__CustomerAccount__c>();
   
   List<String> ListLogins = new List<String>();
   List<Zuora__CustomerAccount__c> BillAccountList = (list<Zuora__CustomerAccount__c>)scope;     
   for (Zuora__CustomerAccount__c BillAcc: BillAccountList ) {
     
           
       //if (Integer.ValueOf(BillAcc.EchecsPaiementConsecutifs__c) > 0 && BillAcc.Zuora__Balance__c > 0) {
         if ( BillAcc.Zuora__Balance__c > 0) {
           ListLogins.add(BillAcc.Zuora__Account__r.Login__c);
       }
   }   
                //------------Generate the token -------------------------- 
   
   List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,90,5,'Impayé');
      
   for (Zuora__CustomerAccount__c BillAcc: BillAccountList ) 
   {
       for (Token__c Tok : TokenList)
       {
           if (Tok.Compte__c.equals(BillAcc.Zuora__Account__c))
           {    
               BillAcc.Token__c = Tok.Name;
           }
       }    
   }
   
   update BillAccountList;
      
   Id CustomerAccountId = null; 
    
   //Returns the current Date based on a GMT calendar.
        //Date d1 = Date.today();        
        //Date d2 = Date.today();
        //Date d3 = Date.today();
        //Date d4 = Date.today();
       
       //Integer NDays = Integer.valueOf(System.Label.Date_d_envoi_impaye);
       //Integer MDays = Integer.valueOf(System.Label.Date_relance_impaye);
        
        //d1 = d1.addDays(0-NDays);
        //d2 = d2.addDays(0-NDays); 
        //d3 = d3.addDays(0-NDays);
        //d4 = d4.addDays(0-MDays); // Relance email impayé à la date de dernière facture + 25 jours 
       

        //list for holding Zuora__CustomerAccount__c updates
       
        List<Zuora__CustomerAccount__c> CustomerAccountUpdate = new List<Zuora__CustomerAccount__c>();
         System.debug('CustomerAccountUpdate' + CustomerAccountUpdate);
                
        for (Zuora__CustomerAccount__c CA : (list<Zuora__CustomerAccount__c>)scope) {
            System.debug('CA' + CA);  
            //if (CA.EchecsPaiementConsecutifs__c == '1' && CA.Zuora__LastInvoiceDate__c == d1) {            
            //if (CA.EchecsPaiementConsecutifs__c == '1') {
            
            if (CA.Zuora__Balance__c  > 0) {                 
              CA.Relances_Impayes__c = true; 
              CustomerAccountUpdate.add(CA);                             
              }
             
             // Relance impayé 
            /*if ( CA.EchecsPaiementConsecutifs__c == '1' && CA.Zuora__LastInvoiceDate__c == d4) {
        
             CA.Email_de_relance_impayes__c = 'Relance_email_1ere_facture_impayee'; 
              CustomerAccountUpdate.add(CA);       
                
              }
              
            if (CA.EchecsPaiementConsecutifs__c == '2' && CA.Zuora__LastInvoiceDate__c == d2) {
       
              CA.Email_de_relance_impayes__c = '2ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);                  
              }

             if (CA.EchecsPaiementConsecutifs__c == '3' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 3ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '4' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 4ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '5' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 5ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '6' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 6ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '7' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 7ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '8' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 8ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '9' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 9ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }
              if (CA.EchecsPaiementConsecutifs__c == '10' && CA.Zuora__LastInvoiceDate__c == d3) {
       
             CA.Email_de_relance_impayes__c = ' 10ème email de facture impayée'; 
              CustomerAccountUpdate.add(CA);      
             }*/
                   
    }
            
   update CustomerAccountUpdate; 
   }
        
   catch(Exception e) {       
    System.debug('An exception occurred: ' + e.getMessage());
            /* Envoie de mail pour inforamtion */
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String emailList ='leila.bouaifel@saint-gobain.com';
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email});
            mail.setSubject('Error on execution batch relance impayé ');
            String body='Une ereur c\'est produite lor de l\'execution du batch de relance des impayés! </BR>';
            mail.setHtmlBody(body);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            /* FIN Envoi du mail */
}      
 }
    
    public void finish(Database.BatchableContext BC) {
        
    }

    public void execute(SchedulableContext context) {
        Batch_RelanceImpaye b = new Batch_RelanceImpaye(); 
        database.executebatch(b);
    }
    
}