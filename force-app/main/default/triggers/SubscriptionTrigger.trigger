// 28/07/2017, Modified by Qiuyan Liu, EB114, call Zuora to generate an invoice and cancel the new subscription is the current record is "post résiliation"
// 22/01/2018, Xavier Templet, add support for sales incentives 
// 05/04/2018, Modified by Qiuyan Liu, limit DML, soql query, Apex CUP correction, on function ActivationServicesInsert and ActivationServicesUpdate
trigger SubscriptionTrigger on Zuora__Subscription__c (before insert, before update, after insert, after update)
{
    
    if (trigger.isInsert && trigger.isbefore) {
        ParrainageTrigger.subscribeGodSon(trigger.new);
    }
    //before updating the subscription record 
    if (trigger.isUpdate && trigger.isbefore)
    {      
        //Service Activation after updating subscription
        ParrainageTrigger.checkActifProbis(trigger.new,Trigger.oldMap);
        ParrainageTrigger.subscribeGodSon(trigger.new);
        SubscriptionMethods.ActivationServicesUpdate(trigger.new, Trigger.oldMap); 
    } 
    
    if (trigger.isUpdate && trigger.isAfter) {      
        List<Id> IdList = new List<Id>();
        
        for (Zuora__Subscription__c s : trigger.new) {
            if (s.Zuora__Status__c != trigger.oldMap.get(s.Id).Zuora__Status__c && s.Zuora__Status__c == 'Active' && s.Type_de_geste__c == 'Geste commercial post-résiliation') {
                IdList.add(s.Id);
            }
        }
        
        //System.enqueueJob(new BillRunGenerator(new List<Id>(Trigger.newMap.keyset()))); 
        if (IdList.size() > 0) {
            System.enqueueJob(new BillRunGenerator(IdList)); 
        }

        onboardingTraitements.createOnboardingTasks(Trigger.oldMap, Trigger.newMap, Trigger.new);
    } 
    
    // for sales fact creation
    if (trigger.isInsert && trigger.isAfter) {      
        //Map<Id,Zuora__Subscription__c> NewSub = new Map<Id,Zuora__Subscription__c>();
        List<Zuora__Subscription__c> NewSubLst = new List<Zuora__Subscription__c>();  
        Map<Id,Id> Sub2Quote = new Map<Id,Id>();
        List<String> IdList = new List<String>();
        
        for (Zuora__Subscription__c s : trigger.new) {
            if (s.Zuora__Status__c == 'Active' && s.Type_de_geste__c == 'Création de souscription') {
                NewSubLst.add(s);
                Sub2Quote.put(s.Id, s.TECH_QuoteID__c);
                IdList.add(s.TECH_QuoteID__c);
            }
        }
        
        if (NewSubLst.size() > 0) {
            SalesFact_Methods.InsertSF_ActiveSub(NewSubLst, Sub2Quote, IdList, Trigger.newMap);
        }
    } 
    
    if (trigger.isUpdate && trigger.isAfter) {      
        //Map<Id,Zuora__Subscription__c> NewSub = new Map<Id,Zuora__Subscription__c>();
        List<Zuora__Subscription__c> NewSubLst = new List<Zuora__Subscription__c>();  
        Map<Id,Id> Sub2Quote = new Map<Id,Id>();
        List<String> IdList = new List<String>();
        
        Set<Id> Ids = new Set<Id>();
        for (Zuora__Subscription__c acc: Trigger.new)
            
        {Ids.add(acc.Zuora__Account__c); 
        } 
        List<Account> child = (Ids.size()>0 ? [SELECT Id, Statut_de_la_souscription__c, (SELECT ID, Zuora__Status__c, Zuora__SubscriptionEndDate__c FROM ZUORA__Subscriptions__r ORDER BY Zuora__SubscriptionEndDate__c DESC NULLS FIRST LIMIT 1 )  from Account where Id in :Ids] : new List<Account>());
        List<Account> nchild = new List<Account>();    
        Date d1 = Date.today(); 
        
        
        for (Zuora__Subscription__c s : trigger.new) {
            if (s.Zuora__Status__c != trigger.oldMap.get(s.Id).Zuora__Status__c && s.Zuora__Status__c == 'Active' && s.Type_de_geste__c == 'Création de souscription') {
                NewSubLst.add(s);
                Sub2Quote.put(s.Id, s.TECH_QuoteID__c);
                IdList.add(s.TECH_QuoteID__c);
            }
            
            if (s.Zuora__Status__c == 'Active' && s.Type_de_geste__c != 'Geste commercial post-résiliation')  
            {
                for (Account act: child)
                {
                    if (act.Statut_de_la_souscription__c == 'Pending Activation') {
                        act.Statut_de_la_souscription__c = 'Active';
                        nchild.add(act);
                    }
                } 
            } 
        }
        if (nchild.isEmpty() == false)
            update nchild;
        
        if (NewSubLst.size() > 0) {
            SalesFact_Methods.InsertSF_ActiveSub(NewSubLst, Sub2Quote, IdList, Trigger.newMap);
        }            
        
    } 
    
    
    //before Creating the subscription record 
    if (trigger.IsInsert && trigger.isbefore)
    {      
        //service activation after creation subscription
        SubscriptionMethods.ActivationServicesInsert(trigger.new);    
    }
    
    //Update Statut de la souscription on Account object 
    
    if (trigger.IsInsert && trigger.IsAfter) {   
        // 28/07/2017, Added by Qiuyan Liu, EB114, call SubscriptionMethods.newPostResiliaiton to generate an invoice and cancel the new subscription is the current record is "post résiliation"
        //SubscriptionMethods.newPostResiliaiton(Trigger.new);
        List<Id> BillRunGeneratorIdList = new List<Id>();
        
        for (Zuora__Subscription__c s : trigger.new) {
            if (s.Zuora__Status__c == 'Active' && s.Type_de_geste__c == 'Geste commercial post-résiliation') {
                BillRunGeneratorIdList.add(s.Id);
            }
        }
        
        //System.enqueueJob(new BillRunGenerator(new List<Id>(Trigger.newMap.keyset()))); 
        if (BillRunGeneratorIdList.size() > 0) {
            System.enqueueJob(new BillRunGenerator(BillRunGeneratorIdList)); 
        }
        
        
        Set<Id> Ids = new Set<Id>();
        System.debug('## Ids' + Ids);
        
        for (Zuora__Subscription__c acc: Trigger.new)
            
        {
            //Zuora__Subscription__c oldAcc = Trigger.oldMap.get(acc.Id);
            
            //if (oldAcc.Zuora__Status__c != acc.Zuora__Status__c)
            Ids.add(acc.Zuora__Account__c); 
        } 
        
        List<Account> child = (Ids.size()>0 ? [SELECT Id, Statut_de_la_souscription__c, (SELECT ID, Zuora__Status__c, Zuora__SubscriptionEndDate__c FROM ZUORA__Subscriptions__r ORDER BY Zuora__SubscriptionEndDate__c DESC NULLS FIRST LIMIT 1 )  from Account where Id in :Ids] : new List<Account>());
        List<Account> newchild = new List<Account>();
        
        Date d1 = Date.today();  
        
        for(Zuora__Subscription__c sub: Trigger.new) {
            if (sub.Zuora__Status__c == 'Active'  && (sub.Zuora__SubscriptionEndDate__c > d1 || sub.Zuora__SubscriptionEndDate__c == null) && sub.Type_de_geste__c != 'Geste commercial post-résiliation' &&  !Test.isRunningTest())  
            {
                for (Account act: child)
                {
                    if (act.Statut_de_la_souscription__c != 'Active') {
                        act.Statut_de_la_souscription__c = 'Active';
                        newchild.add(act);
                    }
                    
                } 
            } 
            if (sub.Zuora__Status__c == 'Pending Activation' && (sub.Zuora__SubscriptionEndDate__c > d1 || sub.Zuora__SubscriptionEndDate__c == null) && sub.Type_de_geste__c != 'Geste commercial post-résiliation' &&  !Test.isRunningTest())  
            {
                for (Account act: child)
                {
                    if (act.Statut_de_la_souscription__c != 'Pending Activation') {
                        act.Statut_de_la_souscription__c = 'Pending Activation';
                        newchild.add(act);
                    }
                    
                } 
            } 
            
        }  
        if (newchild.isEmpty() == false){
            update newchild;
        }
        onboardingTraitements.createOnboardingTasks(Trigger.oldMap, Trigger.newMap, Trigger.new);
    }
}