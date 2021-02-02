/**
* @author Musabimana Clement
* @date 14/08/2018
* @description Methodes qui permettent de renseigner ou vider en masse les dates de suspension sur les critères d'intervention d'un contact
**/
public with sharing class VFC_CriteresInterventionSuspension {
    public Contact curContact{get;set;}
    public Date dateDebutSuspension{get;set;}
    public Date dateFinFinSuspension{get;set;}
    public string Motifdesuspension{get;set;}
    public Boolean isDatesInvalides{get;set;}
    public Boolean isDateDebutSupDateFin{get;set;}
    public Boolean ismotifnull{get;set;}    
    public GeoCat__c critereInterventionGenerique{get;set;} // Utilisé uniquement pour afficher la date sous format standard dans la VFP
    

    public VFC_CriteresInterventionSuspension(ApexPages.StandardController stdController) {
        curContact = [SELECT Id,Name FROM Contact where Id =:stdController.getId()];
        isDatesInvalides = false;
        isDateDebutSupDateFin = false;
        ismotifnull = false;
        critereInterventionGenerique = new GeoCat__c();
        
    
    }
     
    public PageReference setDateSuspension() {
    	isDatesInvalides = false;
    	isDateDebutSupDateFin = false;
        ismotifnull = false;
                
        PageReference pr = new PageReference('/'+curContact.Id);
        pr.setRedirect(true);
        
        dateDebutSuspension = critereInterventionGenerique.Date_de_debut__c;
        dateFinFinSuspension = critereInterventionGenerique.Date_de_fin__c;
        Motifdesuspension = critereInterventionGenerique.Motifs_de_suspension__c;
        
        System.debug('VFC_CriteresInterventionSuspension setDateSuspension dateDebutSuspension: '+dateDebutSuspension);
        System.debug('VFC_CriteresInterventionSuspension setDateSuspension dateFinFinSuspension: '+dateFinFinSuspension);
        
              
        if((dateDebutSuspension != null && dateFinFinSuspension != null) || (dateDebutSuspension == null && dateFinFinSuspension == null)){
        	if(dateDebutSuspension == null || (dateFinFinSuspension >= dateDebutSuspension)){
        		changeSuspensionDate(dateDebutSuspension, dateFinFinSuspension);
	        }
	        else {
        		isDateDebutSupDateFin = true;
	        }
        }
        else {
    		isDatesInvalides = true;
        }
        
        if(isDatesInvalides || isDateDebutSupDateFin ){
        	return null;
        }
        
        if((dateDebutSuspension!= null || dateFinFinSuspension != null) && Motifdesuspension == null) {
          
          ismotifnull = true; 
          return null;
            
        }
        
        if((dateDebutSuspension== null && dateFinFinSuspension == null) && Motifdesuspension != null) {
          
        ismotifnull = true;
        return null;
    
                      
        }
        return pr;
    }
    
        
    public PageReference cancelModification() {
        PageReference pr = new PageReference('/'+curContact.Id);
        pr.setRedirect(true);
        return pr;
    }

    public void changeSuspensionDate(Date dateDebut, Date dateFin) {
    	List<GeoCat__c> lGeoCat = [SELECT id, Date_de_debut__c, Date_de_fin__c FROM GeoCat__c WHERE Contact__c =: curContact.Id];
    	for(GeoCat__c geocat: lGeoCat){
    		geocat.Date_de_debut__c = dateDebut;
    		geocat.Date_de_fin__c = dateFin;
            geocat.Motifs_de_suspension__c = Motifdesuspension;
    	}
    	update lGeoCat;
    }

}