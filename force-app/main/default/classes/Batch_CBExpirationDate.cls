/**
* @author Leila BOUAIFEL
* @date 06/02/2017
*
* @description Send emails in mass to each Account with CB expiration date on Payment Methods object 
*/

public with sharing class Batch_CBExpirationDate implements Database.Batchable<sObject>, Schedulable  {
    
   public Batch_CBExpirationDate() {}
    String query;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Calcul de a date de début du mois en cours (les cartes expirant le mois en cours)
        String DebutMoisFormate = DateTime.now().AddDays(1 - Date.Today().day()).format('yyyy-MM-dd');
        
        //Calcul de a date de début du mois passé (pour les cartes expirées)
        String DebutMoisPasseFormate = DateTime.now().AddMonths(-1).AddDays(1 - Date.Today().day()).format('yyyy-MM-dd');
        
        query='SELECT Date_d_expiration_CB__c, Id, Name, Zuora__BillingAccount__c,Zuora__BillingAccount__r.Zuora__Account__c, Zuora__DefaultPaymentMethod__c, Email_expiration_CB__c, Zuora__BillingAccount__r.Zuora__Account__r.Login__c FROM Zuora__PaymentMethod__c WHERE Zuora__DefaultPaymentMethod__c = true AND (Date_d_expiration_CB__c ='+ DebutMoisFormate +' OR Date_d_expiration_CB__c ='+ DebutMoisPasseFormate +' ) AND Zuora__BillingAccount__c IN (SELECT Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE (Zuora__Status__c != \'Cancelled\' ) OR (Zuora__SubscriptionEndDate__c > Today))';

        //query='SELECT Date_d_expiration_CB__c, Id, Name, Zuora__BillingAccount__c,Zuora__BillingAccount__r.Zuora__Account__c, Zuora__DefaultPaymentMethod__c, Email_expiration_CB__c, Zuora__BillingAccount__r.Zuora__Account__r.Login__c FROM Zuora__PaymentMethod__c WHERE Zuora__DefaultPaymentMethod__c = true AND Date_d_expiration_CB__c ='+ DebutMoisFormate +' AND Zuora__BillingAccount__c IN (SELECT Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE (Zuora__Status__c != \'Cancelled\' ) OR (Zuora__SubscriptionEndDate__c > Today))';
        /*if(test.Isrunningtest()){
            query='SELECT Date_d_expiration_CB__c, Id, Name, Zuora__BillingAccount__c,Zuora__BillingAccount__r.Zuora__Account__c, Zuora__DefaultPaymentMethod__c, Email_expiration_CB__c, Zuora__BillingAccount__r.Zuora__Account__r.Login__c FROM Zuora__PaymentMethod__c WHERE Zuora__DefaultPaymentMethod__c = true  AND Zuora__BillingAccount__c IN (SELECT Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE (Zuora__Status__c != \'Cancelled\' ) )';
        }*/
        
        /*List<Zuora__Subscription__c> ZuSubList = new List<Zuora__Subscription__c>();
        ZuSubList = [SELECT Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE (Zuora__Status__c != 'Cancelled' ) OR (Zuora__SubscriptionEndDate__c > Today)];
        system.debug('ZuSubList.size(): ' + ZuSubList.size());
                                                                                             
        List<Zuora__PaymentMethod__c> PaymMethList = new List<Zuora__PaymentMethod__c>();
        PaymMethList = [SELECT Date_d_expiration_CB__c, Id, Name, Zuora__BillingAccount__c,Zuora__BillingAccount__r.Zuora__Account__c, Zuora__DefaultPaymentMethod__c, Email_expiration_CB__c, Zuora__BillingAccount__r.Zuora__Account__r.Login__c FROM Zuora__PaymentMethod__c WHERE Zuora__DefaultPaymentMethod__c = true  AND Date_d_expiration_CB__c < today AND (Date_d_expiration_CB__c =:d1 OR Date_d_expiration_CB__c =:d2 OR Date_d_expiration_CB__c =:d3 OR Date_d_expiration_CB__c =:d4 OR Date_d_expiration_CB__c =:d5) AND Zuora__BillingAccount__c IN (SELECT Zuora__CustomerAccount__c FROM Zuora__Subscription__c WHERE (Zuora__Status__c != 'Cancelled' ) OR (Zuora__SubscriptionEndDate__c > Today))];
        */
        system.debug('## scopequery: ' + query);
        
        return Database.getQueryLocator(query);
        
       
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
      System.debug('scope' + scope);
        try { 
        List<Zuora__PaymentMethod__c> PaymAccList = new List<Zuora__PaymentMethod__c>();
        
        List<String> ListLogins = new List<String>();        
        List<Zuora__PaymentMethod__c> PaymAccountList = (list<Zuora__PaymentMethod__c>)scope;
        
        for (Zuora__PaymentMethod__c PaymAcc : PaymAccountList){
         
            if (PaymAcc.Zuora__DefaultPaymentMethod__c == true && PaymAcc.Date_d_expiration_CB__c != null) {
                 ListLogins.add(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__r.Login__c);
              }
        }
        //------------Generate the token -------------------------- 
                        
           /* List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,45,5,'Expiration CB');
                        
            for (Zuora__PaymentMethod__c PaymAcc: PaymAccountList ) 
                {
                    for (Token__c Tok : TokenList)
                        {
                        if (Tok.Compte__c.equals(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__c))
                                {    
                                PaymAcc.Token__c = Tok.Name;
                                }
                        }    
               }*/
   
   //update PaymAccountList; // Fin de generate token list
 
 // read and update payment method            
        Id PaymentMethodId = null; 
        
  //Returns the current Date based on a GMT calendar.
        Date d1 = Date.today(); 
        Date d2 = Date.today();
        Date d3 = Date.today();
        Date d4 = Date.today();
        Date d5 = Date.today();
   
        if(test.Isrunningtest()){
            d1 = Date.newInstance(Date.today().Year(),Date.today().month(),1);
            d2 = Date.newInstance(Date.today().Year(),Date.today().month(),8);
            d3 = Date.newInstance(Date.today().Year(),Date.today().month(),15);
            d4 = Date.newInstance(Date.today().Year(),Date.today().month(),22);
            d5 = Date.newInstance(Date.today().Year(),Date.today().month(),1); 
        }        
        
        Integer d1Days = Integer.valueOf(System.Label.Date_1_expiration_CB);
        Integer d2Days = Integer.valueOf(System.Label.Date_2_expiration_CB);
        Integer d3Days = Integer.valueOf(System.Label.Date_3_expiration_CB);
        Integer d4Days = Integer.valueOf(System.Label.Date_4_expiration_CB);
        Integer d5Days = Integer.valueOf(System.Label.Date_5_expiration_CB);
        
        d1 = d1.addDays(d1Days);
        d2 = d2.addDays(0-d2Days);
        d3 = d3.addDays(0-d3Days);
        d4 = d4.addDays(0-d4Days);
        d5 = d5.addMonths(0-d5Days);

        //list for holding Zuora__PaymentMethod__c updates
       
        List<Zuora__PaymentMethod__c> PaymentMethodUpdate = new List<Zuora__PaymentMethod__c>();
         System.debug('PaymentMethodUpdate' + PaymentMethodUpdate);
                
        for (Zuora__PaymentMethod__c PM : (list<Zuora__PaymentMethod__c>)scope) {
            
            if (PM.Zuora__DefaultPaymentMethod__c == true && PM.Date_d_expiration_CB__c == d1) {
        
              PM.Email_expiration_CB__c = '1er Email expiration CB'; 
              PaymentMethodUpdate.add(PM); 
             
             //------------Generate the token -------------------------- 
                        
            List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,45,5,'Expiration CB');
                        
            for (Zuora__PaymentMethod__c PaymAcc: PaymAccountList ) 
                {
                    for (Token__c Tok : TokenList)
                        {
                        if (Tok.Compte__c.equals(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__c))
                                {    
                                PaymAcc.Token__c = Tok.Name;
                                }
                        }    
               }
   
           update PaymAccountList;
              }
                          
             if ( PM.Zuora__DefaultPaymentMethod__c == true && PM.Date_d_expiration_CB__c == d2) {
        
             PM.Email_expiration_CB__c = '2ème Email expiration CB'; 
             PaymentMethodUpdate.add(PM); 
             
             //------------Generate the token -------------------------- 
                        
            List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,45,5,'Expiration CB');
                        
            for (Zuora__PaymentMethod__c PaymAcc: PaymAccountList ) 
                {
                    for (Token__c Tok : TokenList)
                        {
                        if (Tok.Compte__c.equals(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__c))
                                {    
                                PaymAcc.Token__c = Tok.Name;
                                }
                        }    
               }
   
           update PaymAccountList;      
             }
           
             if (PM.Zuora__DefaultPaymentMethod__c == true && PM.Date_d_expiration_CB__c == d3) {
       
              PM.Email_expiration_CB__c = '3ème Email expiration CB'; 
              PaymentMethodUpdate.add(PM);
             
              //------------Generate the token -------------------------- 
                        
            List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,45,5,'Expiration CB');
                        
            for (Zuora__PaymentMethod__c PaymAcc: PaymAccountList ) 
                {
                    for (Token__c Tok : TokenList)
                        {
                        if (Tok.Compte__c.equals(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__c))
                                {    
                                PaymAcc.Token__c = Tok.Name;
                                }
                        }    
               }
   
           update PaymAccountList;                  
              }
           
             if (PM.Zuora__DefaultPaymentMethod__c == true && PM.Date_d_expiration_CB__c == d4) {
       
             PM.Email_expiration_CB__c = '4ème Email expiration CB'; 
              PaymentMethodUpdate.add(PM);      
             
             //------------Generate the token -------------------------- 
                        
            List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,45,5,'Expiration CB');
                        
            for (Zuora__PaymentMethod__c PaymAcc: PaymAccountList ) 
                {
                    for (Token__c Tok : TokenList)
                        {
                        if (Tok.Compte__c.equals(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__c))
                                {    
                                PaymAcc.Token__c = Tok.Name;
                                }
                        }    
               }
   
       update PaymAccountList;
             }
           
            if (PM.Zuora__DefaultPaymentMethod__c == true && PM.Date_d_expiration_CB__c == d5) {
       
             PM.Email_expiration_CB__c = '5ème Email expiration CB'; 
              PaymentMethodUpdate.add(PM);     
             //------------Generate the token -------------------------- 
                        
            List<Token__c> TokenList = AccountMethods.generateToken(ListLogins ,45,5,'Expiration CB');
                        
            for (Zuora__PaymentMethod__c PaymAcc: PaymAccountList ) 
                {
                    for (Token__c Tok : TokenList)
                        {
                        if (Tok.Compte__c.equals(PaymAcc.Zuora__BillingAccount__r.Zuora__Account__c))
                                {    
                                PaymAcc.Token__c = Tok.Name;
                                }
                        }    
               }
   
           update PaymAccountList;            
             }
         
    }
   update PaymentMethodUpdate;     
    }
        catch(Exception e) {       
        System.debug('An exception occurred: ' + e.getMessage());
            /* Envoie de mail pour inforamtion */
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //String emailList ='leila.bouaifel@saint-gobain.com';
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email});
            mail.setSubject('Error on execution batch CB Expiration ');
            String body='Une ereur c\'est produite lor de l\'execution du batch Expiration CB! </BR>';
            mail.setHtmlBody(body);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            /* FIN Envoi du mail */
}
    } 
    public void finish(Database.BatchableContext BC) {
        
    }

  
    public void execute(SchedulableContext context) {
        Batch_CBExpirationDate b = new Batch_CBExpirationDate(); 
        database.executebatch(b);
    }
 
}