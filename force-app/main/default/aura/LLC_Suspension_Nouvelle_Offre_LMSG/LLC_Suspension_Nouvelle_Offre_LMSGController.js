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
    
    suspensionAction: function(cmp, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        var valueMotifSuspension = cmp.find('motifSuspension').get("v.value");
        var valueStatut = cmp.find('statutCompteNouveau').get("v.value"); 
        cmp.find("editFormSuspension").submit(fields);
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();  
    },
    
    reactivationAction: function(cmp, event, helper) {
        event.preventDefault();
        event.preventDefault();
        var fields = event.getParam("fields");
        var valueMotifSuspension = cmp.find('motifSuspension').get("v.value");
        var valueStatut = cmp.find('statutCompteNouveau').get("v.value"); 
        cmp.find("editFormSuspension").submit(fields);
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire(); 
    },
    
    handleError: function(cmp, event, helper) {
        
    },
    
    handleSuccess: function(cmp, event, helper) {
        
    } 
    
    
    
    
})