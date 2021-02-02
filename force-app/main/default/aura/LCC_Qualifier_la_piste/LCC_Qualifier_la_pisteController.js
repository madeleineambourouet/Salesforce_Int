({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    convertirPiste: function(component, event, helper) { 
      helper.callConvertirPiste(component, event); 
   	},
    
   	recordUpdated: function(component, event, helper) {            
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") {   
            console.log('simpleRecord JSON ' + JSON.stringify(component.get("v.simpleRecord")));
                
        	if ( (component.get("v.simpleRecord.Status") == 'Fermée') || (component.get("v.simpleRecord.Status") == 'Qualifiée') ){ 
                component.set("v.estFerme",true);
            }
            if ((component.get("v.simpleRecord.Salutation") == null) || (component.get("v.simpleRecord.FirstName") == null) || (component.get("v.simpleRecord.LastName") == null) || (component.get("v.simpleRecord.Salutation") == '') || (component.get("v.simpleRecord.FirstName") == '') || (component.get("v.simpleRecord.LastName") == '') ){ 
                component.set("v.estComplet",false);
            } 
            if ( (component.get("v.simpleRecord.Phone") == null) && (component.get("v.simpleRecord.MobilePhone") == null) && (component.get("v.simpleRecord.Email") == null) || (component.get("v.simpleRecord.Phone") == '') && (component.get("v.simpleRecord.MobilePhone") == '') && (component.get("v.simpleRecord.Email") == '') ){ 
                component.set("v.contactOK",false);  
            } 
            if(component.get("v.simpleRecord.SIRET__c") == null || isNaN(component.get("v.simpleRecord.SIRET__c"))){
                component.set("v.estValide",false); 
            }
            else if ( (component.get("v.simpleRecord.SIRET__c")).length != 14) {
                component.set("v.estValide",false);
            }   
            else { 
                var somme = 0; 
                var tmp; 
                for (var cpt = 0; cpt<(component.get("v.simpleRecord.SIRET__c")).length; cpt++) { 
                    if ((cpt % 2) == 0) { 
                        tmp = (component.get("v.simpleRecord.SIRET__c")).charAt(cpt) * 2; 
                        if (tmp > 9) 
                            tmp -= 9; 
                    } 
                    else 
                        tmp = (component.get("v.simpleRecord.SIRET__c")).charAt(cpt); 
                    somme += parseInt(tmp); 
                } 
                if ((somme % 10) == 0) 
                    component.set("v.estValide",true); 
                else 
                    component.set("v.estValide",false); 
            }
            //component.set("v.simpleRecord.Bypass_Validation_Rule__c",true); 
            //alert('Bypass_Validation_Rule__c '+component.get("v.simpleRecord.Bypass_Validation_Rule__c"));
   
        	helper.callLoginCheck(component, event);
        }
        else if (changeType === "REMOVED") { /* handle record removal */ }
        else if (changeType === "CHANGED") { /* handle record change */ }
   	}
})