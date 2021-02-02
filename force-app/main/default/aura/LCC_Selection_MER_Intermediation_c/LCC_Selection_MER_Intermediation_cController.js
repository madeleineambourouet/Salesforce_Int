({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    accept : function(component, event, helper) {
		var error = '';
        var action = component.get("c.selectionPro"); 
        
        action.setParams({
            "intId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                error = response.getReturnValue();
                
                if (error == '')
                    $A.get("e.force:closeQuickAction").fire(); //$A.get('e.force:refreshView').fire();
                else
                    alert(error);
                
                
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
    }
})