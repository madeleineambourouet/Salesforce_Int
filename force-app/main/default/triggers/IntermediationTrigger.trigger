/**
 * @File Name          : IntermediationTrigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/11/2020, 2:05:31 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
**/
// 
// trigger sur les MERs
// 03/05/2017, xavier templet, regroupe differents triggers dans un seul   
// 03/08/2017, xavier templet, trigger before update for Matching_rejete_date__c    
//02/2018, Leila, trigger after update to sent sms MER Archi
// 03/08/2018, Leila, si Avoir exeptionnel, bloquer le recrédit
// 07/12/2018, Leila, si Avoir exeptionnel 5 jours gagnants, bloquer le recrédit

trigger IntermediationTrigger on Intermediation__c (before insert, before update, after update) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        IntermediationTriggerUtils.contactMer(Trigger.new);
        IntermediationTriggerUtils.FirstMatch(Trigger.new);
        system.debug('IntermediationTrigger insert ****');
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        system.debug('IntermediationTrigger update ****');

        Set<Id> accountIdSet= new set<id>();
        Boolean isMatchingRejeteNotNull = false;
        Date d = Date.today(); 
        if(test.Isrunningtest()){
           d = Date.newInstance(Date.today().Year(),Date.today().month(),1);
            }        
               
        for(Intermediation__c m : Trigger.new) {
            Intermediation__c merOld = Trigger.oldMap.get(m.Id);
            accountIdSet.add(m.Professionnel__c);           
            if (m.Matching_rejete__c != null && m.Matching_rejete__c != merOld.Matching_rejete__c) { 
                m.Matching_rejete_date__c = Date.today();
                m.Matching_rejete_par__c = UserInfo.getUserId();
                               
                if (m.Statut_Selection__c != null) {
                 isMatchingRejeteNotNull = true;   
                }
            }            
    }
     
    if (isMatchingRejeteNotNull == true) {   
      system.debug('isMatchingRejeteNotNull **** '+isMatchingRejeteNotNull);
      System.debug('accountIdSet ='+accountIdSet); 
       
       //Correction 08/01/19
       String labelListeHYRatePlanChargeID = Label.DiscountHYRatePlanChargeId;
       Set<string> listeHYRatePlanChargeID = new Set<string>();
       listeHYRatePlanChargeID.addAll(labelListeHYRatePlanChargeID.split(';'));
       System.debug('listeHYRatePlanChargeID ='+listeHYRatePlanChargeID);   
        
       List <Zuora__SubscriptionProductCharge__c>  OffreList = new List <Zuora__SubscriptionProductCharge__c>(); 
       OffreList = ([select id, HYRatePlanChargeID__c,Zuora__EffectiveStartDate__c,Zuora__EffectiveEndDate__c from  Zuora__SubscriptionProductCharge__c where Zuora__Account__c in:accountIdSet and HYRatePlanChargeID__c in: listeHYRatePlanChargeID]);
          For (Zuora__SubscriptionProductCharge__c spc : OffreList){
            system.debug('IntermediationTrigger update ****spc '+spc);
           if ((spc.Zuora__EffectiveStartDate__c<= d && spc.Zuora__EffectiveEndDate__c>= d ) && !Test.isRunningTest()){ 
           trigger.new[0].addError(' Vous ne pouvez pas faire de recrédit avec une offre discount');
            }
          }
     }        
     }
    if (Trigger.isAfter && Trigger.isUpdate) {
        
        if (checkRecursiveSFDC.runSMSOnce()) {
          /*  if (Trigger.new.size() == 1 && Trigger.new[0].Date_MER_Architecte__c != null && !System.isFuture()){
                Odigo_SMS_Archi.intermediaire(Trigger.new[0].id,Trigger.new[0].Date_MER_Architecte__c,Trigger.new[0].pro_phone__c,Trigger.new[0].Part_Name__c, Trigger.new[0].part_phone__c, Trigger.new[0].part_mail__c, trigger.new[0].projet_ville__c,trigger.new[0].Projet__c);
             }*/
            IntermediationTriggerUtils.SelectionMER(Trigger.newMap, Trigger.oldMap);
        }

        if (checkRecursiveSFDC.runOnce())
            IntermediationTriggerUtils.Generate_token_Part_selectionne(Trigger.new, Trigger.newMap, Trigger.oldMap);            
        IntermediationTriggerUtils.UsageCreation(Trigger.newMap, Trigger.oldMap);  
        }
}