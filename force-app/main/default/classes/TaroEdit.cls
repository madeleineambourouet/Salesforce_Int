/**
* @author Clement Musabimana
* @date 20/02/2020
* @description Class permettant de gérer la modification d'un chiffrage Taro
**/
public class TaroEdit {
    
    public String jsonFromTaro {get; set;}
    public String objectName {get; set;}
    public String objectId {get; set;}
    public String bsku {get; set;}
    public String taroJson {get; set;}
    public String taroJsonParameters {get; set;}
    public String urlTaroEnvironnement {get; set;}
    public String urlTaroCSS {get; set;}
    public String urlTaroJS {get; set;}
    
    public TaroEdit(){
        objectName = ApexPages.currentPage().getParameters().get('objectName');
        objectId = ApexPages.currentPage().getParameters().get('id');
        //if(objectName == 'Projet_LMSG__c'){
        for(Projet_LMSG__c projetLmsg :[select Chiffrage_bsku__c,Chiffrage_json__c from Projet_LMSG__c where id =:objectId limit 1]){
            bsku = projetLmsg.Chiffrage_bsku__c;
            taroJson = projetLmsg.Chiffrage_json__c;
        }
        taroJsonParameters = TaroUtils.getParametersFromJson(taroJson);
        urlTaroEnvironnement = Label.PP_TaroEnvironnement;
        urlTaroCSS = Label.PP_TaroUrlCss;
        urlTaroJS = Label.PP_TaroUrlJS;
        //}
        
    }
    
    public void processTaroData(){
        System.debug('processTaroData jsonFromTaro '+jsonFromTaro);
        if(jsonFromTaro == null || jsonFromTaro == '')
            return;

        Projet_LMSG__c projetLmsg = new Projet_LMSG__c(id = objectId, Chiffrage_json__c = jsonFromTaro);
        update projetLmsg;
      
        //return (new ApexPages.StandardController (new Projet_LMSG__c(Id=projetLmsg.Id))).edit();
        /*PageReference pageRef = new PageReference('/lightning/r/Projet_LMSG__c/'+projetLmsg.Id+'/edit');
        pageRef.setRedirect(true);
        return pageRef;*/ 
    }
}