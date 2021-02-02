trigger QuoteUpdateAccount on zqu__Quote__c (before insert, before update)
{   
                String objOwnerId;
                String objRecordId;
                String objAccount;
                
                   
    for(zqu__Quote__c obj: Trigger.new)
    {
        if (obj.Produit__c == 'Offre Homly Travaux')
        {
            objOwnerId = obj.OwnerId;
            objRecordId = obj.Id;
            objAccount = obj.zqu__Account__c;
                                               
            
        }
    }
    
    List<account> accounts = new List<account>([SELECT Id, Update_Owner_Quote__c FROM Account WHERE Id = :objAccount]);
    List<account> accountUpdateList = new List<account>();
    
    for(account a: accounts)
    {
        a.Update_Owner_Quote__c = objOwnerId;
        accountUpdateList.add(a);
    }
    
    if(accountUpdateList.size() > 0)
    {
        update accountUpdateList;
    }
    

    
}