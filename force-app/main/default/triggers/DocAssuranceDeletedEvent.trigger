Trigger DocAssuranceDeletedEvent on Document_Assurance__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsDocAssurance(); 
     }
  }