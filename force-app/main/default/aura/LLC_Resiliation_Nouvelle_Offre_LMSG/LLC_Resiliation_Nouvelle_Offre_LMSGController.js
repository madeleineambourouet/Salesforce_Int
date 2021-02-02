({
    cancelAction: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
        	alert(cmp.find("statutCompteActuel").get("v.value"));
        }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { /* handle record change */}
    },
    handleLoad: function(cmp, event, helper) {
    },
    
    handleSubmit: function(cmp, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        var valueMotifResiliation = cmp.find('motifResiliation').get("v.value");
        var valueStatut = cmp.find('statutCompteNouveau').get("v.value"); 
        fields["Compte_Nouvelles_Offres__c"] = false; 
        cmp.find("editFormResiliation").submit(fields);
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();  
    },
    
    handleError: function(cmp, event, helper) {
        
    },
    
    handleSuccess: function(cmp, event, helper) {
        
    } 
    
    
    
    
})