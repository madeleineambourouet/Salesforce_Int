({
   doInit : function(component, event, helper) { 
      helper.callVerifierQuote(component, event);
   },

   closeModal: function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
   
})