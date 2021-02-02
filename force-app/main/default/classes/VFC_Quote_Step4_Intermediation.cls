global class VFC_Quote_Step4_Intermediation //extends zqu.BaseQuoteWizardController
{
    //Quote object
    public zqu__Quote__c thisQuote {get; set;}

    public List<Contact> lContact {get;set;}
    public List<Geocat__c> lGeocat {get;set;}
    
    public Boolean displayGeocat {get;set;}
    
    public Geocat__c newGeocat {get;set;}
    
    public Boolean newgeo {get; set;}

    public Boolean addContact {get;set;}
    
    public Boolean addgeocat {get;set;}
    
    public Boolean isIntermediationRatePlan {get;set;}
    
    public GeocatMapWrapper mapRecord {get;set;}

    public String baseURL {get; set;}
    //public Map<Reference__c, List<Reference__c>> varNiveau {get;set;}
    //public List<String> vf_niveau1 {get;set;}
    //public List<String> vf_niveau2 {get;set;}
    
    // Used in the display
    public Id           vf_contactIdSelected {get;set;}
    public String       vf_contactLastname {get;set;}
    public String       vf_contactFirstname {get;set;}
    public String       vf_contactAccountName {get;set;}
    public Id           vf_geocatId {get;set;}
    public String       vfc_addupdateTitle {get;set;}
    public String       vfc_accountName {get;set;}
    public Id           vfc_accountId {get;set;}
    public String       vfc_paysName {get;set;}
    public Id           vfc_paysId {get;set;}
    
    
    public VFC_Quote_Step4_Intermediation(ApexPages.StandardController StandardController) //ApexPages.StandardController StandardController
    {
        //super(StandardController);
        
        system.debug('>>>>>>>>>> START Constructor');
        baseURL = system.URL.getSalesforceBaseUrl().toExternalForm();
     
        newGeocat = null;
        
        isIntermediationRatePlan = false;
        
        thisQuote = (zqu__Quote__c)StandardController.getRecord();
        thisQuote = [SELECT Id, zqu__Account__c, zqu__Account__r.Name FROM zqu__Quote__c WHERE Id =: thisQuote.Id];
        
        if (thisQuote != null && thisQuote.zqu__Account__c != null)
        {
            vfc_accountName = EncodingUtil.urlEncode(thisQuote.zqu__Account__r.Name,'UTF-8');
            vfc_accountId = thisQuote.zqu__Account__c;
        }
        List<Reference__c> FR = [SELECT id, Name FROM Reference__c WHERE key__c = 'FRA'];
        if (FR != null && FR.size() > 0)
        {
            vfc_paysName = FR[0].Name;
            vfc_paysId = FR[0].Id;
        }
        
         // Search if intermediation in the quote
         //List<String> okok = new List<String>{Label.OffreIntermediationProductName};
        // Modif Fred
        List<String> lOffre = new List<String>();
        for ( Liste_offre__c lo : Liste_offre__c.getall().values()) {
            lOffre.add(lo.Name);
        }
        // End modif fred

        List<zqu__QuoteRatePlan__c> lQuoteRPIntermediation = [SELECT Id, zqu__ProductRatePlan__c, zqu__ProductRatePlanZuoraId__c, zqu__QuoteProductName__c 
                                                                FROM zqu__QuoteRatePlan__c
                                                                WHERE zqu__Quote__c =: thisQuote.Id
                                                                //AND Name IN ('Offre Homly Travaux','Offre "Essentiel" - mensuel','Offre "Energie" - mensuel','Offre "Gestion" - mensuel','Offre "Intégral" - mensuel','Offre "Essentiel" - annuel','Offre "Gestion" - annuel','Offre "Intégral" - annuel')];
                                                                //AND Name IN :lOffre 
                                                                AND zqu__ProductRatePlan__r.Typedeproduit__c = 'Pack'  
                                                                AND zqu__AmendmentType__c != 'RemoveProduct' 
                                                                ];
        system.debug('lQuoteRPIntermediatio.size = ' + lQuoteRPIntermediation.size());                                                        
        if (lQuoteRPIntermediation != null && lQuoteRPIntermediation.size() > 0)
            isIntermediationRatePlan = true;
        
        vf_contactAccountName = thisQuote.zqu__Account__r.Name;
        
        listContact();
        
        displayGeocat = false;
        addgeocat = false;
        addcontact = false;
        system.debug('>>>>>>>>>> END Constructor');
    }


    public PageReference listGeocat()
    {
        system.debug('>>>>>>>>>> START listGeocat');
        
        // Get the geocat of the selected contact
        lGeocat = [SELECT Id, Name, Ville__c, DDP__c, Zone_d_intervention__c, Nb_Competence__c, Categorie_niveau__c, estimation__c, Contact__c  FROM Geocat__c WHERE Contact__c =: vf_contactIdSelected];
        displayGeocat = true;
        
        system.debug('>>>>>>>>>> END listGeocat');
        return null;
    }
    
    public PageReference backlistGeocat()
    {
        addgeocat = false;
        displaygeocat = false;
        listContact();
        return (null);
    }
    
    public PageReference addGeocat()
    {
        system.debug('>>>>>>>>>> START addGeocat');
        
        addgeocat = true;
        newgeo = true;
        if (newGeocat == null)
        {

            newGeocat = new Geocat__c();
        
            mapRecord = new GeocatMapWrapper();
            mapRecord.populateTreeview(null,null);
        }
        
        vfc_addupdateTitle = Label.Geocat_AddGeocatTitle;
        
        system.debug('>>>>>>>>>> END addGeocat');
        return (null);
    }

    public PageReference editGeocat()
    {
        system.debug('>>>>>>>>>> START editGeocat');
        vfc_addupdateTitle = Label.Geocat_UpdateGeocatTitle;
        addgeocat = true;
        newgeo = true;
        if (newGeocat == null)
        {

            newGeocat = [SELECT Id, Name, Ville__c, Zone_d_intervention__c, DDP__c, Adresse__c, Exclusion__c, Date_de_debut__c, Date_de_fin__c, estimation__c, Contact__c,Nom_Du_Critere__c  FROM GeoCat__c WHERE Id =: vf_geocatId];
            List<Competence__c> lCompGeocat = [SELECT Id, Niveau_1__c, Niveau_2__c FROM Competence__c WHERE Geocat__c =: vf_geocatId AND TECH_DeleteOnScreen__c = false];
            system.debug('>>>>>>>>>>> lCompGeocat: ' + lCompGeocat);
        
            mapRecord = new GeocatMapWrapper();
            // Select the competence et geocat
            if (newGeocat != null && lCompGeocat != null && lCompGeocat.size() > 0)
                mapRecord.populateTreeview(lCompGeocat,vf_geocatId);
        }
        system.debug('>>>>>>>>>> END editGeocat');
        
        return (null);
    }

    public PageReference deleteGeocat()
    {
        if (vf_geocatId != null)
        {
            GeoCat__c geoToDelete = new GeoCat__c();
            geoToDelete.Id = vf_geocatId;
            delete geoToDelete;
        }
        
        return (listGeocat());
    }

    public PageReference saveGeocat()
    {
        system.debug('>>>>>>>>>> START saveGeocat');
        
        addgeocat = false;
        
        

        if (newgeocat != null)
        {
            
            if(newgeocat.Date_de_debut__c > newgeocat.Date_de_fin__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date de début doit être inférieure a la date de fin'));
                
                if (newgeocat.id != null)
                    return (editGeocat());
                else
                    return (addgeocat());
            }

         if (String.isEmpty(newgeocat.Exclusion__c) == false)
            {
                List<String> list_exclusion = (newgeocat.Exclusion__c).splitByCharacterType();
            
                for (Integer i = 0; i < list_exclusion.size(); i++)
                {
                    if (list_exclusion[i].isNumeric())
                    {
                        if ((list_exclusion[i].length() != 2) && (list_exclusion[i].length() != 5))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                            if (newgeocat.id != null)
                                return (editGeocat());
                            else
                                return (addgeocat());
                        }
                    }
                    else if (!(list_exclusion[i].equals(';')))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                        if (newgeocat.id != null)
                            return (editGeocat());
                        else
                            return (addgeocat());
                    }
                }
            }
            
            if (mapRecord.isGeocatSelected())
            {  if (newgeocat.Id != null)
                {
              
                    update newgeocat;
                    mapRecord.manageCompetenceOnGeocat(newgeocat.Id);
                }
                else
                {
                    newgeocat.Contact__c = vf_contactIdSelected;
                    insert newgeocat;
                    mapRecord.manageCompetenceOnGeocat(newgeocat.Id);
                }
            }
            else
            {
                system.debug('>>>> AddMessage : No Competence selected.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il faut sélectionner au moins une compétence.'));
                if (newgeocat.id != null)
                    return (editGeocat());
                else
                    return (addgeocat());
            }
        }
        system.debug('>>>>>>>>>> END saveGeocat');
        
        newgeocat = null;
        
        return (listGeocat());
    }

        public void saveGeocatBis()
    {
        system.debug('>>>>>>>>>> START saveGeocat');
        
        addgeocat = false;
        
        

        if (newgeocat != null)
        {
            
            if(newgeocat.Date_de_debut__c > newgeocat.Date_de_fin__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date de début doit être inférieure a la date de fin'));
                
            }

         if (String.isEmpty(newgeocat.Exclusion__c) == false)
            {
                List<String> list_exclusion = (newgeocat.Exclusion__c).splitByCharacterType();
            
                for (Integer i = 0; i < list_exclusion.size(); i++)
                {
                    if (list_exclusion[i].isNumeric())
                    {
                        if ((list_exclusion[i].length() != 2) && (list_exclusion[i].length() != 5))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                          
                        }
                    }
                    else if (!(list_exclusion[i].equals(';')))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                        
                    }
                }
            }
            
            if (mapRecord.isGeocatSelected())
            {  if (newgeocat.Id != null)
                {
              
                    update newgeocat;
                    mapRecord.manageCompetenceOnGeocat(newgeocat.Id);
                }
                else
                {
                    newgeocat.Contact__c = vf_contactIdSelected;
                    insert newgeocat;
                    mapRecord.manageCompetenceOnGeocat(newgeocat.Id);
                }
            }
            else
            {
                system.debug('>>>> AddMessage : No Competence selected.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il faut sélectionner au moins une compétence.'));
            }
        }
        system.debug('>>>>>>>>>> END saveGeocat');
        
        newgeocat = null;
    }
    
    public PageReference backsaveGeocat()
    {
        newgeocat = null;
        addgeocat = false;
        displaygeocat = true;
        return (listGeocat());
    }
    
    public PageReference refreshContact()
    {
        listContact();
        return (null);
    }
    
//////// UTILS
    public void listContact()
    {
        lContact = [SELECT Id, Lastname, Firstname, Fonction__c, PXS_Nb_Geocat_With_Competence__c, Estimation_total__c FROM Contact WHERE AccountId =: thisQuote.zqu__Account__c];
    }
  
//////// NAVIGATION
//Global method to retrieve back button text
    public String BackButtonText {
        get {
            if(BackButtonText == null || BackButtonText.length() == 0) BackButtonText = zqu.QuoteWizardManager.getBackButtonText();
            return BackButtonText;
        }
        private set;
    }
 
    //Global method to retrieve next button text
    public String NextButtonText {
        get {
            if(NextButtonText == null || BackButtonText.length() == 0) NextButtonText = zqu.QuoteWizardManager.getNextButtonText();
            return NextButtonText;
        }
        private set;
    }
 
    //Navigation methods
    public PageReference navigateNext() {
        upsert thisQuote;
        // calculate competence on the quote
        if (thisQuote != null)
        {
            zqu__Quote__c quo = [SELECT Id, zqu__Account__c FROM zqu__Quote__c WHERE Id =: thisQuote.Id];
            List<zqu__Quote__c> lquote = new List<zqu__Quote__c>();
            lquote.add(quo);
            QuoteMethods.calculateTexteCompetence(lquote);
        }
        Map<String, String> customUrlParameters = new Map<String, String>{'Id' => thisQuote.Id};
        return zqu.QuoteWizardManager.navigateNext(customUrlParameters);
    }
 
    public PageReference navigateBack() {
        upsert thisQuote;
        Map<String, String> customUrlParameters = new Map<String, String>{'Id' => thisQuote.Id};
        //,'oppId' => thisQuote.zqu__Opportunity__c
        return zqu.QuoteWizardManager.navigateBack(customUrlParameters);
    }
 
    //If the user clicks cancel, use global method to delete all quote information and navigate back to the Opportunity page
    public PageReference cancel() {
        zqu__Quote__c quote = [SELECT zqu__Account__c FROM zqu__Quote__c WHERE Id =: thisQuote.Id LIMIT 1];
        return zqu.QuoteWizardManager.cancel('/' + thisQuote.zqu__Account__c);
    }

}