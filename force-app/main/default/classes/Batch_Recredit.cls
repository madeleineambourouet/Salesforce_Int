// 
// Batch pour les recrédits sur MERs rejetées
// 17/07/2017, xavier templet, version initiale   
// 18/08/2017, xavier templet, Database.Batchable<sObject> and LIMIT to max 5 quotes created by batch   
// 30/08/2017, xavier templet, refactoring to avoid soql governor limit
// 11/09/2017, xavier templet, refactoring for 1 quote per account including recatching


public with sharing class Batch_Recredit implements Database.Batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Integer iter_jours;
        if (test.isRunningTest()) iter_jours = 1;
        else iter_jours = Integer.valueOf(System.Label.DureeRattrapageRecredit);
        Date Date_j = Date.today();
        Date Date_j0 = Date_j.addDays(-iter_jours);
            
        return Database.getQueryLocator(    
        'select Id, Name, Prix_de_la_competence__c, ' +
            'Matching_rejete__c, Matching_rejete_date__c, Professionnel__r.Id, Professionnel__r.Statut_de_paiement__c, ' +
                'Projet__c, Projet__r.Name, Projet__r.Statut_Projet__c from Intermediation__c ' +
                    'where recredit_quote__c = null AND Matching_rejete__c != NULL AND Matching_rejete__c != \'\' AND Matching_rejete_date__c >= :Date_j0 ' +
                        'AND IsModified__c = true AND Date_de_s_lection__c != NULL');
    }
    
    public void execute(Database.BatchableContext BC, List<Intermediation__c> scope) {
        
try{
        String ProductRatePlanName = String.valueOf(System.Label.ProductRatePlan_pour_recredit_usage);
        ProductRatePlanName = '%'+ProductRatePlanName+'%';
        Integer LoopCount = 0;
        Integer iter_jours;
        Integer MaxLoopCount;
        if (test.isRunningTest()) {iter_jours = 1; MaxLoopCount = 20;}
        else {
            iter_jours = Integer.valueOf(System.Label.DureeRattrapageRecredit);
            MaxLoopCount = Integer.valueOf(System.Label.MaxQuoteCreatedByBatch);
        }
        Date Date_j = Date.today();
        Date Date_j0 = Date_j.addDays(-iter_jours);
        DateTime DateTime_j0 = DateTime.now();
        DateTime_j0 = DateTime_j0.addDays(-iter_jours);

        System.debug('Batch_Recredit >>>>> scope :' + scope);
        if (scope == null || scope.size() == 0) return; 
        
        //on fait tous les appels soql avant l'itération sur les jours passés, potentiellement à rattraper 
        Reference__c Motif = [Select Id from Reference__c where Name = 'Recrédit à rattraper'];
        List<Case> ExistingCaseRecredit = [Select Id, AccountId from Case 
            where Motif__c = :Motif.Id AND Origin = 'TC Service Client pro' AND (Status = 'Nouvelle' OR Status = 'En cours') AND CreatedDate >= :DateTime_j0];
        Map<Id, Case> ExistingCaseRecreditList = new Map<Id, Case>();
        for (Case c : ExistingCaseRecredit) ExistingCaseRecreditList.put(c.AccountId, c);
        system.debug('Batch_Recredit >>>>> ExistingCaseRecreditList: ' + ExistingCaseRecreditList);
            
            // On récupère les produits du catalogue
            List <zqu__ProductRatePlan__c> productRatePlanList = [SELECT id, Name, Est_intermediation__c, zqu__Product__c, 
                zqu__Product__r.Name, zqu__ZuoraId__c FROM zqu__ProductRatePlan__c 
                    WHERE Name like :ProductRatePlanName AND zqu__Product__r.zqu__Deleted__c = false];
            system.debug('Batch_Recredit >>>>> productRatePlanList: ' + productRatePlanList);
            if (productRatePlanList == null) return;
            List <zqu__ProductRatePlanCharge__c> productRatePlanChargeList = [SELECT id, Name, zqu__ProductRatePlan__c, 
                zqu__ProductRatePlan__r.Name, zqu__Type__c, zqu__Model__c, zqu__ZuoraId__c 
                    FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN : productRatePlanList];
            system.debug('Batch_Recredit >>>>> productRatePlanChargeList: ' + productRatePlanChargeList);
            if (productRatePlanChargeList == null) return;
            List <zqu__ProductRatePlanChargeTier__c> productRatePlanChargeTierList = 
                [SELECT id, Name, zqu__Price__c, zqu__Currency__c, zqu__ProductRatePlanCharge__c, 
                    zqu__ProductRatePlanCharge__r.Name, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c, 
                        zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c, 
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name 
                                FROM zqu__ProductRatePlanChargeTier__c WHERE zqu__ProductRatePlanCharge__c IN :productRatePlanChargeList];
            //system.debug('Batch_Recredit >>>>> productRatePlanChargeTierList: ' + productRatePlanChargeTierList);
            if (productRatePlanChargeTierList == null) system.debug('Batch_Recredit >>>>> NO zqu__ProductRatePlanChargeTier__c FOUND!!!!');

                
        // construit une 1ere liste de account potentiellement à recréditer et map associée 
        // Map account with MER to recredit
        Map<Id, List<Intermediation__c>> Account2Recredit0 = new Map<Id, List<Intermediation__c>>(); 
        List<Account> accList0 = new List<Account>();
        for (Intermediation__c m : scope){
            Account acc = new Account();
            acc.Id = m.Professionnel__r.Id;
            List<Intermediation__c> mer4Account = new List<Intermediation__c>();
            if (!Account2Recredit0.containsKey(acc.Id)) accList0.add(acc);
            else mer4Account = Account2Recredit0.get(acc.Id);
            mer4Account.add(m);
            Account2Recredit0.put(acc.Id,mer4Account);
        } //System.debug('Batch_Recredit >>>>> accList0 :' + accList0);
        List<Account> accList0Details = [SELECT id, Name, Statut_de_paiement__c, Contact_principal__c, Contact_principal__r.Name FROM Account WHERE id IN :accList0]; 
        Map<Id, Account> accList0DetailsMap = new Map<Id, Account>(accList0Details);

        List<Zuora__Subscription__c> ZuoSubList = [select Id, Name, Zuora__Account__c, Zuora__SubscriptionStartDate__c, Zuora__Zuora_Id__c 
            from Zuora__Subscription__c where Zuora__Account__c IN :accList0 AND Zuora__Status__c  = 'Active'];
        Map<Id, Zuora__Subscription__c> Account2ZuoSub = new Map<Id, Zuora__Subscription__c>();
        for (Zuora__Subscription__c zsub : ZuoSubList) Account2ZuoSub.put(zsub.Zuora__Account__c, zsub); 
        //System.debug('Batch_Recredit >>>>> Account2ZuoSub :' + Account2ZuoSub);
        
        List<Zuora__CustomerAccount__c> ZuoBillAccntList = [select Id, Name, Zuora__Account__c, Zuora__AccountNumber__c, Zuora__Currency__c, Zuora__Zuora_Id__c 
            from Zuora__CustomerAccount__c where Zuora__Account__c IN :accList0];
        Map<Id, Zuora__CustomerAccount__c> Account2BillAccnt = new Map<Id, Zuora__CustomerAccount__c>(); 
        for (Zuora__CustomerAccount__c zba : ZuoBillAccntList) Account2BillAccnt.put(zba.Zuora__Account__c, zba); 
        //System.debug('Batch_Recredit >>>>> Account2BillAccnt :' + Account2BillAccnt);

        List<zqu__Quote__c> ZuoQuoteList = [select Id, Name, zqu__account__c, zqu__Status__c from zqu__Quote__c where zqu__account__c IN :accList0];
        Map<Id, zqu__Quote__c> Account2Quote = new Map<Id, zqu__Quote__c>(); 
        for (zqu__Quote__c zq : ZuoQuoteList) 
            if (zq.zqu__Status__c != 'Sent to Z-Billing' && zq.zqu__Status__c != 'Abandonnée') 
                Account2Quote.put(zq.zqu__account__c, zq); 
        //System.debug('Batch_Recredit >>>>> Account2Quote :' + Account2Quote);
        
        //pour tous les account id de la liste aller voir si Zuora__Subscription__c / Zuora__Status__c  = active, pour potentiellement réduire la liste
        // Autres cas à checker 
        //if (('{!Account.Statut_de_paiement__c}' == 'A mettre en recouvrement') || ('{!Account.Statut_de_paiement__c}' == 'Client transmis au recouvrement') || ('{!Account.Statut_de_paiement__c}' == 'Résilié impayé')) 
        //alert('Vous ne vous pouvez pas de créer de proposition commerciale, le statut de paiement est en recouvrement ou résilié impayé.'); 
        //zqu__Status__c NOT IN ('Sent to Z-Billing','Abandonnée') 
        //alert('Vous ne pouvez pas créer de nouvelle proposition. Vous avez la souscription '+SubscriptionResult[2]+' au statut '+SubscriptionResult[1]+'.');      
        List<Account> accList2Details = new List<Account>();
        Map<Id, List<Intermediation__c>> Account2Recredit2 = new Map<Id, List<Intermediation__c>>(); 
        for(Account a : accList0) {
            List<Intermediation__c> mer4Account = new List<Intermediation__c>();
            Account accnt = new Account();
            accnt = accList0DetailsMap.get(a.Id);
            if (Account2ZuoSub.containsKey(a.Id) && !Account2Quote.containsKey(a.Id) 
                && accnt.Statut_de_paiement__c != 'A mettre en recouvrement' && accnt.Statut_de_paiement__c != 'Client transmis au recouvrement' && accnt.Statut_de_paiement__c != 'Résilié impayé') {
                    accList2Details.add(a);
                    mer4Account = Account2Recredit0.get(a.Id);
                    Account2Recredit2.put(a.Id, mer4Account);
            }
        }   
        System.debug('Batch_Recredit >>>>> accList2Details :' + accList2Details);
        System.debug('Batch_Recredit >>>>> Account2Recredit2 :' + Account2Recredit2);

        // on construit une map du compte vers le contact de facturation
        // 
        List<Contact> InvContactList = [SELECT Id, Name, AccountID, Contact_de_facturation__c FROM Contact WHERE Contact_de_facturation__c = TRUE AND AccountID IN :accList2Details];
        Map<Id, Contact> Account2InvContact = new Map<Id, Contact>();
        for (Contact c : InvContactList) Account2InvContact.put(c.AccountID, c);
        //System.debug('Batch_Recredit >>>>> Account2InvContact :' + Account2InvContact);
         
        // Pour les accounts qui n'ont pas été retenus ou si erreur fonctionnelle... il y a création d'une requête pour étudier le cas
        // si le TC peut résoudre le pb, le jour suivant le batch va créer la quote ...
        List<Case> RecreditCaseList = new List<Case>(); 
        string message;
        for(Account accnt : accList0Details) {
            message = '';
            if (!Account2Recredit2.containsKey(accnt.Id) && !ExistingCaseRecreditList.containsKey(accnt.Id)) {
                if (!Account2ZuoSub.containsKey(accnt.Id)) message = 'Souscription pas active';
                else message = 'Souscription active';
                if (Account2Quote.containsKey(accnt.Id)) message = message + ', Proposition déjà en cours';
                else message = message  + ', Pas d\'autre proposition en cours';
                if (accnt.Statut_de_paiement__c != null) message = message + ', Statut de paiement: ' + accnt.Statut_de_paiement__c;
                
                // création d'une requête
                Case rc = new Case();
                rc.AccountId = accnt.Id;
                rc.ContactId = accnt.Contact_principal__c; 
                rc.Origin = 'TC Service Client pro';
                rc.Subject = 'Problème avec un recrédit suite à un rejet de la mise en relation';
                rc.Description_interne__c = 'Batch_Recredit: ' + message;
                rc.Status = 'Nouvelle';
                rc.Priority = 'Moyenne';
                //rc.Type Problème
                //rc.Projet__c = Pas de projet en particulier car ce sont des problèmes liés au compte du PRO
                //rc.Origine_Requ_te__c
                //rc.Type_Contact__c
                rc.Motif__c = Motif.Id;
                RecreditCaseList.add(rc);
            }
        } System.debug('Batch_Recredit >>>>> RecreditCaseList :' + RecreditCaseList);   
        if (RecreditCaseList != null && RecreditCaseList.size()>0) insert RecreditCaseList;

        if (accList2Details == null || accList2Details.size() == 0) return;

        /*on récupère les cases de recrédit pour faire le lien avec la MER ou la quote (essai, traitement voir ligne 320) 
        Reference__c Motif2 = [Select Id from Reference__c where Name = 'Recrédit'];
        List<Case> CaseRecreditRequestList = [Select Id, AccountId, Projet__c, Subject from Case 
            where Motif__c = :Motif2.Id AND Origin = 'TC Service Client pro' AND (Status = 'Nouvelle' OR Status = 'En cours') AND AccountId in :accList2Details];
        System.debug('Batch_Recredit >>>>> CaseRecreditRequestList :' + CaseRecreditRequestList);
        */
        
        ID RTAmendQuote = [SELECT Id FROM RecordType WHERE DeveloperName = 'Amendment' LIMIT 1].Id; 

        Date myDate = date.today();
        List<zqu__Quote__c> quoList = new List<zqu__Quote__c>();
        List<zqu__QuoteAmendment__c> quoAmendmentList = new List<zqu__QuoteAmendment__c>(); 
        List<zqu__QuoteRatePlan__c>  quoRatePlanList = new List<zqu__QuoteRatePlan__c>();
        List<zqu__QuoteRatePlanCharge__c> quoRatePlanChargeList = new List<zqu__QuoteRatePlanCharge__c>(); 
        List<zqu__QuoteChargeSummary__c> quoQuoteChargeSummaryList = new List<zqu__QuoteChargeSummary__c>();

        /* la quote doit avoir la date de / des MERs recréditées, on fait une fenetre glissante jour / jour 
        for(Integer i=0;i<iter_jours;i++) {
        //if (i != 0) Date_j = Date_j.addDays(-1);
        //System.debug('Batch_Recredit >>>>> Date_j :' + Date_j);

        //je prends compte par compte de Account2Recredit2, je checke chaque mer si date ok j ajoute le compte et la mer pour traitement   
        List<Account> accListDetails = new List<Account>();
        For (Account acc : accList2Details) {
                List<Intermediation__c> mer4Account = new List<Intermediation__c>();
                mer4Account = Account2Recredit2.get(acc.Id);
                for (Intermediation__c m : mer4Account) 
                    if (m.Matching_rejete_date__c == Date_j) { 
                        accListDetails.add(accList0DetailsMap.get(acc.Id));
                        break;
                    }
        }
        if (accListDetails == null || accListDetails.size() == 0) continue;*/ 

        // pour tous les account id de la liste restante créer une quote de type amendment
        for (Account accnt: accList2Details) {
            // LIMIT to max 5 quotes created by batch
            LoopCount++; if (LoopCount > MaxLoopCount) break;  
            zqu__Quote__c quote = new zqu__Quote__c();  
            Zuora__Subscription__c ZuoSub = new Zuora__Subscription__c();
            ZuoSub = Account2ZuoSub.get(accnt.Id);
            //system.debug('Batch_Recredit >>>>> ZuoSub: ' + ZuoSub);
            Zuora__CustomerAccount__c ZuoBillAccnt = new Zuora__CustomerAccount__c();
            ZuoBillAccnt = Account2BillAccnt.get(accnt.Id);
            //system.debug('Batch_Recredit >>>>> ZuoBillAccnt: ' + ZuoBillAccnt);

            quote.Quote_Key__c = Date_j;
            quote.RecordTypeId = RTAmendQuote;
            quote.zqu__Amendment_Name__c = 'Recrédit';
            quote.zqu__account__c = accnt.Id;
            //quote.Type_de_geste__c = 'Modification de souscription';
            quote.zqu__SoldToContact__c = accnt.Contact_principal__c;
            if (Account2InvContact.containsKey(accnt.Id)) 
                quote.zqu__BillToContact__c = Account2InvContact.get(accnt.Id).Id;
            else quote.zqu__BillToContact__c = accnt.Contact_principal__c; 
            quote.zqu__StartDate__c = myDate;
            quote.zqu__ValidUntil__c = myDate.addMonths(1);
            quote.zqu__Status__c = 'New';
            quote.zqu__SubscriptionType__c = 'Amend Subscription';
            quote.zqu__Subscription_Term_Type__c = 'Evergreen';
            quote.zqu__InvoiceProcessingOption__c = 'Subscription';
            quote.zqu__ZuoraAccountID__c = ZuoBillAccnt.Zuora__Zuora_Id__c;
            quote.zqu__InvoiceOwnerId__c = ZuoBillAccnt.Zuora__Zuora_Id__c;
            quote.zqu__InvoiceOwnerName__c = ZuoBillAccnt.Name;
            //quote.zqu__Zuora_Account_Number__c = ZuoBillAccnt.Zuora__AccountNumber__c;
            quote.zqu__Currency__c = ZuoBillAccnt.Zuora__Currency__c;
            quote.zqu__SubscriptionTermStartDate__c = ZuoSub.Zuora__SubscriptionStartDate__c;
            //quote.zqu__SubscriptionTermEndDate__c = ;
            //quote.zqu__ZuoraSubscriptionID__c = ZuoSub.Zuora__Zuora_Id__c;
            quote.zqu__ExistSubscriptionID__c = ZuoSub.Zuora__Zuora_Id__c;
            quote.zqu__Hidden_Subscription_Name__c = ZuoSub.Name;
            //quote.zqu__SubscriptionName__c = ZuoSub.Name;
            //quote.Modification_offres__c = true;
            quote.zqu__ApplyCreditBalance__c = true;
            //quote.zqu__RecordReadOnly__c = true;
            quote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';
            //quote.zqu__Is_Charge_Expired__c = true;
            //quote.zqu__Is_Parent_Quote__c = false;
            quote.zqu__SubscriptionVersion__c = 1.0;            
            //quote.zqu__BillCycleDay__c 
            //quote.zqu__AutoRenew__c = true;
            //quote.zqu__Opportunity__c = opp.Id;
            //quote.zqu__InitialTerm__c = 12.0;
            //quote.zqu__RenewalTerm__c = 6.0;
            //quote.zqu__BillingMethod__c = 'Both';
            
            //insert quote;
            quoList.add(quote);
        }//for (Account accnt: accList2Details)
        //}//for(Integer i=0;i<iter_jours;i++)
        
        system.debug('Batch_Recredit >>>>> quoList: ' + quoList);
        insert quoList;
        system.debug('Batch_Recredit >>>>> total created quote = ' + LoopCount);

        //List<Case> CaseRecreditRequestList2update = new List<Case>();
        List<Intermediation__c> mer2update = new List<Intermediation__c>();
        Map<Id, zqu__ProductRatePlanChargeTier__c> Mer2ProductRPCT = new Map<Id, zqu__ProductRatePlanChargeTier__c>();
        for (zqu__Quote__c q : quoList) {       

            List<Intermediation__c> mer4Account = new List<Intermediation__c>();
            List<Intermediation__c> merList = new List<Intermediation__c>();
            Map<Id, List<Intermediation__c>> Account2Recredit = new Map<Id, List<Intermediation__c>>(); 
            mer4Account = Account2Recredit2.get(q.zqu__account__c);
            //for (Intermediation__c m : mer4Account) if (m.Matching_rejete_date__c == q.Quote_Key__c) merList.add(m);
            //if (merList != null && merList.size() > 0) 
            //  Account2Recredit.put(q.zqu__account__c, merList);
            if (mer4Account != null && mer4Account.size() > 0) 
                Account2Recredit.put(q.zqu__account__c, mer4Account);
            System.debug('Batch_Recredit >>>>> Account2Recredit :' + Account2Recredit);

            for (Intermediation__c mer : mer4Account){      

            // connaissant le prix de la mer, connaissant le catalogue, je vais ajouter un produit correspondant pour la quote
            // Prix__c ou Prix_de_la_competence__c ????????
            Decimal myPrice = mer.Prix_de_la_competence__c * -1.0;
            //system.debug('Batch_Recredit >>>>> Query productRatePlanChargeTier with Price: ' + myPrice);
            zqu__ProductRatePlanChargeTier__c ProductRatePlanChargeTier = new zqu__ProductRatePlanChargeTier__c();
            for (zqu__ProductRatePlanChargeTier__c prpctier : productRatePlanChargeTierList) 
                if (prpctier.zqu__Price__c == myPrice) {
                    ProductRatePlanChargeTier = prpctier;
                    //system.debug('Batch_Recredit >>>>> productRatePlanChargeTier: ' + productRatePlanChargeTier);
                    break;
                }
            Mer2ProductRPCT.put(mer.Id, ProductRatePlanChargeTier);
            
            zqu__QuoteAmendment__c quoAmendment = new zqu__QuoteAmendment__c();
                quoAmendment.Name = 'Recrédit ' + mer.Name;
                quoAmendment.zqu__Type__c = 'NewProduct';
                quoAmendment.zqu__Quote__c = q.Id;
                quoAmendment.Quote_Amendment_Key__c = mer.Id;
                //zqu__Description__c = 'Offre rajoutée: ' + productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name + ', détail: ' +
                    //productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name
                //zqu__TotalAmount__c = ProductRatePlanChargeTier.zqu__Price__c;
                //Detail_des_modifications__c = 'Offre rajoutée: ' + productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name + ', détail: ' +
                    //productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name
                
/*
zqu__AutoRenew__c
zqu__DeltaMRR__c
zqu__DeltaTCV__c
zqu__InitialTerm__c
zqu__QuoteAmendmentZuoraId__c
zqu__RenewalSetting__c
zqu__RenewalTerm__c
zqu__Status__c
zqu__TermStartDate__c
zqu__TermType__c
*/
                //insert quoAmendment;
                quoAmendmentList.add(quoAmendment); 

                /*for (Case c : CaseRecreditRequestList) {
                    if (c.AccountId == q.zqu__account__c && c.Projet__c == mer.Projet__c && c.Subject.containsIgnoreCase(mer.Name)) {
                        //Requete_Recredit__c est un lookup vers le case
                        //mer.Requete_Recredit__c = c.Id;
                        //Proposition_liee__c est un lookup vers la quote 
                        c.Proposition_liee__c = q.Id;
                        CaseRecreditRequestList2update.add(c);
                        continue; 
                    }
                }*/

                mer.recredit_quote__c = q.Id;
                mer2update.add(mer);
                
            } //for (Intermediation__c mer : merList)
        }//for (zqu__Quote__c q : quoList)      
        system.debug('Batch_Recredit >>>>> quoAmendmentList: ' + quoAmendmentList);
        insert quoAmendmentList;
        update mer2update;
        //system.debug('Batch_Recredit >>>>> CaseRecreditRequestList2update: ' + CaseRecreditRequestList2update);
        //update CaseRecreditRequestList2update;

        Map<Id, zqu__ProductRatePlanChargeTier__c> Amendment2ProductRPCT = new Map<Id, zqu__ProductRatePlanChargeTier__c>();
        for (zqu__QuoteAmendment__c qA : quoAmendmentList) {        
            zqu__ProductRatePlanChargeTier__c ProductRatePlanChargeTier = new zqu__ProductRatePlanChargeTier__c();
            ProductRatePlanChargeTier = Mer2ProductRPCT.get(qA.Quote_Amendment_Key__c);
            Amendment2ProductRPCT.put(qA.Id, ProductRatePlanChargeTier);
            
            zqu__QuoteRatePlan__c  quoRatePlan = new zqu__QuoteRatePlan__c();
                quoRatePlan.Name = productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name;
                quoRatePlan.zqu__ProductRatePlan__c= productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c;
                quoRatePlan.zqu__QuoteProductName__c = productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name;
                quoRatePlan.zqu__ProductRatePlanZuoraId__c = productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
                quoRatePlan.zqu__QuoteAmendment__c = qA.Id;
                quoRatePlan.zqu__Quote__c = qA.zqu__Quote__c;
                quoRatePlan.zqu__AmendmentType__c = 'NewProduct';
/*
zqu__QuoteRatePlanZuoraId__c
zqu__SubscriptionRatePlanZuoraId__c
zqu__Time_Product_Added__c
*/          
                //insert quoRatePlan;
                quoRatePlanList.add(quoRatePlan);
        }//for (zqu__QuoteAmendment__c qA : quoAmendmentList)
        system.debug('Batch_Recredit >>>>> quoRatePlanList: ' + quoRatePlanList);
        insert quoRatePlanList;

        Map<Id, zqu__ProductRatePlanChargeTier__c> qRatePlan2ProductRPCT = new Map<Id, zqu__ProductRatePlanChargeTier__c>();
        Map<Id, String> qRatePlanName = new Map<Id, String>();          
        for (zqu__QuoteRatePlan__c qRatePlan : quoRatePlanList) {   
            zqu__ProductRatePlanChargeTier__c ProductRatePlanChargeTier = new zqu__ProductRatePlanChargeTier__c();
            ProductRatePlanChargeTier = Amendment2ProductRPCT.get(qRatePlan.zqu__QuoteAmendment__c);
            qRatePlan2ProductRPCT.put(qRatePlan.Id, ProductRatePlanChargeTier);
            qRatePlanName.put(qRatePlan.Id, qRatePlan.Name);
            
            zqu__QuoteRatePlanCharge__c quoRatePlanCharge = new zqu__QuoteRatePlanCharge__c(); 
                quoRatePlanCharge.Name = productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.Name;
                quoRatePlanCharge.zqu__QuoteRatePlan__c = qRatePlan.Id;
                quoRatePlanCharge.zqu__ProductRatePlanCharge__c = productRatePlanChargeTier.zqu__ProductRatePlanCharge__c;
                quoRatePlanCharge.zqu__Quantity__c = 1;
                quoRatePlanCharge.zqu__ChargeType__c = 'One-Time';
                quoRatePlanCharge.zqu__Model__c = 'Flat Fee Pricing';
                quoRatePlanCharge.zqu__FeeType__c = 'Flat Fee';
                quoRatePlanCharge.zqu__ProductRatePlanChargeZuoraId__c = productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c;
                quoRatePlanCharge.zqu__Total__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoRatePlanCharge.zqu__ListTotal__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoRatePlanCharge.zqu__ListPrice__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoRatePlanCharge.zqu__EffectivePrice__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoRatePlanCharge.zqu__Description__c = productRatePlanChargeTier.zqu__ProductRatePlanCharge__r.Name;
                quoRatePlanCharge.zqu__Currency__c = productRatePlanChargeTier.zqu__Currency__c;
                quoRatePlanCharge.zqu__TCV__c = 0.0;
                quoRatePlanCharge.zqu__MRR__c = 0.0;
/*
zqu__Apply_Discount_To_One_Time_Charges__c
zqu__Apply_Discount_To_Recurring_Charges__c
zqu__Apply_Discount_To_Usage_Charges__c
zqu__BillCycleDay__c
zqu__BillCycleType__c
zqu__BillingPeriodAlignment__c
zqu__Discount__c
zqu__Discount_Level__c
zqu__EndDateCondition__c
zqu__IncludedUnits__c
License_ID__c
License_number__c
zqu__ListPriceBase__c
zqu__PreviewedMRR__c
zqu__Period__c
zqu__PriceChangeOption__c
zqu__PriceIncreasePercentage__c
PU_HT__c
zqu__QuoteRatePlanChargeZuoraId__c
zqu__SpecificBillingPeriod__c
zqu__SpecificEndDate__c
zqu__SubscriptionRatePlanChargeZuoraId__c
zqu__PreviewedTCV__c
Total_HT__c
zqu__TriggerDate__c
zqu__TriggerEvent__c
zqu__UOM__c
zqu__Upto_How_Many_Periods__c
zqu__Upto_How_Many_Periods_Type__c
*/
                //insert quoRatePlanCharge;
                quoRatePlanChargeList.add(quoRatePlanCharge);
        }//for (zqu__QuoteRatePlan__c qRatePlan : quoRatePlanList)
        system.debug('Batch_Recredit >>>>> quoRatePlanChargeList: ' + quoRatePlanChargeList);
        insert quoRatePlanChargeList; 

        for (zqu__QuoteRatePlanCharge__c qRatePlanCharge : quoRatePlanChargeList) { 
            zqu__ProductRatePlanChargeTier__c ProductRatePlanChargeTier = new zqu__ProductRatePlanChargeTier__c();
            ProductRatePlanChargeTier = qRatePlan2ProductRPCT.get(qRatePlanCharge.zqu__QuoteRatePlan__c);
            
                        
            zqu__QuoteChargeSummary__c quoQuoteChargeSummary = new zqu__QuoteChargeSummary__c();
                quoQuoteChargeSummary.zqu__QuoteRatePlan__c = qRatePlanCharge.zqu__QuoteRatePlan__c;
                quoQuoteChargeSummary.Name = qRatePlanName.get(qRatePlanCharge.zqu__QuoteRatePlan__c);
                quoQuoteChargeSummary.zqu__QuoteRatePlanCharge__c = qRatePlanCharge.Id;
                quoQuoteChargeSummary.zqu__Description__c = qRatePlanCharge.Name;
                quoQuoteChargeSummary.zqu__Discount__c = 0.0;
                quoQuoteChargeSummary.zqu__EffectivePrice__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoQuoteChargeSummary.zqu__ListPrice__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoQuoteChargeSummary.zqu__TotalPrice__c = ProductRatePlanChargeTier.zqu__Price__c;
                quoQuoteChargeSummary.zqu__Model__c = 'Flat Fee Pricing';
                quoQuoteChargeSummary.zqu__Type__c = 'One-Time';
                quoQuoteChargeSummary.zqu__MRR__c = 0.0;
                quoQuoteChargeSummary.zqu__TCV__c = 0.0;
                quoQuoteChargeSummary.zqu__Quantity__c = 1.0;
/*
zqu__Apply_Discount_To_One_Time_Charges__c
zqu__Apply_Discount_To_Recurring_Charges__c
zqu__Apply_Discount_To_Usage_Charges__c
zqu__ChangeLog__c
zqu__Discount_Level__c
zqu__IncludedUnits__c
License_ID__c
License_number__c
zqu__ListTotal__c
zqu__PreviewedMRR__c
zqu__Opportunity__c
zqu__Period__c
zqu__Product_Name__c
zqu__Product_Rate_Plan_Name__c
zqu__Quote_Charge__c
zqu__PreviewedTCV__c
zqu__UOM__c
zqu__Upto_How_Many_Periods__c

*/
                //insert quoQuoteChargeSummary;
                quoQuoteChargeSummaryList.add(quoQuoteChargeSummary);
        }//for (zqu__QuoteRatePlanCharge__c qRatePlanCharge : quoRatePlanChargeList)
        system.debug('Batch_Recredit >>>>> quoQuoteChargeSummaryList: ' + quoQuoteChargeSummaryList);
        insert quoQuoteChargeSummaryList;
        
        if (quoList !=null) {
            //...
            //update quoQuoteChargeSummaryList
            //update quoRatePlanChargeList; 
            //update quoRatePlanList;
            //update quoAmendmentList; 
            //for (zqu__Quote__c zq : quoList) zq.zqu__Status__c = 'En cours';
            QuoteMethods.AmendmentDetails(quoList);
            update quoList;
            //QuoteMethods.calculateTexteCompetence(quoList);
        } //System.debug('Batch_Recredit >>>>> quotes :' + quoList);

        
} catch (Exception e) {
          System.assert(false, 'Batch_Recredit: Exception occured. Exception Details: ' + e.getMessage());
}


    } //execute


    public void finish(Database.BatchableContext BC) {
/*
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()];

        System.debug('Batch_Recredit >>>>> job :' + job);
*/        
    }
    
    public void execute(SchedulableContext context) {
        Batch_Recredit b = new Batch_Recredit(); 
        database.executebatch(b);
    }


}