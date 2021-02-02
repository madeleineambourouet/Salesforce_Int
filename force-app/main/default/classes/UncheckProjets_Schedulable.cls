global class UncheckProjets_Schedulable implements Schedulable {
    
    global void execute(SchedulableContext context){
        Integer jours = Integer.valueOf(Label.Rematching_Delay);
        Datetime myDate = Datetime.now();
        myDate = myDate.addDays(jours*(-1));
        String myDateForm = myDate.format('yyyy-MM-dd') + 'T00:00:00.000+0000';
        
        
        // The objectifs commerciaux to apply the batch on
        //String query = 'SELECT id FROM Projet__c WHERE batch__c = true';
        //Add CreatedDate in query filter to make the query better performance
        String query = 'SELECT id FROM Projet__c WHERE batch__c = true AND CreatedDate > '+ myDateForm;
        UncheckProjets_Batchable batch = new UncheckProjets_Batchable(query);
        Database.executeBatch(batch,100);
        
    }
    
}