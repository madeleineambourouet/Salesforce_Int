({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    transformerChiffrageToProjet: function(component, event, helper) { 
        var url = "/apex/VF_TransformChiffrage?chiffrageId="+component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        }); 
        urlEvent.fire(); 
   	},
    
   	recordUpdated: function(component, event, helper) {     
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {     
            //console.log('simpleRecord JSON ' + JSON.stringify(component.get("v.simpleRecord")));
            //alert('simpleRecord JSON ' + JSON.stringify(component.get("v.simpleRecord")));
        	if ( (component.get("v.simpleRecord.Projet__c") == '') || (component.get("v.simpleRecord.Projet__c") == null) ){ 
                component.set('v.message', '');
                var url = "/apex/VF_TransformChiffrage?chiffrageId="+component.get("v.simpleRecord.Id");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
            } 
            else {
                component.set("v.estTransforme",true);
            }
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   	}
})