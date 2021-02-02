Trigger ContactDeletedEvent on Contact (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsContact(); 
     }
  }