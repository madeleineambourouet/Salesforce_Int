Trigger ZuoraDeletedEvent on Zuora__SubscriptionProductCharge__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsZuora(); 
     }
  }