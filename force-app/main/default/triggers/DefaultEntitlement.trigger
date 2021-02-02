trigger DefaultEntitlement on Case (Before Insert, Before Update) {
    
    
    list <id> contactids = new list<id>();
    list <id> acctIds = new list<id>();
    
    for (Case c: Trigger.new){
            System.debug('***' + c);
          if (c.EntitlementId == null){
              System.debug('Inside Entitlement Null');
              if(c.ContactId != null){
                  contactIds.add(c.ContactId);
              }
              if(c.AccountId!= null){
                   acctIds.add(c.AccountId);
              }
          }
   }
   System.debug('@@@ contact '+contactIds);
 if(contactIds.isEmpty()==false || acctIds.isEmpty()==false){   
 System.debug('inside second loop');
    List <EntitlementContact> entlContacts = 
                [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId 
                From EntitlementContact e
                Where e.ContactId in :contactIds And e.Entitlement.EndDate >= Today
                ];
                System.debug('***' + entlContacts);
        if(entlContacts.isEmpty()==false){
         System.debug('inside entlcontact loop');
            for(Case c : Trigger.new){
                if(c.EntitlementId == null && c.ContactId != null){
                    for(EntitlementContact ec:entlContacts){
                        if(ec.ContactId==c.ContactId){
                            c.EntitlementId = ec.EntitlementId;
                            if(c.AssetId==null && ec.Entitlement.AssetId!=null)
                                c.AssetId=ec.Entitlement.AssetId;
                            break;
                        }
                    } 
                }
            } 
        } else{
        System.debug('inside master else loop');
        List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate, 
                    e.AccountId, e.AssetId
                    From Entitlement e
                    Where e.AccountId in :acctIds And e.EndDate >= Today 
                    ];
                    System.debug('***' + entls);
            if(entls.isEmpty()==false){
                for(Case c : Trigger.new){
                    if(c.EntitlementId == null && c.AccountId != null){
                        for(Entitlement e:entls){
                            if(e.AccountId==c.AccountId){
                                c.EntitlementId = e.Id;
                                if(c.AssetId==null && e.AssetId!=null)
                                    c.AssetId=e.AssetId;
                                break;
                            }
                        } 
                    }
                } 
            }
        }
    }
 }
 
 /*trigger  CaseEntitlementUpdate on Case (Before Insert, Before Update) {
    
    For (Case C : trigger.New){

    CaseEntitlementUpdate CaseUpdate = new CaseEntitlementUpdate();
      }
}*/