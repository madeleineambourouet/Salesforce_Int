({
     callRegenererPdf : function(component, event) {
        var retour = '';
        var action = component.get("c.callRegenererPdf"); 
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
                    var dwidth=1024; 
                    var dheight=600; 
                    var dtop=window.screen.availHeight/2-dwidth/2; 
                    var dleft=window.screen.availWidth/2-dwidth/2; 
                    var pageURL = window.location.hostname; 
       				//window.open('/apex/zqu__zqgeneratepdf?SID={!$Api.Session_ID}&SURL={!$Api.Partner_Server_URL_100}&QID='+component.get("v.recordId")+'&format=pdf','newwindow','height='+dheight+',width='+dwidth+',top='+dtop+',left='+dleft+',toolbar=0,menubar=0,scrollbars=1,resizable=0,location=0,status=0'); 
       				window.open('/apex/VF_lightning_open_zqu_zqgeneratepdf?QID='+component.get("v.recordId"),'newwindow','height='+dheight+',width='+dwidth+',top='+dtop+',left='+dleft+',toolbar=0,menubar=0,scrollbars=1,resizable=0,location=0,status=0'); 
       				$A.get("e.force:closeQuickAction").fire();
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