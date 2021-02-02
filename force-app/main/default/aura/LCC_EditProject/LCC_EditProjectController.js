({
    doInit : function(component, event, helper) { 
        helper.loadprojetData(component, event);
    },
    handleCloseCompMotifClotureProjet : function(component, event, helper) { 
        alert('OK');
    },
    saveProjectNonAdmin: function(component, event, helper) { 
        if(component.find('statutProjetNonAdmin').get("v.value") == '' || component.find('statutProjetNonAdmin').get("v.value") == undefined){
            component.get('v.projetVariables').statusSelected = component.get('v.projetVariables.statusOptions') != undefined && component.get('v.projetVariables.statusOptions') != null && component.get('v.projetVariables.statusOptions') != '' ? component.get('v.projetVariables.statusOptions')[0].value : '';    
        }
        else{
            component.get('v.projetVariables').statusSelected = component.find('statutProjetNonAdmin').get("v.value");
        }
        if(component.find('subStatutProjetNonAdmin').get("v.value") == '' || component.find('subStatutProjetNonAdmin').get("v.value") == undefined){
            component.get('v.projetVariables').subStatusSelected = (component.get('v.projetVariables.subStatusOptions') != undefined && component.get('v.projetVariables.subStatusOptions') != null && component.get('v.projetVariables.subStatusOptions') != '' ? component.get('v.projetVariables.subStatusOptions')[0].value : '');    
        }
        else{
            component.get('v.projetVariables').subStatusSelected = component.find('subStatutProjetNonAdmin').get("v.value");
        } 
        if(component.find('subStatutProjet2NonAdmin').get("v.value") == '' || component.find('subStatutProjet2NonAdmin').get("v.value") == undefined){
            component.get('v.projetVariables').subStatusSelected2 = component.get('v.projetVariables.subStatusOptions2') != undefined && component.get('v.projetVariables.subStatusOptions2') != null && component.get('v.projetVariables.subStatusOptions2') != '' ? component.get('v.projetVariables.subStatusOptions2')[0].value : '';    
        }
        else{
            component.get('v.projetVariables').subStatusSelected2 = component.find('subStatutProjet2NonAdmin').get("v.value");
        }  
        component.get('v.projetVariables').curProject.Date_estimee_debut_projet__c = component.find('DateEstimeeDebutProjetNonAdmin').get("v.value"); 
        //alert(component.find('DateEstimeeDebutProjetNonAdmin').get("v.value"));
        component.get('v.projetVariables').curProject.Proprietaire_du_projet__c = component.find('ProprietaireProjetNonAdmin').get("v.value");    
        //alert(component.get('v.projetVariables').statusSelected);
        //alert(component.get('v.projetVariables').subStatusSelected);
        //alert(component.get('v.projetVariables').subStatusSelected2); 
        helper.saveProject(component, event);
    },
    saveProjectAdmin: function(component, event, helper) { 
        component.get('v.projetVariables').curProject.Statut_Projet__c = ''; 
        component.get('v.projetVariables').curProject.Sous_statut__c = '';
        
        component.get('v.projetVariables').curProject.Motif_de_refus__c = component.find('MotifRefusProjetAdmin').get("v.value");
        
        if(component.find('statutProjetAdmin').get("v.value") != '' && component.find('statutProjetAdmin').get("v.value") != undefined){
            component.get('v.projetVariables').curProject.Statut_Projet__c = component.find('statutProjetAdmin').get("v.value");
            component.get('v.projetVariables').statusSelected = component.find('statutProjetAdmin').get("v.value");
        }
        if(component.find('subStatutProjetAdmin').get("v.value") != '' && component.find('subStatutProjetAdmin').get("v.value") != undefined){
            component.get('v.projetVariables').curProject.Sous_statut__c = component.find('subStatutProjetAdmin').get("v.value");
            component.get('v.projetVariables').subStatusSelected = component.find('subStatutProjetAdmin').get("v.value");
        }  
        component.get('v.projetVariables').curProject.Date_estimee_debut_projet__c = component.find('dateEstimeeDebutProjetAdmin').get("v.value"); 
        component.get('v.projetVariables').curProject.Proprietaire_du_projet__c = component.find('proprietaireProjetAdmin').get("v.value");    
        helper.saveProject(component, event);
    },
    
    statusChangeNonAdmin: function(component, event, helper) {
        component.get('v.projetVariables').statusSelected = component.find('statutProjetNonAdmin').get("v.value"); 
        helper.statusChangeNonAdmin(component, event);
    },
    
    changePojectQualifDate: function(component, event, helper) {
        component.get('v.projetVariables').statusSelected = component.find('statutProjetAdmin').get("v.value"); 
        helper.changePojectQualifDate(component, event);
    },
    
    cancelProject: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    openProject: function(component, event, helper) {
        helper.openProject(component, event);
    },
    
    closeProject: function(component, event, helper) {
        if(component.get('v.projetVariables').isAdmin == false){
            if(component.find('statutProjetNonAdmin').get("v.value") == '' || component.find('statutProjetNonAdmin').get("v.value") == undefined){
                component.get('v.projetVariables').statusSelected = component.get('v.projetVariables.statusOptions') != undefined && component.get('v.projetVariables.statusOptions') != null && component.get('v.projetVariables.statusOptions') != '' ? component.get('v.projetVariables.statusOptions')[0].value : '';    
            }
            else{
                component.get('v.projetVariables').statusSelected = component.find('statutProjetNonAdmin').get("v.value");
            }
            if(component.find('subStatutProjetNonAdmin').get("v.value") == '' || component.find('subStatutProjetNonAdmin').get("v.value") == undefined){
                component.get('v.projetVariables').subStatusSelected = (component.get('v.projetVariables.subStatusOptions') != undefined && component.get('v.projetVariables.subStatusOptions') != null && component.get('v.projetVariables.subStatusOptions') != '' ? component.get('v.projetVariables.subStatusOptions')[0].value : '');    
            }
            else{
                component.get('v.projetVariables').subStatusSelected = component.find('subStatutProjetNonAdmin').get("v.value");
            }
        } 
        else{
            component.get('v.projetVariables').statusSelected = component.find('statutProjetAdmin').get("v.value");
            component.get('v.projetVariables').subStatusSelected = component.find('subStatutProjetAdmin').get("v.value");
        }
        helper.closeProject(component, event);
    },
    
    recordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { /* handle record load */ }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { /* handle record change */ }
    },
    handleLoad: function(cmp, event, helper) {
        
    },
    
    handleSubmit: function(cmp, event, helper) {
        
    },
    
    handleError: function(cmp, event, helper) {
        
    },
    
    handleSuccess: function(cmp, event, helper) {
        
    }, 
    
    handleSubmitMotifCloture: function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        console.log(fields);
        component.set("v.MotifEmpty",false);
        var value = component.find('motifClotureNonAdmin_cloture').get("v.value");
        //alert(fields["Etat__c"]);
        var etat = component.find('etatNonAdmin_cloture').get("v.value");
        // is input numeric?
        if (value == null || value == undefined || value == '') {
            component.set("v.MotifEmpty",true);
        }
        else if(fields["Etat__c"]=='Contact part ouvert')  {
            fields["Statut_Projet__c"] = 'Part NRP';
            fields["Etat__c"] = 'Contact part clos';   
            component.find("editFormClotureProjetNonAdmin").submit(fields);
            component.set('v.isVisbleClotureMotif', false);
            component.get('v.projetVariables').issaveOK = true;
            $A.get('e.force:refreshView').fire();
            $A.get("e.force:closeQuickAction").fire();    
        }
    },
    cancelProjectMotifCloture: function(cmp, event, helper)  { 
        cmp.set('v.isVisbleClotureMotif', false);
    }   
    
    
})