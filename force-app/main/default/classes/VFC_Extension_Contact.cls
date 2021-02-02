global class VFC_Extension_Contact {
    
    private static final Reference__c FR = [SELECT id, Name FROM Reference__c WHERE key__c = 'FRA' LIMIT 1];
    //String fr15 = (''+FR.id).substring(0,15);
    
    public VFC_Extension_Contact(ApexPages.StandardController stdController)
    {
            
    }
    
    public PageReference fillCountry()
    {
        String accountId = ApexPages.currentPage().getParameters().get('AccountId');
        String accountName = ApexPages.currentPage().getParameters().get('AccountName');
        system.debug('>>>>> AccountId: ' + accountId);
        system.debug('>>>>> AccountName: ' + accountName );
        String urlAccount = '';
        if (accountId != null && accountId != '')
            urlAccount = '&con4=' + accountName + '&con4_lkid=' + accountId;
        
        PageReference pf = new PageReference('/003/e?nooverride=1&' + Label.ID_Pays_lkp_contact + '=' + FR.Name + '&' + Label.ID_Pays_lkp_contact + '_lkid=' + FR.Id + urlAccount);
        pf.setRedirect(true);
        
        return pf;
        
    }    

}