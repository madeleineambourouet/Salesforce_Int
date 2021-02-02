public class VFC_Extension_Account 
{
    
    //private final Account compte;
    private final ID RTid;
    private static final Reference__c FR = [SELECT id, Name FROM Reference__c WHERE key__c = 'FRA' LIMIT 1];

    public VFC_Extension_Account(ApexPages.StandardController controller)
    {
       //compte = ((Account)controller).getRecord(); 
       RTid = ((Account)controller.getRecord()).RecordTypeId;
    }
 
    public PageReference fillCountry()
    {
        PageReference pf = new PageReference('/001/e?nooverride=1&' + Label.ID_Pays_lkp_PRO + '=' + FR.Name + '&' + Label.ID_Pays_lkp_PRO + '_lkid=' + FR.Id + '&RecordType=' + RTid);
        pf.setRedirect(true);
        
        return pf;
        
    }
    
    
}