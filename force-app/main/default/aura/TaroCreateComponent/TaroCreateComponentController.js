({
   	closeModal: function(component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
   	},
    
   	doInit: function(component, event, helper) {            
  		var workspaceAPI = component.find("workspace");
        var dwidth=1024; 
        var dheight=600; 
        var dtop=window.screen.availHeight/2-dwidth/2; 
        var dleft=window.screen.availWidth/2-dwidth/2; 
        var pageURL = ''; 
        if(component.get("v.sObjectName") == 'Projet__c'){
        	pageURL = '/apex/TaroTransformProjetHY?objectName='+component.get("v.sObjectName")+'&id='+component.get("v.recordId");
        }
        else if(component.get("v.sObjectName") == 'Account'){
        	pageURL = '/apex/TaroCreatePage?objectName='+component.get("v.sObjectName")+'&id='+component.get("v.recordId");
        }
        //pageURL = '/apex/TaroCreatePage?objectName='+component.get("v.sObjectName")+'&id='+component.get("v.recordId");
        workspaceAPI.openTab({
            url: pageURL,
            focus: true
        }).then(function(openParResponse) {
            console.log("New ParentTab Id: ", openParResponse);
        })
        .catch(function(error) {
            console.log(error);
        }); 
		$A.get("e.force:closeQuickAction").fire();
   	}
})