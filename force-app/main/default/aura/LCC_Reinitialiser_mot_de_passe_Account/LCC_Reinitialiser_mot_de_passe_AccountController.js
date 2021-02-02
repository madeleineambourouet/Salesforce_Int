({
    accept : function(component, event, helper) {
        var account = component.get("v.accountRecord");
        account.Id = component.get("v.recordId");
        account.Reinitialisation_mdp__c = true;
        
        var action = component.get("c.reinitMDP");
        action.setParams({
            "acc": account
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
        
        
    },

 	close : function (component, event, helper) {
    	var dismissActionPanel = $A.get("e.force:closeQuickAction");
	dismissActionPanel.fire(); 
    }
});