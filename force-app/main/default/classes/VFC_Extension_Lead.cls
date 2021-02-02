global class VFC_Extension_Lead {
    
    private static final Reference__c FR = [SELECT id, Name FROM Reference__c WHERE key__c = 'FRA' LIMIT 1];
    //String fr15 = (''+FR.id).substring(0,15);
    
    public VFC_Extension_Lead(ApexPages.StandardController stdController){
        
    }
    
    public PageReference fillCountry()
    {
        
        PageReference pf = new PageReference('/00Q/e?nooverride=1&' + Label.ID_Pays_lkp_piste + '=' + FR.Name + '&' + Label.ID_Pays_lkp_piste + '_lkid=' + FR.Id);
        pf.setRedirect(true);
        
        return pf;
        
    }    

}