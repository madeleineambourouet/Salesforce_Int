Trigger GeoCatDeletedEvent on GeoCat__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsGeoCat(); 
     }
  }