public with sharing class ChiffrageToProjetCtrl {
    public String chiffrageId {get; set;}
    public String categorieKey {get; set;}
    public Boolean showHeader  {get; set;}
    public String chiffrageUrl {get; set;}
    
    public ChiffrageToProjetCtrl(){
    	showHeader = false;
    	String showHeaderString = ApexPages.currentPage().getParameters().get('showHeader');
    	System.debug('ChiffrageToProjetCtrl +++ showHeaderString'+showHeaderString);
    	if(showHeaderString != null && showHeaderString.trim() !=''){
    		showHeader = Boolean.valueOf(showHeaderString);
    	}
    	
    	String paramId = ApexPages.currentPage().getParameters().get('chiffrageId');
        //Si l'id est sur 18 caractère on le reduit à 15 pour l'envoyer côté web qui ne traite un format que à 15 caractère
        chiffrageId = paramId.left(15);
        system.debug('chiffrageId '+chiffrageId);
        System.debug('ChiffrageToProjetCtrl +++ chiffrageId'+chiffrageId);
        List<Chiffrage__c> cList = [SELECT Id, Categorie__c, Categorie__r.Key__c FROM Chiffrage__c WHERE id=:chiffrageId];
        categorieKey = cList.size() > 0? (cList[0].Categorie__c != null ? cList[0].Categorie__r.Key__c : null) : null;
        
        //@CMU:26/03/2019: conditionnement de l'url de transformation du chiffrage SG/HY suivant la source
        List<Chiffrage__c> chiffrageTrackingList = [Select id,Tracking__c,tracking__r.source__c  from Chiffrage__c where id =:chiffrageId Limit 1];
        Chiffrage__c chiffrageTracking = null;
        System.debug('ChiffrageToProjetCtrl +++ chiffrageTrackingList'+chiffrageTrackingList);
        if(chiffrageTrackingList != null && !chiffrageTrackingList.isEmpty()){
            chiffrageTracking = chiffrageTrackingList[0];
        }
        if(chiffrageTracking != null && chiffrageTracking.Tracking__r.source__c == System.Label.Tracking_SourceLaMaisonSG){
            chiffrageUrl = System.Label.URL_iframe_TransformChiffrageSG;
        }
        else{
            chiffrageUrl = System.Label.URL_iframe_TransformChiffrage;
        }
        System.debug('ChiffrageToProjetCtrl +++ chiffrageUrl'+chiffrageUrl);
    }
}