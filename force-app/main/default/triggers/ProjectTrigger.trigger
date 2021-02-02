trigger ProjectTrigger on Projet__c (before insert, before update) {
    
    User currentUser = [SELECT id, Name, Title, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
    
    if (Trigger.isInsert && Trigger.isBefore){
        
        
        AccountMethods.setUserInfoBySGI(null, Trigger.new, false, currentUser);
        
    }
    
  /* ------------ No updated needed for SGI number --------------------------
    if (Trigger.isUpdate && Trigger.isBefore)
    {
                    
        List<Projet__c> projetsUpdate = new List<Projet__c>();
        for (Projet__c proj : Trigger.new)
        {
             if (Trigger.newMap.get(proj.id).Numero_SGI__c  != Trigger.oldMap.get(proj.id).Numero_SGI__c)
             {
                projetsUpdate.add(proj);
             }
        }       
        if (projetsUpdate.size()>0)
        {
            AccountMethods.setUserInfoBySGI(null, projetsUpdate, false, currentUser); 
            
        }
    
    }
    */

}