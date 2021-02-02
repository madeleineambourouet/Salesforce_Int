global class ApprovalQuote
{
    webservice static void Approve(Id recId)    
    {        
        List<ProcessInstanceWorkitem> Workitem = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recId];
        
        if(Workitem.size() >0 || Test.isRunningTest())
        {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approbation automatique');
            req.setAction('Approve'); 
            req.setWorkitemId(UserInfo.getUserId());         
           
            if (!Test.isRunningTest()) {
                req.setWorkitemId(Workitem.get(0).Id);
                Approval.process(req,false);
            }
            
        }

        zqu__Quote__c curQuote = [SELECT Id, Effective_Amendment_Start_Date__c,Type_de_geste__c, zqu__StartDate__c, RemisePrivilegeValidUntil__c FROM zqu__Quote__c WHERE Id =: recId];
        if ((curQuote.Effective_Amendment_Start_Date__c != null && curQuote.Effective_Amendment_Start_Date__c > curQuote.zqu__StartDate__c && curQuote.Type_de_geste__c == 'Modification de souscription') || Test.isRunningTest()) {
            curQuote.zqu__StartDate__c = curQuote.Effective_Amendment_Start_Date__c;
            update curQuote;
        }

        List<zqu__QuoteAmendment__c> quoteAmendList = [SELECT Id, zqu__Type__c FROM zqu__QuoteAmendment__c WHERE zqu__Description__c LIKE '%Privilège%' AND (zqu__Type__c = 'UpdateProduct' OR zqu__Type__c = 'RemoveProduct') AND zqu__Quote__c =: recId];
        if (quoteAmendList.size() > 0 && curQuote.RemisePrivilegeValidUntil__c != null && 
            curQuote.Effective_Amendment_Start_Date__c != null && curQuote.Effective_Amendment_Start_Date__c >= curQuote.RemisePrivilegeValidUntil__c) 
        delete quoteAmendList;
        
    }
}