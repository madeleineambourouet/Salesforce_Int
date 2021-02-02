/**
 * @File Name          : Projet_LMSG_AffiliationWS.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 12-28-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/15/2020   Hassan Dakhcha     Initial Version
**/
public class Projet_LMSG_AffiliationWS implements Queueable, Database.AllowsCallouts{

    private List<Projet_LMSG__c> queueList = new List<Projet_LMSG__c>(); 
    public Projet_LMSG_AffiliationWS(List<Projet_LMSG__c> pList) {
        queueList.addAll(pList);
    }
    public void execute(QueueableContext context) {
        processProject(queueList[0]);
        queueList.remove(0);
        if(!queueList.isEmpty() && !Test.isRunningTest()) // cannot chain jobs in tests
            System.enqueueJob(new Projet_LMSG_AffiliationWS(queueList));
    }
    // Called from the trigger :
    public static void notifyAffiliation(Map<Id,Projet_LMSG__c> oldMap, Map<Id,Projet_LMSG__c> newMap) {
        if(Label.ActivateProjectLMSGNotificationToPartnerShip != 'true' && !Test.isRunningTest())
            return;

        List<Projet_LMSG__c> prjToNotify = new List<Projet_LMSG__c>();
        for(id project : newMap.keySet()) {
            if( (newMap.get(project).idLead__c!=null && newMap.get(project).idLead__c!='') &&
                (oldMap==null || (oldMap.get(project).Statut__c != newMap.get(project).Statut__c ||
                oldMap.get(project).Sous_statut__c != newMap.get(project).Sous_statut__c ||
                oldMap.get(project).Motif__c != newMap.get(project).Motif__c))) {
                    prjToNotify.add(newMap.get(project));
            }
        }
        if(prjToNotify.isEmpty()) {
            return;
        }
        System.enqueueJob(new Projet_LMSG_AffiliationWS(prjToNotify));
    }
    public void processProject(Projet_LMSG__c project) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Basic '+
                            EncodingUtil.base64Encode(Blob.valueOf(Label.ProjetAffiliationWSLogin + ':' + Label.ProjetAffiliationWSPassword)));
            request.setEndpoint(Label.URL_Projet_LMSG_AffiliationWSEndpoint + project.idLead__c);
            String body = '{"sfPPProjectId": "' + project.id + '",'+
                            '"status": "' + (project.Statut__c!=null ? project.Statut__c : '') + '",' +
                            '"subStatus": "' + (project.Sous_statut__c!=null ? project.Sous_statut__c : '') + '",' +
                            '"reason": "' + (project.Motif__c!=null ? project.Motif__c : '') + '"}';
            request.setBody(body);

            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                insert new Exception_Control__c(Objet__c='Projet_LMSG__c',
                                                Record_Id__c=project.Id,
                                                Function_Name__c='Projet_LMSG_AffiliationWS:processProject',
                                                ErrorMSG__c=response.getStatusCode() + ' ' +
                                                            response.getBody().substring(0, math.min(220,response.getBody().length())));
            }
        } catch (Exception e) {
            insert new Exception_Control__c( Objet__c='Projet_LMSG__c',
                                            Record_Id__c=project.Id,
                                            Function_Name__c='Projet_LMSG_AffiliationWS:processProject',
                                            ErrorMSG__c='Exception : ' + e.getMessage().substring(0, math.min(220, e.getMessage().length())));
        } 
    }
}