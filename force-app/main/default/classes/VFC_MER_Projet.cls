// 06/03/2018 Modified by Leila BOUAIFEL, MER MM2
// 06/03/2019 Modified by Leila BOUAIFEL, MER LMSG
public with sharing class VFC_MER_Projet {

    public Projet__c curPrj{get;set;}
    public Intermediation__c curMER{get;set;}
    //public List<GeoCat__c> curCI{get;set;}
    //public List<Competence__c> curCompetence{get;set;}
    public List<SelectOption> CompetenceOptions{get;set;}
    public String CompetenceSelected{get;set;}
    public Boolean isAdmin{get;set;}
    public Boolean isCompetenceNull{get;set;}
    public Boolean isContactNull{get;set;}
    public Boolean isArtisansQualifies{get;set;}
    public Boolean isAccompagnement{get;set;}
    public String pageBlockTitle{get; set;}

    public Map<Id, String> CompetenceMap;  
    public Map<Id, Decimal> CompetenceMapPrice;  
    public Map<Id, String> CompetenceMapKey;  
    

    public VFC_MER_Projet(ApexPages.standardController stdController) {
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        isAdmin = (userProfileName == 'Administrateur fonctionnel' || userProfileName == 'Administrateur système' || userProfileName == 'System Administrator' || userProfileName == 'Service Commercial' ) ? true : false;
        //isAdmin = false;
        curPrj = [SELECT Id, Name, Categorie_lkp__r.Name, Demande_du_Part__c FROM Projet__c WHERE Id =:ApexPages.currentPage().getParameters().get('id')];
        system.debug('>>>>> VFC_MER_Projet.curPrj: ' + curPrj);

        curMER = new Intermediation__c();
        curMer.Projet__c = curPrj.Id;
         if (curPrj.Demande_du_Part__c != 'Architectes' || curPrj.Demande_du_Part__c != 'Accompagnement de A à Z' || Test.isRunningTest()) {
        curMer.Date_de_matching__c = date.today();
        //curMer.Statut_Selection__c = 'Demandee';
        //curMer.Selection_demandee_a__c = Datetime.now();
        curMer.ranking__c =  1;

        // je recupère les compétences associées à la catégorie
        List<Mapping_CC__c> mappingPrj = [SELECT Id, Name, Categorie_key__c, Categorie_libelle__c, Categorie_ref__c, 
            Competence_key__c, Competence_libelle__c, Competence_ref__c, Inclus__c, Mapping_key__c, Poids__c, Tarif__c
                FROM Mapping_CC__c WHERE Actif__c = true AND Categorie_libelle__c = :curPrj.Categorie_lkp__r.Name];
        system.debug('>>>>> VFC_MER_Projet.mappingPrj: ' + mappingPrj);
        List<Id> CompetenceLst = new List<Id>();
        for (Mapping_CC__c mapCC : mappingPrj) CompetenceLst.add(mapCC.Competence_ref__c);

        // je vais aussi chercher les parents de ces compétences pour pouvoir les différencier
        List<Reference__c> CompetenceLstDetails = new List<Reference__c>();
        CompetenceLstDetails = [SELECT Id, Name, Key__c, Libelle__c, Libelle_2__c, Libelle_3__c, Parent__c, Competence_Price__c 
            FROM Reference__c WHERE Id in :CompetenceLst AND Lov_Type__c = 'Competence'];
        system.debug('>>>>> VFC_MER_Projet.CompetenceLstDetails: ' + CompetenceLstDetails);

        CompetenceMapPrice = new Map<Id, Decimal>();  
        CompetenceMapKey = new Map<Id, String>();  
        Map<Id, String> CompetenceMapName = new Map<Id, String>();  
        List<String> ParentCompetenceLst = new List<String>();
        for (Reference__c cptce : CompetenceLstDetails) {
            CompetenceMapName.put(cptce.Id, cptce.Name);
            CompetenceMapPrice.put(cptce.Id, cptce.Competence_Price__c);
            CompetenceMapKey.put(cptce.Id, cptce.Key__c);
            ParentCompetenceLst.add(cptce.Parent__c);
        }

        List<Reference__c> ParentCompetenceLstDetails = new List<Reference__c>();
        ParentCompetenceLstDetails = [SELECT Id, Name, Key__c, Libelle__c, Libelle_2__c, Libelle_3__c, Parent__c, Competence_Price__c 
            FROM Reference__c WHERE Key__c in :ParentCompetenceLst AND Lov_Type__c = 'Competence'];
        system.debug('>>>>> VFC_MER_Projet.ParentCompetenceLstDetails: ' + ParentCompetenceLstDetails);

        Map<Id, String> CompetenceMapParentName = new Map<Id, String>();  
        for (Reference__c cptce : CompetenceLstDetails) 
            for (Reference__c cptceParent : ParentCompetenceLstDetails) 
                if(cptce.Parent__c == cptceParent.Key__c) CompetenceMapParentName.put(cptce.Id, cptceParent.Name);

        CompetenceOptions = new List<SelectOption>();
        CompetenceMap = new Map<Id, String>();  
        CompetenceOptions.add(new SelectOption('', ''));
        for (Reference__c cptce : CompetenceLstDetails) {
            CompetenceMap.put(cptce.Id, CompetenceMapName.get(cptce.Id) + ' - ' + CompetenceMapParentName.get(cptce.Id));
            CompetenceOptions.add(new SelectOption(CompetenceMap.get(cptce.Id), CompetenceMap.get(cptce.Id)));
        }
        system.debug('>>>>> VFC_MER_Projet.CompetenceOptions: ' + CompetenceOptions);

    }
        
        isArtisansQualifies = curPrj.Demande_du_Part__c == 'Architectes'? false : true;
        pageBlockTitle = isArtisansQualifies ? 'Nouvelle MER avec Competence' : 'Nouvelle MER pour projet Architectes';
        curMer.Date_MER_Architecte__c = isArtisansQualifies == false?  Date.today() : null; 
        
       // MeR LMSG ajouté le 10-07-19 
        isAccompagnement = curPrj.Demande_du_Part__c == 'Accompagnement de A à Z'? false : true;
        pageBlockTitle = isAccompagnement ? 'Nouvelle MER avec Competence' : 'Nouvelle MER pour projet Accompagnement de A à Z';
        curMer.Date_MER_LMSG__c = isAccompagnement == false?  Date.today() : null; 
        
   }
    public void CompetenceChanged() {
        
        system.debug('>>>>> VFC_MER_Projet.RefCompetenceSelected: ' + CompetenceSelected );
        for (Id cptce : CompetenceMap.keyset()) {
            if (CompetenceMap.get(cptce) == CompetenceSelected) {
                curMER.Competence__c = cptce;
                curMer.Prix__c = CompetenceMapPrice.get(cptce);
                curMer.ID_COMPETENCE__c = CompetenceMapKey.get(cptce);
                break;
            }        
        }
    }

    public void ContactProChanged() {
        //curMER.Critere_d_intervention__c =  xxxxx;
        //curMER.Criteres_d_intervention__c =  xxxxxxx;
        
    }

    //public PageReference saveNewMER() {
    public PageReference saveNewMER() {
        Map<String, Id> rtMap = new Map<String, Id>();
        for (Recordtype rt : [select id, Name, DeveloperName from RecordType where SobjectType = 'Intermediation__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }        
        curMER.RecordTypeId = isArtisansQualifies ? rtMap.get('MER_Artisans_qualifies') : rtMap.get('MER_MM2');
        curMER.RecordTypeId = isArtisansQualifies ? rtMap.get('MER_Artisans_qualifies') : rtMap.get('MER_LMSG');  
        isCompetenceNull = CompetenceSelected == null ? true: false;
        if (isCompetenceNull && isArtisansQualifies) {
            //alert('Vous devez assigner une compétence à cette MER!');
            return null;
        }
        else {
            if (curMER.Contact__c == null) {
                Account pro = [SELECT Id, Name, Contact_principal__c FROM Account WHERE Id = :curMER.Professionnel__c];
                curMER.Contact__c = pro.Contact_principal__c;
                if (curMER.Contact__c == null) {
                    isContactNull = true;
                    return null;
                }
            }
           insert curMER;
     
            PageReference tempPage = ApexPages.currentPage();            
            tempPage.setRedirect(true);
            return tempPage;
            
        }
        //PageReference pr = new PageReference('/'+curPrj.Id);
        //pr.setRedirect(true);
        //PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        //return pr;
    }
    
    public PageReference cancelEditMER() {
         
        PageReference pr = new PageReference('/'+curPrj.Id);
        pr.setRedirect(true);
        return pr;
    }


}