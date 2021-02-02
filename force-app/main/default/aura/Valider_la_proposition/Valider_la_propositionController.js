({
	myAction : function(component, event, helper) {
		var error = '';
        var action = component.get("c.validerProposition");
        
        action.setParams({
            "quoId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                error = response.getReturnValue();
                if (error == '' || error == null){
                    var urlQuo = '/apex/VF_Quote_CustomZBilling?Id=' + component.get("v.recordId");
                    urlQuo += '&retUrl=/' + component.get("v.recordId") + 'console=true';
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": urlQuo
                    });
    				urlEvent.fire();
                } else {
                    alert(error);
                }
                
            }
            else {
                alert(state);
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        //$A.get("e.force:closeQuickAction").fire();
        return 'ok';
	}
})