({
    closeModal: function(component, event, helper) { 
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doInit: function(component, event, helper) {   
        if( component.get("v.projectRecord.Statut__c") != 'PUBLISHED' &&
            component.get("v.projectRecord.Statut__c") != 'FINISHED' &&
            component.get("v.projectRecord.Statut__c") != 'SIGNED'
        ) { 
            var workspaceAPI = component.find("workspace");
            var dwidth=1024; 
            var dheight=600; 
            var dtop=window.screen.availHeight/2-dwidth/2; 
            var dleft=window.screen.availWidth/2-dwidth/2; 
            var pageURL = '/apex/TaroEditPage?objectName='+component.get("v.sObjectName")+'&id='+component.get("v.recordId");
            //window.open('/apex/TaroCreatePage','self','height='+dheight+',width='+dwidth+',top='+dtop+',left='+dleft+',toolbar=0,menubar=0,scrollbars=1,resizable=0,location=0,status=0'); 
            /*workspaceAPI.openTab({
                url: pageURL,
                focus: true
            }).then(function(openParResponse) {
                console.log("New ParentTab Id: ", openParResponse);
            })
            .catch(function(error) {
                console.log(error);
            }); */
            
            workspaceAPI.openTab({
                url: '/lightning/r/LMSG__c/'+component.get("v.recordId")+'/view',
                focus: true
            }).then(function(openParResponse) {
                workspaceAPI.openSubtab({
                    parentTabId: openParResponse,
                    url: pageURL,
                    focus: true
                });
            })
            .catch(function(error) {
                console.log(error);
            });
            //$A.get("e.force:closeQuickAction").fire();
        } else {
            component.set("v.projectLocked", true);
        }
    },
    
    onTabClosed : function(component, event, helper) {
        var tabId = event.getParam('tabId');
        console.log('Tab closed: ' +tabId);
    }, 
})