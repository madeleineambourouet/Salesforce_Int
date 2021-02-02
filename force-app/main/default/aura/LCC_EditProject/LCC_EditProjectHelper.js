({
    loadprojetData : function(component, event) {
        var retour = '';
        var action = component.get("c.CallLoadprojetData"); 
        action.setParams({
            "projetId": component.get('v.recordId')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                //if(response.getReturnValue() == true){
            		//$A.get('e.force:refreshView').fire();
       			 	//$A.get("e.force:closeQuickAction").fire();
                //}
                //else{
                	//console.log("success with response.getReturnValue(): " + response.getReturnValue());
                	console.log('currency data is:' + JSON.stringify(response.getReturnValue()));
                	component.set('v.projetVariables', response.getReturnValue());
                	//alert(component.get('v.projetVariables').isEtatLocked);
            		//$A.get('e.force:refreshView').fire();
       			 	//$A.get("e.force:closeQuickAction").fire();
                //}
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     },
     saveProject : function(component, event) {
        var retour = '';
        var action = component.get("c.CallSaveProject");
        action.setParams({
            "projetVariablesObject": JSON.stringify(component.get('v.projetVariables'))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.projetVariables', response.getReturnValue());
                if(component.get('v.projetVariables') != null && component.get('v.projetVariables') != undefined && component.get('v.projetVariables').isnotoktoclose == false && component.get('v.projetVariables').isEtatLocked == false && component.get('v.projetVariables').isDateOk == false && component.get('v.projetVariables').issaveOK == true){
            		$A.get('e.force:refreshView').fire();
       			 	$A.get("e.force:closeQuickAction").fire();
                }
                else{
                	component.set('v.projetVariables', response.getReturnValue());
                }
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     },
     statusChangeNonAdmin : function(component, event) {
        var retour = '';
        var action = component.get("c.CallStatusChange");
        action.setParams({
            "projetVariablesObject": JSON.stringify(component.get('v.projetVariables'))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.projetVariables', response.getReturnValue());
                //$A.get('e.force:refreshView').fire();
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     },
     changePojectQualifDate : function(component, event) {
        var retour = '';
        var action = component.get("c.CallChangePojectQualifDate");
        action.setParams({
            "projetVariablesObject": JSON.stringify(component.get('v.projetVariables'))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.projetVariables', response.getReturnValue());
                //$A.get('e.force:refreshView').fire();
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     },
     openProject : function(component, event) {
        var retour = '';
        var action = component.get("c.CallOpenProject");
        action.setParams({
            "projetVariablesObject": JSON.stringify(component.get('v.projetVariables'))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.projetVariables', response.getReturnValue());
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     },
     closeProject : function(component, event) {
        var retour = '';
        var action = component.get("c.CallCloseProject");
        action.setParams({
            "projetVariablesObject": JSON.stringify(component.get('v.projetVariables'))
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.projetVariables', response.getReturnValue());
                if(component.get('v.projetVariables').isnotoktoclose == false){
                    $A.get('e.force:refreshView').fire();
                    component.set('v.isVisbleClotureMotif', true);
                }
                else{
                    $A.get('e.force:refreshView').fire();
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