Trigger DocCertfDeletedEvent on Document_Certification__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsDocCertf(); 
     }
  }