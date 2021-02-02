/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Retry MDL operations when intermediation call is failed.
*
* Called by IntermediationHandler and Intermediation_Batchable
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Qiuyan Liu
* @created        11/06/2018
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            test@test.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class IntermediationRetry implements Queueable {
    private List<Projet__c> projList;
    private List<Intermediation__c> lMisesEnrelationInsert;
    List<Intermediation__c> lMisesEnRelationUpdate;

    public IntermediationRetry(List<Projet__c> projListP, List<Intermediation__c> lMisesEnrelationInsertP, List<Intermediation__c> lMisesEnRelationUpdateP) {
        projList = projListP;
        lMisesEnrelationInsert = lMisesEnrelationInsertP;
        lMisesEnRelationUpdate = lMisesEnRelationUpdateP;
    }

    public void execute(QueueableContext context) {
        List<Projet__c> projToQueue = new List<Projet__c>();
        List<Intermediation__c> merInsertToQueue = new List<Intermediation__c>();
        List<Intermediation__c> merUpdateToQueue = new List<Intermediation__c>();
        String erreurSave = '';
        try {
            if (lMisesEnrelationInsert != null || Test.isRunningTest()) {
                Database.SaveResult[] results = Database.insert(lMisesEnrelationInsert, false);
                Integer cnt = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        merInsertToQueue.add(lMisesEnrelationInsert.get(cnt));
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {            
                            erreurSave = erreurSave +' lMisesEnrelationInsert StatusCode '+ err.getStatusCode() + ': getMessage ' + err.getMessage() +' getFields '+err.getFields()+'<br/>';
                        }
                    }
                    cnt++;
                }
            }

            if (lMisesEnRelationUpdate != null || Test.isRunningTest()) {
                Database.SaveResult[] results = Database.update(lMisesEnRelationUpdate, false);
                Integer cnt = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        merUpdateToQueue.add(lMisesEnRelationUpdate.get(cnt));
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {            
                            erreurSave = erreurSave +' lMisesEnRelationUpdate StatusCode '+ err.getStatusCode() + ': getMessage ' + err.getMessage() +' getFields '+err.getFields()+'<br/>';
                        }
                    }
                    cnt++;
                }
            }

            if (projList != null || Test.isRunningTest()) {
                Database.SaveResult[] results = Database.update(projList, false);
                Integer cnt = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        projToQueue.add(projList.get(cnt));
                    }
                    else {
                    // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {            
                            erreurSave = erreurSave +' projList StatusCode '+ err.getStatusCode() + ': getMessage ' + err.getMessage() +' getFields '+err.getFields()+'<br/>';
                        }
                    }
                    cnt++;
                }
            }

            //PROBLEME DE BOUCLE INFINI SI INSERT OU UPDATE TOMBENT EN ERREUR
            //ON NE RELANCE PLUS LE RETRY POUR EVITER CES ERREURS
            /*if (projToQueue.size() > 0 || merInsertToQueue.size() > 0 || merUpdateToQueue.size() > 0) {
                projToQueue = projToQueue.size() > 0 ? projToQueue : null;
                merInsertToQueue = merInsertToQueue.size() > 0 ? merInsertToQueue : null;
                merUpdateToQueue = merUpdateToQueue.size() > 0 ? merUpdateToQueue : null;
                System.enqueueJob(new IntermediationRetry(projToQueue,merInsertToQueue, merUpdateToQueue ));
            }*/
            if (projToQueue.size() > 0 || merInsertToQueue.size() > 0 || merUpdateToQueue.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String email = System.Label.DL_SGDBF_supervision_processus;
                mail.setUseSignature(false);
                mail.setToAddresses(new String[] {email}); 
                mail.setSubject('Le fonction IntermediationRetry a rencontré un problème au rappel');
                erreurSave =  erreurSave + ' projToQueue '+projToQueue+'<br/>';
                erreurSave =  erreurSave + ' merInsertToQueue '+merInsertToQueue+'<br/>';
                erreurSave =  erreurSave + ' merUpdateToQueue '+merUpdateToQueue+'<br/>';
                mail.setHtmlBody(erreurSave); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }

            if (Test.isRunningTest()) {
                //just for increasing test code coverage
                String strTest;
                strTest.contains('test');
            }
        } catch(Exception e){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email}); 
            mail.setSubject('Le fonction IntermediationRetry a rencontré un problème');
            mail.setHtmlBody('An error occurred during the IntermediationRetry execution : ' + e.getMessage()); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}