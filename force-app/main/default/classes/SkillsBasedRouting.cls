Global class SkillsBasedRouting {
    @InvocableMethod
    public static void routeUsingSkills(List<String> ProjetsLMSG) {
        List<Projet_LMSG__c> ProjetObjects = [SELECT Id, OwnerId FROM Projet_LMSG__c WHERE Id in :ProjetsLMSG];
        for (Projet_LMSG__c ProjetObj : ProjetObjects) {
            try {
                // Create a PendingServiceRouting to initiate routing
                createPendingServiceRouting(ProjetObj);
            } catch(exception e) {
                System.debug('ERROR:' + e.getStackTraceString());
                throw e;
            }
        }
    }
    
    public static void createPendingServiceRouting(Projet_LMSG__c ProjetObj) {
        // Create a new SkillsBased PendingServiceRouting
        PendingServiceRouting psrObj = new PendingServiceRouting(
            CapacityWeight = 1,
            IsReadyForRouting = FALSE,
            RoutingModel  = 'MostAvailable',
            RoutingPriority = 1,
            RoutingType = 'SkillsBased',
            ServiceChannelId = getChannelId('sfdc_livemessage'),
            WorkItemId = ProjetObj.Id,
            PushTimeout = 0
        );
        insert psrObj;
        psrObj = [select id, IsReadyForRouting from PendingServiceRouting where id = : psrObj.id];
        
        // Now add SkillRequirement(s) to the PendingServiceRouting
        SkillRequirement srObj = new SkillRequirement(
            RelatedRecordId = psrObj.id,
            SkillId = getSkillId(ProjetObj.OwnerId)
            //SkillLevel = 5
        );
        insert srObj;
        
        // Update PendingServiceRouting as IsReadyForRouting
        psrObj.IsReadyForRouting = TRUE;
        update psrObj; 
    }
   
    
    public static String getChannelId(String channelName) {
        ServiceChannel channel = [Select Id From ServiceChannel Where DeveloperName = :channelName];
        return channel.Id;
    }
    
    public static String getSkillId(String ProjetOwner) {
        String skillName = 'Leila';
        if (ProjetOwner != null) {
            if (ProjetOwner .contains('Sophie')) {
                skillName = 'Sophie';
            } else if (ProjetOwner .contains('Leila')) {
                skillName = 'Leila';
            }
                  
        }
        
        Skill skill = [Select Id From Skill Where DeveloperName = :skillName];
        return skill.Id;
    }
}