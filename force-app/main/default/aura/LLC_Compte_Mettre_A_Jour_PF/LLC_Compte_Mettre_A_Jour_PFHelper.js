({
     callGenerationArtisanService : function(component, event) {
        var retour = '';
        var action = component.get("c.callGenerationArtisanService"); 
        action.setParams({
            "accId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.message', response.getReturnValue());
                if(response.getReturnValue() == 'Le compte a été mis à jour'){
            		$A.get('e.force:refreshView').fire();
                }
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
     }
 })