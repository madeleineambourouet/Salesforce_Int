/**
* @author Clement Musabimana
* @date 20/02/2020
* @description Class permettant de gérer la transformation projet hy vers un chiffrage Taro (projet lmsg)
**/
public class TaroTransformProjetHY {
    
    public String jsonFromTaro {get; set;}
    public String particulierId {get; set;}
    public String objectId {get; set;}
    public Projet_LMSG__c projetLmsgRecord {get; set;} 
    public Boolean showTaro {get; set;}
    public Boolean hasErrors {get; set;}
   // public Boolean Statut_Ctc_Part_Ouvert {get; set;}
   // public Boolean Statut_RPH_Ouvert {get; set;}
   // public Boolean Part_NouvelleOffre {get; set;}
    public String urlTaroEnvironnement {get; set;}
    public String urlTaroCSS {get; set;}
    public String urlTaroJS {get; set;}
    
    public TaroTransformProjetHY(){
        objectId = ApexPages.currentPage().getParameters().get('id');  
        Boolean Part_NouvelleOffre=true ;
        Boolean Etat_Ctc_Part_Ouvert = true;
        Boolean Etat_EPH_Ouvert = true;
    
        for(Projet__c projetHy :[select particulier__c, Etat__c, Particulier__r.Compte_Nouvelles_Offres__c from Projet__c where id =:objectId limit 1]){
            particulierId = projetHy.particulier__c;
            Part_NouvelleOffre = projetHy.Particulier__r.Compte_Nouvelles_Offres__c;
            Etat_Ctc_Part_Ouvert = projetHy.Etat__c == 'Contact part ouvert';
            Etat_EPH_Ouvert =  projetHy.Etat__c == 'Projet EPH ouvert';
        }

        //projetLmsgRecord = new Projet_LMSG__c(Id='a2W3E000000vPTbUAM');
        hasErrors = false;
        String errorMsg = Part_NouvelleOffre == false ? 'Le particulier lié au projet n\'a pas été activé nouvelles offres <br/>' : '';
        errorMsg += (Etat_Ctc_Part_Ouvert == false && Etat_EPH_Ouvert == false) ? 'Seulement les projets avec un état <b>"Contact part ouvert"</b> ou <b>"Projet EPH ouvert"</b> peuvent être transformés' : '';
        if(errorMsg != '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsg));
            hasErrors = true;
        }

        showTaro = true;
        urlTaroEnvironnement = Label.PP_TaroEnvironnement;
        urlTaroCSS = Label.PP_TaroUrlCss;
        urlTaroJS = Label.PP_TaroUrlJS;
    }
    
    public PageReference processTaroData(){
        System.debug('processTaroData jsonFromTaro '+jsonFromTaro);
        Boolean isSaveOk = false;
        TaroUtils.TaroChiffrage taroChiffrage = TaroUtils.getChiffrageFromJson(jsonFromTaro);
        Projet_LMSG__c projetLmsg = TaroUtils.getDataNewProjetLMSGFromChiffrage(taroChiffrage, jsonFromTaro, particulierId);
        if(projetLmsg != null){
            projetLmsg.Projet_Parent__c = objectId;
            insert projetLmsg;
            projetLmsgRecord = projetLmsg;
            isSaveOk = true;
        }
        if(isSaveOk == true){
            showTaro = false;
        }
        //PageReference pageRef = new PageReference('/lightning/r/Projet_LMSG__c/'+projetLmsg.Id+'/view');
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public PageReference updateQuestion(){
        System.debug('updateQuestion projetLmsgRecord '+projetLmsgRecord);
        if(projetLmsgRecord != null){
            projetLmsgRecord.Statut__c = Label.PP_Projet_statut_depose;
            update projetLmsgRecord;
        }
        PageReference pageRef = new PageReference('/lightning/r/Projet_LMSG__c/'+projetLmsgRecord.Id+'/view');
        pageRef.setRedirect(true);
        return pageRef;
    }
}