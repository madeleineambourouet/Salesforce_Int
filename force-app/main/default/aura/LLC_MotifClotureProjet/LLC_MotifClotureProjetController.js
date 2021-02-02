({
    cancelProject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { /* handle record load */ }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { /* handle record change */}
    },
    handleLoad: function(cmp, event, helper) {
    },
    
    handleSubmit: function(cmp, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        cmp.set("v.MotifEmpty",false);
        var value = cmp.find('motifClotureNonAdmin').get("v.value");
        alert(fields["Etat__c"]);
        alert(fields["Motif_de_cloture__c"]);
        alert(fields["Statut_Projet__c"]);
        alert(fields["Sous_statut__c"]);
        // is input numeric?
        if (value == null || value == undefined || value == '') {
            cmp.set("v.MotifEmpty",true);
        }
        else if(fields["Etat__c"]=='Contact part ouvert')  {
            fields["Statut_Projet__c"] = 'Part NRP';
            fields["Etat__c"] = 'Contact part clos';   
            cmp.find("editFormClotureProjetNonAdmin").submit(fields);
            //$A.get('e.force:refreshView').fire();
            //$A.get("e.force:closeQuickAction").fire();    
        }
    },
    
    handleError: function(cmp, event, helper) {
        
    },
    
    handleSuccess: function(cmp, event, helper) {
        
    } 
    
    
    
    
})