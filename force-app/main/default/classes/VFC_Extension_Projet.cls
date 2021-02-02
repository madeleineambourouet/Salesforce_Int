public class VFC_Extension_Projet
{
    
    private static final Reference__c FR = [SELECT id, Name FROM Reference__c WHERE key__c = 'FRA' LIMIT 1];

    public VFC_Extension_Projet(ApexPages.StandardController controller)
    {
       
    }
 
    public PageReference fillCountry()
    {
        String accountId = ApexPages.currentPage().getParameters().get('AccountId');
        String accountName = ApexPages.currentPage().getParameters().get('AccountName');
        
        String urlAccount = '';
        if (accountId != null && accountId != '')
            urlAccount = '&' + Label.ID_Particulier_lkp_projet + '=' + accountName + '&' + Label.ID_Particulier_lkp_projet + '_lkid=' + accountId;
        
        PageReference pf = new PageReference('/'+Label.Trigramme_Projet+'/e?nooverride=1&' + Label.ID_Pays_lkp_projet + '=' + FR.Name + '&' + Label.ID_Pays_lkp_projet + '_lkid=' + FR.Id + urlAccount);
        pf.setRedirect(true);
        
        return pf;
        
    }
    
    
}