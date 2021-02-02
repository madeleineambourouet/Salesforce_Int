Trigger ProjetDeletedEvent on Projet__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsProjet(); 
     }
  }