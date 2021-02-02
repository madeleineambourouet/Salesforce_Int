/**
* @author Qiuyan Liu
* @date 08/09/2017
*
* @description Created for EB136
*/
public with sharing class SubscriptionProductChargeMethods {
    public static void CancelSubscription(Map<Id, Zuora__SubscriptionProductCharge__c> oldMap, Map<Id, Zuora__SubscriptionProductCharge__c> newMap) {
        Set<Id> cIdList = new Set<Id>();
        for (Id cId : newMap.keyset()) {
            Zuora__SubscriptionProductCharge__c oldC = (oldMap == null) ? null : oldMap.get(cId);
            Zuora__SubscriptionProductCharge__c newC = newMap.get(cId);
            System.debug('oldC ' + oldC);
            System.debug('newC ' + newC);
            if ((oldC != null && oldC.Zuora__EffectiveEndDate__c != newC.Zuora__EffectiveEndDate__c && newC.Zuora__EffectiveEndDate__c != null) || (oldC == null && newC.Zuora__EffectiveEndDate__c != null)) {
                cIdList.add(cId);
            }
        }

        if (cIdList.size() > 0) {
            List<Zuora__SubscriptionProductCharge__c> cList = [SELECT Id, ID_Quote_Resiliation__c, Zuora__Subscription__r.TECH_QuoteID__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__r.Type_de_geste__c != 'Geste commercial post-résiliation' AND Id in:cIdList];
            for (Zuora__SubscriptionProductCharge__c c : cList) {
                c.ID_Quote_Resiliation__c = c.Zuora__Subscription__r.TECH_QuoteID__c;
            }
            //update cList;
            Database.update(cList, false);
        }
    }
}