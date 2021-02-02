({
    callChiffrageDetail : function(component, event) {
        var retour = '';
        var action = component.get("c.callChiffrageDetail"); 
        action.setParams({
            "projetLmsgId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                console.log("success with state: " + state);
                if(response.getReturnValue() != ''){
                    component.set('v.chiffrage',response.getReturnValue());
                    var chiffrage = component.get('v.chiffrage');
                    var periodeTravauxLibelle = '';
                    if(chiffrage.periodeTravaux == 'ASAP'){
                        periodeTravauxLibelle = 'Dès que possible';
                    }
                    else if(chiffrage.periodeTravaux == '3_MONTHS'){
                        periodeTravauxLibelle = 'Dans 3 mois';
                    }
                    else if(chiffrage.periodeTravaux == '6_MONTHS'){
                        periodeTravauxLibelle = 'Dans 6 mois';
                    }
                    else if(chiffrage.periodeTravaux == '12_MONTHS'){
                        periodeTravauxLibelle = 'Dans 1 an';
                    }
                    else if(chiffrage.periodeTravaux == 'UNKNOWN'){
                        periodeTravauxLibelle = 'Je ne sais pas';
                    }
                    console.log("v.chiffrage: " , chiffrage.package_info);
                    component.set('v.besoinTravaux',chiffrage.besoinsTravaux);
                    component.set('v.bugetTravaux',chiffrage.total.minimum+' - '+chiffrage.total.maximum+'€');
                    component.set('v.dateTravaux',periodeTravauxLibelle);
                    component.set('v.zoneVilleTravaux',chiffrage.postalCode.name);
                    component.set('v.zoneCPTravaux',chiffrage.postalCode.postalCode);
                    component.set('v.sectionsTravaux',chiffrage.summary.sections);
                    component.set('v.totalGrants',chiffrage.totalGrants);
                    component.set('v.rgeGrants',chiffrage.grants);
                    if(chiffrage.grants) {
                        component.set('v.visibleSection', 'Reno');
                    } else {
                        component.set('v.visibleSection', 'Summary');   
                    }
                    component.set('v.message', 'Détail ok');
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