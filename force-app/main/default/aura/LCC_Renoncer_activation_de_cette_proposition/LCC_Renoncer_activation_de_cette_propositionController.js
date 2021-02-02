({
   doInit : function(component, event, helper) { 
      helper.callVerifierQuote(component, event);
   },

   confirmRenoncerActivation: function(component, event, helper) {
       	window.open("/apex/resignationQuote?id="+component.get("v.recordId"), "Resiliation", "width=600,height=700"); 
        $A.get('e.force:refreshView').fire();
      	$A.get("e.force:closeQuickAction").fire();
   },

   closeModal: function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
   
})