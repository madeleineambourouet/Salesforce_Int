Trigger AccountDeletedEvent on Account (After delete) {     
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsAccount(); 
     }
  }