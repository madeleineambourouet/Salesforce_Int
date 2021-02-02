trigger QuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        Set<Id> prpcSet = new Set<Id>();
        for (zqu__QuoteRatePlanCharge__c c : Trigger.new){
            if (c.zqu__ProductRatePlanCharge__c != null) {
                prpcSet.add(c.zqu__ProductRatePlanCharge__c);
            }
        }
        if (prpcSet.size() > 0) {
            Map<Id, zqu__ProductRatePlanCharge__c> prpcMap = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, HYRatePlanChargeID__c FROM zqu__ProductRatePlanCharge__c WHERE Id in:prpcSet]);
            for (zqu__QuoteRatePlanCharge__c c : Trigger.new) {
                if (prpcMap.get(c.zqu__ProductRatePlanCharge__c) != null) {
                    c.HYRatePlanChargeID__c = prpcMap.get(c.zqu__ProductRatePlanCharge__c) .HYRatePlanChargeID__c;
                }
                
            }
        }
        
    }
    
}