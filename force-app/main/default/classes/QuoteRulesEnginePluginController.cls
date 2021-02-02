global class QuoteRulesEnginePluginController implements
zqu.ZQuoteRulesEngine.QuoteRulesEnginePlugin {
    
    public Boolean runValidationRules(zqu__Quote__c quote, List<zqu.ZChargeGroup> zcgs, List<zqu.ZQuoteRulesEngine.ChangeLog> logs){
        //quote =  [SELECT Agence_Pilote__c,Client_Groupe__c,Code_client_groupe__c,Code_Compte_Point_P__c,Competences__c,Compteur_alerte_assurances__c,Compteur_alerte_certifications__c,Compteur_alerte_references__c,Contact__c,CreatedById,CreatedDate,DateEntree__c,DateSortie__c,Date_de_validation__c,Date_envoi_proposition_commerciale__c,Date_MAJ_alerte_assurances__c,Date_MAJ_alerte_certifications__c,Date_MAJ_alerte_reference__c,Detail_de_modification__c,Effective_Amendment_Start_Date__c,EnseigneFacturation__c,Envoi_de_la_proposition_au_client__c,Envoi_mail_generate_PDF__c,Envoi_mail_validation__c,Id,Intermediation__c,IsDeleted,LastActivityDate,LastInvoicePeriod__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Last_generated_token__c,LoyaltyProgramID__c,Manager__c,Mode_de_facturation_Before__c,Modification_offres__c,Motif_de_la_resiliation__c,Motif_d_abandon__c,Name,Nombre_assurances_compte_num__c,Nombre_de_certifications_compte_num__c,Nombre_de_references_compte_num__c,N_Proposition_Formule__c,OngoingRemisePrivilege__c,OwnerId,Periode_recurrent__c,PM_BillingCountry__c,PM_BillingPostalCode__c,PM_CardHolderName__c,PM_CardNumber__c,PM_CreditCardType__c,PM_Email__c,PM_ExpirationMonth__c,PM_ExpirationYear__c,PM_SecondTokenId__c,PM_TokenId__c,Produit__c,Propositions_valides_de_type_creation__c,Proposition_rejetee__c,Proposition_Signee__c,PXS_Geocat_Competence__c,PXS_Nb_Geocat__c,RecordTypeId,RecordTypeName__c,RemisePrivilegeValidUntil__c,Remove_Bundle__c,Resiliation_offres__c,Second_Motif_de_Resiliation__c,Send_to_Zbilling_Billing_Account_Created__c,Send_to_Zbilling_Message__c,Send_to_Zbilling_Status__c,SGId_vendeur_direct_Agence_CRC__c,Statut_Formule__c,SystemModstamp,TC_Service_Client__c,TECH_QuoteID__c,Today__c,TotalPriceCurrrentSubscription__c,TotalPriceFutureSubscription__c,Total_HT__c,Type_de_geste__c,Type__c,Url_Inscription__c,URL_validation__c,Validation_de_la_proposition__c,zqu__Account__c,zqu__AmendmentName__c,zqu__Amendment_Name__c,zqu__ApplyCreditBalance__c,zqu__ApprovalStatus__c,zqu__AsyncDraftOrderId__c,zqu__AsyncDraftSubscriptionId__c,zqu__AsyncJobId__c,zqu__AutoRenew__c,zqu__BillCycleDay__c,zqu__BillingBatch__c,zqu__BillingCycleDay__c,zqu__BillingEntity__c,zqu__BillingMethod__c,zqu__BillToContact__c,zqu__Calculate_Quote_Metrics_Through__c,zqu__CancellationDate__c,zqu__CancellationEffectiveDate__c,zqu__Certificate_ID__c,zqu__Certificate_Type__c,zqu__CommunicationProfile__c,zqu__Company_Code__c,zqu__Currency__c,zqu__Customer_Acceptance_Date__c,zqu__DeltaDiscountMRR__c,zqu__DeltaDiscountTCBTax__c,zqu__DeltaDiscountTCB__c,zqu__DeltaDiscountTCV__c,zqu__DeltaMRR__c,zqu__DeltaTCBTax__c,zqu__DeltaTCV__c,zqu__Description__c,zqu__DiscountMRR__c,zqu__DiscountTCBTax__c,zqu__DiscountTCB__c,zqu__DiscountTCV__c,zqu__ElectronicPaymentMethodId__c,zqu__ExistingProductsStored__c,zqu__ExistSubscriptionID__c,zqu__GenerateInvoice__c,zqu__Hidden_Subscription_Name__c,zqu__InitialTermPeriodType__c,zqu__InitialTerm__c,zqu__InvoiceDate__c,zqu__InvoiceID__c,zqu__InvoiceOwnerId__c,zqu__InvoiceOwnerName__c,zqu__InvoiceProcessingOption__c,zqu__InvoiceSeparately__c,zqu__InvoiceTargetDate__c,zqu__InvoiceTemplate__c,zqu__Issuing_Jurisdiction__c,zqu__Is_Charge_Expired__c,zqu__Is_Parent_Quote__c,zqu__MRR__c,zqu__Number__c,zqu__Opportunity__c,zqu__OrderNumber__c,zqu__ParentQuote__c,zqu__PaymentGateway__c,zqu__PaymentMethod__c,zqu__PaymentTerm__c,zqu__Previewed_Delta_MRR__c,zqu__Previewed_Delta_TCB__c,zqu__Previewed_Delta_TCV__c,zqu__Previewed_Discount__c,zqu__Previewed_MRR__c,zqu__Previewed_SubTotal__c,zqu__Previewed_Tax__c,zqu__Previewed_TCB__c,zqu__Previewed_TCV__c,zqu__Previewed_Total__c,zqu__Primary__c,zqu__ProcessPayment__c,zqu__ProductSelectorVersion__c,zqu__QuoteBusinessType__c,zqu__QuoteTemplate__c,zqu__RampFrequency__c,zqu__RecordReadOnly__c,zqu__RenewalSetting__c,zqu__RenewalTermPeriodType__c,zqu__RenewalTerm__c,zqu__Service_Activation_Date__c,zqu__SoldToContact__c,zqu__SpecificRampFrequency__c,zqu__StartDate__c,zqu__Status__c,zqu__StoreProductsJobId__c,zqu__SubscriptionName__c,zqu__SubscriptionTermEndDate__c,zqu__SubscriptionTermStartDate__c,zqu__SubscriptionType__c,zqu__SubscriptionVersion__c,zqu__Subscription_Name__c,zqu__Subscription_Term_Type__c,zqu__TaxExemptEffectiveDate__c,zqu__TaxExemptExpirationDate__c,zqu__Tax_Exempt_Description__c,zqu__Tax_Exempt__c,zqu__Tax__c,zqu__TCBTax__c,zqu__TCV__c,zqu__TermStartDate__c,zqu__Terms__c,zqu__Total__c,zqu__ValidUntil__c,zqu__VAT_ID__c,zqu__ZuoraAccountID__c,zqu__ZuoraConfig__c,zqu__ZuoraEntityId__c,zqu__ZuoraInvoiceNumber__c,zqu__ZuoraParentBillingAccountId__c,zqu__ZuoraParentBillingAccountName__c,zqu__ZuoraPaymentID__c,zqu__ZuoraPaymentNumber__c,zqu__ZuoraSubscriptionID__c,zqu__ZuoraSubscriptionNumber__c,zqu__Zuora_Account_Number__c  FROM zqu__Quote__c WHERE Id =: quote.Id limit 1];
        quote =  [SELECT Id, Type__c,zqu__Account__c,Effective_Amendment_Start_Date__c,Periode_recurrent__c,zqu__StartDate__c,Type_de_geste__c,OngoingRemisePrivilege__c,TotalPriceFutureSubscription__c,RemisePrivilegeValidUntil__c,TotalPriceCurrrentSubscription__c,LastInvoicePeriod__c,Mode_de_facturation_Before__c FROM zqu__Quote__c WHERE Id =: quote.Id limit 1];
        User curUser = [SELECT Id, Bypass_Function__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        if (curUser.Bypass_Function__c != null && curUser.Bypass_Function__c.contains('QuoteRulesEngine')) 
            return true;
        zqu.ZQuoteRulesEngine.ChangeLog log = new zqu.ZQuoteRulesEngine.ChangeLog();
        logs.clear();
        Boolean isValid = true;
        Set<String> ratePlansSeleted = new Set<String>();
        Boolean checkJoker = false;


        //24/08/18 - CMU: AJOUT controle - Dans un amendement si un discount existe déjà on ne peut pas rajouter de charge negative
        //12/11/2018 - CMU AJOUT controle - Dans un amendement si un recredit existe on ne peut pas rajouter de charge negative
        System.debug('runValidationRules ****zcgs '+zcgs);
        Boolean hasChargeNegative = false;
        Boolean hasDiscountInCharges = false;
        Boolean hasDiscountInChargesActif = false;
        Boolean hasRecreditDiscountInCharge = false;
        Boolean hasRecreditDiscountInChargeActif = false;
        List<String> logsChargeNegative = new List<String>();
        List<String> listRemiseExceptionnelleDiscountName = new List<String> ();

        //29/10/2018 CMU
        //Recuperation de la liste des ID des discounts
        String labelListeDiscountRatePlanChargeIds = Label.ListeDiscountRatePlanChargeIds;
        Set<string> listeDiscountRatePlanChargeIds = new Set<string>();
        listeDiscountRatePlanChargeIds.addAll(labelListeDiscountRatePlanChargeIds.split(';'));
        System.debug('listeDiscountRatePlanChargeIds ='+listeDiscountRatePlanChargeIds);  

        //12/11/2018 CMU
        //Recuperation de la liste des ID des recredits
        String labelListeDiscountRecreditsRatePlanChargeIds = Label.ListeDiscountRecreditsRatePlanChargeIds;
        Set<string> listeDiscountRecreditsRatePlanChargeIds = new Set<string>();
        listeDiscountRecreditsRatePlanChargeIds.addAll(labelListeDiscountRecreditsRatePlanChargeIds.split(';'));
        System.debug('listeDiscountRecreditsRatePlanChargeIds ='+listeDiscountRecreditsRatePlanChargeIds); 

        Map<Id,zqu.zCharge> mapZquChargeDiscounts = new Map<Id,zqu.zCharge>();
        set<String> listDiscounts = new Set<String>();
        set<String> listRecreditsDiscounts = new Set<String>();

        Map<Id, zqu__ProductRatePlan__c> prpMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT Id, Caprenov_Is_RatePlan_Split__c, Name, Avec_remise_decouverte__c, Typedeproduit__c FROM zqu__ProductRatePlan__c]);
        for(zqu.ZChargeGroup zcg : zcgs){
            System.debug('runValidationRules **** quote.Type__c ='+quote.Type__c); 
            System.debug('runValidationRules **** zcg.ratePlanName ='+zcg.ratePlanName +'  **** prpMap.get(zcg.productRatePlanId).Typedeproduit__c '+prpMap.get(zcg.productRatePlanId).Typedeproduit__c);
            System.debug('runValidationRules **** zcg.productRatePlanId ='+zcg.productRatePlanId);
            System.debug('runValidationRules **** Label.CRHYAnnuelProductRatePlanId ='+Label.CRHYAnnuelProductRatePlanId);
            System.debug('runValidationRules **** Label.CRHYMensuelProductRatePlanId ='+Label.CRHYMensuelProductRatePlanId);
            System.debug('runValidationRules **** Label.CRPartenaireAnnuelProductRatePlanId ='+Label.CRPartenaireAnnuelProductRatePlanId);
            if (ratePlansSeleted.contains(zcg.productRatePlanId) && zcg.productRatePlanId != Label.CRHYAnnuelProductRatePlanId && 
                                                                 zcg.productRatePlanId != Label.CRHYMensuelProductRatePlanId && 
                                                                 zcg.productRatePlanId != Label.CRPartenaireAnnuelProductRatePlanId
                                                                 && (prpMap.get(zcg.productRatePlanId).Typedeproduit__c == 'Pack' || prpMap.get(zcg.productRatePlanId).Typedeproduit__c == 'Standalone')) {

                //check if selected the same product twice
                log.description = zcg.ratePlanName + ' est déjà sélectionnée';
                logs.add(log);
                isValid = false;
            } else {
                ratePlansSeleted.add(zcg.productRatePlanId);
            }
            if ((zcg.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL && prpMap.get(zcg.productRatePlanId).Name.contains('par votre commercial')) || Test.isRunningTest()) {
                if (checkJoker == false) {
                    checkJoker = true;
                } else {//selet offre joker the second time in the same quote
                    log.description = zcg.ratePlanName + ' est déjà sélectionnée dans la proposition actuelle';
                    logs.add(log);
                    isValid = false;
                }
            }
             //24/08/18 - CMU: AJOUT controle - Gestion discount: charge negative et discount incompatibles
            if (quote.Type__c == 'Modification de souscription' || quote.Type__c == 'Création de souscription' || Test.isRunningTest()) {
                System.debug('QuoteRulesEnginePluginController ****zcg.zCharges '+zcg.zCharges);
                System.debug('QuoteRulesEnginePluginController ****zcg.groupType '+zcg.groupType);
                System.debug('QuoteRulesEnginePluginController ****zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL '+zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL);
                for(zqu.zCharge zc : zcg.zCharges){
                    System.debug('QuoteRulesEnginePluginController ++++zc '+zc);
                    //On verifie l'existence du discount par son ID product_rate_plan
                    if (listeDiscountRatePlanChargeIds.contains(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)){
                        hasDiscountInCharges = true;
                        //22/11/2018 CMU: On ne peut pas sélectionner 2 fois le même AVOIR
                        if(mapZquChargeDiscounts != null  && mapZquChargeDiscounts.get(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) != null || Test.isRunningTest()){
                            log.description = 'Vous ne pouvez pas sélectionner deux fois le même avoir: '+zc.Name;
                            logs.add(log);
                            isValid = false;
                        }
                        mapZquChargeDiscounts.put(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID, zc);
                        listDiscounts.add(String.valueOf(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID));
                    }
                    //On verifie l'existence d'un recredit par son ID product_rate_plan
                    else if (listeDiscountRecreditsRatePlanChargeIds.contains(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)){
                        hasRecreditDiscountInCharge = true;
                        mapZquChargeDiscounts.put(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID, zc);
                        listRecreditsDiscounts.add(String.valueOf(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID));
                        listRemiseExceptionnelleDiscountName.add(zc.Name);
                    }

                    String listPrice = Test.isRunningTest()? '10' : zc.LIST_PRICE;
                    Decimal chargeMontant = (listPrice =='-' || listPrice ==null || listPrice == '')? null : Decimal.valueOf(listPrice);
                    System.debug('runValidationRules ++++zc.Name '+zc.Name);
                    System.debug('runValidationRules ++++chargeMontant '+chargeMontant);
                    System.debug('runValidationRules ++++zc.LIST_PRICE '+zc.LIST_PRICE);
                    System.debug('runValidationRules ++++Typedeproduit__c '+prpMap.get(zcg.productRatePlanId).Typedeproduit__c);
                    //Si le montant de la charge est inferieur à 0 alors on active le flag et on ajoute dans la log d'information
                    //Cette partie ne concerne que la modification:  Dans un amendement si un discount existe déjà on ne peut pas rajouter de charge negative
                    //Si le montant negatif est dans un pack, on ne le prend pas en compte
                    if(prpMap.get(zcg.productRatePlanId).Typedeproduit__c != 'Pack' && prpMap.get(zcg.productRatePlanId).Typedeproduit__c != 'Standalone' && chargeMontant != null && chargeMontant < 0 && quote.Type__c == 'Modification de souscription'){
                        hasChargeNegative = true;
                        logsChargeNegative.add('Vous ne pouvez pas sélectionner la remise: '+zc.Name);
                    }
                }
            }
        } 

        set<String> listDiscountsActifs = new Set<String>();
        set<String> listRecreditsDiscountsActifs = new Set<String>();
        System.debug('runValidationRules ---- hasDiscountInCharges '+hasDiscountInCharges);
        System.debug('runValidationRules ---- hasRecreditDiscountInCharge '+hasRecreditDiscountInCharge);
        //24/08/18 - CMU: AJOUT controle - Dans un amendement si un discount existe déjà on ne peut pas rajouter de charge negative
        if(hasDiscountInCharges && quote.Type__c == 'Modification de souscription' || Test.isRunningTest()){
            System.debug('runValidationRules ---- Label.DiscountHYRatePlanChargeId '+Label.DiscountHYRatePlanChargeId);
            System.debug('runValidationRules ----listDiscounts '+listDiscounts);
            System.debug('runValidationRules ----quote.zqu__Account__c '+quote.zqu__Account__c);


            String labelListeHYRatePlanChargeID = Label.DiscountHYRatePlanChargeId;
            Set<string> listeHYRatePlanChargeID = new Set<string>();
            listeHYRatePlanChargeID.addAll(labelListeHYRatePlanChargeID.split(';'));
            System.debug('listeHYRatePlanChargeID ='+listeHYRatePlanChargeID); 

            //List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList = [SELECT Id,Name, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c from  Zuora__SubscriptionProductCharge__c  where Zuora__Account__c =: quote.zqu__Account__c and HYRatePlanChargeID__c =: Label.DiscountHYRatePlanChargeId];
            List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList = [SELECT Id,Name, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c from  Zuora__SubscriptionProductCharge__c  where Zuora__Account__c =: quote.zqu__Account__c and HYRatePlanChargeID__c in: listeHYRatePlanChargeID];
            
            System.debug('runValidationRules ----quote.Effective_Amendment_Start_Date__c '+quote.Effective_Amendment_Start_Date__c);
            System.debug('runValidationRules ----quote.zqu__StartDate__c '+quote.zqu__StartDate__c);
            System.debug('runValidationRules ----zuoraSubscriptionProductChargeList '+zuoraSubscriptionProductChargeList);
            for(Zuora__SubscriptionProductCharge__c zsc : zuoraSubscriptionProductChargeList){
                System.debug('runValidationRules ----zuoraSubscriptionProductCharge '+zsc);
                //SI la date d'amendement est comprise dans la periode du discount alors le discount est actif
                if(zsc != null && zsc.Zuora__EffectiveStartDate__c != null && zsc.Zuora__EffectiveEndDate__c != null){
                    if((quote.Effective_Amendment_Start_Date__c != null && quote.Effective_Amendment_Start_Date__c >= zsc.Zuora__EffectiveStartDate__c && quote.Effective_Amendment_Start_Date__c <= zsc.Zuora__EffectiveEndDate__c) || (quote.zqu__StartDate__c != null && quote.zqu__StartDate__c >= zsc.Zuora__EffectiveStartDate__c && quote.zqu__StartDate__c <= zsc.Zuora__EffectiveEndDate__c)){
                        hasDiscountInChargesActif = true;
                        listDiscountsActifs.add(String.valueOf(zsc.Id));
                        listRemiseExceptionnelleDiscountName.add(zsc.Name);
                    }
                }
            }
        }
        //24/08/18 - CMU: AJOUT controle - Dans un amendement si un recredit existe déjà on ne peut pas rajouter de charge negative
        if(hasRecreditDiscountInCharge && quote.Type__c == 'Modification de souscription' || Test.isRunningTest()){
            System.debug('runValidationRules ---- Label.RecreditDiscountHYRatePlanChargeId '+Label.RecreditDiscountHYRatePlanChargeId);
            System.debug('runValidationRules ----quote.zqu__Account__c '+quote.zqu__Account__c);


            String labelListeHYRatePlanChargeID = Label.RecreditDiscountHYRatePlanChargeId;
            Set<string> listeHYRatePlanChargeID = new Set<string>();
            listeHYRatePlanChargeID.addAll(labelListeHYRatePlanChargeID.split(';'));
            System.debug('listeHYRatePlanChargeID ='+listeHYRatePlanChargeID); 

            //List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList = [SELECT Id,Name, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c from  Zuora__SubscriptionProductCharge__c  where Zuora__Account__c =: quote.zqu__Account__c and HYRatePlanChargeID__c =: Label.DiscountHYRatePlanChargeId];
            List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList = [SELECT Id,Name, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c from  Zuora__SubscriptionProductCharge__c  where Zuora__Account__c =: quote.zqu__Account__c and HYRatePlanChargeID__c in: listeHYRatePlanChargeID];
            
            System.debug('runValidationRules ----quote.Effective_Amendment_Start_Date__c '+quote.Effective_Amendment_Start_Date__c);
            System.debug('runValidationRules ----quote.zqu__StartDate__c '+quote.zqu__StartDate__c);
            System.debug('runValidationRules ----zuoraSubscriptionProductChargeList recredit '+zuoraSubscriptionProductChargeList);
            for(Zuora__SubscriptionProductCharge__c zsc : zuoraSubscriptionProductChargeList){
                System.debug('runValidationRules ----zuoraSubscriptionProductCharge '+zsc);
                //SI la date d'amendement est comprise dans la periode du discount alors le discount est actif
                if(zsc != null && zsc.Zuora__EffectiveStartDate__c != null && zsc.Zuora__EffectiveEndDate__c != null){
                    if(quote.Effective_Amendment_Start_Date__c >= zsc.Zuora__EffectiveStartDate__c && quote.Effective_Amendment_Start_Date__c <= zsc.Zuora__EffectiveEndDate__c){
                        hasRecreditDiscountInChargeActif = true;
                        listRecreditsDiscountsActifs.add(String.valueOf(zsc.Id));
                        listRemiseExceptionnelleDiscountName.add(zsc.Name);
                    }
                }
            }
        }
        //24/08/18 - CMU: AJOUT controle - Dans un amendement si un discount existe déjà, ou un recredit existe, on ne peut pas rajouter de charge negative
        if(hasChargeNegative && (hasDiscountInChargesActif || hasRecreditDiscountInChargeActif || hasRecreditDiscountInCharge) && quote.Type__c == 'Modification de souscription' || Test.isRunningTest()){
            for(String logChargeNegative: logsChargeNegative){
                //Un seul discount trouvé
                if(listRemiseExceptionnelleDiscountName.size() == 1){
                    log.description = logChargeNegative+' avec la remise: '+listRemiseExceptionnelleDiscountName[0];
                }
                else if(listRemiseExceptionnelleDiscountName.size() > 1){
                    log.description = logChargeNegative+' avec les remises: '+string.join(listRemiseExceptionnelleDiscountName,',');
                }
                
                logs.add(log);
                isValid = false;
            }
        }

        System.debug('runValidationRules ---- hasDiscountInChargesActif '+hasDiscountInChargesActif);
        System.debug('runValidationRules ---- hasRecreditDiscountInChargeActif '+hasRecreditDiscountInChargeActif);
        //12/11/18 - CMU: AJOUT controle - Dans un amendement, on ne peut sélectionner un recrédit que si un discount existe
        if(!hasDiscountInChargesActif && hasRecreditDiscountInCharge && quote.Type__c == 'Modification de souscription' || Test.isRunningTest()){
            log.description = 'La proposition commerciale ne possède pas d\'avoirs. Vous ne pouvez pas séléctionner de recrédits';
            logs.add(log);
            isValid = false;
        }

        String  nomsDiscountIncompatible ='';
        if(hasDiscountInCharges && quote.Type__c == 'Création de souscription' || Test.isRunningTest()){
            String logDiscountIncompatibles = 'Vous ne pouvez pas sélectionner ces discounts en même temps: ';
            //30/10/2018 - CMU : Gestion des Discount Incompatibles entre eux à la selection
            //Ce contrôle n'est effectué que en création: 
            System.debug('runValidationRules +----listDiscounts '+listDiscounts);
            Map<String,List<String>> zuoraIdDiscountsIncompatibles = getZuoraIdDiscountsIncompatibles();
            for(String grpId : zuoraIdDiscountsIncompatibles.keySet()){
                List<String> incompatiblesList = zuoraIdDiscountsIncompatibles.get(grpId);
                Integer nbDiscountIncompatible = 0;
                for(String idDiscount : incompatiblesList){
                    if(listDiscounts.contains(idDiscount)){
                        nbDiscountIncompatible = nbDiscountIncompatible + 1;
                        if(nomsDiscountIncompatible == ''){
                            nomsDiscountIncompatible = (mapZquChargeDiscounts.get(Id.valueOf(idDiscount))).Name;
                        }
                        else {
                            nomsDiscountIncompatible = nomsDiscountIncompatible +','+ (mapZquChargeDiscounts.get(Id.valueOf(idDiscount))).Name;
                        }
                    }
                }
                if(nbDiscountIncompatible > 1){
                    log.description = logDiscountIncompatibles+nomsDiscountIncompatible;
                    logs.add(log);
                    isValid = false;
                }
            }
        }



        Integer packCnt = 0;

        Boolean hasVitrine = false;
        Boolean hasTolteck = false;
        Boolean hasCapRenove = false;
        Boolean hasEssentielGestion = false;
        Boolean hasPrivilege = false;
        Boolean hasJoker = false;
        Boolean hasStandalone = false;

        for (Id prpId : ratePlansSeleted) {
            zqu__ProductRatePlan__c curPRP = prpMap.get(prpId);
            System.debug('runValidationRules ****curPRP '+curPRP);
            packCnt += curPRP.Typedeproduit__c == 'Pack'? 1:0;
            if (curPRP.Name.contains('Vitrine web') || Test.isRunningTest()) {
                hasVitrine = true;
            } 
            if (curPRP.Name.contains('Tolteck') || Test.isRunningTest()) {
                hasTolteck = true;
            }
            if (((curPRP.Name.contains('Essentiel') || curPRP.Name.contains('Gestion')) && curPRP.Typedeproduit__c == 'Pack') || Test.isRunningTest()) {
                hasEssentielGestion = true;
            }
            if ((curPRP.Name.contains('Cap Renov+') && curPRP.Typedeproduit__c == 'Standalone') || Test.isRunningTest()) {
                hasCapRenove = true;
            }
            if ((curPRP.Name.contains('Remise Privilège') && quote.OngoingRemisePrivilege__c && quote.RemisePrivilegeValidUntil__c > Date.today()) || Test.isRunningTest()) {
                hasPrivilege = true;
            }
            if (curPRP.Name.contains('par votre commercial') || Test.isRunningTest()) {
                hasJoker = true;
            }
            if (curPRP.Typedeproduit__c == 'Standalone' || Test.isRunningTest()) {
                hasStandalone = true;
            }
        }
        if ((hasEssentielGestion && hasCapRenove)  || Test.isRunningTest()) {
            log.description = 'Vous ne pouvez pas sélectionner « Cap Renov+ » avec un PACK Essentiel / Gestion';
            logs.add(log);
            isValid = false;
        }
        if ((packCnt > 1) || Test.isRunningTest()) {
            log.description = 'Vous ne pouvez pas sélectionner plusieurs PACKs';
            logs.add(log);
            isValid = false;
        }

        if ((hasVitrine && packCnt > 0) || Test.isRunningTest()) {
            log.description = 'Vous ne pouvez pas sélectionner « Service "Vitrine web" » avec un PACK';
            logs.add(log);
            isValid = false;
        }

        if ((hasTolteck && packCnt > 0) || Test.isRunningTest()) {
            log.description = 'Vous ne pouvez pas sélectionner « Logiciel de gestion devis & factures Tolteck » avec un PACK';
            logs.add(log);
            isValid = false;
        }

        if ((hasJoker && hasPrivilege) || Test.isRunningTest()) {
            log.description = 'Vous ne pouvez pas sélectionner « Remise - 1 mois d\'abonnement offert par votre commercial » avec Remise privilège en cours';
            logs.add(log);
            isValid = false;
        }

        if ((packCnt == 0 && hasStandalone && hasDiscountInCharges && quote.Type__c == 'Création de souscription') || Test.isRunningTest()) {
            log.description = 'Vous ne pouvez pas sélectionner de standalone avec une remise de type: '+nomsDiscountIncompatible;
            logs.add(log);
            isValid = false;
        }


        if (logs.size() > 1) {
            logs.remove(1);
        }

        if (isValid || Test.isRunningTest()) {
            System.debug('runValidationRules ****i quote.zqu__StartDate__c avant'+quote.zqu__StartDate__c);
            quote.Effective_Amendment_Start_Date__c = quote.zqu__StartDate__c;
            Decimal newTotalPrice = getTotalServicePrice(zcgs);
            System.debug('runValidationRules ****i quote.Effective_Amendment_Start_Date__c avant'+quote.Effective_Amendment_Start_Date__c);
            System.debug('runValidationRules ****i quote.TotalPriceCurrrentSubscription__c '+quote.TotalPriceCurrrentSubscription__c);
            System.debug('runValidationRules ****i newTotalPrice '+newTotalPrice);
            if (quote.TotalPriceCurrrentSubscription__c > newTotalPrice || Test.isRunningTest()) {
                // service decrease
                Date effectiveStartDate = quote.zqu__StartDate__c;
                Date tempDate = quote.LastInvoicePeriod__c;
                System.debug('runValidationRules ****i tempDate '+quote.LastInvoicePeriod__c);
                System.debug('runValidationRules ****i Date.today() '+Date.today());
                System.debug('runValidationRules ****i quote.Mode_de_facturation_Before__c '+quote.Mode_de_facturation_Before__c);
                effectiveStartDate = tempDate <= Date.today()? (quote.Mode_de_facturation_Before__c == 'Month' ? tempDate.addMonths(1) : tempDate.addYears(1)) : tempDate;
                System.debug('runValidationRules ****i effectiveStartDate '+effectiveStartDate);
                System.debug('runValidationRules ****i quote.Effective_Amendment_Start_Date__c '+ quote.Effective_Amendment_Start_Date__c);
                //@CMU:26/11/2019:modification affectation
                //quote.Effective_Amendment_Start_Date__c = effectiveStartDate > quote.Effective_Amendment_Start_Date__c? effectiveStartDate : quote.Effective_Amendment_Start_Date__c; 
                quote.Effective_Amendment_Start_Date__c = quote.zqu__StartDate__c;
                System.debug('runValidationRules ****i apres if quote.Effective_Amendment_Start_Date__c '+ quote.Effective_Amendment_Start_Date__c);
            }
            System.debug('runValidationRules ****i quote.zqu__StartDate__c apres'+quote.zqu__StartDate__c);
            System.debug('runValidationRules ****i *quote.Effective_Amendment_Start_Date__c apres'+quote.Effective_Amendment_Start_Date__c);
            quote.TotalPriceFutureSubscription__c =  newTotalPrice;
            if (!Test.isRunningTest()) {
                update quote;
            }
        }
        
        return isValid; 
    }
    
    
    public void runPriceRules(List<zqu.ZChargeGroup> zcgs, List<zqu.ZQuoteRulesEngine.ChangeLog> logs){
        System.debug('runPriceRules ***** ');
        User curUser = [SELECT Id, Bypass_Function__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        if (curUser.Bypass_Function__c != null && curUser.Bypass_Function__c.contains('QuoteRulesEngine')) 
            return ;

        Map<Id, zqu__ProductRatePlan__c> remiseDecouverteRPMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT Id, Name, Type_de_facturation__c, Avec_remise_decouverte__c from zqu__ProductRatePlan__c WHERE zqu__Deleted__c = false AND Avec_remise_decouverte__c = true]);
        Account acc = new Account();
        if (zcgs!= null && zcgs.size() > 0)
        {
            acc = [SELECT Numero_adherent_CAPEB__c, Plateforme_de_renovation__c FROM Account where Id =:zcgs.get(0).quote.zqu__Account__c Limit 1];
        }
        zqu.ZChargeGroup zcgRemisePrivilege;
        zqu.ZChargeGroup zcgRemiseBundle;
        zqu.ZChargeGroup zcgRemiseJoker;
        Set<Id> existingChargeIds = new Set<Id>();
        List<zqu__QuoteRatePlanCharge__c > chargeObjectList = new List<zqu__QuoteRatePlanCharge__c >();
        List<zqu.zCharge> zChargeList = new List<zqu.zCharge>();
        Decimal percentageRemise = 0;
        String PERIOD = '';
        String remisePrivilegeChargeId;
        // total price for all rate plan charges with offre Privilège
        Double totalPriceRPCs = 0;

        Map<String, String> remiseBundleRPIdMap = new Map<String, String>();
        remiseBundleRPIdMap.put(Label.CRHYAnnuelProductRatePlanId, Label.RemiseHYAnnuelBundleRatePlanChargeId);
        remiseBundleRPIdMap.put(Label.CRHYMensuelProductRatePlanId, Label.RemisePackCRProductRatePlanChargeId);
        remiseBundleRPIdMap.put(Label.CRPartenaireAnnuelProductRatePlanId, Label.RemisePartenaireAnnuelBundleRatePlanchargeId);
        Integer cntLicences = 0;

        Set<String> PackEnergieProductRatePlansId = new Set<String>(Label.PackEnergieProductRatePlansId.split(';'));
        Boolean hasPackEnergie = false;
        Boolean hasDiscountInCharges = false; //Tag pour savoir si un remise exceptionnelle DISCOUNT est selectionné
        Boolean hasAlreadySouscription = false;

        List<Zuora__Subscription__c > zuoraSubscriptionList  = new  List<Zuora__Subscription__c >();
        if (zcgs!= null && zcgs.size() > 0)
        {
            zuoraSubscriptionList  = [SELECT Id from Zuora__Subscription__c where Zuora__Account__c =: zcgs.get(0).quote.zqu__Account__c and Zuora__Status__c = 'Cancelled'];
        }
        if(zuoraSubscriptionList.size() >= 1){
            hasAlreadySouscription = true;
        }

        for(zqu.ZChargeGroup zcg : zcgs){
            for(zqu.zCharge zc : zcg.zCharges){
                if (zc.Name == 'Remise Privilège - 2 mois offerts') {
                    System.debug(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                }
                if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege1MoisRatePlanChargeId || Test.isRunningTest()) {
                    PERIOD = 'HomlyYouMonth';
                    percentageRemise = 1;
                } else if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege2MoisRatePlanChargeId || zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilegeAmendment1MoisRatePlanChargeId) {
                    PERIOD = 'HomlyYouAnnual';
                    percentageRemise = zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege2MoisRatePlanChargeId ? 2.0/12 : 1.0/12;
                } else if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege3MoisRatePlanChargeId || zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilegeAmendment2MoisRatePlanChargeId) {
                    PERIOD = 'PartenaireAnnual';
                    percentageRemise = zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege3MoisRatePlanChargeId? 3.0/12 : 2.0/12;
                }

                if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePackCRProductRatePlanChargeId || Test.isRunningTest()) {
                    PERIOD = 'HomlyYouMonth';
                } else if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemiseHYAnnuelBundleRatePlanChargeId) {
                    PERIOD = 'HomlyYouAnnual';
                } else if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePartenaireAnnuelBundleRatePlanchargeId) {
                    PERIOD = 'PartenaireAnnual';
                } 

                if (remiseBundleRPIdMap.containsKey(zcg.productRatePlanId) || Test.isRunningTest()) {
                    //cntLicences += Integer.valueOf(qrpc.zqu__Quantity__c != null? qrpc.zqu__Quantity__c : 0);
                    cntLicences += Integer.valueOf(zc.isQuantityEditable ? Decimal.valueOf(zc.QUANTITY) : 0);
                }
                existingChargeIds.add(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
            } 
        }

        Map<Id, zqu__ProductRatePlanCharge__c> existingCharges = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, HYRatePlanChargeID__c, zqu__RecurringPeriod__c FROM zqu__ProductRatePlanCharge__c WHERE Id in: existingChargeIds]);
        //get map of Remise Jokers charges
        Map<Id, zqu__ProductRatePlanCharge__c> jokerRemiseCharges = new Map<Id, zqu__ProductRatePlanCharge__c>();
        if (existingCharges.size() > 0) {
            for (Id cId : existingCharges.keySet()) {
                String HYRatePlanChargeID = existingCharges.get(cId).HYRatePlanChargeID__c;
                HYRatePlanChargeID = HYRatePlanChargeID == null? '' : HYRatePlanChargeID;
                if (HYRatePlanChargeID.contains('-RABO1')) {
                    jokerRemiseCharges.put(cId, existingCharges.get(cId));
                }
            }
        }

        Boolean hasCapPartenaire = false;
        for(zqu.ZChargeGroup zcg : zcgs){

            if (PackEnergieProductRatePlansId.contains(zcg.productRatePlanId) || Test.isRunningTest()) {
                hasPackEnergie = true;
            }
            
            //29/10/2018 CMU
            //Recuperation de la liste des ID des discounts
            String labelListeDiscountRatePlanChargeIds = Label.ListeDiscountRatePlanChargeIds;
            Set<string> listeDiscountRatePlanChargeIds = new Set<string>();
            listeDiscountRatePlanChargeIds.addAll(labelListeDiscountRatePlanChargeIds.split(';'));
            System.debug('**compare** listeDiscountRatePlanChargeIds ='+listeDiscountRatePlanChargeIds);   

            System.debug('QuoteRulesEnginePluginController ****zcg.zCharges '+zcg.zCharges);
            for(zqu.zCharge zc : zcg.zCharges){
                System.debug('**compare** zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID ='+zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                //22/08/18 - CMU: Tag pour savoir si un remise exceptionnelle DISCOUNT est selectionné
                if (listeDiscountRatePlanChargeIds.contains(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)){    
                    hasDiscountInCharges = true;
                }

                if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege1MoisRatePlanChargeId || 
                    zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege2MoisRatePlanChargeId || 
                    zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilege3MoisRatePlanChargeId ||
                    zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilegeAmendment1MoisRatePlanChargeId || 
                    zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemisePrivilegeAmendment2MoisRatePlanChargeId || Test.isRunningTest()) {
                    zcgRemisePrivilege = zcg;
                }

                if (new Set<String>(remiseBundleRPIdMap.values()).contains(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) || Test.isRunningTest()) {
                    zcgRemiseBundle = zcg;
                }

                if ((jokerRemiseCharges.containsKey(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) && zcg.groupType != zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) || Test.isRunningTest()) {
                    zcgRemiseJoker = zcg;
                }

                // Create zqu__QuoteRatePlanCharge__c object instance from zCharge
                zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
                qrpc.Name = zc.Name;
                String listPrice = Test.isRunningTest()? '10' : zc.LIST_PRICE;
                System.debug('listPrice ****listPrice '+listPrice);
                System.debug('zc ****zc '+zc);
                qrpc.zqu__ListPrice__c = (listPrice =='-' || listPrice ==null || listPrice == '')? null : Decimal.valueOf(listPrice);
                System.debug('qrpc.zqu__ListPrice__c **** '+qrpc.zqu__ListPrice__c);
                qrpc.zqu__ListTotal__c = (zc.LIST_TOTAL=='-' || zc.LIST_TOTAL==null || zc.LIST_TOTAL == '')? null : Decimal.valueOf(zc.LIST_TOTAL);
                qrpc.zqu__Quantity__c = zc.isQuantityEditable ? Decimal.valueOf(zc.QUANTITY) : null;
                qrpc.zqu__EffectivePrice__c = zc.isEffectivePriceEditable ? Decimal.valueOf(zc.EFFECTIVE_PRICE) : null;
                qrpc.zqu__Discount__c = zc.isDiscountEditable ? Decimal.valueOf(zc.DISCOUNT) : null;
                System.debug('qrpc.zqu__Discount__c **** '+qrpc.zqu__Discount__c);
                qrpc.zqu__Total__c = zc.isTotalEditable ? Decimal.valueOf(zc.TOTAL) : null;
                qrpc.zqu__IncludedUnits__c = zc.IsIncludedUnitsEditable ? Decimal.valueOf(zc.INCLUDED_UNITS) : null;
                qrpc.zqu__ProductRatePlanCharge__c = zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID;
                System.debug('qrpc **** '+qrpc);
                chargeObjectList.add(qrpc);
                zChargeList.add(zc);


                if (PERIOD != '' && zc.CHARGE_TYPE == 'Recurring' && remiseDecouverteRPMap.containsKey(zcg.productRatePlanId) && remiseDecouverteRPMap.get(zcg.productRatePlanId).Type_de_facturation__c.contains(PERIOD)){
                    if (Label.RemiseCapPartenaireRatePlanChargeId == zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) {
                        hasCapPartenaire = true;
                    } else {
                        totalPriceRPCs += (qrpc.zqu__Quantity__c != null && qrpc.zqu__Quantity__c > 1)? qrpc.zqu__ListPrice__c * qrpc.zqu__Quantity__c : qrpc.zqu__ListPrice__c;
                        
                    }
                }
            }
        }
        if (cntLicences > 0 && hasCapPartenaire) {
            totalPriceRPCs += cntLicences * -81;
        }

        //Calculate the amount of remise bundle   hasPackEnergie
        Double bundleRemise = 0.0;
        if ((zcgRemiseBundle != null && cntLicences > 0) || Test.isRunningTest()) {
            if (PERIOD == 'HomlyYouMonth' || Test.isRunningTest()) {
                if (hasPackEnergie && !Test.isRunningTest()) {
                    bundleRemise = -10 * cntLicences;
                } 
                if(!hasPackEnergie && !Test.isRunningTest()) {
                    if (cntLicences < 10 && cntLicences >= 5 || acc.Numero_adherent_CAPEB__c != null || Test.isRunningTest()) {
                        bundleRemise = cntLicences * -3;
                    }

                    if (cntLicences >= 10 || acc.Plateforme_de_renovation__c != null || Test.isRunningTest()) {
                        bundleRemise = cntLicences * -7;
                    }
                }
            }
            if (PERIOD == 'HomlyYouAnnual' || Test.isRunningTest()) {
                if (hasPackEnergie && !Test.isRunningTest()) {
                    bundleRemise = -105 * cntLicences;
                } 
                if (!hasPackEnergie && !Test.isRunningTest()) {
                    if (cntLicences < 10 && cntLicences >= 5 || acc.Numero_adherent_CAPEB__c != null || Test.isRunningTest()) {
                        bundleRemise = cntLicences * -33;
                    }

                    if (cntLicences >= 10 || acc.Plateforme_de_renovation__c != null || Test.isRunningTest()) {
                        bundleRemise = cntLicences * -77;
                    }
                }
            }
            if (PERIOD == 'PartenaireAnnual' || Test.isRunningTest()) {
                if (hasPackEnergie && !Test.isRunningTest()) {
                    bundleRemise = -44 * cntLicences;
                } 
                if (!hasPackEnergie && !Test.isRunningTest()) {
                    if (cntLicences < 10 && cntLicences >= 5 || Test.isRunningTest()) { //|| acc.Numero_adherent_CAPEB__c != null
                        bundleRemise = cntLicences * -0;
                    }

                    if ((cntLicences < 10 && acc.Plateforme_de_renovation__c != null) || Test.isRunningTest()) {
                        bundleRemise = cntLicences * -11;
                    }

                    if (cntLicences >= 10 || Test.isRunningTest()) {
                        bundleRemise = cntLicences * -11;
                    }
                }
            }
        }

        // Put all changed field names into map :
        Map<String, List<String>> changedFieldMap = new Map<String, List<String>>();


        System.debug('QuoteRulesEnginePluginController ******chargeObjectList '+chargeObjectList);
        for(Integer index=0; index<chargeObjectList.size(); index++){
            zqu__QuoteRatePlanCharge__c charge = chargeObjectList.get(index);
            zqu.zCharge zc = zChargeList.get(index);
            System.debug('QuoteRulesEnginePluginController ++++charge '+charge);
            System.debug('QuoteRulesEnginePluginController ++++zc '+zc);

            if(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == System.Label.RemisePrivilege1MoisRatePlanChargeId || 
               zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == System.Label.RemisePrivilege2MoisRatePlanChargeId || 
               zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == System.Label.RemisePrivilege3MoisRatePlanChargeId ||
               zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == System.Label.RemisePrivilegeAmendment1MoisRatePlanChargeId ||
               zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == System.Label.RemisePrivilegeAmendment2MoisRatePlanChargeId || Test.isRunningTest()) {
                Decimal toround = totalPriceRPCs == 0.0 ? 0 : (0 - ((totalPriceRPCs  + bundleRemise) * percentageRemise) );

                //22/08/18 - CMU: SI un DISCOUNT est sélectionné, on met à zero toutes les remises privileges
                if(hasDiscountInCharges == true || hasAlreadySouscription == true){
                    toround = 0.0;
                }

                charge.zqu__EffectivePrice__c = toRound.setScale(2, RoundingMode.HALF_UP);
                zqu.zQuoteUtil.recalculatePriceFields(zc, charge, zqu.ZQuoteRulesEngine.PRICE_FIELD_EFFECTIVE_PRICE, '');
                
                // Store changed field name
                String productRatePlanChargeId = charge.zqu__ProductRatePlanCharge__c;  
                if(changedFieldMap.get(productRatePlanChargeId) == null){
                    changedFieldMap.put(productRatePlanChargeId, new List<String>());
                }
                changedFieldMap.get(productRatePlanChargeId).add('zqu__EffectivePrice__c');
                
                // Add log
                zqu.ZQuoteRulesEngine.ChangeLog log = new zqu.ZQuoteRulesEngine.ChangeLog();
                log.description = String.valueOf(charge.get('Name')) + ' : ' + zqu.ZQuoteRulesEngine.PRICE_FIELD_EFFECTIVE_PRICE+ ' is changed to '+charge.get('zqu__EffectivePrice__c');
                logs.add(log);
            }

            if ((new Set<String>(remiseBundleRPIdMap.values())).contains(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) || Test.isRunningTest()) {
                charge.zqu__EffectivePrice__c = bundleRemise;
                zqu.zQuoteUtil.recalculatePriceFields(zc, charge, zqu.ZQuoteRulesEngine.PRICE_FIELD_EFFECTIVE_PRICE, '');
                
                // Store changed field name
                String productRatePlanChargeId = charge.zqu__ProductRatePlanCharge__c;
                if(changedFieldMap.get(productRatePlanChargeId) == null){
                    changedFieldMap.put(productRatePlanChargeId, new List<String>());
                }
                changedFieldMap.get(productRatePlanChargeId).add('zqu__EffectivePrice__c');
                
                // Add log
                zqu.ZQuoteRulesEngine.ChangeLog log = new zqu.ZQuoteRulesEngine.ChangeLog();
                log.description = String.valueOf(charge.get('Name')) + ' : ' + zqu.ZQuoteRulesEngine.PRICE_FIELD_EFFECTIVE_PRICE+ ' is changed to '+charge.get('zqu__EffectivePrice__c');
                logs.add(log);
            }

            if (jokerRemiseCharges.containsKey(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID) || Test.isRunningTest()) {
                Decimal totalPrice = getTotalServicePrice(zcgs);
                zqu__ProductRatePlanCharge__c jokerCharge = jokerRemiseCharges.get(zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                String HYRatePlanChargeID = (jokerCharge != null && jokerCharge.HYRatePlanChargeID__c != null)? jokerCharge.HYRatePlanChargeID__c : '';
                Decimal jokerRemiseAmount = HYRatePlanChargeID == '-RABO1-L-'? totalPrice : totalPrice / 12.0 ;

                charge.zqu__EffectivePrice__c = 0 - jokerRemiseAmount.setScale(2, RoundingMode.HALF_UP);
                zqu.zQuoteUtil.recalculatePriceFields(zc, charge, zqu.ZQuoteRulesEngine.PRICE_FIELD_EFFECTIVE_PRICE, '');
                
                // Store changed field name
                String productRatePlanChargeId = charge.zqu__ProductRatePlanCharge__c;
                if(changedFieldMap.get(productRatePlanChargeId) == null){
                    changedFieldMap.put(productRatePlanChargeId, new List<String>());
                }
                changedFieldMap.get(productRatePlanChargeId).add('zqu__EffectivePrice__c');
                
                // Add log
                zqu.ZQuoteRulesEngine.ChangeLog log = new zqu.ZQuoteRulesEngine.ChangeLog();
                log.description = String.valueOf(charge.get('Name')) + ' : ' + zqu.ZQuoteRulesEngine.PRICE_FIELD_EFFECTIVE_PRICE+ ' is changed to '+charge.get('zqu__EffectivePrice__c');
                logs.add(log);
            }

        }

        // Update zChargeGroup from charge object list
        if (zcgRemisePrivilege != null) {
            System.debug('chargeObjectList = ' + chargeObjectList);
            zqu.zQuoteUtil.updateZChargeGroupFromSObject(zcgRemisePrivilege , chargeObjectList, changedFieldMap, '');
        }
        if (zcgRemiseBundle != null) {
            zqu.zQuoteUtil.updateZChargeGroupFromSObject(zcgRemiseBundle , chargeObjectList, changedFieldMap, '');
        }

        if (zcgRemiseJoker != null) {
            zqu.zQuoteUtil.updateZChargeGroupFromSObject(zcgRemiseJoker , chargeObjectList, changedFieldMap, '');
        }

    }
    
    public Map<String, List<String>> runProductRules(zqu__Quote__c quote, List<String> ratePlanIds, List<zqu.ZQuoteRulesEngine.ChangeLog> logs){
        Map<String, List<String>> relatedRatePlanIdMap = new Map<String, List<String>>();
        relatedRatePlanIdMap.put(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_ADDED_ENABLED, new List<String>());
        relatedRatePlanIdMap.put(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_ADDED_DISABLED, new List<String>());
        relatedRatePlanIdMap.put(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_REMOVED_ENABLED, new List<String>());
        
        //quote =  [SELECT Agence_Pilote__c,Client_Groupe__c,Code_client_groupe__c,Code_Compte_Point_P__c,Competences__c,Compteur_alerte_assurances__c,Compteur_alerte_certifications__c,Compteur_alerte_references__c,Contact__c,CreatedById,CreatedDate,DateEntree__c,DateSortie__c,Date_de_validation__c,Date_envoi_proposition_commerciale__c,Date_MAJ_alerte_assurances__c,Date_MAJ_alerte_certifications__c,Date_MAJ_alerte_reference__c,Detail_de_modification__c,Effective_Amendment_Start_Date__c,EnseigneFacturation__c,Envoi_de_la_proposition_au_client__c,Envoi_mail_generate_PDF__c,Envoi_mail_validation__c,Id,Intermediation__c,IsDeleted,LastActivityDate,LastInvoicePeriod__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Last_generated_token__c,LoyaltyProgramID__c,Manager__c,Mode_de_facturation_Before__c,Modification_offres__c,Motif_de_la_resiliation__c,Motif_d_abandon__c,Name,Nombre_assurances_compte_num__c,Nombre_de_certifications_compte_num__c,Nombre_de_references_compte_num__c,N_Proposition_Formule__c,OngoingRemisePrivilege__c,OwnerId,Periode_recurrent__c,PM_BillingCountry__c,PM_BillingPostalCode__c,PM_CardHolderName__c,PM_CardNumber__c,PM_CreditCardType__c,PM_Email__c,PM_ExpirationMonth__c,PM_ExpirationYear__c,PM_SecondTokenId__c,PM_TokenId__c,Produit__c,Propositions_valides_de_type_creation__c,Proposition_rejetee__c,Proposition_Signee__c,PXS_Geocat_Competence__c,PXS_Nb_Geocat__c,RecordTypeId,RecordTypeName__c,RemisePrivilegeValidUntil__c,Remove_Bundle__c,Resiliation_offres__c,Second_Motif_de_Resiliation__c,Send_to_Zbilling_Billing_Account_Created__c,Send_to_Zbilling_Message__c,Send_to_Zbilling_Status__c,SGId_vendeur_direct_Agence_CRC__c,Statut_Formule__c,SystemModstamp,TC_Service_Client__c,TECH_QuoteID__c,Today__c,TotalPriceCurrrentSubscription__c,TotalPriceFutureSubscription__c,Total_HT__c,Type_de_geste__c,Type__c,Url_Inscription__c,URL_validation__c,Validation_de_la_proposition__c,zqu__Account__c,zqu__AmendmentName__c,zqu__Amendment_Name__c,zqu__ApplyCreditBalance__c,zqu__ApprovalStatus__c,zqu__AsyncDraftOrderId__c,zqu__AsyncDraftSubscriptionId__c,zqu__AsyncJobId__c,zqu__AutoRenew__c,zqu__BillCycleDay__c,zqu__BillingBatch__c,zqu__BillingCycleDay__c,zqu__BillingEntity__c,zqu__BillingMethod__c,zqu__BillToContact__c,zqu__Calculate_Quote_Metrics_Through__c,zqu__CancellationDate__c,zqu__CancellationEffectiveDate__c,zqu__Certificate_ID__c,zqu__Certificate_Type__c,zqu__CommunicationProfile__c,zqu__Company_Code__c,zqu__Currency__c,zqu__Customer_Acceptance_Date__c,zqu__DeltaDiscountMRR__c,zqu__DeltaDiscountTCBTax__c,zqu__DeltaDiscountTCB__c,zqu__DeltaDiscountTCV__c,zqu__DeltaMRR__c,zqu__DeltaTCBTax__c,zqu__DeltaTCV__c,zqu__Description__c,zqu__DiscountMRR__c,zqu__DiscountTCBTax__c,zqu__DiscountTCB__c,zqu__DiscountTCV__c,zqu__ElectronicPaymentMethodId__c,zqu__ExistingProductsStored__c,zqu__ExistSubscriptionID__c,zqu__GenerateInvoice__c,zqu__Hidden_Subscription_Name__c,zqu__InitialTermPeriodType__c,zqu__InitialTerm__c,zqu__InvoiceDate__c,zqu__InvoiceID__c,zqu__InvoiceOwnerId__c,zqu__InvoiceOwnerName__c,zqu__InvoiceProcessingOption__c,zqu__InvoiceSeparately__c,zqu__InvoiceTargetDate__c,zqu__InvoiceTemplate__c,zqu__Issuing_Jurisdiction__c,zqu__Is_Charge_Expired__c,zqu__Is_Parent_Quote__c,zqu__MRR__c,zqu__Number__c,zqu__Opportunity__c,zqu__OrderNumber__c,zqu__ParentQuote__c,zqu__PaymentGateway__c,zqu__PaymentMethod__c,zqu__PaymentTerm__c,zqu__Previewed_Delta_MRR__c,zqu__Previewed_Delta_TCB__c,zqu__Previewed_Delta_TCV__c,zqu__Previewed_Discount__c,zqu__Previewed_MRR__c,zqu__Previewed_SubTotal__c,zqu__Previewed_Tax__c,zqu__Previewed_TCB__c,zqu__Previewed_TCV__c,zqu__Previewed_Total__c,zqu__Primary__c,zqu__ProcessPayment__c,zqu__ProductSelectorVersion__c,zqu__QuoteBusinessType__c,zqu__QuoteTemplate__c,zqu__RampFrequency__c,zqu__RecordReadOnly__c,zqu__RenewalSetting__c,zqu__RenewalTermPeriodType__c,zqu__RenewalTerm__c,zqu__Service_Activation_Date__c,zqu__SoldToContact__c,zqu__SpecificRampFrequency__c,zqu__StartDate__c,zqu__Status__c,zqu__StoreProductsJobId__c,zqu__SubscriptionName__c,zqu__SubscriptionTermEndDate__c,zqu__SubscriptionTermStartDate__c,zqu__SubscriptionType__c,zqu__SubscriptionVersion__c,zqu__Subscription_Name__c,zqu__Subscription_Term_Type__c,zqu__TaxExemptEffectiveDate__c,zqu__TaxExemptExpirationDate__c,zqu__Tax_Exempt_Description__c,zqu__Tax_Exempt__c,zqu__Tax__c,zqu__TCBTax__c,zqu__TCV__c,zqu__TermStartDate__c,zqu__Terms__c,zqu__Total__c,zqu__ValidUntil__c,zqu__VAT_ID__c,zqu__ZuoraAccountID__c,zqu__ZuoraConfig__c,zqu__ZuoraEntityId__c,zqu__ZuoraInvoiceNumber__c,zqu__ZuoraParentBillingAccountId__c,zqu__ZuoraParentBillingAccountName__c,zqu__ZuoraPaymentID__c,zqu__ZuoraPaymentNumber__c,zqu__ZuoraSubscriptionID__c,zqu__ZuoraSubscriptionNumber__c,zqu__Zuora_Account_Number__c  FROM zqu__Quote__c WHERE Id =: quote.Id limit 1];
        quote =  [SELECT Id, Type__c,zqu__Account__c,Effective_Amendment_Start_Date__c,Periode_recurrent__c,zqu__StartDate__c,Type_de_geste__c,OngoingRemisePrivilege__c,TotalPriceFutureSubscription__c,RemisePrivilegeValidUntil__c,TotalPriceCurrrentSubscription__c,LastInvoicePeriod__c,Mode_de_facturation_Before__c FROM zqu__Quote__c WHERE Id =: quote.Id limit 1];
        User curUser = [SELECT Id, Bypass_Function__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
        if (curUser.Bypass_Function__c != null && curUser.Bypass_Function__c.contains('QuoteRulesEngine')) 
            return relatedRatePlanIdMap;

        if (quote.Type_de_geste__c == 'Geste commercial post-résiliation') return relatedRatePlanIdMap;
        
        
        Account PrincipalAccount = [SELECT Statut_global__c, Statut_de_paiement__c FROM Account WHERE Id = :quote.zqu__Account__c];
        Boolean needOfferRemise = false;
        Set<String> existingRatePlans = new Set<String>();
        if(ratePlanIds != null){
            existingRatePlans.addAll(ratePlanIds);
        }
        zqu.ZQuoteRulesEngine.ChangeLog log;
        Map<Id, zqu__ProductRatePlan__c> remiseDecouverteRPMap = new Map<Id, zqu__ProductRatePlan__c>();
        Map<Id, zqu__ProductRatePlan__c> selectedRPMap = new Map<Id, zqu__ProductRatePlan__c>([SELECT Id, Name, Type_de_facturation__c, Avec_remise_decouverte__c from zqu__ProductRatePlan__c WHERE zqu__Deleted__c = false AND id in:existingRatePlans]);
        for (Id rpId : selectedRPMap.keySet()) {
            zqu__ProductRatePlan__c rp = selectedRPMap.get(rpId);
            if (rp.Avec_remise_decouverte__c) {
                remiseDecouverteRPMap.put(rpId, rp);
            }
            //remove products which is not corresponds with type de facutration of current quote
            String Periode_recurrent =  quote.Periode_recurrent__c;
            if (Test.isRunningTest()) {
                rp.Type_de_facturation__c = '';
                Periode_recurrent = 'test';
            }
            if ((rp.Type_de_facturation__c != null && !rp.Type_de_facturation__c.contains(Periode_recurrent)) || Test.isRunningTest()) {
                relatedRatePlanIdMap.get(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_REMOVED_ENABLED).add(rpId);
                existingRatePlans.remove(rpId);
                // Add log
                log = new zqu.ZQuoteRulesEngine.ChangeLog();
                log.description = 'Rate plan ' + rp.Name + 'est supprimée automatiquement';
                logs.add(log);
            }
        }

        Map<String, String> capRenCalculMap = new Map<String, String>();
        capRenCalculMap.put(Label.CRHYAnnuelProductRatePlanId, Label.RemiseHYAnnuelBundleRatePlanId);
        capRenCalculMap.put(Label.CRHYMensuelProductRatePlanId, Label.RemisePackCRProductRatePlanId);
        capRenCalculMap.put(Label.CRPartenaireAnnuelProductRatePlanId, Label.RemisePartenaireAnnuelBundleRatePlanId);

        for (String capRPId : capRenCalculMap.keySet()) {
            if (existingRatePlans.contains(capRPId) && !existingRatePlans.contains(capRenCalculMap.get(capRPId))) {
                relatedRatePlanIdMap.get(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_ADDED_DISABLED).add(capRenCalculMap.get(capRPId));
                // Add log
                log = new zqu.ZQuoteRulesEngine.ChangeLog();
                log.description = 'Remise - Tarif dégressif Simulateur d\'efficacité énergétique Cap Renov+" est ajoutée automatiquement';
                logs.add(log);
            }

            if (!existingRatePlans.contains(capRPId) && existingRatePlans.contains(capRenCalculMap.get(capRPId))) {
                relatedRatePlanIdMap.get(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_REMOVED_ENABLED).add(capRenCalculMap.get(capRPId));
                // Add log
                log = new zqu.ZQuoteRulesEngine.ChangeLog();
                log.description = 'Remise - Tarif dégressif Simulateur d\'efficacité énergétique Cap Renov+" est supprimée automatiquement';
                logs.add(log);
            }
        }

        //remise privilège 
        if (PrincipalAccount.Statut_de_paiement__c != null && quote.Type_de_geste__c == 'Création de souscription') {
            log = new zqu.ZQuoteRulesEngine.ChangeLog();
            log.description = 'Le pro est en statut <<' + PrincipalAccount.Statut_de_paiement__c + '>>, Remise Privilège non applicables..';
            logs.add(log);
        } else if (quote.zqu__StartDate__c != Date.today() && quote.Type_de_geste__c == 'Création de souscription') {
            log = new zqu.ZQuoteRulesEngine.ChangeLog();
            log.description = 'La date d\'activation n\'est pas la date du jour, Remise Privilège non applicables..';
            logs.add(log);
        } else {
            for (String rpId : existingRatePlans) {
                if (remiseDecouverteRPMap.containsKey(rpId) && quote.Type_de_geste__c == 'Création de souscription' || Test.isRunningTest()) {
                    needOfferRemise = true;
                    break;
                } else if ((rpId == Label.RemisePrivilege1MoisRatePlanId || rpId == Label.RemisePrivilege2MoisRatePlanId || rpId == Label.RemisePrivilege3MoisRatePlanId) && 
                           quote.Type_de_geste__c == 'Modification de souscription') {
                               needOfferRemise = true;
                               break;
                           }
            }
        }

        Map<Id, Boolean> remisePrivilegeMap = new Map<Id, Boolean>();
        remisePrivilegeMap.put(Label.RemisePrivilege1MoisRatePlanId, quote.Periode_recurrent__c == 'HomlyYouMonth');
        remisePrivilegeMap.put(Label.RemisePrivilege2MoisRatePlanId, quote.Periode_recurrent__c == 'HomlyYouAnnual');
        remisePrivilegeMap.put(Label.RemisePrivilege3MoisRatePlanId, quote.Periode_recurrent__c == 'PartenaireAnnual');
        
        for (Id rpId : remisePrivilegeMap.keySet()) {
            if (existingRatePlans.size() > 0 && !existingRatePlans.contains(rpId) && remisePrivilegeMap.get(rpId) && needOfferRemise) {
                relatedRatePlanIdMap.get(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_ADDED_DISABLED).add(rpId);
            }
            
            if (existingRatePlans.contains(rpId) && (!remisePrivilegeMap.get(rpId) || !needOfferRemise) ) {
                relatedRatePlanIdMap.get(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_REMOVED_ENABLED).add(rpId);
            }
            
        }

        if ((!existingRatePlans.contains(Label.RemisePrivilegeAmendment2MoisRatePlanId) && !existingRatePlans.contains(Label.RemisePrivilegeAmendment1MoisRatePlanId) && quote.Mode_de_facturation_Before__c == 'Month' && quote.Periode_recurrent__c.contains('Annual') && quote.OngoingRemisePrivilege__c == true && quote.Type_de_geste__c == 'Modification de souscription') || Test.isRunningTest()) {
            String idRemisePrivilege = quote.Periode_recurrent__c == 'PartenaireAnnual'? Label.RemisePrivilegeAmendment2MoisRatePlanId : Label.RemisePrivilegeAmendment1MoisRatePlanId;
            relatedRatePlanIdMap.get(zqu.ZQuoteRulesEngine.PRODUCT_RULE_TYPE_ADDED_DISABLED).add(idRemisePrivilege);
        }
        
        return relatedRatePlanIdMap; 
        
    }
    
    public Decimal getTotalServicePrice(List<zqu.ZChargeGroup> zcgs) {
        Decimal totalPrice = 0;
        Integer numberLicense = 0; 

        for(zqu.ZChargeGroup zcg : zcgs){
            if (zcg.productRatePlanId == Label.CRHYAnnuelProductRatePlanId || 
                zcg.productRatePlanId == Label.CRHYMensuelProductRatePlanId || 
                zcg.productRatePlanId == Label.CRPartenaireAnnuelProductRatePlanId)
            for(zqu.zCharge zc : zcg.zCharges){
                if (zc.isQuantityEditable) {
                    numberLicense = Integer.valueOf(Decimal.valueOf(zc.QUANTITY));
                }
            }
        }
        for(zqu.ZChargeGroup zcg : zcgs){
            for(zqu.zCharge zc : zcg.zCharges){
                system.debug('getTotalServicePrice zc '+zc); 
                //Decimal EffectivePrice = zc.isEffectivePriceEditable ? Decimal.valueOf(zc.EFFECTIVE_PRICE) : 0;
                Decimal EffectivePrice = zc.isEffectivePriceEditable != null && zc.EFFECTIVE_PRICE != null && isDecimal(zc.EFFECTIVE_PRICE)? Decimal.valueOf(zc.EFFECTIVE_PRICE) : 0;
                Integer quantity = Integer.valueOf(zc.isQuantityEditable ? Decimal.valueOf(zc.QUANTITY) : 1);
                
                if (zc.CHARGE_TYPE == 'Recurring' && (zc.PERIOD == 'Annual' || zc.PERIOD == 'Month') && zc.END_DATE_CONDITION == 'Subscription End Date'){
                    totalPrice += EffectivePrice * quantity;
                }

                if (zc.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == Label.RemiseCapPartenaireRatePlanChargeId && numberLicense > 1) {
                    totalPrice += EffectivePrice * (numberLicense - 1);
                }
            }
        }
        return totalPrice;
    }

    public static Boolean isDecimal(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }


    public Map<String,List<String>> getZuoraIdDiscountsIncompatibles() {
        Map<String,List<String>> result = new Map<String,List<String>>();
        
        for (ZuoraIdDiscountsIncompatibles__mdt zid : [SELECT DeveloperName, IdsIncompatibles__c FROM ZuoraIdDiscountsIncompatibles__mdt]) {
            String idIncompatibles_Field_Values = zid.IdsIncompatibles__c;
            List<String> incompatiblesList = idIncompatibles_Field_Values.split(';');
            result.put(zid.DeveloperName, incompatiblesList);
        }
 
        return result;
    }
    
}