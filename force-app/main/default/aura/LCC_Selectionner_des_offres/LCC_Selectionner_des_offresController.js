({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
       
   	recordUpdated: function(component, event, helper) {             
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {   
            console.log('simpleRecord JSON ' + JSON.stringify(component.get("v.simpleRecord")));
            //alert('simpleRecord JSON ' + JSON.stringify(component.get("v.simpleRecord")));
        	if ( (component.get("v.simpleRecord.zqu__Status__c") != 'En cours') ){ 
                component.set('v.message', 'La proposition commerciale a été envoyée au client. Vous ne pouvez pas modifier les offres.');
                
            } 
            else {
               	document.location.href="/apex/zqu__SelectProducts?id="+component.get("v.recordId"); 
            }
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   	}
})