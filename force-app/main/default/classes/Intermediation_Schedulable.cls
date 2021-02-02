//@Modified by Qiuyan Liu, 07/06/2018 remove filter batch__c = false, use second parameter of function Database.executeBatch(batch, sizeLot) for processing projects in chunks
global class Intermediation_Schedulable implements Schedulable {

    global void execute(SchedulableContext context){
        
       try{
			Integer sizeLot = Integer.valueOf(Label.Taille_Lot_Intermediation);
			Integer jours = Integer.valueOf(Label.Rematching_Delay);
			Datetime myDate = Datetime.now();
			myDate = myDate.addDays(jours*(-1));
			String myDateForm = myDate.format('yyyy-MM-dd') + 'T00:00:00.000+0000';
	
            /*String query = 'SELECT id, INSEE_formule__c, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, '
                                + 'LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c, TEXTELIBRE__c, Adresse_IP__c, '
                                + 'Numero_SGI__c, Source__c, Type_de_source__c, Code_postal__r.Name, Demande_du_Part__c '
                                + 'FROM Projet__c '
	                            + 'WHERE Etat__c = \'ODC ouverte\' AND Filtre_batch_B__c = true AND (Demande_du_Part__c = null OR Demande_du_Part__c=\'Artisans qualifiés\') '
    	                        + 'AND recevoir_pro__c = false AND batch__c = false AND CreatedDate > '+ myDateForm
        	                    + ' LIMIT '  + sizeLot; */
            String query = 'SELECT id, INSEE_formule__c, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, '
                                + 'LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c, TEXTELIBRE__c, Adresse_IP__c, '
                                + 'Numero_SGI__c, Source__c, Type_de_source__c, Code_postal__r.Name, Demande_du_Part__c '
                                + 'FROM Projet__c '
                                + 'WHERE Etat__c = \'ODC ouverte\' AND Filtre_batch_B__c = true AND (Demande_du_Part__c = null OR Demande_du_Part__c=\'Artisans qualifiés\') '
                                + 'AND recevoir_pro__c = false AND CreatedDate > '+ myDateForm;

            Intermediation_Batchable batch = new Intermediation_Batchable(query);
            Database.executeBatch(batch, sizeLot);
            
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            /* Envoie de mail pour inforamtion */
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email});
            mail.setSubject('Error on execution batch intemediation ');
            String body='Une ereur c\'est produite lor de l\'execution du batch intemediation! </BR>';
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            /* FIN Envoi du mail */
        }

    }
}