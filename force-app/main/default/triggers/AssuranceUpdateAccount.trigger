trigger AssuranceUpdateAccount on Document_Assurance__c (after insert, after update, after delete) {

    list <id> objAccount = new list<id>();
    List <Document_Assurance__c> ConcernedDocs = new List<Document_Assurance__c> ();           
    if (Trigger.isDelete && Trigger.isAfter)
        ConcernedDocs = Trigger.Old;
    else
        ConcernedDocs = Trigger.New;
    
    
    for(Document_Assurance__c obj: ConcernedDocs)
    {
        if (obj.Date_d_expiration__c != null)
        {
            
            objAccount.add(obj.Compte__c);                 
            
        }
    }
    List<Account> Accounts = new List<Account>([SELECT Id, Last_date_expiration_assurances__c, (select Id, Date_d_expiration__c from Documents__r where Date_d_expiration__c != null ORDER BY Date_d_expiration__c desc LIMIT 1)  FROM Account WHERE Id IN :objAccount]);
    
    
    /*List<Document_Assurance__c> DocassurancesList = new List<Document_Assurance__c>([select Id, Date_d_expiration__c from Document_Assurance__c WHERE Compte__c = :objAccount ORDER BY Date_d_expiration__c desc  LIMIT 1 ]);            

*/    
    List<Account> AccountUpdateList = new List<Account>();
    
    for(Account A: Accounts)
    {
        System.debug('>>>>>>>>>>>> UPDATE Documents ' + A.Documents__r);
        If (A.Documents__r != null && A.Documents__r.size() >0)
            A.Last_date_expiration_assurances__c = A.Documents__r[0].Date_d_expiration__c;
        else
            A.Last_date_expiration_assurances__c = null;
        AccountUpdateList.add(A);
    }
    System.debug('>>>>>>>>>>>> UPDATE Account ' + AccountUpdateList);
    if(AccountUpdateList.size() > 0)
    {
        update AccountUpdateList;
    }
    
    //fill Presence_Assurance__c in Account object
    if (trigger.isAfter && (trigger.isInsert || trigger.isDelete )) {
        Set<Id> accIdList = new Set<Id>();
        //we use Trigger.new for update because the account of Document_Assurance__c is never changed
        List<Document_Assurance__c> daList = (Trigger.isInsert || trigger.isUpdate)?Trigger.new : Trigger.old;
        
        for (Document_Assurance__c da : daList) {
            accIdList.add(da.Compte__c);
        }

        List<Account> accList = [SELECT Id, Presence_Assurance__c , (SELECT Id FROM Documents__r) FROM Account WHERE Id in :accIdList];   
        for (Account acc : accList) {
            acc.Presence_Assurance__c = acc.Documents__r.size();
        }
        update accList;

        //update Check_Assurance__c in Zuora__SubscriptionProductCharge__c
        List<Zuora__SubscriptionProductCharge__c> quoteList = [SELECT Id, Check_Assurance__c, Zuora__Account__r.Presence_Assurance__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Account__c in:accIdList];
        for (Zuora__SubscriptionProductCharge__c spc : quoteList) {
            if (spc.Zuora__Account__r.Presence_Assurance__c > 0) {
                spc.Check_Assurance__c = false;
            } else {
                spc.Check_Assurance__c = true;
            }
        }
        update quoteList;
    }

 }