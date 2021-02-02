({
    closeModal: function(component, event, helper) { 
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doInit: function(component, event, helper) {     
        helper.callChiffrageDetail(component, event);
    },
})