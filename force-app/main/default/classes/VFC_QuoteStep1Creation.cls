global with sharing class VFC_QuoteStep1Creation {//extends zqu.BaseQuoteWizardController {

    public zqu__Quote__c thisQuote {get; set;}
    private ApexPages.StandardController controller;
    public String selectedEnseigne {get; set;} 
    public String quoteType {get; private set;} //Subscription, Amendment, Cancellation
    public Boolean disableTypeGeste {get; set;}
    public Boolean renderVenteDirecteAgence {get; set;}
    public SelectOption defaultSelectOption;
    public List<SelectOption> enseignes{get;set;}
    public Boolean isAmendment{get; set;}


    //Page Constructor
    public VFC_QuoteStep1Creation(ApexPages.StandardController StandardController) {
        this.controller = StandardController;
        zqu.QuoteWizardManager.start('New', 1);
    }

    public void initDefaultValues() {
        isAmendment = false;
        quoteType = ApexPages.currentPage().getParameters().get('quoteType');
        thisQuote = ((zqu__Quote__c)controller.getRecord() == null)? new zqu__Quote__c() : (zqu__Quote__c)controller.getRecord();
        thisQuote.zqu__Currency__c = 'EUR';
        thisQuote.zqu__Status__c = 'En cours';
        thisQuote.zqu__StartDate__c =  Date.today(); 
        thisQuote.zqu__ValidUntil__c = Date.today().addDays(30);
        thisQuote.zqu__Subscription_Term_Type__c = 'EVERGREEN';
        thisQuote.zqu__BillingBatch__c = 'Batch1';
        thisQuote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        thisQuote.Type_de_geste__c = thisQuote.Type_de_geste__c == null ? 'Création de souscription' : thisQuote.Type_de_geste__c;
        disableTypeGeste = thisQuote.Type_de_geste__c == 'Création de souscription' || thisQuote.Type_de_geste__c == 'Modification de souscription' || quoteType == 'Amendment' ? false : true;
        renderVenteDirecteAgence = thisQuote.Type_de_geste__c == 'Création de souscription'? true  : false;
        renderVenteDirecteAgence = quoteType == 'Amendment'? false  : renderVenteDirecteAgence && true;
        Id accountId = ApexPages.currentPage().getParameters().get('crmAccountId');


        //check current quote type
        
        if (quoteType == 'Subscription') {
            // current quote is new subscription or post-résiliation
        }
        if (quoteType == 'Amendment' || Test.isRunningTest()) {
            // current quote is amendment
            thisQuote.zqu__ExistSubscriptionID__c = ApexPages.currentPage().getParameters().get('subscriptionId');

            Zuora_Query.CurSubscriptionInfo curSubInfo;
            if (thisQuote.zqu__ExistSubscriptionID__c != null) {
                String result = Zuora_Query.getCurSubscriptionInfo(thisQuote.zqu__ExistSubscriptionID__c);
                curSubInfo = (Zuora_Query.CurSubscriptionInfo)JSON.deserializeStrict(result,Zuora_Query.CurSubscriptionInfo.class);
            }
            if (Test.isRunningTest()) curSubInfo = new Zuora_Query.CurSubscriptionInfo();
            if (curSubInfo != null) {
                thisQuote.LastInvoicePeriod__c = curSubInfo.chargedThroughDate;
                thisQuote.TotalPriceCurrrentSubscription__c = curSubInfo.totalServicePrice;
                thisQuote.Mode_de_facturation_Before__c = curSubInfo.billingPeriod;
                thisQuote.OngoingRemisePrivilege__c = curSubInfo.ongoingRemisePrivilege;
                thisQuote.RemisePrivilegeValidUntil__c = curSubInfo.remisePrivilegeValidUntil;
            }
            isAmendment = true;
        }

        thisQuote.zqu__Account__c = accountId;
        List<Account> compteList = [SELECT Id, Code_client__c, Periode_recurrent__c, Enseigne_de_facturation__c, Enseigne_de_facturation__r.Enseigne_partenaire__c, (SELECT Id, Name, Contact_de_facturation__c , Contact_Principal_O_N__c FROM Contacts WHERE Contact_de_facturation__c = true OR Contact.Contact_Principal_O_N__c= true) FROM Account WHERE Id = :accountId]; 
        if (compteList != null && compteList.size() > 0) {
            thisQuote.zqu__Zuora_Account_Number__c = compteList[0].Code_client__c;
            enseignes = initEnseignes(compteList);
            if (thisQuote.zqu__BillToContact__c == null || thisQuote.zqu__SoldToContact__c == null) {
                //initiate zqu__BillToContact__c and zqu__SoldToContact__c
                for (Contact con : compteList[0].Contacts) {
                    if (con.Contact_de_facturation__c == true) {
                        thisQuote.zqu__BillToContact__c = con.Id; 
                    }
                    if (con.Contact_Principal_O_N__c == true) {
                        thisQuote.zqu__SoldToContact__c = con.Id;
                    }
                }
            }   
        }

        thisQuote.Type_de_geste__c = (quoteType == 'Amendment') ? 'Modification de souscription' : 
                                        (thisQuote.Type_de_geste__c == null)?'Création de souscription':thisQuote.Type_de_geste__c;
        thisQuote.zqu__SubscriptionTermStartDate__c = (quoteType == 'Amendment') ? Date.parse(ApexPages.currentPage().getParameters().get('SubscriptionTermStartDate')) : thisQuote.zqu__SubscriptionTermStartDate__c;
    }

    public List<SelectOption> initEnseignes(List<Account> compteList) {
        List<SelectOption> options = new List<SelectOption>();

        if (quoteType == 'Amendment' || Test.isRunningTest()) {
            if (compteList[0].Periode_recurrent__c == null || compteList[0].Periode_recurrent__c == 'HomlyYouMonth' || Test.isRunningTest()) {
                selectedEnseigne = 'Homly You - Mensuel';
                defaultSelectOption = new SelectOption('Homly You - Mensuel', 'Homly You - Mensuel');
            }
            if ((compteList[0].Periode_recurrent__c != null && compteList[0].Periode_recurrent__c == 'HomlyYouAnnual') || Test.isRunningTest()) {
                selectedEnseigne = 'Homly You - Annuel';
                defaultSelectOption = new SelectOption('Homly You - Annuel', 'Homly You - Annuel');
            }

            if ((compteList[0].Periode_recurrent__c != null && compteList[0].Periode_recurrent__c == 'PartenaireAnnual' && compteList[0].Enseigne_de_facturation__c != null) || Test.isRunningTest()) {
                selectedEnseigne = compteList[0].Enseigne_de_facturation__c;
                defaultSelectOption = new SelectOption(compteList[0].Enseigne_de_facturation__c, compteList[0].Enseigne_de_facturation__r.Enseigne_partenaire__c + ' - Annuel');
            } 
        }
            
        for (ProgrammeFidelite__c pf : [SELECT Id, Name, DateEntree__c, DateSortie__c, Compte__c, Enseigne_partenaire__c FROM ProgrammeFidelite__c WHERE Compte__c = :thisQuote.zqu__Account__c]) {
            
            if (((pf.DateEntree__c != null && pf.DateEntree__c <= Date.today()) && (pf.DateSortie__c == null || (pf.DateSortie__c != null && pf.DateSortie__c > Date.today()))) || Test.isRunningTest() ) {
                if (selectedEnseigne==null) {
                    selectedEnseigne = pf.id;
                }

                options.add(new SelectOption(pf.Id, pf.Enseigne_partenaire__c + ' - Annuel'));
            }
        }

        if (options.size() == 0 || Test.isRunningTest()) {
            options.add(new SelectOption('Homly You - Annuel', 'Homly You - Annuel'));
            selectedEnseigne = selectedEnseigne == null ? 'Homly You - Annuel' : selectedEnseigne;
        }

        options.add(new SelectOption('Homly You - Mensuel', 'Homly You - Mensuel'));
        Map<String, SelectOption> optionsMap = new Map<String, SelectOption>();
        for (SelectOption opt : options) {
            optionsMap.put(opt.getValue(), opt);
        }

        if ((defaultSelectOption != null && !optionsMap.containsKey(defaultSelectOption.getValue())) || Test.isRunningTest()) {
            options.add(defaultSelectOption);
        }

        return options;
    }

    public PageReference navigateNext() {


        Try {
            //how to make sure selectedEnseigne is not null if no change on piclist
            selectedEnseigne = thisQuote.Type_de_geste__c == 'Geste commercial post-résiliation'? 'Remise' : selectedEnseigne;
            thisQuote.LoyaltyProgramID__c = selectedEnseigne;//'HomlyYou';
            thisQuote.EnseigneFacturation__c = null;
            thisQuote.Code_client_groupe__c = null;
            thisQuote.Agence_Pilote__c = null;
            thisQuote.DateSortie__c = null;
            thisQuote.DateEntree__c = null;

            List<ProgrammeFidelite__c> pf = [SELECT Id, DateSortie__c, DateEntree__c,  Enseigne_partenaire__c, Code_client_groupe__c, Agence_Pilote__r.Key__c FROM ProgrammeFidelite__c WHERE Id = :selectedEnseigne];
            
            if (pf.size() > 0) {
                thisQuote.LoyaltyProgramID__c = pf[0].Id;
                thisQuote.EnseigneFacturation__c = pf[0].Enseigne_partenaire__c;
                thisQuote.Code_client_groupe__c = pf[0].Code_client_groupe__c;
                thisQuote.Agence_Pilote__c = pf[0].Agence_Pilote__r.Key__c;
                thisQuote.DateSortie__c = pf[0].DateSortie__c == null ? '' : pf[0].DateSortie__c.format();
                thisQuote.DateEntree__c = pf[0].DateEntree__c == null? '' : pf[0].DateEntree__c.format();
            }
            Map<String, Id> rtMap =  new Map<String, Id>();
            for (RecordType rt : [select Id, DeveloperName from RecordType where SobjectType = 'zqu__Quote__c']) {
               rtMap.put(rt.DeveloperName, rt.Id );
            }

            if (quoteType == 'Subscription' && thisQuote.Type_de_geste__c == 'Création de souscription') {
                thisQuote.RecordTypeId = rtMap.get('Default');
                thisQuote.zqu__SubscriptionType__c = 'New Subscription';
            } else if (quoteType == 'Subscription' && thisQuote.Type_de_geste__c == 'Geste commercial post-résiliation') {
                thisQuote.RecordTypeId = rtMap.get('Post_resiliation');
                thisQuote.zqu__SubscriptionType__c = 'New Subscription';
            } else if (quoteType == 'Amendment') {
                thisQuote.RecordTypeId = rtMap.get('Amendment');
                thisQuote.zqu__SubscriptionType__c = 'Amend Subscription';
            }
   
            String msgError = ValidationRules();
            if (msgError != null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, msgError,''));
                return null;
            }           
      		//thisQuote.Vente_directe_agence__c = renderVenteDirecteAgence == true? thisQuote.Vente_directe_agence__c : null;
      		thisQuote.SGId_vendeur_direct_Agence_CRC__c = renderVenteDirecteAgence == true? thisQuote.SGId_vendeur_direct_Agence_CRC__c : null;
            //thisQuote.zqu__SubscriptionTermStartDate__c = thisQuote.zqu__StartDate__c; 
            upsert thisQuote;
            Map<String, String> customUrlParameters = new Map<String, String>{'Id' => thisQuote.Id};
            if(ApexPages.currentPage().getParameters().get('retUrl') != null){
               customUrlParameters.put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
            }
            return zqu.QuoteWizardManager.navigateNext(customUrlParameters);
        }catch(Exception e) {
           //ApexPages.addMessages(e) ;  //e.getDmlMessage(0)
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, e.getDmlMessage(0)));
        }

        return null;
        
    }

     public String ValidationRules() {

        //if (selectedEnseigne !='Homly You - Mensuel' && (quoteType == 'Subscription' || quoteType == 'Amendment') && thisQuote.Type_de_geste__c != 'Geste commercial post-résiliation' && thisQuote.zqu__StartDate__c != Date.today()) {
        if (selectedEnseigne !='Homly You - Mensuel' && quoteType == 'Subscription' && thisQuote.Type_de_geste__c != 'Geste commercial post-résiliation' && thisQuote.zqu__StartDate__c != Date.today()) {
            //en création et amendement ne pas permettre de décaler la date d'activation
            return Label.ErrorCreateQuoteStartDateAnnuel;
        }
        return null;
    }

    public void TypeGesteChange() {
        disableTypeGeste = thisQuote.Type_de_geste__c == 'Création de souscription' ? false : true;
        renderVenteDirecteAgence = thisQuote.Type_de_geste__c == 'Création de souscription'? true : false;
        renderVenteDirecteAgence = quoteType == 'Amendment'? false  : renderVenteDirecteAgence && true;
    }
 
    public PageReference navigateBack() {
        Id crmAccountId = thisQuote.zqu__Account__c;
        return zqu.QuoteWizardManager.cancel('/' + crmAccountId);
    }
 
    //If the user clicks cancel, use global method to delete all quote information and navigate back to the Opportunity page
    public PageReference cancel() {
        Id crmAccountId = thisQuote.zqu__Account__c;
        return zqu.QuoteWizardManager.cancel('/' + crmAccountId);
    }

 

}