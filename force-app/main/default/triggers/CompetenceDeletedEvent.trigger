Trigger CompetenceDeletedEvent on Competence__c (After delete) {
      if(trigger.isDelete && trigger.isAfter ){
         GetDeletedRecords.getRecordsCompetences(); 
     }
  }