({
    doInit : function(component, event, helper) { 
        component.find('record').reloadRecord(true); 
    },
    fermerPreinscrit: function(component, event, helper) {  
       helper.callFermerPreinscrit(component, event);
   },
 
   closeModal: function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
    
   recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { /* handle record load */ }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   }
})