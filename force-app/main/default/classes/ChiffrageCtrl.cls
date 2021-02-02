public with sharing class ChiffrageCtrl {
    public String chiffrageId {get; set;}
    public String chiffrageUrl {get; set;}
    
    public ChiffrageCtrl(){
        String paramId = ApexPages.currentPage().getParameters().get('id');
        //Si l'id est sur 18 caractère on le reduit à 15 pour l'envoyer côté web qui ne traite un format que à 15 caractère
        chiffrageId = paramId.left(15);
        system.debug('chiffrageId '+chiffrageId);
        
        //@CMU:26/03/2019: conditionnement de l'url de visualisation du chiffrage SG/HY suivant la source        
        List<Chiffrage__c> chiffrageTrackingList = [Select id,Tracking__c,tracking__r.source__c  from Chiffrage__c where id =:chiffrageId Limit 1];
        Chiffrage__c chiffrageTracking = null;
        if(chiffrageTrackingList != null && !chiffrageTrackingList.isEmpty()){
            chiffrageTracking = chiffrageTrackingList[0];
        }
        if(chiffrageTracking != null && chiffrageTracking.Tracking__r.source__c == System.Label.Tracking_SourceLaMaisonSG){
            chiffrageUrl = System.Label.URL_iframe_ViewChiffrageSG;
        }
        else{
            chiffrageUrl = System.Label.URL_iframe_ViewChiffrage;
        }
    }
}