/**
* @author Clement Musabimana
* @date 20/02/2020
* @description Class permettant de gérer la création d'un chiffrage Taro ou la transformation d'un projet HY vers projet Lsmg
**/
public class TaroCreate {

    public String jsonFromTaro {get; set;}
    public String particulierId {get; set;}
    public Projet_LMSG__c projetLmsgRecord {get; set;} 
    public Boolean showTaro {get; set;}
    public String urlTaroEnvironnement {get; set;}
    public String urlTaroCSS {get; set;}
    public String urlTaroJS {get; set;}
    public Boolean hasErrors {get; set;}

    public TaroCreate(){
        particulierId = ApexPages.currentPage().getParameters().get('id'); 
        
        // Add check if the particulier is Nouvelles Offres
        hasErrors = false;
        Account partAcc = [SELECT Compte_Nouvelles_Offres__c from Account where id =:particulierId limit 1];
        if(partAcc!=null && partAcc.Compte_Nouvelles_Offres__c==false) {  
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Le particulier n\'a pas été activé nouvelles offres <br/>'));
            hasErrors = true;
        }      
        showTaro = true;
        urlTaroEnvironnement = Label.PP_TaroEnvironnement;
        urlTaroCSS = Label.PP_TaroUrlCss;
        urlTaroJS = Label.PP_TaroUrlJS;
    }
    
    public PageReference processTaroData(){
        System.debug('processTaroData jsonFromTaro '+jsonFromTaro);
        TaroUtils.TaroChiffrage taroChiffrage = TaroUtils.getChiffrageFromJson(jsonFromTaro);
        Boolean isSaveOk = false;
        Projet_LMSG__c projetLmsg = TaroUtils.getDataNewProjetLMSGFromChiffrage(taroChiffrage, jsonFromTaro, particulierId);
        if(projetLmsg != null){
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