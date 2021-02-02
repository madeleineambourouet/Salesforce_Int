({ 
    getDocumentType : function(component, event, helper) {
        var retour = '';
        var action = component.get("c.callDocumentType");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.typeDocument', response.getReturnValue());
                console.log("getDocumentType success with response.getReturnValue(): " + response.getReturnValue());
                var arrayOfMapKeys = [];
                for (var singlekey in response.getReturnValue()) {
                    if(component.get('v.sobjecttype') == 'UBO__c') {
                        if(singlekey == 'address_proof' || singlekey == 'id') {
                            arrayOfMapKeys.push(singlekey);
                        }
                    } else {
                        arrayOfMapKeys.push(singlekey);
                    }
                    console.log("getDocumentType: singlekey " + singlekey+" "+response.getReturnValue()[singlekey]);
                }
                component.set('v.listKey', arrayOfMapKeys);
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'Un problème est arrivé dans la récupération du type de document');
            }
        });
        $A.enqueueAction(action);
     },  
})