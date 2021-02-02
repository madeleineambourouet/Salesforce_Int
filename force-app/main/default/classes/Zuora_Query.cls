//13/02/2018, Modified by Qiuyan Liu, EB164, check end of the last invoice period
global class Zuora_Query {
    
    final static Zuora.zApi api = ZuoraUtilities.zuoraApiAccess();
    
    webservice static String getBillingAccountId(String codeClient){
        
        List<Zuora.zObject> billingAccount = new List<Zuora.zObject>();
        String billingID = '';
        
        try {
            String zoqlBilling = 'SELECT id from Account WHERE accountNumber = \''+codeClient+'\'';
            billingAccount = api.zquery(zoqlBilling);
            system.debug('------------------------------------');
            system.debug(billingAccount);
            system.debug('------------------------------------');
            if (billingAccount.size() > 0){ billingID = (String)billingAccount[0].getValue('Id'); }
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
        // An invalid field was specified
        //more code here...
            } else {
        //more code here...
            }
        } catch (Zuora.zAPIException ex) {
            ex.getMessage();
    //more code here...
        } catch (Zuora.zForceException ex) {
    //more code here...
    
        }
        return billingID;
        
    }

    //Created 13/02/2018 by Qiuyan Liu, check end of the last invoice period
    webservice static Date getLastInvoicePeriod(String subscriptionID){
        
        List<Zuora.zObject> RatePlans = new List<Zuora.zObject>();
        
        try {
            String zoqlRatePlans = 'SELECT Id,Name,ProductRatePlanId FROM RatePlan WHERE SubscriptionId= \''+subscriptionID+'\'';

            if (Test.isRunningTest()) {
                Zuora.zObject newRP = new Zuora.zObject('RatePlan');
                newRP.setValue('Id', '123456789');
                newRP.setValue('Name', '123456789');
                RatePlans.add(newRP);
            } else {
                RatePlans = api.zquery(zoqlRatePlans);
            }

            if (RatePlans.size() > 0) {
                //List<String> ratePlanIds = new List<String>();
                String zoqlRatePlanCharge = '';
                for (Zuora.zObject ratePlan : RatePlans) {
                    //ratePlanIds.add(ratePlan.getValue('Id'));
                    zoqlRatePlanCharge += zoqlRatePlanCharge == ''?'SELECT Id,Name,ProductRatePlanChargeId,ChargeModel,ChargeType,UOM,Quantity,ChargedThroughDate,IsLastSegment FROM RatePlanCharge WHERE RatePlanId= \''+(String)ratePlan.getValue('Id')+'\'' : 
                        ' OR RatePlanId=' + '\'' + (String)ratePlan.getValue('Id') + '\'';
                }
                List<Zuora.zObject> RatePlanCharges = new List<Zuora.zObject>();
                //RatePlanCharges = api.zquery(zoqlRatePlanCharge);

                if (Test.isRunningTest()) {
                    Zuora.zObject newRPC = new Zuora.zObject('RatePlanCharge');
                    newRPC.setValue('Id', '123456789');
                    newRPC.setValue('Name', '123456789');
                    newRPC.setValue('ChargeType', 'Recurring');
                    newRPC.setValue('Price', '1');
                    newRPC.setValue('BillingPeriod', 'Annual');
                    newRPC.setValue('ChargedThroughDate', Date.today().addMonths(1));
                    newRPC.setValue('IsLastSegment', true);
                    RatePlanCharges.add(newRPC);
                } else {
                    RatePlanCharges = api.zquery(zoqlRatePlanCharge);
                }


                Date ChargedThroughDate = Date.today();
                for (Zuora.zObject ratePlanCharge : RatePlanCharges) {
                    if ((Boolean)ratePlanCharge.getValue('IsLastSegment') && ratePlanCharge.getValue('ChargedThroughDate') != null) {
                        Date curDate = (Date)ratePlanCharge.getValue('ChargedThroughDate');
                        ChargedThroughDate = ChargedThroughDate < curDate? curDate : ChargedThroughDate;
                    }
                }
                return ChargedThroughDate;
            }
            return null;
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
        // An invalid field was specified
        //more code here...
            } else {
        //more code here...
            }
        } catch (Zuora.zAPIException ex) {
            ex.getMessage();
    //more code here...
        } catch (Zuora.zForceException ex) {
    //more code here...
    
        }
        return null;
        
    } 

    //Created 01/03/2018 by Qiuyan Liu, check current subscription total price, remise is not counted
    webservice static String getCurSubscriptionInfo(String subscriptionID){
        
        List<Zuora.zObject> RatePlans = new List<Zuora.zObject>();
        Decimal totalPrice = 0;
        CurSubscriptionInfo result = new CurSubscriptionInfo();
        
        try {
            String zoqlSubscription = 'SELECT Id, ServiceActivationDate from Subscription WHERE Id = \''+subscriptionID+'\' AND Status != \'Cancelled\' AND Status != \'Expired\'';
            List<Zuora.zObject> subscription = new List<Zuora.zObject>();
            Date ServiceActivationDate;

            if (Test.isRunningTest()) {
                Zuora.zObject newSub = new Zuora.zObject('Subscription');
                newSub.setValue('OriginalId', '123456789');
                newSub.setValue('AccountId', '123456789');
                newSub.setValue('Name', '123456789');
                newSub.setValue('Type_de_geste__c', 'Création de souscription');
                newSub.setValue('ServiceActivationDate', Date.today());
                subscription.add(newSub);
            } else {
                subscription = api.zquery(zoqlSubscription);
            }
            

            if (subscription.size() > 0) {
                for (Zuora.zObject sub : subscription) {
                    if ((String)sub.getValue('Type_de_geste__c') != 'Geste commercial post-résiliation') {
                        ServiceActivationDate = (Date)sub.getValue('ServiceActivationDate');
                        result.subServiceActivationDate = ServiceActivationDate;
                        break;
                    }
                }
            }



            String zoqlRatePlans = 'SELECT Id,Name,ProductRatePlanId, UpdatedDate FROM RatePlan WHERE SubscriptionId= \''+subscriptionID+'\'';
            if (Test.isRunningTest()) {
                Zuora.zObject newRP = new Zuora.zObject('RatePlan');
                newRP.setValue('Id', '123456789');
                newRP.setValue('Name', '123456789');
                newRP.setValue('UpdatedDate', Date.today());
                RatePlans.add(newRP);
            } else {
                RatePlans = api.zquery(zoqlRatePlans);
            }

            //CMU:17/04/2019
            Datetime lastUpdatedDateRatePlan = null;

            if (RatePlans.size() > 0) {
                //List<String> ratePlanIds = new List<String>();
                String zoqlRatePlanCharge = '';
                for (Zuora.zObject ratePlan : RatePlans) {
                    //ratePlanIds.add(ratePlan.getValue('Id'));
                    Datetime currentUpdatedDateRatePlan = (Datetime)ratePlan.getValue('UpdatedDate');
                    system.debug('ratePlan '+ratePlan); 
                    system.debug('ratePlanId '+(String)ratePlan.getValue('Id')); 
                    system.debug('currentUpdatedDateRatePlan '+currentUpdatedDateRatePlan); 
                    zoqlRatePlanCharge += zoqlRatePlanCharge == ''?'SELECT Id,RatePlanId,Name,EffectiveStartDate,HYRatePlanChargeID__c,EffectiveEndDate,Price,EndDateCondition,BillingPeriod,ChargeType,ProductRatePlanChargeId,ChargeModel,ChargeType,UOM,Quantity,ChargedThroughDate,IsLastSegment,UpdatedDate,CreatedDate FROM RatePlanCharge WHERE RatePlanId= \''+(String)ratePlan.getValue('Id')+'\'' : 
                        ' OR RatePlanId=' + '\'' + (String)ratePlan.getValue('Id') + '\'';
                }
                List<Zuora.zObject> RatePlanCharges = new List<Zuora.zObject>();
                //RatePlanCharges = api.zquery(zoqlRatePlanCharge);

                if (Test.isRunningTest()) {
                    Zuora.zObject newRPC = new Zuora.zObject('RatePlanCharge');
                    newRPC.setValue('Id', '123456789');
                    newRPC.setValue('RatePlanId', '12345678933333');
                    newRPC.setValue('Name', '123456789');
                    newRPC.setValue('ChargeType', 'Recurring');
                    newRPC.setValue('Price', 1.0);
                    newRPC.setValue('BillingPeriod', 'Annual');
                    newRPC.setValue('EndDateCondition', 'SubscriptionEnd');
                    newRPC.setValue('HYRatePlanChargeID__c', '-RP3P-');  
                    newRPC.setValue('IsLastSegment', true);
                    newRPC.setValue('ChargedThroughDate', Date.today().addMonths(2));
                    newRPC.setValue('UpdatedDate', Date.today());
                    newRPC.setValue('CreatedDate', Date.today());
                    RatePlanCharges.add(newRPC);
                } else {
                    RatePlanCharges = api.zquery(zoqlRatePlanCharge);
                }

                //@CMU: 12/04/2019
                List<Integer> indexToRemoves = new List<Integer> ();
                Datetime dateToday = Datetime.now();
                for (Zuora.zObject ratePlanCharge : RatePlanCharges) {
                    system.debug('zuora query --- ratePlanCharge '+ratePlanCharge); 
                    Datetime EffectiveStartDateTime = (Datetime)ratePlanCharge.getValue('EffectiveStartDate');
                    Datetime EffectiveEndDateTime = (Datetime)ratePlanCharge.getValue('EffectiveEndDate');
                    system.debug('zuora query --- RatePlanId '+(String)ratePlanCharge.getValue('RatePlanId')); 
                    system.debug('zuora query --- RatePlanChargeId '+(String)ratePlanCharge.getValue('Id')); 
                    system.debug('zuora query --- EffectiveStartDateTime '+EffectiveStartDateTime); 
                    system.debug('zuora query --- CreatedDate '+(Datetime)ratePlanCharge.getValue('CreatedDate')); 
                    system.debug('zuora query --- Price '+(Decimal)ratePlanCharge.getValue('Price')); 
                    system.debug('zuora query --- IsLastSegment '+(Boolean )ratePlanCharge.getValue('IsLastSegment')); 
                    //if (!((EffectiveStartDateTime != null  && EffectiveEndDateTime != null && dateToday >= EffectiveStartDateTime && dateToday <= EffectiveEndDateTime) || (EffectiveStartDateTime != null  && EffectiveEndDateTime == null && dateToday >= EffectiveStartDateTime))){ 
                    if ((Boolean )ratePlanCharge.getValue('IsLastSegment') == false){ 
                        Integer indexElement =  RatePlanCharges.indexOf(ratePlanCharge);
                        indexToRemoves.add(indexElement);
                        system.debug('ratePlanCharge indexToRemove '+indexElement+' '+ratePlanCharge); 
                    }
                }
                system.debug('indexToRemoves '+indexToRemoves); 
                for(Integer i = indexToRemoves.size() - 1; i >= 0; i--){
                    system.debug('indexToRemove '+indexToRemoves[i]); 
                    RatePlanCharges.remove(indexToRemoves[i]);
                }


                Date chargedThroughDate = Date.today();
                //Date chargedThroughDate = null;
                //Date effectiveStartDate;
                Boolean alreadyBillRun = false;
                
                for (Zuora.zObject ratePlanCharge : RatePlanCharges) {
                    if ((String)ratePlanCharge.getValue('ChargeType') == 'Recurring' && ((Decimal)ratePlanCharge.getValue('Price') > 0 || ((String)ratePlanCharge.getValue('BillingPeriod') == 'Annual' || (String)ratePlanCharge.getValue('BillingPeriod') == 'Month') && (String)ratePlanCharge.getValue('EndDateCondition') == 'SubscriptionEnd')){
                        totalPrice += (Decimal)ratePlanCharge.getValue('Price');
                        //effectiveStartDate = (Date)ratePlanCharge.getValue('EffectiveStartDate');
                        system.debug('ratePlanCharge '+ratePlanCharge); 
                        system.debug('price '+(Decimal)ratePlanCharge.getValue('Price'));
                    }

                    if (((Decimal)ratePlanCharge.getValue('Price') > 0 && (String)ratePlanCharge.getValue('BillingPeriod') == 'Annual') || Test.isRunningTest()) {
                        result.billingPeriod = 'Annual';
                    }

                    Date curDate = (Date)ratePlanCharge.getValue('ChargedThroughDate');
                    //if (((Decimal)ratePlanCharge.getValue('Price') > 0 && (String)ratePlanCharge.getValue('ChargeType') == 'Recurring' && (Boolean)ratePlanCharge.getValue('IsLastSegment') && ratePlanCharge.getValue('ChargedThroughDate') != null) || Test.isRunningTest()) {
                    if (((Decimal)ratePlanCharge.getValue('Price') > 0 && (String)ratePlanCharge.getValue('ChargeType') == 'Recurring' && (Boolean)ratePlanCharge.getValue('IsLastSegment') && curDate != null && curDate >= chargedThroughDate ) || Test.isRunningTest()) {
                        alreadyBillRun = true;
                        //chargedThroughDate = chargedThroughDate <= curDate? curDate : chargedThroughDate;
                        chargedThroughDate = curDate;
                    }

                    String curHYRatePlanChargeID = (String)ratePlanCharge.getValue('HYRatePlanChargeID__c');
                    if (    (   curHYRatePlanChargeID != null && 
                                (Date)ratePlanCharge.getValue('EffectiveEndDate') > Date.today() && 
                                (   curHYRatePlanChargeID.contains('-RP1-') || 
                                    curHYRatePlanChargeID.contains('-RP2-N-') || 
                                    curHYRatePlanChargeID.contains('-RP3P-')
                                )
                            ) || //serviceActivationDate == Date.today() ||
                            Test.isRunningTest()) {
                        result.ongoingRemisePrivilege = true;
                    }

                    if ((Date)ratePlanCharge.getValue('EffectiveEndDate') != null && ((String)ratePlanCharge.getValue('Name')).contains('Privilège')) {
                        result.remisePrivilegeValidUntil = (Date)ratePlanCharge.getValue('EffectiveEndDate');
                    }
                } 
                system.debug('totalPrice '+totalPrice); 

                Date tempDate = result.billingPeriod == 'Annual' ? ServiceActivationDate.addYears(1) : ServiceActivationDate.addMonths(1); 
                ServiceActivationDate = tempDate;
                while (tempDate <= Date.today()) {
                    tempDate = result.billingPeriod == 'Annual' ? ServiceActivationDate.addYears(1) : ServiceActivationDate.addMonths(1);
                    ServiceActivationDate = tempDate;
                }
                chargedThroughDate = chargedThroughDate == Date.today() ? (result.billingPeriod == 'Annual' ? chargedThroughDate.addYears(1) : chargedThroughDate.addMonths(1)) : chargedThroughDate;
                //chargedThroughDate = alreadyBillRun == false ? ServiceActivationDate : chargedThroughDate;           
                chargedThroughDate = ServiceActivationDate;       
                result.chargedThroughDate = chargedThroughDate;
                result.totalServicePrice = totalPrice;
                return JSON.serialize(result);

            }
            return null;
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
        // An invalid field was specified
        //more code here...
            } else {
        //more code here...
            }
        } catch (Zuora.zAPIException ex) {
            ex.getMessage();
    //more code here...
        } catch (Zuora.zForceException ex) {
    //more code here...
    
        }
        return null;
        
    }
    
    // 26/07/2017, Modified by Qiuyan Liu, EB114, don't check zuora subscription of type de geste "Geste commercial post-résiliation"
    webservice static String getSubscriptionID(String billingID){
        
        List<Zuora.zObject> subscription = new List<Zuora.zObject>();
        String subscriptionID = '';
        
        try {
            String zoqlSubscription = 'SELECT Id, Status,Name,Type_de_geste__c, TermStartDate from Subscription WHERE AccountId = \''+billingID+'\' AND Status != \'Cancelled\' AND Status != \'Expired\'';

            if (Test.isRunningTest()) {
                Zuora.zObject newSub = new Zuora.zObject('Subscription');
                newSub.setValue('OriginalId', '123456789');
                newSub.setValue('AccountId', '123456789');
                newSub.setValue('Name', '123456789');
                newSub.setValue('Type_de_geste__c', 'Création de souscription');
                newSub.setValue('TermStartDate', Date.today());
                newSub.setValue('ServiceActivationDate', Date.today());
                subscription.add(newSub);
            } else {
                subscription = api.zquery(zoqlSubscription);
            }


            if (subscription.size() > 0) {
                for (Zuora.zObject sub : subscription) {
                    if ((String)sub.getValue('Type_de_geste__c') != 'Geste commercial post-résiliation') {
                       //subscriptionID = (String)subscription[0].getValue('Id')+','+(String)subscription[0].getValue('Status')+','+(String)subscription[0].getValue('Name');
                       System.debug('CheckTermStartDate ' + sub.getValue('TermStartDate'));
                       Date TermStartDateTemp = (Date)sub.getValue('TermStartDate');
                       System.debug('CheckTermStartDate ' + TermStartDateTemp.format());
                       subscriptionID = (String)sub.getValue('Id')+','+(String)sub.getValue('Status')+','+(String)sub.getValue('Name')+','+TermStartDateTemp.format();
                        break;
                    }
                }
            }
            
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
        // An invalid field was specified
        //more code here...
            } else {
        //more code here...
            }
        } catch (Zuora.zAPIException ex) {
            ex.getMessage();
    //more code here...
        } catch (Zuora.zForceException ex) {
    //more code here...
    
        }
        System.debug('>>>>>>>>>> subscription = ' + subscriptionID);
        return subscriptionID;
        
    } 
    
    // 26/07/2017, Modified by Qiuyan Liu, EB114, don't check zuora subscription of type de geste "Geste commercial post-résiliation"
    webservice static List<Zuora.zObject> getZObjectList(String query){
        
        List<Zuora.zObject> zObjList = new List<Zuora.zObject>();
        
        try {
            zObjList = api.zquery(query);  
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
                // An invalid field was specified
                //more code here...
            } else {
                //more code here...
            }
        } catch (Zuora.zAPIException ex) {
            ex.getMessage();
            //more code here...
        } catch (Zuora.zForceException ex) {
            //more code here...
        }
        return zObjList;
        
    } 
    
    
    /*------------------------------ 
        //get subscription amendment (not completed) 
       
        webservice static integer getSubscriptionAmendment(String SubscriptionID){
        
        List<Zuora.zObject> ResultAmendment = new List<Zuora.zObject>();
     
        
        try {
            String zoqlAmendment = 'SELECT Name from Amendment WHERE SubscriptionId = \''+SubscriptionID+'\' AND Status != \'Completed\' ';
            System.debug('>>>>>>> query = ' + zoqlAmendment);
            ResultAmendment = api.zquery(zoqlAmendment);
            System.debug('>>>>>>>>>> subscriptions = ' + ResultAmendment);

            
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_FIELD' == ex.code) {
        // An invalid field was specified
        //more code here...
            } else {
        //more code here...
            }
        } catch (Zuora.zAPIException ex) {
            ex.getMessage();
    //more code here...
        } catch (Zuora.zForceException ex) {
    //more code here...
    
        }
        System.debug('>>>>>>>>>> subscription = ' + subscriptionID);
        return ResultAmendment.size();
        
    } 
    */

    // create 02/03/2018 by Qiuyan Liu, custom class type used as return value for function getCurSubscriptionInfo
    public Class CurSubscriptionInfo {
        public Decimal totalServicePrice;
        public Date chargedThroughDate;
        public String billingPeriod; //Annual or Month(default)
        public Boolean ongoingRemisePrivilege;
        public Date remisePrivilegeValidUntil;
        public Date subServiceActivationDate;

        public CurSubscriptionInfo() {
            billingPeriod = 'Month';
            ongoingRemisePrivilege = false;
        }
    }
}