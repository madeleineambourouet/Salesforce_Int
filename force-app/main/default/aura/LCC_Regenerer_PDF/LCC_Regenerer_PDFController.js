({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    
   	recordUpdated: function(component, event, helper) {            
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {   
            helper.callRegenererPdf(component, event);
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   	}
})