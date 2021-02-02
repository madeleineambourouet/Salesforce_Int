// 20/07/2017, Modified by Qiuyan Liu, EB114, set recordtype for Quote according to the value of "Type de geste"
global class DefaultValues extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin{  
   global override void populateDefaultFieldValue
      (SObject record, zqu.PropertyComponentController.ParentController pcc)
   {    
       Id recordId = (Id)(record.get('Id'));
       if (recordId != null) {
           String quoteCurrency = [SELECT zqu__Currency__c FROM zqu__Quote__c WHERE Id = :recordId].zqu__Currency__c;
           record.put('zqu__Currency__c', quoteCurrency);
       }
       //EB114, set recordtype for Quote according to the value of "Type de geste"
       Id rtId = (Id)(record.get('RecordTypeId'));
       if (rtId != null) {
           Map<Id, String> rtMap =  new Map<Id, String>();
           for (RecordType rt : [select Id, DeveloperName from RecordType where SobjectType = 'zqu__Quote__c']) {
               rtMap.put(rt.Id , rt.DeveloperName);
           }
           System.debug('rtMap ' + rtMap);
           
           if (rtMap.get(rtId) == 'Amendment') {
               record.put('Type_de_geste__c', 'Modification de souscription');
           } else if (rtMap.get(rtId) == 'Default') {
               record.put('Type_de_geste__c', 'Création de souscription');
           } else if (rtMap.get(rtId) == 'Post_resiliation') {
               record.put('Type_de_geste__c', 'Geste commercial post-résiliation');
           } else {
               record.put('Type_de_geste__c', null);
           }
       }
           
     if(!Test.isRunningTest()) 
     { super.populateDefaultFieldValue(record, pcc);  }
     
      //Populate default values in the quote header  
      record.put('zqu__Status__c', 'En cours');    
      //record.put('zqu__RenewalTerm__c', 12);    
       
      //Date ouverture du service SGDBF
      /*Date DateService = Date.newInstance(2016, 7, 4); 
       
      if (Date.today()< DateService ) {
      //date d'ouverture du service
      record.put('zqu__StartDate__c', DateService ); 
      record.put('zqu__ValidUntil__c', DateService.addDays(30));
      } 
      else
      {
      //date du jour
      record.put('zqu__StartDate__c', Date.today()); 
      record.put('zqu__ValidUntil__c', Date.today().addDays(30));
      }*/
      
      Date DateService = (Date.today() < Date.newInstance(2016, 7, 4)) ? Date.newInstance(2016, 7, 4) : Date.today();
      record.put('zqu__StartDate__c', DateService ); 
      record.put('zqu__ValidUntil__c', DateService.addDays(30));

      // Retrieve the account ID from the quote         
      Id accountId = (Id) record.get('zqu__Account__c');

      // Retrieve the recordType          
      Id Record_Type = (Id) record.get('RecordTypeId'); 
            // Retrieve billToContactid   
          Id billToContactid = (Id) record.get('zqu__BillToContact__c');
            // Retrieve soldToContactid   
          Id soldToContactid = (Id) record.get('zqu__SoldToContact__c');              
      
    //  List<RecordType>QuoteRecordType = [SELECT DeveloperName,Id FROM RecordType WHERE Id = :Record_Type]; 
    // uniquement pour la création d'une nouvelle proposition commerciale
    //if (QuoteRecordType[0].DeveloperName == 'Default' ) {
         
    if ((billToContactid == null) && (soldToContactid == null) ) {  //création de compte de facturation
      
      // Find Code client of related account        
      List<Account>Compte = [SELECT Id, Code_client__c FROM Account WHERE Id = :accountId]; 
      //  set zura account number      
      if  (Compte.size() > 0) 
        {     
            record.put('zqu__Zuora_Account_Number__c', Compte[0].Code_client__c);  
        }
         
      
      // Find the billTo contact (Contact de facturation) associated with the account         
      List<Contact>billToContact = [SELECT Id, Name FROM Contact WHERE Account.Id = :accountId AND Contact.Contact_de_facturation__c = true]; 
      
      // Find the soldTo contact (Contact principal) associated with the account         
      List<Contact>soldToContact = [SELECT Id, Name FROM Contact WHERE Account.Id = :accountId AND Contact.Contact_Principal_O_N__c= true]; 
           
      
      
      
      //  set the billTo  Contact      
      if  (billToContact.size() > 0) {             
         // System.debug('mp: about to add ' + billToContact[0].Id + ' as a contact ID');             
         record.put('zqu__BillToContact__c', billToContact[0].Id);             
                   
         if(!Test.isRunningTest()) 
         {
         // Beforeretrieving  the lookup  options, needs to populate the map first             
         super.setLookupOptions(pcc);             
      
         // Now retrieve the lookup component options             
         zqu.LookupComponentOptions billToOptions = super.getLookupOption('zqu__BillToContact__c');             
         billToOptions.targetId = billToContact[0].Id;             
         billToOptions.targetName = billToContact[0].Name; 
         }                   
      }
      
            // set the soldTo to contact      
      if  (soldToContact.size() > 0) {             
         // System.debug('mp: about to add ' + soldToContact[0].Id + ' as a contact ID');                         
         record.put('zqu__SoldToContact__c', soldToContact[0].Id);             
      
         if(!Test.isRunningTest()) 
         {
         // Beforeretrieving  the lookup  options, needs to populate the map first             
         super.setLookupOptions(pcc);             
      
         // Now retrieve the lookup component options             
           
         zqu.LookupComponentOptions soldToOptions  = super.getLookupOption('zqu__SoldToContact__c');             
         soldToOptions.targetId = soldToContact[0].Id;             
         soldToOptions.targetName = soldToContact[0].Name; 
         }        
      }
      
      
      }
   }
}