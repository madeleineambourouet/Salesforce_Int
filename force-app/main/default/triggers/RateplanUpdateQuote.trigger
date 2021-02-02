Trigger RateplanUpdateQuote on zqu__QuoteRatePlan__c (after insert, after update){   
                
                String objRecordId;
                String objQuoteId;
                String objRateplanname;
                //String objRPC;
                
    // If Homly Travaux is added             
    for(zqu__QuoteRatePlan__c obj: Trigger.new) {
        
        if ((obj.zqu__QuoteProductName__c == 'Offre Homly Travaux' || obj.zqu__QuoteProductName__c == 'Offre CapRenov+') && (obj.zqu__AmendmentType__c== 'NewProduct'|| obj.zqu__AmendmentType__c== 'UpdateProduct'))
         //if ((obj.Charge_principale__c == 'RPC-1' ) && (obj.zqu__AmendmentType__c== 'NewProduct'|| obj.zqu__AmendmentType__c== 'UpdateProduct'))
        {            
            objRecordId = obj.Id;
            objQuoteId = obj.zqu__Quote__c;
            objRateplanname=obj.zqu__QuoteProductName__c;  
            //objRPC=obj.Charge_principale__c;        
        }
        
        //system.debug('>>>>>>>>obj' + objRPC);
    }
    
    List<zqu__Quote__c> Quotes = new List<zqu__Quote__c>([SELECT Id, Produit__c FROM zqu__Quote__c WHERE Id = :objQuoteId]);
    List<zqu__Quote__c> QuoteUpdateList = new List<zqu__Quote__c>();
   
    for(zqu__Quote__c z: Quotes)
    {
       z.Produit__c = objRateplanname;
        //z.Produit__c = objRPC;
        QuoteUpdateList.add(z);
        system.debug('>>>>>>>>QuoteUpdate' + z);
        //system.debug('>>>>>>>>objRateplanname' + objRPC);
    }
     
          
       if(QuoteUpdateList.size() > 0)
                {
                    update QuoteUpdateList;
                }
                
    // If Homly Travaux is removed
 for(zqu__QuoteRatePlan__c obj2: Trigger.new)
    {
        if ((obj2.zqu__QuoteProductName__c == 'Offre Homly Travaux' || obj2.zqu__QuoteProductName__c == 'Offre CapRenov+') && obj2.zqu__AmendmentType__c== 'RemoveProduct')
        {           
            objRecordId = obj2.Id;
            objQuoteId = obj2.zqu__Quote__c;
            objRateplanname=null;          
        }
    }
    
    List<zqu__Quote__c> Quotes2 = new List<zqu__Quote__c>([SELECT Id, Produit__c FROM zqu__Quote__c WHERE Id = :objQuoteId]);
    List<zqu__Quote__c> QuoteUpdateList2 = new List<zqu__Quote__c>();
   
    for(zqu__Quote__c z2: Quotes2)
    {
        z2.Produit__c = objRateplanname;
        //z2.Produit__c = objRPC;        
        QuoteUpdateList2.add(z2);
        system.debug('>>>>>>>>QuoteUpdateList2' + z2);
        //system.debug('>>>>>>>>objRateplanname' + objRPC);
    }
               
      if(QuoteUpdateList2.size() > 0)
                {
                    update QuoteUpdateList2;
                }            
}