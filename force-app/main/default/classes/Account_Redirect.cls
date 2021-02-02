public class Account_Redirect 
{
    
    public Account_Redirect(ApexPages.StandardController controller)
    {
       
    }
    
    public PageReference redirect()
    {
        return (new PageReference('/apex/vf_account_hideAccountTeamButton'));
    }
    

}