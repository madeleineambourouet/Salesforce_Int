({
    accept : function(component, event, helper) {
        var verifAcc = component.get("c.creerModifQuote");
        var getUrl = component.get("c.getUrl");
        
        verifAcc.setParams({
            "accId": component.get("v.recordId")
        });
        
		getUrl.setParams({
            "accId": component.get("v.recordId")
        });        
        
        verifAcc.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var error = response.getReturnValue();
                if (error == '') {
                    getUrl.setCallback(this, function(response) {
                        var tmp = response.getReturnValue();
                        if (tmp.startsWith('/apex')) {
                            var urlEvent = $A.get("e.force:navigateToURL");
                    		urlEvent.setParams({
                      			"url": tmp
                    		});
    						urlEvent.fire();
                            
                        } else {
                            alert(tmp);
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    });
                    $A.enqueueAction(getUrl); 
                } else {
                    alert(error);
                    $A.get("e.force:closeQuickAction").fire();
                }
                
            } else {
                alert(state);
				$A.get("e.force:closeQuickAction").fire();                
            }
        });
      $A.enqueueAction(verifAcc);     
        
    }
})