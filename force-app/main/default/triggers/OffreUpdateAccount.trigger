//Original name of this trigger is "OffreUpdateAccount "
//@modified by Qiuyan Liu, 08/09/2017
//@modified by Leila Bouaifel, 03/01/2017
//@Modified by Qiuyan Liu 21/06/2018, correction for double subscriptions problem, only charge in active subscription should be take into account 
trigger OffreUpdateAccount on Zuora__SubscriptionProductCharge__c (after insert, after update) {   
    
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate) ) {
       
        List<Account> accUpdateList = new List<Account>();
    
       // for (Zuora__SubscriptionProductCharge__c spc : [SELECT Name, Zuora__EffectiveStartDate__c, Zuora__Account__c, Zuora__Account__r.Date_d_effet_de_l_offre_Homly_Travaux__c, Zuora__Account__r.Product_on_offre__c,HYRatePlanChargeID__c FROM Zuora__SubscriptionProductCharge__c WHERE (Name='Abonnement Offre Homly Travaux' OR HYRatePlanChargeID__c='RPC1')AND Zuora__EffectiveEndDate__c=null AND Id IN: Trigger.newMap.keyset()]) {
        // Nouvelle offre HYRatePlanChargeID__c contient'-A-' ou HYRatePlanChargeID__c contient'-M-'
        for (Zuora__SubscriptionProductCharge__c spc : [SELECT Name, Zuora__EffectiveStartDate__c, Zuora__Account__c, Zuora__Account__r.Date_d_effet_de_l_offre_Homly_Travaux__c, Zuora__Account__r.Product_on_offre__c,HYRatePlanChargeID__c FROM Zuora__SubscriptionProductCharge__c WHERE (HYRatePlanChargeID__c like '%-A-' OR HYRatePlanChargeID__c like '%-M-') AND Zuora__EffectiveStartDate__c != null AND Zuora__EffectiveEndDate__c=null AND Id IN: Trigger.newMap.keyset()]) {
            if (spc.Zuora__Account__r.Product_on_offre__c == null || spc.Zuora__Account__r.Date_d_effet_de_l_offre_Homly_Travaux__c == null || spc.Zuora__Account__r.Date_d_effet_de_l_offre_Homly_Travaux__c != spc.Zuora__EffectiveStartDate__c) {
                spc.Zuora__Account__r.Date_d_effet_de_l_offre_Homly_Travaux__c = spc.Zuora__EffectiveStartDate__c;
                //spc.Zuora__Account__r.Product_on_offre__c = spc.Name;
                spc.Zuora__Account__r.Product_on_offre__c = spc.HYRatePlanChargeID__c;
                spc.Zuora__Account__r.Id = spc.Zuora__Account__c;
                accUpdateList.add(spc.Zuora__Account__r);
            }
        }
        Set<Account> accUpdateSet = new Set<Account>();
        Set<Account> accDuplicateSet = new Set<Account>();

        for (Account acc : accUpdateList) {
            if (!accUpdateSet.add(acc)) {
                accDuplicateSet.add(acc);
            }
        }
        
        if (accUpdateSet.size() > 0) {
            update new List<Account>(accUpdateSet);
        }
        
        if (accDuplicateSet.size() > 0) {
            List<EmailMassHelper.EmailDefination> emailList = new List<EmailMassHelper.EmailDefination>();
            String adresse = Label.OWEmailAddressesNoReply;
            OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :adresse];
            for (Account ac : accDuplicateSet) {
                EmailMassHelper.EmailDefination myEmail = new EmailMassHelper.EmailDefination();
                myEmail.emailHtmlBody = 'Il y a plus qu\'une offre HT pour le pro ' + ac.Id;
                myEmail.fromAddress = owea.Id;
                myEmail.toAddressList = new String[]{System.Label.DL_SGDBF_supervision_processus};
                myEmail.emailSubject = '[ERROR] from SubscriptionProductChargeTrigger';
                emailList.add(myEmail);
            }
            if (emailList.size() > 0) {
                EmailMassHelper.sendEmailMass(emailList);
            }
        }     

        // Add by Qiuyan
       SubscriptionProductChargeMethods.CancelSubscription(Trigger.oldMap, Trigger.newMap);
    }
    
}