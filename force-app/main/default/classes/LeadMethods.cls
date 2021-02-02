public class LeadMethods 
{
    public Id accountId {get;set;}
    
    public LeadMethods()
    {
        accountId = null;
        
        if (apexpages.currentPage().getParameters().get('AccountId') != null)
        {
            accountId = apexpages.currentPage().getParameters().get('AccountId');
        }
    }

}