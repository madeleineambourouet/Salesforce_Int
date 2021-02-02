public without sharing class LLC_Editproject {
    public class ProjetVariables{
        @AuraEnabled
        public Projet__c curProject{get;set;}    
        @AuraEnabled
        public List<SelectOptionCustom> statusOptions{get;set;}   
        @AuraEnabled
        public List<SelectOptionCustom> subStatusOptions{get;set;}   
        @AuraEnabled
        public List<SelectOptionCustom> subStatusOptions2{get;set;}
        @AuraEnabled
        public String statusCurrent{get;set;}
        @AuraEnabled
        public String statusSelected{get;set;}
        @AuraEnabled
        public String subStatusSelected{get;set;}
        @AuraEnabled
        public String subStatusSelected2{get;set;}
        @AuraEnabled
        public Datetime DateFinODCouverte{get;set;}
        @AuraEnabled
        public Datetime DateDebutODCouverte{get;set;}
        @AuraEnabled
        public Boolean isnotoktoclose{get;set;}  
        @AuraEnabled  
        public Boolean isEtatLocked{get;set;}
        @AuraEnabled
        public Boolean isOwnerLocked{get;set;}
        @AuraEnabled
        public Boolean isPasDeProValid{get;set;}
        @AuraEnabled
        public Boolean  issaveOK{get;set;}  
        @AuraEnabled 
        public Boolean isAdmin{get;set;}
        @AuraEnabled
        public Boolean isDateOk{get;set;}
        @AuraEnabled
        public Boolean isMotifRefusOK{get;set;}
        @AuraEnabled        
        public Boolean isDateKO{get;set;}
        @AuraEnabled
        public Boolean isMotifRefusKO{get;set;}
        @AuraEnabled
        public String  messageError{get;set;}
        @AuraEnabled
        public Map<String, List<SelectOptionCustom>> soMap;
        @AuraEnabled
        public Map<String, List<SelectOptionCustom>> soMap2;
        @AuraEnabled
        public Map<String, String> nextStatusEtatMap = new Map<String, String>();    
    }
    public class SelectOptionCustom {
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public Boolean isDisabled{get;set;}
    }
    
    @AuraEnabled
    public static ProjetVariables CallLoadprojetData (String projetId) {
        list<SelectOption> listSelectOptionsSoMap = new list<SelectOption>();
        list<SelectOption> listSelectOptionsSoMap2 = new list<SelectOption>();
        ProjetVariables projetVariables = new ProjetVariables();
        projetVariables.soMap = new Map<String, List<SelectOptionCustom>>();
        projetVariables.soMap2 = new Map<String, List<SelectOptionCustom>>();
        projetVariables.statusOptions = new list<SelectOptionCustom>();
        projetVariables.isPasDeProValid = false;
        projetVariables.isnotoktoclose = false;
        projetVariables.issaveOK = false;
        projetVariables.isDateOk = false;
        projetVariables.isDateKO = false;
        projetVariables.isMotifRefusKO = false;
        projetVariables.isMotifRefusOK = false;
        projetVariables.messageError = '';
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        projetVariables.isAdmin = (userProfileName == 'Administrateur fonctionnel' || userProfileName == 'Administrateur système' || userProfileName == 'System Administrator') ? true : false;
        //isAdmin = false;
        projetVariables.curProject = [SELECT Id, Mises_en_relation_selectionnees__c, Proprietaire_du_projet__c,Proprietaire_EPH__c, Proprietaire_du_projet__r.Name, Name, Sous_statut__c, Statut_Projet__c, Date_de_Qualification__c,Motif_de_cloture__c,Motif_de_refus__c, Date_de_debut_ODC_ouverte__c, Date_de_fin_ODC_ouverte__c, Type_de_reference__c, Source__c, Etat__c, Souhaite_participer_au_jeu_concours__c,Partenaire_eligible__c, Categorie_lkp__c, Date_estimee_debut_projet__c  FROM Projet__c where Id =:projetId];
        projetVariables.isEtatLocked = (projetVariables.curProject.Etat__c == 'ODC close' || projetVariables.curProject.Etat__c == 'Contact part clos') ? true : false;
        projetVariables.isOwnerLocked = (projetVariables.curProject.Proprietaire_du_projet__c != null && projetVariables.curProject.Proprietaire_du_projet__c != UserInfo.getUserId()) ? true : false;
        
        Map<String,List<String>> statusMap = GetDependentOptions('Projet__c', 'Statut_Projet__c', 'Sous_statut__c');
        
        projetVariables.statusCurrent =  projetVariables.curProject.Statut_Projet__c;

        list<SelectOptionCustom> statusOptionList = new list<SelectOptionCustom>();
        Map<Decimal, String> statusTempMap = new Map<Decimal, String>();
        
            for (StatusCycleProject__c cs : StatusCycleProject__c.getall().values()) {
 
            if (cs.Current_Value__c == projetVariables.curProject.Statut_Projet__c) {
                
                
                statusTempMap.put(cs.Order__c, cs.Next_Value__c);
                projetVariables.nextStatusEtatMap.put(cs.Next_Value__c, cs.Etat__c);
                
                list<SelectOptionCustom> subStatusOptionList = new list<SelectOptionCustom>();
                
                list<SelectOptionCustom> subStatusOptionList2 = new list<SelectOptionCustom>();
                
                List<String> curSubStatusList = null;
                
                // values of partenaire eligible  
                List<String> curSubStatusList2 = null;
                
                for (String str : statusMap.keyset()) {
                    //get the sub status for 'Projet Partenaire' seperatly, because there is a bug from the result of Map<String,List<String>> statusMap = TStringUtils.GetDependentOptions()...
                    if (str == 'Projet Partenaire' && str == cs.Next_Value__c) {
                        curSubStatusList = statusMap.get(str);
                        break;
                    }
                }         
                List<String> tempSubStatus = statusMap.get(cs.Next_Value__c) == null ? new List<String>() : statusMap.get(cs.Next_Value__c);
                
                
                curSubStatusList = (curSubStatusList == null) ? tempSubStatus : curSubStatusList;
                
                for (String subStatus : curSubStatusList) {
                    SelectOptionCustom temp = new SelectOptionCustom();
                    temp.value= subStatus;
                    temp.label=subStatus;
                    temp.isDisabled = false;
                    subStatusOptionList.add(temp);
                }
                projetVariables.soMap.put(cs.Next_Value__c, subStatusOptionList);
                // values of partenaire eligible
                //soMap2.put(cs.Next_Value__c, subStatusOptionList2);
                
            }
        }
        
        List<Decimal> statusCurValuesList = new List<Decimal>();
        statusCurValuesList.addAll(statusTempMap.keyset());
        statusCurValuesList.sort(); 
        
        for (Decimal ord : statusCurValuesList) {
            
            
            SelectOptionCustom temp2 = new SelectOptionCustom();
            temp2.value= statusTempMap.get(ord);
            temp2.label=statusTempMap.get(ord);
            temp2.isDisabled = false;
            statusOptionList.add(temp2);
            
            if (projetVariables.statusSelected == null) {
                projetVariables.statusSelected = statusTempMap.get(ord);
                projetVariables.subStatusOptions = projetVariables.soMap.get(projetVariables.statusSelected);
                
                //partenaire eligible
                projetVariables.subStatusOptions2 = projetVariables.soMap2.get(projetVariables.statusSelected);                
            }
        }
        projetVariables.statusOptions = statusOptionList;
        return projetVariables;
    }
    
    @AuraEnabled
    public static ProjetVariables CallSaveProject (String projetVariablesObject) {

        ProjetVariables projetVariables = (ProjetVariables) JSON.deserializeStrict(projetVariablesObject, ProjetVariables.class);
       
        projetVariables.issaveOK = false;
        projetVariables.isPasDeProValid = false;
        projetVariables.isDateOk = false;
        projetVariables.isDateKO = false;
        projetVariables.isMotifRefusKO = false;
        projetVariables.isMotifRefusOK = false;
        projetVariables.isnotoktoclose = false;
        projetVariables.messageError = '';
        
        if (projetVariables.statusSelected == 'Pas de pros à suivre' && (!projetVariables.isAdmin)) {
            //|| (isAdmin && curProject.Statut_Projet__c == 'Pas de pros à suivre')
            // don't block admin even if the new status is 'Pas de pros à suivre' and there is already a "mise en relation" selected on the project 
            Projet__c pro = [SELECT Id, Mises_en_relation_selectionnees__c, Proprietaire_du_projet__c, Proprietaire_du_projet__r.Name, Name, Sous_statut__c, Statut_Projet__c, Date_de_fin_ODC_ouverte__c, Type_de_reference__c, Source__c, Etat__c, Souhaite_participer_au_jeu_concours__c,Partenaire_eligible__c  FROM Projet__c where Id =:projetVariables.curProject.Id];
            if (pro.Mises_en_relation_selectionnees__c != 0) {
                projetVariables.isPasDeProValid = true;
                return projetVariables;
            }
        }        
               
       // Le champ Date estimée début projet doit être rempli pour les sous-statuts suivants :       
        //if ( curProject.Sous_statut__c == 'Demande précoce' || curProject.Sous_statut__c == 'Autorisation manquante' || curProject.Sous_statut__c == 'Achat en attente' || curProject.Sous_statut__c == 'Financement en attente' || curProject.Sous_statut__c == 'Modification du projet' ) {
        if ( projetVariables.subStatusSelected == 'Demande précoce' || projetVariables.subStatusSelected == 'Autorisation manquante' || projetVariables.subStatusSelected == 'Achat en attente' || projetVariables.subStatusSelected == 'Financement en attente' || projetVariables.subStatusSelected == 'Modification du projet' ) {    
            if (projetVariables.curProject.Date_estimee_debut_projet__c == null) {
                projetVariables.isDateOk = true;
                return projetVariables;  
            }
        } 
        
        // Le champ Date estimée ne dois pas être remplis pour les statuts différents de ceux-ci :       
       
        if (projetVariables.subStatusSelected != 'Demande précoce' && projetVariables.subStatusSelected != 'Autorisation manquante' && projetVariables.subStatusSelected != 'Achat en attente' && projetVariables.subStatusSelected != 'Financement en attente' && projetVariables.subStatusSelected != 'Modification du projet') {     
            if (projetVariables.curProject.Date_estimee_debut_projet__c != null) {
                projetVariables.isDateKO = true;
                return projetVariables;  
            }
        }
        
        //Le champ motif de refus ne doit pas être remplis pour le statut hors cible si refus de l'offre LMSG n'est pas sélectionnée
         if (projetVariables.statusSelected == 'Hors cible' && projetVariables.subStatusSelected != 'Refus de l’offre LMSG') {
            
            if (projetVariables.curProject.Motif_de_refus__c != '' && projetVariables.curProject.Motif_de_refus__c != null) {
                projetVariables.isMotifRefusKO = true;
                System.debug('projetVariables.subStatusSelected '+projetVariables.subStatusSelected);
                System.debug('projetVariables.curProject.Motif_de_refus__c '+projetVariables.curProject.Motif_de_refus__c);
                return projetVariables;  
            }
        }
        
         //Le champ Motif de refus doit être remplis pour le statut projet "Hors Cible" et le sous-status "Refus de l’offre LMSG"
        if (projetVariables.statusSelected == 'Hors cible' && projetVariables.subStatusSelected == 'Refus de l’offre LMSG' ) {  
            
            if (projetVariables.curProject.Motif_de_refus__c == '' || projetVariables.curProject.Motif_de_refus__c == null){
                projetVariables.isMotifRefusOK = true;
                System.debug('projetVariables.subStatusSelected '+projetVariables.subStatusSelected);
                System.debug('projetVariables.curProject.Motif_de_refus__c '+projetVariables.curProject.Motif_de_refus__c);
                return projetVariables;  
            }
        } 
        
        //////DECOMMENTER if (!projetVariables.isAdmin) {
        System.debug('CallSaveProject *** projetVariables.isAdmin '+projetVariables.isAdmin);
        System.debug('CallSaveProject *** projetVariables.statusSelected '+projetVariables.statusSelected);
        System.debug('CallSaveProject *** projetVariables.subStatusSelected '+projetVariables.subStatusSelected);
        System.debug('CallSaveProject *** projetVariables.isAdmin '+projetVariables.isAdmin);
        System.debug('CallSaveProject *** projetVariables.curProject.Etat__c '+projetVariables.curProject.Etat__c);
        if (!projetVariables.isAdmin) {
            projetVariables.curProject.Statut_Projet__c = projetVariables.statusSelected;
            projetVariables.curProject.Sous_statut__c = projetVariables.subStatusSelected;
            
            
            if (projetVariables.nextStatusEtatMap.get(projetVariables.statusSelected) != null) {
                projetVariables.curProject.Etat__c = projetVariables.nextStatusEtatMap.get(projetVariables.statusSelected);
            }
        }
        
        if (projetVariables.curProject.Etat__c=='Contact part clos' || projetVariables.curProject.Etat__c== 'ODC close') projetVariables.curProject.ClosedBy__c = 'Agent';
        
        projetVariables = ChangePojectQualifDate(projetVariables);
        projetVariables = ChangePojectODCDate(projetVariables);
        try{
            update projetVariables.curProject;
        }
        catch(DmlException ex){
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                projetVariables.messageError = projetVariables.messageError + ex.getDmlMessage(i); 
            }
            projetVariables.issaveOK = false; 
            return projetVariables;
        }
        
        
        if(projetVariables.isEtatLocked == false && projetVariables.isPasDeProValid == false && projetVariables.isDateOk == false && projetVariables.isMotifRefusOK == false && projetVariables.isDateKO == false && projetVariables.isMotifRefusKO == false){
            projetVariables.issaveOK = true; 
        }	
        else{
            projetVariables.issaveOK = false;  
        }
        return projetVariables;
    }
    
    
    @AuraEnabled
    public static ProjetVariables CallSaveProjectMotif (String projetVariablesObject) {
        System.debug('CallSaveProject *** projetVariables '+projetVariablesObject);
        //ProjetVariables projetVariables = (ProjetVariables)projetVariablesObject;
        ProjetVariables projetVariables = (ProjetVariables) JSON.deserializeStrict(projetVariablesObject, ProjetVariables.class);
        System.debug('CallSaveProject *** projetVariables '+projetVariables);
        if (projetVariables.curProject.Etat__c == 'Contact part ouvert') {
            projetVariables.curProject.Statut_Projet__c = 'Part NRP';
            projetVariables.curProject.Etat__c = 'Contact part clos';       
        }
        
        update projetVariables.curProject;
        return projetVariables;
    }
    @AuraEnabled
    public static ProjetVariables CallStatusChange(String projetVariablesObject) {
        System.debug('CallStatusChange *** projetVariables '+projetVariablesObject);
        //ProjetVariables projetVariables = (ProjetVariables)projetVariablesObject;
        ProjetVariables projetVariables = (ProjetVariables) JSON.deserializeStrict(projetVariablesObject, ProjetVariables.class);
        
        projetVariables.isDateOk = false;
        projetVariables.isDateKO = false;
         projetVariables.isMotifRefusOK = false;
        projetVariables.isMotifRefusKO = false;
        projetVariables.isnotoktoclose = false;
        projetVariables.subStatusOptions = projetVariables.soMap.get(projetVariables.statusSelected);
        projetVariables.subStatusOptions2 = projetVariables.soMap2.get(projetVariables.statusSelected);
        initDefautPicklistValue(projetVariables);  
        return projetVariables;
    }
    
    @AuraEnabled
    public static ProjetVariables CallOpenProject(String projetVariablesObject) {
        System.debug('CallOpenProject *** projetVariables '+projetVariablesObject);
        //ProjetVariables projetVariables = (ProjetVariables)projetVariablesObject;
        ProjetVariables projetVariables = (ProjetVariables) JSON.deserializeStrict(projetVariablesObject, ProjetVariables.class);
        System.debug('CallOpenProject *** projetVariables '+projetVariables);
        System.debug('CallOpenProject *** projetVariables.curProject.Etat__c '+projetVariables.curProject.Etat__c);
        if (projetVariables.curProject.Etat__c=='Contact part clos' )  {
            
            projetVariables.curProject.Statut_Projet__c = 'Nouveau';
            projetVariables.curProject.Sous_statut__c = '';            
            projetVariables.curProject.Etat__c = 'Contact part ouvert';       
        }
        
        if (projetVariables.curProject.Etat__c=='ODC close' ) {
            
            projetVariables.curProject.Statut_Projet__c = 'Qualifié';
            projetVariables.curProject.Sous_statut__c = '';
            projetVariables.curProject.Etat__c = 'ODC ouverte';       
        }
        
        update projetVariables.curProject;    
        
        return projetVariables;
    }
    
    @AuraEnabled
    public static ProjetVariables CallCloseProject(String projetVariablesObject) {
        System.debug('CallCloseProject *** projetVariables '+projetVariablesObject);
        //ProjetVariables projetVariables = (ProjetVariables)projetVariablesObject;
        ProjetVariables projetVariables = (ProjetVariables) JSON.deserializeStrict(projetVariablesObject, ProjetVariables.class);
        
        //if (curProject.Etat__c=='Contact part ouvert' && curProject.Statut_Projet__c == 'Part NRP'  && (curProject.Sous_statut__c == '1er appel' || curProject.Sous_statut__c == '2ème appel' || curProject.Sous_statut__c == '3ème appel'))  {
        if (projetVariables.curProject.Etat__c=='Contact part ouvert' && projetVariables.statusSelected == 'Part NRP'  && (projetVariables.subStatusSelected == '1er appel' || projetVariables.subStatusSelected == '2ème appel' || projetVariables.subStatusSelected == '3ème appel'))  {
            projetVariables.curProject.Statut_Projet__c = 'Part NRP';
            
            
            PageReference pr = new PageReference('/apex/VF_Motif_de_cloture_Projet?Id='+projetVariables.curProject.Id);
            pr.setRedirect(true);
            projetVariables.isnotoktoclose = false;    
            return projetVariables;
            
        } 
        
        projetVariables.isnotoktoclose = true;  
        return projetVariables;
    }
    
    @AuraEnabled
    public static ProjetVariables CallChangePojectQualifDate(String projetVariablesObject) {
                //ProjetVariables projetVariables = (ProjetVariables)projetVariablesObject;
        ProjetVariables projetVariables = (ProjetVariables) JSON.deserializeStrict(projetVariablesObject, ProjetVariables.class);
       
        return ChangePojectQualifDate(projetVariables);
    }
    
    public static ProjetVariables initDefautPicklistValue(ProjetVariables projetVariables) {
        if (!projetVariables.isAdmin) {
            
            if (projetVariables.curProject.Statut_Projet__c == 'Projet partenaire' && projetVariables.statusSelected == 'Projet partenaire transmis' ) {
                projetVariables.subStatusSelected = projetVariables.curProject.Sous_statut__c;
            }
        }
        return projetVariables;
    }
    
    public static Map<String,List<String>> GetDependentOptions(String objName, string controllingName, String dependentName) {
        String Controlling_Dependent = controllingName + '&' + dependentName;
        Map<String,List<String>> result = new Map<String,List<String>>();
        
        for (Field_Dependency__mdt fd : [SELECT Object__c, Controlling_Dependent__c, Controlling_Field_Value__c,Dependent_Field_Values__c FROM Field_Dependency__mdt where Controlling_Dependent__c = :Controlling_Dependent AND Object__c = :objName]) {
            String Dependent_Field_Values = fd.Dependent_Field_Values__c;
            List<String> dependentValuesList = Dependent_Field_Values.split(';');
            result.put(fd.Controlling_Field_Value__c, dependentValuesList);
        }
        
        return result;
    }
    
    public static ProjetVariables ChangePojectQualifDate(ProjetVariables projetVariables) {
        if (projetVariables.statusSelected == 'Qualifié' || projetVariables.curProject.Statut_Projet__c == 'Qualifié') 
            if (projetVariables.curProject.Date_de_Qualification__c == null)
            projetVariables.curProject.Date_de_Qualification__c = datetime.now();
        return projetVariables;
    }
    
    public static ProjetVariables ChangePojectODCDate(ProjetVariables projetVariables) {
        if (projetVariables.curProject.Etat__c == 'ODC ouverte') {
            projetVariables.DateDebutODCouverte = datetime.now();
            if (projetVariables.curProject.Categorie_lkp__c != null) {
                Reference__c refCAT = [select id, Duree_selection_auto__c from Reference__c where id = :projetVariables.curProject.Categorie_lkp__c];
                if (refCAT.Duree_selection_auto__c != null)
                    projetVariables.DateFinODCouverte = projetVariables.DateDebutODCouverte + refCAT.Duree_selection_auto__c;
            }
            projetVariables.curProject.Date_de_debut_ODC_ouverte__c = projetVariables.DateDebutODCouverte;
            projetVariables.curProject.Date_de_fin_ODC_ouverte__c = projetVariables.DateFinODCouverte;
        }
        return projetVariables;
    }
}