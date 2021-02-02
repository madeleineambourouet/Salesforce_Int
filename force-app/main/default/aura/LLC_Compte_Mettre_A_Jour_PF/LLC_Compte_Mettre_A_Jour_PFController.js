({
     doInit : function(component, event, helper) { 
         component.set('v.message', '');
         helper.callGenerationArtisanService(component, event);
     },
     accept : function(component, event, helper) {
         component.set('v.message', '');
         $A.get("e.force:closeQuickAction").fire();
     }
 })