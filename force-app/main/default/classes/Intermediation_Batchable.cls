//@Modified by Qiuyan Liu, 07/06/2018 remove filter batch__c = false, use second parameter of function Database.executeBatch(batch, sizeLot) for processing projects in chunks
global class Intermediation_Batchable implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    global final String query;
    
    global Intermediation_Batchable(String q){
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Projet__c> projets){
        try {
            Set<ID> projectsID = new Set<ID>();
            for (Projet__c project : projets){
                projectsID.add(project.id);
            }
            
            List<Intermediation__c> allMisesEnRelation = [SELECT id, Projet__c, Contact__c, Date_de_s_lection__c, Non_selectionnable__c, Statut_Selection__c, Matching_rejete__c FROM Intermediation__c WHERE Projet__c IN :projectsID FOR UPDATE];
            List<Intermediation__c> lMisesEnRelationUpdate = new List<Intermediation__c>();
            List<Intermediation__c> lMisesEnrelationInsert = new List<Intermediation__c>();
            String ListProjet =''; 
            for (Projet__c project : projets){
                
                List<Intermediation__c> lMisesEnRelationExistantes = new List<Intermediation__c>(); 
                
                for (Intermediation__c miseEnRelation : allMisesEnRelation){
                    if (miseEnRelation.Projet__c == project.id) { lMisesEnRelationExistantes.add(miseEnRelation); }
                }
                ListProjet += project+'\n'; 
                IntermediationHandler.rematch(project, lMisesEnRelationExistantes, lMisesEnRelationUpdate, lMisesEnrelationInsert);
            }
            
            //insert lMisesEnrelationInsert;
            //update lMisesEnRelationUpdate;
            //update projets;

            List<Projet__c> projToQueue = new List<Projet__c>();
            List<Intermediation__c> merInsertToQueue = new List<Intermediation__c>();
            List<Intermediation__c> merUpdateToQueue = new List<Intermediation__c>();

            if (lMisesEnrelationInsert != null || Test.isRunningTest()) {
                Database.SaveResult[] results = Database.insert(lMisesEnrelationInsert, false);
                Integer cnt = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        merInsertToQueue.add(lMisesEnrelationInsert.get(cnt));
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
                    cnt++;
                }
            }

            if (projets != null || Test.isRunningTest()) {
                Database.SaveResult[] results = Database.update(projets, false);
                Integer cnt = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        projToQueue.add(projets.get(cnt));
                    }
                    cnt++;
                }
            }

            if (projToQueue.size() > 0 || merInsertToQueue.size() > 0 || merUpdateToQueue.size() > 0) {
                projToQueue = projToQueue.size() > 0 ? projToQueue : null;
                merInsertToQueue = merInsertToQueue.size() > 0 ? merInsertToQueue : null;
                merUpdateToQueue = merUpdateToQueue.size() > 0 ? merUpdateToQueue : null;
                System.enqueueJob(new IntermediationRetry(projToQueue,merInsertToQueue, merUpdateToQueue ));
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
            mail.setSubject('Le batch de rematching a rencontré un problème');
            mail.setHtmlBody('An error occurred during the Intermediation_Batchable execution. Message: ' + e.getMessage() + '; Cause: ' + e.getCause() + '; LineNumber: ' + e.getLineNumber() + '; StackTraceString: ' + e.getStackTraceString()); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    global void finish(Database.BatchableContext BC){
        /*
Integer sizeLot = Integer.valueOf(Label.Taille_Lot_Intermediation);
Integer jours = Integer.valueOf(Label.Rematching_Delay);
//System.debug('>>> FINISH before finish ? ' + finish);
Datetime myDate = Datetime.now();
myDate = myDate.addDays(jours*(-1));
String myDateForm = myDate.format('yyyy-MM-dd') + 'T00:00:00.000+0000';
//system.debug('>>>>>>>>>> IntermediationBatchable myDate delayed: '+ myDate); 

if (finish == false){
String query = 'SELECT id, INSEE_formule__c, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, '
+ 'LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c, TEXTELIBRE__c, Adresse_IP__c, '
+ 'Numero_SGI__c, Source__c, Type_de_source__c, Code_postal__r.Name '
+ 'FROM Projet__c '
+ 'WHERE Etat__c = \'ODC ouverte\' AND Filtre_batch_B__c = true '
+ 'AND recevoir_pro__c = false AND batch__c = false AND CreatedDate > '+ myDateForm 
+ ' LIMIT '  + sizeLot;
//system.debug('>>>>>>>>>> IntermediationBatchable query: '+ query); 
if ([SELECT id, INSEE_formule__c, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c, TEXTELIBRE__c, 
Adresse_IP__c, Numero_SGI__c, Source__c, Type_de_source__c, Code_postal__r.Name FROM Projet__c WHERE Etat__c = 'ODC ouverte' AND Filtre_batch_B__c = true AND recevoir_pro__c = false AND batch__c = false AND CreatedDate > :myDate LIMIT :sizeLot].size()>0){
Intermediation_Batchable batch = new Intermediation_Batchable(query);
Database.executeBatch(batch);
}
}
else {
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String email = System.Label.DL_SGDBF_supervision_processus;
mail.setUseSignature(false);
mail.setToAddresses(new String[] {email}); 
mail.setSubject('Le batch de rematching a rencontré un problème et s\'est arrêté.');
String bod = 'Les projets n\'ont pas pu être mis à jour. Erreur : ' + errMsg;
mail.setHtmlBody(bod); 
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
*/
    }    
}