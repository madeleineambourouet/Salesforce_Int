Trigger IntermediationDeletedEvent on Intermediation__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsIntermed(); 
     }
  }