global class UncheckProjets_Batchable implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global final String query;
    
    global UncheckProjets_Batchable(String q){
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Projet__c> projets){
    
        for (Projet__c project : projets){
            
            project.batch__c = false;
            
        }
        
        update projets;
        
    }

    global void finish(Database.BatchableContext BC){
        
    }
    
    
}