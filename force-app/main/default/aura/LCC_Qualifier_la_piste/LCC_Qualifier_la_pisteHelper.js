({
     callLoginCheck: function(component, event) {
        var retour = '';
        var action = component.get("c.callLoginCheck"); 
        action.setParams({
            "email": component.get("v.simpleRecord.Email"),
            "leadId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                component.set('v.message', '');
                var retour = response.getReturnValue();
                var splitRetour = retour.split(':');
                var estUnique = splitRetour[0];
                var nombreDeComptesExistants = splitRetour[1];
                var typeDeDoublon = splitRetour[2];
                
                component.set('v.message', '');
                if(estUnique == 'true'){
                    component.set('v.estUnique', true);
                }
                else if(estUnique == 'false'){
                    component.set('v.estUnique', false);
                }
                //FIN CONTROLE
                if (component.get("v.estValide") && component.get("v.estComplet") && component.get("v.estUnique") && component.get("v.contactOK") && !component.get("v.estFerme")){
                    var keepon = 0;
                    if (nombreDeComptesExistants != null && nombreDeComptesExistants != undefined && nombreDeComptesExistants > 0) { 
                        if (typeDeDoublon == 'SIRET') 
                            component.set("v.keepon",1); 
                        else if (typeDeDoublon  == 'Email&Tel' || typeDeDoublon == 'Email&Mobile' || typeDeDoublon == 'Société&Tel' || typeDeDoublon  == 'Société&Mobile') 
                            component.set("v.keepon",2);
                        else if (typeDeDoublon  == 'Email&Société') 
                            component.set("v.keepon",3);
                    }
                    else if(keepon == 0){ 
                        this.callConvertirPiste(component, event); 
                    }
                }
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     },
    
     callConvertirPiste: function(component, event) {
        var retour = '';
        var action = component.get("c.callConvertirPiste"); 
        action.setParams({
            "leadId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                var retour = response.getReturnValue();
                if(retour == null || retour == ''){
                	component.set('v.message', '');
                }
                else if(retour.indexOf() == -1){
                    var splitRetour = retour.split(':');
                    var leadConvertedAccountId = splitRetour[1];
                	component.set('v.message', '');
                    //OUVERTURE QUOTE
                    var url = "/apex/zqu__CreateQuote?crmAccountId="+leadConvertedAccountId+"&quoteType=Subscription&retUrl=/"+leadConvertedAccountId+"&stepNumber=1";
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": url
                    });
                    urlEvent.fire();
                }
                else{ 
                    component.set('v.message', response.getReturnValue());
                }  
            }
            else {
                console.log("Failed with state: " + state);
                component.set('v.message', 'L\'appel a echoué. Veuillez contacter votre administrateur');
            }

        });
        $A.enqueueAction(action);
     }
 })