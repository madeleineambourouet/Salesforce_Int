trigger CopyDescriptionField on Event (before insert, before update) {

 for(Event event : trigger.new) {
 
     event.Compte_rendu_du_RDV_client__c = event.Description;    
    }

}