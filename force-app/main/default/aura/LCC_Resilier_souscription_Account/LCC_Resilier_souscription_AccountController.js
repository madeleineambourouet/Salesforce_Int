({
    accept : function(component, event, helper) {
        var verifAcc = component.get("c.resilierSouscription");
        var getUrl = component.get("c.getUrl");
        
        verifAcc.setParams({
            "accId": component.get("v.recordId")
        });
        
        
        verifAcc.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                var tmp = response.getReturnValue();
                if (tmp.startsWith('/apex')) {/*
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      	"url": tmp,
                        "target": "_blank"
                    });
    						urlEvent.fire();*/
                    var pageURL = window.location.hostname; 
                    window.open("https://"+pageURL+tmp, "_self");	                    
                    
                } else {
                    $A.get("e.force:closeQuickAction").fire();
                }
                
            } else {
				$A.get("e.force:closeQuickAction").fire();                
            }
        });
      $A.enqueueAction(verifAcc);     
        
    }
})