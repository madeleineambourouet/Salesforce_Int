({
    accept : function(component, event, helper) {
        
        var account = component.get("v.accountRecord");
        account.Id = component.get("v.recordId");
        
        var action = component.get("c.seConnecter");
        
        action.setParams({
            "accId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var URL;
            if (state === "SUCCESS") {
                account = response.getReturnValue();
                var Token = '';
                if(account.Last_URL_redirection__c != null && account.Last_URL_redirection__c != ''){
                	Token = account.Last_URL_redirection__c.replace($A.get("$Label.c.URL_web_pour_email"),'');
                }
                var logAs;
				if (account.IsPersonAccount == true || account.IsPersonAccount == "true") {
                    logAs = $A.get("$Label.c.URL_Log_In_as_part");
                } else {
                    logAs = $A.get("$Label.c.URL_Log_in_as");
                }
                //console.log(logAs);
                URL = $A.get("$Label.c.URL_web_pour_email") + logAs+Token;
                var urlEvent = $A.get("e.force:navigateToURL");
    			
                urlEvent.setParams({
      				"url": URL
    			});
        
        		urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                alert(state);
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
        
        $A.get("e.force:closeQuickAction").fire();
    }
})