({
   closeModal: function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire();
   },
    
   recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            var projetEtat = component.get("v.simpleRecord.Etat__c");
        	if ( (projetEtat != '' && projetEtat != null && !projetEtat.toUpperCase().includes(" CLOS")) || projetEtat == null || projetEtat == ''){ 
                var arr = component.get("v.simpleRecord.DateTimeDerniereDemandeMatching__c");
                if (arr == null || arr == '') arr = '01/01/2018 00:00'; 
                var datetimeArr = arr.split(" "); 
                var myDate = datetimeArr[0].split("/"); 
                var strLastCall = myDate[1] + '/' + myDate[0] + '/' + myDate[2] + ' ' + datetimeArr[1];  
                var DateTimeDerniereDemandeMatching = new Date(strLastCall); 
                var diff = Math.abs(new Date() - DateTimeDerniereDemandeMatching)/60000;   
                if (component.get("v.simpleRecord.Matching_Demande__c") != true || diff > 10) { 
                    helper.callUpdateprojetMatching(component, event);
                } 
                else { 
                	component.set("v.isMatchingEncours",true);
                } 
            } 
            else {
                component.set("v.isEtatClosOrNull",true);
            }
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   }
})