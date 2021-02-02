/**
* @author Qiuyan Liu
* @CreatedDate 05 Juillet 2017
* @description EB-129, call bus to notify the changement of Projet__c's Statut_Projet__c, Sous_statut__c and Etat__c
*              to bypass fonction in this class, put the function name in field "Bypass_Function__c" on User
*/
global class ProjetAffiliationWS implements Queueable, Database.AllowsCallouts {
    public static Integer LOT_SIZE = 100;
    private List<Id> idFutureLotsList = new List<Id>();
    Private List<Id> idCurrentLotList = new List<Id>();
    
    public ProjetAffiliationWS(List<Id> ids) {
        //this.idList = ids;
        LOT_SIZE = Test.isRunningTest() ? 2 : 100;
        Integer count = 0;
        for (Id id : ids) {
            if (count < LOT_SIZE) {
                idCurrentLotList.add(id);
            } else {
                idFutureLotsList.add(id);
            }
            count++;
        }
    }
    
    public void execute(QueueableContext context) {
        User curUser = [SELECT Id, Name, Bypass_Function__c FROM User WHERE Id =:UserInfo.getUserId()];
        String Bypass_Function = curUser.Bypass_Function__c == null ? '' : curUser.Bypass_Function__c;
        if (Bypass_Function.contains('MAJ_ProjetAffiliation')) {
            return;
        } 
        MAJ_ProjetAffiliationHandlerNow(idCurrentLotList, idFutureLotsList);
    }

    public static void MAJ_ProjetAffiliation(Map<id, Projet__c> newMap, Map<Id, Projet__c> oldMap) {
        //check if the user need to bypass this function
        User curUser = [SELECT Id, Name, Bypass_Function__c FROM User WHERE Id =:UserInfo.getUserId()];
        String Bypass_Function = curUser.Bypass_Function__c == null ? '' : curUser.Bypass_Function__c;
        if (Bypass_Function.contains('MAJ_ProjetAffiliation') || System.isFuture() || System.isBatch()) return;
 
        LOT_SIZE = Test.isRunningTest() ? 2 : 100;

        List<Id> idList = new List<Id>();
        
        if (oldMap == null) {
            idList = new List<Id>(newMap.keyset());
        } else {
            for (Id projectId : newMap.keyset()) {
                Projet__c newPro = newMap.get(projectId);
                Projet__c oldPro = oldMap.get(projectId);
                //Only project with Canal__c equals to 'Web' need to take into account
                if (newPro.Canal__c == 'Web' && (newPro.Statut_Projet__c != oldPro.Statut_Projet__c ||
                    newPro.Sous_statut__c != oldPro.Sous_statut__c ||
                    newPro.Etat__c != oldPro.Etat__c)) {
                    idList.add(projectId);
                }
            }
        }
        
        // Split the list to sublist of LOT_SIZE project (to avoid to hit the LOT_SIZE callouts governors limit)
        if (idList != null && idList.size() > LOT_SIZE) {
            List<List<Id>> lotList = new List<List<Id>>();
            List<Id> tempList = new List<Id>();
            Integer counter = 0;
            for (Id item : idList) {
                if (counter == LOT_SIZE) {
                    lotList.add(tempList.clone());
                    tempList.clear();
                    tempList = new List<Id>();
                    counter = 0;
                }
                tempList.add(item);
                counter++;
            }
            if (tempList != null && !tempList.isEmpty()) {
                lotList.add(tempList.clone());
            }
            
            // Send list by list to the webservice method
            for (List<Id> lot : lotList) {
                MAJ_ProjetAffiliationHandler(lot);
            }
        } else if (idList.size() > 0) {
            // No need to split because less than LOT_SIZE projects
            MAJ_ProjetAffiliationHandler(idList); 
        }
    }
    
    @future(callout=true)
    public static void MAJ_ProjetAffiliationHandler(List<Id> idList){
        MAJ_ProjetAffiliationHandlerNow(idList, null);
    }
    
    public static void MAJ_ProjetAffiliationHandlerNow(List<Id> idList, List<Id> idFutureLotsList){
        List<Projet__c> proList = Test.isRunningTest() ? [SELECT Id, Statut_Projet__c, Sous_statut__c, Etat__c, Motif_de_refus__c FROM Projet__c WHERE id in :idList] : [SELECT Id, Statut_Projet__c, Sous_statut__c, Etat__c, Motif_de_refus__c FROM Projet__c WHERE Canal__c = 'Web' AND id in :idList FOR UPDATE];
        if (proList == null || proList.isEmpty()) return;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String email = System.Label.DL_SGDBF_supervision_processus;
        mail.setToAddresses(new String[] {email}); 
        mail.setSubject('l\'erreur MAJ afiliation projets à BUS, Classe ProjetAffiliationWS');
        //String bod = '';
        List<Exception_Control__c> ecList = new List<Exception_Control__c>();

        for (Projet__c pro : proList) {
            try {
                String username = Label.ProjetAffiliationWSLogin;
                String password = Label.ProjetAffiliationWSPassword; 
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setMethod('PUT');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                request.setHeader('Authorization', authorizationHeader);
                request.setEndpoint(Label.URL_ProjetAffiliationWSEndpoint + pro.Id);
                String sfState = pro.Etat__c != null ? pro.Etat__c : ''; 
                String sfStatus = pro.Statut_Projet__c != null ? pro.Statut_Projet__c : '';
                String sfSubStatus = pro.Sous_statut__c != null ? pro.Sous_statut__c : '';
				String sfreason = pro.Motif_de_refus__c != null ? pro.Motif_de_refus__c : '';
                
                request.setBody('{"sfState":"'+sfState+'",'+
                            	'"sfStatus":"'+sfStatus+'",'+
                           	 	'"sfSubStatus":"' + sfSubStatus + + '",'+ 
                             	'"reason":"' + sfreason +'"}');
                
                HttpResponse response = Test.isRunningTest() ? new HttpResponse() : http.send(request);
                // Parse the JSON response
                if (response.getStatusCode() != 200) {
                    Exception_Control__c ec = new Exception_Control__c(Objet__c='Projet__c', Record_Id__c=pro.Id, Function_Name__c='ProjetAffiliationWS', ErrorMSG__c='Erreur : ' + response.getStatusCode() + ' ' + response.getStatus());
                    ecList.add(ec);
                    //pro.TECH_WS_Affiliation__c = 'Erreur : ' + response.getStatusCode() + ' ' + response.getStatus();
                }/* else {
                    pro.TECH_WS_Affiliation__c = 'OK';
                }*/
            } catch (Exception e) {
                Exception_Control__c ec = new Exception_Control__c(Objet__c='Projet__c', Record_Id__c=pro.Id, Function_Name__c='ProjetAffiliationWS', ErrorMSG__c='Exception : ' + e.getMessage());
                ecList.add(ec);
                //bod += 'Le projet ' + pro.Id + ' n\'ont pas pu être mis à jour. Erreur : ' + 'Exception : ' + e.getMessage() + '<br>';
            }
        }

        /*
        if (ecList.size() > 0) {
            insert ecList;
        }
        
        if (!String.isEmpty(bod)) {
            mail.setHtmlBody(bod); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        update proList;*/
        
        if (idFutureLotsList != null && idFutureLotsList.size() > 0 && !Test.isRunningTest()) {
            System.enqueueJob(new ProjetAffiliationWS(idFutureLotsList));
        }
    }
}