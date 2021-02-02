({
     callVerifierQuote : function(component, event) {
        var retour = '';
        var action = component.get("c.callVerifierQuoteDateActivation"); 
        action.setParams({
            "quoteId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.message', response.getReturnValue());
                if(response.getReturnValue() == ''){
            		$A.get('e.force:refreshView').fire();
                    var url = "/apex/ModifyActivateDate?id="+component.get("v.recordId");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": url
                    });
                    urlEvent.fire();
       			 	$A.get("e.force:closeQuickAction").fire();
                }
                else{
                	component.set('v.message', response.getReturnValue());
                }
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     }
 })