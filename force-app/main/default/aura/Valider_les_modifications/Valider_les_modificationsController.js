({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    
	myAction : function(component, event, helper) {
		var msg = '';
        var action = component.get("c.validerModification");
        
        action.setParams({
            "quoId": component.get("v.recordId"),
            "typeQ": "modif"
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                msg = response.getReturnValue();
                if (msg == '' || msg == null){
                    var urlQuo = '/apex/VF_Quote_CustomZBilling?Id=' + component.get("v.recordId");
                    urlQuo += '&retUrl=/' + component.get("v.recordId") + 'console=true';
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": urlQuo
                    });
    				urlEvent.fire();
                } else {
                    //alert(msg);
                	component.set("v.message",msg);
                    //$A.get("e.force:closeQuickAction").fire();
                }
                
            }
            else {
                //alert(state);
                component.set("v.message",state);
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        //$A.get("e.force:closeQuickAction").fire();
        return 'ok';
	}
})