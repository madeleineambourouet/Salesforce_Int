({
    annulerRappel: function(component, event, helper) {  
       helper.callAnnulerRappel(component, event);
   },
 
   closeModal: function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
  
})