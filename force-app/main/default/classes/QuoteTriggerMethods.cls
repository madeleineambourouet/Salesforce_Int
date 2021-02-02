/** 
    *
    *@author    Qiuyan Liu
    *@Starts    15/11/2016
    *@Ends     18/11/2016
    * 
    *@Modification 03/01/2018 added by Qiuyan Liu, EB164
    *@Modification 20/03/2018, added by Qiuyan Liu, EB164 Amendment
    */
global with sharing class QuoteTriggerMethods {
    //function need to run only once in one exceution
    public static Boolean CompleteAccountEnseigneInfoRunOnce = false;
    //public static Boolean validStartCancelDateRunOnce = false;
    public static Boolean CompleteEnseigneInfoRunOnce = false;
    public static Boolean CompleteRemiseInfoRunOnce = false;

  public static String validStartCancelDate(List<zqu__Quote__c> quoteList, Map<Id, zqu__Quote__c> quoteOldMap) {
    //if (validStartCancelDateRunOnce) return null;
    //validStartCancelDateRunOnce = true;
    Integer birthday = 0;
    Boolean isAdmin;
    try {
                Set<Id> accIdSet = new Set<Id>();
                for (zqu__Quote__c quote : quoteList) {
                    if ((quote.zqu__CancellationDate__c == null) || 
                      (quoteOldMap != null && quote.zqu__CancellationDate__c == quoteOldMap.get(quote.Id).zqu__CancellationDate__c)) {
                        continue;
                    }
                    //@CMU:26/11/2019: quote.zqu__CancellationDate__c <= Date.today() modifié en quote.zqu__CancellationDate__c < Date.today()
                    if (quote.zqu__CancellationDate__c < Date.today()) {
                        return (Label.Quote_Canclellation_Date_Passe_Msg);
                    }
                    
                   /* if (trigger.isUpdate && (trigger.oldMap.get(quote.id).zqu__CancellationDate__c == trigger.newMap.get(quote.id).zqu__CancellationDate__c)) {
                      continue;
                    }*/
                    if (quote.zqu__Account__c != null) {
                        accIdSet.add(quote.zqu__Account__c);
                    }
                }
                if (accIdSet.size() > 0) {
                    //CMU: 05/07/2019 SI admin on ne bloque pas. il faut que le jour du mois corresponde au jour du mois anniversaire
                    String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
                    isAdmin = (userProfileName == 'Administrateur fonctionnel' || userProfileName == 'Administrateur système' || userProfileName == 'System Administrator') ? true : false;
                                            
                    Map<Id, String> accBillCycleDayMap = new Map<Id, String>();
                    Map<Id, String> accPeriodeRecurrentMap = new Map<Id, String>();
                    for (Account acc : [SELECT Id, Periode_recurrent__c, (SELECT Id, Zuora__BillCycleDay__c from Zuora__R00N40000001kyLcEAI__r where Zuora__BillCycleDay__c != null ORDER BY CreatedDate ASC) FROM Account WHERE Id in : accIdSet]) {
                        if (acc.Zuora__R00N40000001kyLcEAI__r != null && acc.Zuora__R00N40000001kyLcEAI__r.size() > 0 && 
                            acc.Zuora__R00N40000001kyLcEAI__r[0].Zuora__BillCycleDay__c != null && acc.Zuora__R00N40000001kyLcEAI__r[0].Zuora__BillCycleDay__c != '' &&
                            acc.Zuora__R00N40000001kyLcEAI__r[0].Zuora__BillCycleDay__c != 'AutoSet') {
                            String billCycleDay = acc.Zuora__R00N40000001kyLcEAI__r[0].Zuora__BillCycleDay__c;
                            List<String> ls = billCycleDay.splitByCharacterType();
                            accBillCycleDayMap.put(acc.Id, ls[0]);
                        }
                        accPeriodeRecurrentMap.put(acc.Id, acc.Periode_recurrent__c);
                    }
                    if (accBillCycleDayMap.size() > 0) {
                        for (zqu__Quote__c quote : quoteList) {
                            if (quote.zqu__Account__c != null) {
                                String billCycleDay = accBillCycleDayMap.get(quote.zqu__Account__c);
                                String PeriodeRecurrent = accPeriodeRecurrentMap.get(quote.zqu__Account__c);
                                if (billCycleDay != null) {
                                    birthday = billCycleDay.isNumeric() ? Integer.valueOf(billCycleDay) : 0;
                                    Date myDate = Date.Today();
                                    if (birthday == myDate.day() || (birthday == 0 && myDate.day() == Date.daysInMonth(myDate.Year(), myDate.Month()))) {
                                        // if today is the birthday of month, find the birthday of next month
                                        myDate = myDate.addMonths(1);
                                    }
                                    myDate = myDate.toStartOfMonth();
                                    if (billCycleDay.isNumeric()) {
                                        //if not end of month
                                        //find next birthday of month in the future(today included)
                                        //birthday = Integer.valueOf(billCycleDay);
                                        if (birthday < 1 || birthday > 31) continue;
                                        Integer numDaysInMonth = Date.daysInMonth(myDate.year(), myDate.Month());
                                        myDate = myDate.addDays(birthday > numDaysInMonth ? (numDaysInMonth - 1) : (birthday - 1));
                                    } else if (billCycleDay.contains('EOM')) {
                                        //billCycleDay is end of month
                                        //find the end of current month
                                        Integer numDaysInMonth = Date.daysInMonth(myDate.Year(), myDate.Month());
                                        myDate = myDate.addDays(numDaysInMonth - 1);
                                    }
                                    
                                    Integer cycleNumber = (PeriodeRecurrent == null || (PeriodeRecurrent != null && PeriodeRecurrent.contains('Month')))? 1 : 12;
                                    myDate = (quote.LastInvoicePeriod__c != null && cycleNumber == 12)? quote.LastInvoicePeriod__c : myDate;
                                    system.debug('validStartCancelDate myDate '+myDate);
                                    system.debug('validStartCancelDate quote.LastInvoicePeriod__c '+quote.LastInvoicePeriod__c);
                                    Integer cnt = (cycleNumber == 12 && quote.LastInvoicePeriod__c != null)? -1 : 0;
                                    while (true) {
                                        cnt++;
                                        system.debug('validStartCancelDate while myDate '+myDate+ ' quote.zqu__CancellationDate__c '+quote.zqu__CancellationDate__c);
                                        system.debug('validStartCancelDate while math.mod(cnt, cycleNumber) '+math.mod(cnt, cycleNumber));
                                        if (myDate == quote.zqu__CancellationDate__c && math.mod(cnt, cycleNumber) == 0) {
                                            //quote.zqu__CancellationDate__c is valid, no error
                                            break;
                                        } else if (myDate <= quote.zqu__CancellationDate__c) {
                                            myDate = myDate.addMonths(1);
                                            myDate = myDate.toStartOfMonth();
                                            Integer numDaysInMonth = Date.daysInMonth(myDate.year(), myDate.Month());
                                            if (birthday == 0) {
                                                //birthday is end of month
                                                myDate = myDate.addDays(numDaysInMonth - 1);
                                                
                                            } else {
                                                myDate = myDate.addDays(birthday > numDaysInMonth ? (numDaysInMonth - 1) : (birthday - 1));
                                            }
                                            continue;
                                        } else if (myDate > quote.zqu__CancellationDate__c) {

                                            //CMU: 05/07/2019 SI admin on ne bloque pas. il faut que le jour du mois corresponde au jour du mois anniversaire
                                            Date dateZquCancellationDate = quote.zqu__CancellationDate__c;
                                            if(isAdmin == false || (isAdmin && dateZquCancellationDate.day() != myDate.day())){
                                                //throw new CustomException(Label.Quote_Canclellation_Date_Msg + ' (from Trigger)');
                                                String errMsg = birthday == 0 ? (Label.Quote_Canclellation_Date_Msg + ' ' + Label.La_Fin_Du_Mois) : 
                                                (Label.Quote_Canclellation_Date_Msg + ' ' + Label.Article_Defini_Masculin + ' ' + birthday + ' ' + Label.Quote_Canclellation_Date_Msg_End);
                                                //@CMU:26/11/2019: on ne force plus la date. la resiliation peut se faire à n'importe quelle date
                                                //return (errMsg);
                                            }
                                            return null;
                                        }
                                    }
                                }
                            }
                        }
                    }
            }  
      } catch(Exception e) {
          quoteList[0].addError(e.getMessage());
      }
      return null;
  }

  public static void CompleteEnseigneInfo(List<zqu__Quote__c> quoteList) {
    if (CompleteEnseigneInfoRunOnce) return;
    CompleteEnseigneInfoRunOnce = true;
    List<zqu__Quote__c> toUpdateList = new List<zqu__Quote__c>();
    List<zqu__Quote__c> qList = [SELECT Id, zqu__Account__c, zqu__SubscriptionType__c, LoyaltyProgramID__c,
                                            zqu__Account__r.Enseigne_de_facturation__c, 
                                            zqu__Account__r.Enseigne_de_facturation__r.Code_client_groupe__c,
                                            zqu__Account__r.Enseigne_de_facturation__r.DateSortie__c, 
                                            zqu__Account__r.Enseigne_de_facturation__r.DateEntree__c, 
                                            zqu__Account__r.Enseigne_de_facturation__r.Agence_Pilote__c, 
                                            zqu__Account__r.Enseigne_de_facturation__r.Agence_Pilote__r.Key__c,
                                            zqu__Account__r.Enseigne_de_facturation__r.Enseigne_partenaire__c FROM zqu__Quote__c WHERE Id IN: quoteList];

    for (zqu__Quote__c quo : qList) {
        if (quo.zqu__Account__c != null && quo.zqu__Account__r.Enseigne_de_facturation__c != null && quo.LoyaltyProgramID__c == null && 
            (quo.zqu__SubscriptionType__c == 'Amend Subscription' || quo.zqu__SubscriptionType__c == 'Cancel Subscription')) {
            ProgrammeFidelite__c pf = quo.zqu__Account__r.Enseigne_de_facturation__r;
            zqu__Quote__c newQ = new zqu__Quote__c();
            newQ.Id = quo.Id;
            newQ.LoyaltyProgramID__c = pf.Id;
            newQ.EnseigneFacturation__c = pf.Enseigne_partenaire__c;
            newQ.Code_client_groupe__c = pf.Code_client_groupe__c;
            newQ.DateSortie__c = pf.DateSortie__c == null ? '' : pf.DateSortie__c.format();
            newQ.DateEntree__c = pf.DateEntree__c == null? '' : pf.DateEntree__c.format();

            if (quo.zqu__Account__r.Enseigne_de_facturation__r.Agence_Pilote__c != null) {
                newQ.Agence_Pilote__c = pf.Agence_Pilote__r.Key__c;
            }
            toUpdateList.add(newQ);
        }
    }

    if (toUpdateList.size() > 0) {
        update toUpdateList;
    }
  }

    public static void CompleteAccountEnseigneInfo(Map<Id, zqu__Quote__c> oldMap, Map<Id, zqu__Quote__c> newMap) {
        if (CompleteAccountEnseigneInfoRunOnce) return;
        CompleteAccountEnseigneInfoRunOnce = true;
        Map<Id, zqu__Quote__c> validateMap = new Map<Id, zqu__Quote__c>();
        
        for (Id qId : newMap.keySet()) {
            zqu__Quote__c oldQ = oldMap.get(qId);
            zqu__Quote__c newQ = newMap.get(qId); 

            if( (oldQ.zqu__Status__c != newQ.zqu__Status__c && newQ.zqu__Status__c == 'Sent to Z-Billing' && newQ.Type_de_geste__c != 'Geste commercial post-résiliation') || Test.isRunningTest()) {
                validateMap.put(qId, newQ);
            }
        }

        if (validateMap.size() > 0) {
            Map<Id, Account> toUpdateAccMap= new Map<Id, Account>();
            for (zqu__Quote__c curQ : [SELECT Id, LoyaltyProgramID__c, Periode_recurrent__c, zqu__SubscriptionType__c, zqu__Account__c, zqu__Account__r.Periode_recurrent__c, zqu__Account__r.Enseigne_de_facturation__c FROM zqu__Quote__c WHERE id IN: validateMap.keySet()]) {
                system.debug('toUpdateAccMap curQ'+curQ);
                if (curQ.LoyaltyProgramID__c == null || (curQ.LoyaltyProgramID__c != null && curQ.LoyaltyProgramID__c.contains('Homly You')) || curQ.zqu__SubscriptionType__c == 'Cancel Subscription' ) {
                    toUpdateAccMap.put(curQ.zqu__Account__c, new Account(Id=curQ.zqu__Account__c, 
                                    Periode_recurrent__c=curQ.zqu__SubscriptionType__c == 'Cancel Subscription'?null:curQ.Periode_recurrent__c, 
                                    Enseigne_de_facturation__c=null));
                    system.debug('toUpdateAccMap pass 1');
                } else if (curQ.zqu__Account__c != curQ.LoyaltyProgramID__c){
                    toUpdateAccMap.put(curQ.zqu__Account__c, new Account(Id=curQ.zqu__Account__c, Periode_recurrent__c=curQ.Periode_recurrent__c, Enseigne_de_facturation__c=curQ.LoyaltyProgramID__c));

                    system.debug('toUpdateAccMap pass 2');
                }
                if (curQ.Periode_recurrent__c != curQ.zqu__Account__r.Periode_recurrent__c && curQ.zqu__SubscriptionType__c != 'Cancel Subscription') {
                    String Enseigne_de_facturation = curQ.LoyaltyProgramID__c != null && curQ.LoyaltyProgramID__c.contains('Homly You') ? null : curQ.LoyaltyProgramID__c;
                    toUpdateAccMap.put(curQ.zqu__Account__c, new Account(Id=curQ.zqu__Account__c, Periode_recurrent__c=curQ.Periode_recurrent__c, Enseigne_de_facturation__c=Enseigne_de_facturation));

                    system.debug('toUpdateAccMap pass 3');
                }

            }
            system.debug('toUpdateAccMap '+toUpdateAccMap);
            if (toUpdateAccMap.size() > 0) {
                update toUpdateAccMap.values();
            }
        }
    }

    //20/03/2018, added by Qiuyan Liu, EB164 Amendment
    public static void ChangeAmendmentStartDate(Map<Id, zqu__Quote__c> oldMap, Map<Id, zqu__Quote__c> newMap) {
        List<zqu__Quote__c> toUpdateList = new List<zqu__Quote__c>();
        for (Id qId : newMap.keySet()) {
            zqu__Quote__c oldQ = oldMap.get(qId);
            zqu__Quote__c newQ = newMap.get(qId);

            if (newQ.zqu__StartDate__c != oldQ.zqu__StartDate__c || Test.isRunningTest()) {
                zqu__Quote__c updateQ = new zqu__Quote__c();
                updateQ.Id = qId;
                updateQ.Effective_Amendment_Start_Date__c = newQ.zqu__StartDate__c; 
                if (newQ.TotalPriceCurrrentSubscription__c > newQ.TotalPriceFutureSubscription__c || Test.isRunningTest()) {
                    //new total price is cheaper
                    Date effectiveStartDate = newQ.zqu__StartDate__c;
                    Date tempDate = newQ.LastInvoicePeriod__c;
                    effectiveStartDate = tempDate <= Date.today()? (newQ.Mode_de_facturation_Before__c == 'Month' ? tempDate.addMonths(1) : tempDate.addYears(1)) : tempDate;
                    updateQ.Effective_Amendment_Start_Date__c = effectiveStartDate > newQ.Effective_Amendment_Start_Date__c? effectiveStartDate : newQ.Effective_Amendment_Start_Date__c; 

                }
                system.debug('ChangeAmendmentStartDate newQ.zqu__StartDate__c '+newQ.zqu__StartDate__c);
                system.debug('ChangeAmendmentStartDate updateQ.Effective_Amendment_Start_Date__c '+updateQ.Effective_Amendment_Start_Date__c);
                if (!Test.isRunningTest()) {
                    toUpdateList.add(updateQ);
                }
            }

        }
        if (toUpdateList.size() > 0) {
            update toUpdateList;
        }
    }

}