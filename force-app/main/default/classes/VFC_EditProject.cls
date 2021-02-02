/**
* @author Qiuyan Liu
* @date 10/01/2017
*
* @description controller class for Visualforce Page VF_EditProject
*/
public with sharing class VFC_EditProject {
    //private final Projet__c curProject;
    public Projet__c curProject{get;set;}    
    public List<SelectOption> statusOptions{get;set;}
    public List<SelectOption> subStatusOptions{get;set;}
    public List<SelectOption> subStatusOptions2{get;set;}
    public String statusCurrent{get;set;}
    public String statusSelected{get;set;}
    public String subStatusSelected{get;set;}
    public String subStatusSelected2{get;set;}
    public Datetime DateFinODCouverte{get;set;}
    public Datetime DateDebutODCouverte{get;set;}
    public Boolean isnotoktoclose{get;set;}    
    public Boolean isEtatLocked{get;set;}
    public Boolean isOwnerLocked{get;set;}
    public Boolean isPasDeProValid{get;set;}
    public Boolean  issaveOK{get;set;}   
    public Boolean isAdmin{get;set;}
    public Boolean isDateOk{get;set;}
    public Boolean isDateKO{get;set;}  
    public Map<String, List<SelectOption>> soMap;
    public Map<String, List<SelectOption>> soMap2;
    private Map<String, String> nextStatusEtatMap = new Map<String, String>();

    // The extension constructor initializes the private member
    // variable curProject by using the getRecord method from the standard
    // controller.
    public VFC_EditProject(ApexPages.StandardController stdController) {
       
        soMap = new Map<String, List<SelectOption>>();
        soMap2 = new Map<String, List<SelectOption>>();
        isPasDeProValid = false;
        isnotoktoclose = false;
        issaveOK = false;
        isDateOk = false;
        isDateKO = false;
    
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =:UserInfo.getProfileId()].Name;
        isAdmin = (userProfileName == 'Administrateur fonctionnel' || userProfileName == 'Administrateur système' || userProfileName == 'System Administrator') ? true : false;
        //isAdmin = false;
        curProject = [SELECT Id, Mises_en_relation_selectionnees__c, Proprietaire_du_projet__c,Proprietaire_EPH__c, Proprietaire_du_projet__r.Name, Name, Sous_statut__c, Statut_Projet__c, Date_de_Qualification__c,Motif_de_cloture__c, Date_de_debut_ODC_ouverte__c, Date_de_fin_ODC_ouverte__c, Type_de_reference__c, Source__c, Etat__c, Souhaite_participer_au_jeu_concours__c,Partenaire_eligible__c, Categorie_lkp__c, Date_estimee_debut_projet__c FROM Projet__c where Id =:stdController.getId()];
        isEtatLocked = (curProject.Etat__c == 'ODC close' || curProject.Etat__c == 'Contact part clos') ? true : false;
        isOwnerLocked = (curProject.Proprietaire_du_projet__c != null && curProject.Proprietaire_du_projet__c != UserInfo.getUserId()) ? true : false;
        //Map<String,List<String>> statusMapxx = TStringUtils.GetDependentOptions('Projet__c', 'Statut_Projet__c', 'Sous_statut__c');
        Map<String,List<String>> statusMap = GetDependentOptions('Projet__c', 'Statut_Projet__c', 'Sous_statut__c');

        statusCurrent =  curProject.Statut_Projet__c; 
        
        // values of partenaire eligible
        //Map<String,List<String>> statusMap2xx = TStringUtils.GetDependentOptions('Projet__c', 'Statut_Projet__c', 'Partenaire_eligible__c');
        //Map<String,List<String>> statusMap2 = GetDependentOptions('Projet__c', 'Statut_Projet__c', 'Partenaire_eligible__c');
        list<SelectOption> statusOptionList = new list<SelectOption>();
        Map<Decimal, String> statusTempMap = new Map<Decimal, String>();
              
        for (StatusCycleProject__c cs : StatusCycleProject__c.getall().values()) {
            if (cs.Current_Value__c == curProject.Statut_Projet__c) {
                
                statusTempMap.put(cs.Order__c, cs.Next_Value__c);
                nextStatusEtatMap.put(cs.Next_Value__c, cs.Etat__c);
                
                list<SelectOption> subStatusOptionList = new list<SelectOption>();
                
                list<SelectOption> subStatusOptionList2 = new list<SelectOption>();
                
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
                
                /*for (String str : statusMap2.keyset()) {
                    //get the sub status for 'Projet Partenaire' seperatly, because there is a bug from the result of Map<String,List<String>> statusMap = TStringUtils.GetDependentOptions()...
                    if (str == 'Projet Partenaire' && str == cs.Next_Value__c) {
                        curSubStatusList2 = statusMap2.get(str);
                        break;
                    }
                } */

                List<String> tempSubStatus = statusMap.get(cs.Next_Value__c) == null ? new List<String>() : statusMap.get(cs.Next_Value__c);
                
                
                curSubStatusList = (curSubStatusList == null) ? tempSubStatus : curSubStatusList;

                for (String subStatus : curSubStatusList) {
                    subStatusOptionList.add(new SelectOption(subStatus, subStatus));
                }

                /*
                // values of partenaire eligible
                tempSubStatus = statusMap2.get(cs.Next_Value__c) == null ? new List<String>() : statusMap2.get(cs.Next_Value__c);
                curSubStatusList2 = (curSubStatusList2 == null) ? tempSubStatus : curSubStatusList2;
                for (String subStatus2 : curSubStatusList2) {
                    subStatusOptionList2.add(new SelectOption(subStatus2, subStatus2));
                } */

                soMap.put(cs.Next_Value__c, subStatusOptionList);
                // values of partenaire eligible
                //soMap2.put(cs.Next_Value__c, subStatusOptionList2);

            }
        }
        
        List<Decimal> statusCurValuesList = new List<Decimal>();
        statusCurValuesList.addAll(statusTempMap.keyset());
        statusCurValuesList.sort();
            
        for (Decimal ord : statusCurValuesList) {
            statusOptionList.add(new SelectOption(statusTempMap.get(ord), statusTempMap.get(ord)));
            if (statusSelected == null) {
                statusSelected = statusTempMap.get(ord);
                subStatusOptions = soMap.get(statusSelected);

                //partenaire eligible
                subStatusOptions2 = soMap2.get(statusSelected);
                /*String NextEtat = nextStatusEtatMap.get(statusSelected);
                if (!isAdmin &&  NextEtat!= null) curProject.Etat__c = NextEtat; */
                
            }
        }
        
        statusOptions = statusOptionList;
        initDefautPicklistValue();
    }
    
    public PageReference ownerLockClick() {
        curProject.Proprietaire_du_projet__c = (curProject.Proprietaire_du_projet__c == null) ? UserInfo.getUserId() : null;
        update curProject;
        return null;
    }
    
    public void statusChange() {
        isDateOk = false;
        isDateKO = false;
        subStatusOptions = soMap.get(statusSelected);
        subStatusOptions2 = soMap2.get(statusSelected);
        system.debug('sousStatusChange statusSelected '+ statusSelected);
         system.debug('sousStatusChange subStatusSelected '+ subStatusSelected); 
        
        initDefautPicklistValue(); 
      
  }
    
    public void ChangePojectQualifDate() {
        if (statusSelected == 'Qualifié' || curProject.Statut_Projet__c == 'Qualifié') 
            if (curProject.Date_de_Qualification__c == null)
                 curProject.Date_de_Qualification__c = datetime.now();
    }

    public void ChangePojectODCDate() {
        if (curProject.Etat__c == 'ODC ouverte') {
            DateDebutODCouverte = datetime.now();
            if (curProject.Categorie_lkp__c != null) {
                Reference__c refCAT = [select id, Duree_selection_auto__c from Reference__c where id = :curProject.Categorie_lkp__c];
                if (refCAT.Duree_selection_auto__c != null)
                    DateFinODCouverte = DateDebutODCouverte + refCAT.Duree_selection_auto__c;
            }
            curProject.Date_de_debut_ODC_ouverte__c = DateDebutODCouverte;
            curProject.Date_de_fin_ODC_ouverte__c = DateFinODCouverte;
        }
    }

    public PageReference saveProject() {
        issaveOK = false;
        isPasDeProValid = false;
        isDateOk = false;
        isDateKO = false;
        if (statusSelected == 'Pas de pros à suivre' && (!isAdmin)) {
            //|| (isAdmin && curProject.Statut_Projet__c == 'Pas de pros à suivre')
            // don't block admin even if the new status is 'Pas de pros à suivre' and there is already a "mise en relation" selected on the project 
            Projet__c pro = [SELECT Id, Mises_en_relation_selectionnees__c, Proprietaire_du_projet__c, Proprietaire_du_projet__r.Name, Name, Sous_statut__c, Statut_Projet__c, Date_de_fin_ODC_ouverte__c, Type_de_reference__c, Source__c, Etat__c, Souhaite_participer_au_jeu_concours__c,Partenaire_eligible__c  FROM Projet__c where Id =:curProject.Id];
            if (pro.Mises_en_relation_selectionnees__c != 0) {
                isPasDeProValid = true;
                return null;
            }
        }
        
        // Le champ Date estimée début projet doit être rempli pour les sous-statuts suivants :       
        //if ( curProject.Sous_statut__c == 'Demande précoce' || curProject.Sous_statut__c == 'Autorisation manquante' || curProject.Sous_statut__c == 'Achat en attente' || curProject.Sous_statut__c == 'Financement en attente' || curProject.Sous_statut__c == 'Modification du projet' ) {
         if ( subStatusSelected == 'Demande précoce' || subStatusSelected == 'Autorisation manquante' || subStatusSelected == 'Achat en attente' || subStatusSelected == 'Financement en attente' || subStatusSelected == 'Modification du projet' ) {    
               if (curProject.Date_estimee_debut_projet__c == null) {
                isDateOk = true;
                return null;  
              }
          } 
        
        // Le champ Date estimée ne dois pas être remplis pour les statuts différents de ceux-ci :       
        //if (curProject.Sous_statut__c != 'Demande précoce' && curProject.Sous_statut__c != 'Autorisation manquante' && curProject.Sous_statut__c != 'Achat en attente' && curProject.Sous_statut__c != 'Financement en attente' && curProject.Sous_statut__c != 'Modification du projet') {
        if (subStatusSelected != 'Demande précoce' && subStatusSelected != 'Autorisation manquante' && subStatusSelected != 'Achat en attente' && subStatusSelected != 'Financement en attente' && subStatusSelected != 'Modification du projet') {     
            if (curProject.Date_estimee_debut_projet__c!= null) {
                isDateKO = true;
                return null;  
              }
          } 
        
       // *** Règle de validation : si Statut projet = Part NRP alors sous-statut doit être rempli ***
       /* try{
            update curProject;
        }
        catch(DmlException ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        */
        if (!isAdmin) {
            curProject.Statut_Projet__c = statusSelected;
            curProject.Sous_statut__c = subStatusSelected;
            //curProject.Partenaire_eligible__c = subStatusSelected2;

            if (nextStatusEtatMap.get(statusSelected) != null) {
                curProject.Etat__c = nextStatusEtatMap.get(statusSelected);
            }
        }
        
        

        if (curProject.Etat__c=='Contact part clos' || curProject.Etat__c== 'ODC close') curProject.ClosedBy__c = 'Agent';
        
        ChangePojectQualifDate();
        ChangePojectODCDate();
        update curProject;
        PageReference pr = new PageReference('/'+curProject.Id);
        pr.setRedirect(true);
        return pr;
        //issaveOK = true;
        //return null;
    }
    
    
    // Réouverture d'un projet clos : remettre l'état à ouvert.
    public PageReference OpenProject() { 
        
         if (curProject.Etat__c=='Contact part clos' )  {
        
         curProject.Statut_Projet__c = 'Nouveau';
         curProject.Sous_statut__c = '';            
         curProject.Etat__c = 'Contact part ouvert';       
        }
       
        if (curProject.Etat__c=='ODC close' ) {
            
         curProject.Statut_Projet__c = 'Qualifié';
         curProject.Sous_statut__c = '';
         curProject.Etat__c = 'ODC ouverte';       
        }
                    
       update curProject;
       PageReference pr = new PageReference('/'+curProject.Id);
       pr.setRedirect(true);
       return pr;
    }
    
    // Ouverture de la page Motif de clôture du projet
    public PageReference CloseProject() { 
       system.debug('curProject.Etat__c '+curProject.Etat__c);
       system.debug('curProject.Statut_Projet__c '+curProject.Statut_Projet__c); 
       system.debug('curProject.Sous_statut__c '+curProject.Sous_statut__c);
        
        
        
       system.debug('statusSelected '+statusSelected);
       system.debug('subStatusSelected '+subStatusSelected); 
        
      
        
       //if (curProject.Etat__c=='Contact part ouvert' && curProject.Statut_Projet__c == 'Part NRP'  && (curProject.Sous_statut__c == '1er appel' || curProject.Sous_statut__c == '2ème appel' || curProject.Sous_statut__c == '3ème appel'))  {
       if (curProject.Etat__c=='Contact part ouvert' && statusSelected == 'Part NRP'  && (subStatusSelected == '1er appel' || subStatusSelected == '2ème appel' || subStatusSelected == '3ème appel'))  {
        curProject.Statut_Projet__c = 'Part NRP';
      
       
       PageReference pr = new PageReference('/apex/VF_Motif_de_cloture_Projet?Id='+curProject.Id);
       pr.setRedirect(true);
       isnotoktoclose = false;    
       return pr;
       
       } system.debug('curProject.isnotoktoclose '+isnotoktoclose);
      isnotoktoclose = true;  
      return null;  
       
    }
    
     // Fermeture manuelle d'un projet ouvert / Cloturer l'état.   
    public PageReference saveProjectMotif() {
    
        if (curProject.Etat__c=='Contact part ouvert')  {
        
             curProject.Statut_Projet__c = 'Part NRP';
             curProject.Etat__c = 'Contact part clos';       
        }
                           
       update curProject;
       PageReference pr = new PageReference('/'+curProject.Id); 
       pr.setRedirect(true);
       return pr;   
    }
    
    public PageReference cancelProject() {
        PageReference pr = new PageReference('/'+curProject.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public void initDefautPicklistValue() {
        if (!isAdmin) {

            if (curProject.Statut_Projet__c == 'Projet partenaire' && statusSelected == 'Projet partenaire transmis' ) {
                subStatusSelected = curProject.Sous_statut__c;
          
            }
        }
    }
    
    public Map<String,List<String>> GetDependentOptions(String objName, string controllingName, String dependentName) {
        String Controlling_Dependent = controllingName + '&' + dependentName;
        Map<String,List<String>> result = new Map<String,List<String>>();
        
        for (Field_Dependency__mdt fd : [SELECT Object__c, Controlling_Dependent__c, Controlling_Field_Value__c,Dependent_Field_Values__c FROM Field_Dependency__mdt where Controlling_Dependent__c = :Controlling_Dependent AND Object__c = :objName]) {
            String Dependent_Field_Values = fd.Dependent_Field_Values__c;
            List<String> dependentValuesList = Dependent_Field_Values.split(';');
            result.put(fd.Controlling_Field_Value__c, dependentValuesList);
        }
 
        return result;
    }
}