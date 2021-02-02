({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    
   	recordUpdated: function(component, event, helper) {            
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {  
            if (component.get("v.simpleRecord.zqu__Status__c") == 'En cours' || component.get("v.simpleRecord.zqu__Status__c") == 'Envoyée' || component.get("v.simpleRecord.zqu__Status__c") == 'New'){ 
                if (component.get("v.simpleRecord.Motif_d_abandon__c") == '' || component.get("v.simpleRecord.Motif_d_abandon__c") == null){ 
                	component.set("v.message","Veuillez renseigner le motif d'abandon avant d'archiver cette proposition.");
                }
                else{
           	 		helper.callAbandonnerProposition(component, event);
                }  
            }
            else{
            	component.set("v.message","Vous ne pouvez pas abandonner cette proposition commerciale à ce statut.");
            }
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   	}
})