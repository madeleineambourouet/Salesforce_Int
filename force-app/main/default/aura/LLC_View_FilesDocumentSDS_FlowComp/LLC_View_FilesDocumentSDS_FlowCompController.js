({
    init : function(component) {

        var action = component.get("c.showDocumentFiles"); 
        action.setParams({
            documentId: component.get('v.idDocument')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();  

           // alert(state);
            if (state === "SUCCESS") {
                var retourText = JSON.stringify(response.getReturnValue());
                console.log(retourText);
                component.set("v.message", "");
                component.set("v.retour", "ok");
                if(retourText.indexOf("Exception message") == -1){
                    component.set("v.listeFichiers", response.getReturnValue());
                }
            	else {
                    component.set("v.message", retourText);
                }
            } 
        });
        
        $A.enqueueAction(action);  

    },
   
})