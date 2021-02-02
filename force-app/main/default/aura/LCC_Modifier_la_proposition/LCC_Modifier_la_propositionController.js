({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    
   	recordUpdated: function(component, event, helper) {            
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {   
            if (component.get("v.simpleRecord.Type__c") == 'Création de souscription'){ 
                if (component.get("v.simpleRecord.zqu__Status__c") != 'En cours'){ 
                	component.set("v.message","La proposition commerciale a été envoyée au client. Vous ne pouvez pas la modifier.");
                }
                else{
                    //OUVERTURE QUOTE EDIT
                    var url = "/apex/zqu__EditQuoteDetail?id="+component.get("v.recordId");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": url
                    });
                    urlEvent.fire();
                }
            }
            else{
                //OUVERTURE QUOTE EDIT
                var url = "/apex/zqu__EditQuoteDetail?id="+component.get("v.recordId");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
            }
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   	}
})