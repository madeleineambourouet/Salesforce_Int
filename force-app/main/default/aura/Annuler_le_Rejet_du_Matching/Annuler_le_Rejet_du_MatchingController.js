({
    accept : function(component, event, helper) {
        var error = '';
        var action = component.get("c.annulerMatching"); 
        
        action.setParams({
            "intId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                
                console.log("success with state: " + state);
                var c = confirm('Attention! Vous allez supprimer l\'amendement correspondant à cette mise en relation');
                if (c) {
                	error = response.getReturnValue();
                	alert(error);
                }
                
            }
            else {
                alert(error);
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        //$A.get("e.force:closeQuickAction").fire();
        return 'ok';
    }
})