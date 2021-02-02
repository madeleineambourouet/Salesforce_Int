/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-23-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-07-2020   Hassan Dakhcha   Initial Version
**/
public class ProjectPlaceWS {
    @AuraEnabled
    public static String callProjectPlaceEmailChange(String recordId, String newEmail) {
        try {
            System.debug('#### HDAK callProjectPlaceEmailChange recordId ' + recordId + ' ' + newEmail);
           
              // check if the email is already known in SF
            List<Contact> contactList = [SELECT id, Name FROM Contact Where email =:newEmail OR email__c =:newEmail];
            if(!contactList.isEmpty()) {
                return 'Le nouvel email (' + newEmail + ') est déja présent dans SF';
            }
           
            Account acc = null;
            String wbeId = null;
            if(recordId.startsWith('001')) { // personal Account
                acc = [SELECT id, External_ID__c, new_email__c, email_change_status_code__c  FROM Account WHERE id=:recordId];
            }
            Contact ctc = null;
            if(recordId.startsWith('003')) {
                ctc = [SELECT id, External_Contact_Id__c, new_email__c, email_change_status_code__c  FROM Contact WHERE id=:recordId];
            }
            if(ctc == null && acc == null)  {
                return 'record Not Found';
            }
            String partWbeId = null;
            if(acc!=null) {
                partWbeId = acc.External_ID__c !=null ? acc.External_ID__c.substringAfter('part_') : null;
            }
            wbeId= ctc!=null ? ctc.External_Contact_Id__c : partWbeId;
            
            if(wbeId == null) {
                return 'L\'utilisateur n\'est pas activé nouvelle offre';
            }

            String tokenStr = '';
            if(!Test.isRunningTest()) {
                Map<WBE_Token__c, Boolean> TokenMap = matchMethods.getToken();
                List<WBE_Token__c> token = new List<WBE_Token__c> (TokenMap.keySet());

                if(token.isEmpty() || token[0] == null) {
                    return 'wbe token error';
                }
                tokenStr = token[0].Token__c;
                System.debug('#### HDAK callProjectPlaceEmailChange : Token   ' +  token[0]);
            }
            
            HttpRequest req = new HttpRequest();
            String emailEncoded = EncodingUtil.urlEncode(newEmail, 'UTF-8');
            req.setEndpoint(System.Label.WBE_Endpoint + '/crc/credentials/email/change?email=' + emailEncoded + '&userId=' + wbeId);
            req.setMethod('POST'); 
            req.setTimeout(20000);
            req.setHeader('Authorization', 'Bearer ' + tokenStr);
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setHeader('Content-Length', '0');

            System.debug('#### HDAK callProjectPlaceEmailChange : request   ' + '/crc/credentials/email/change?email=' + emailEncoded + '&userId=' + wbeId);
        
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('#### HDAK callProjectPlaceEmailChange : response   ' + res.getStatusCode());
            System.debug('#### HDAK callProjectPlaceEmailChange : response   ' + res.getStatus());
            System.debug('#### HDAK callProjectPlaceEmailChange : response   ' + res.getBody());
            
            String returnValue = String.valueOf(res.getStatusCode()) + ' ' + res.getStatus() + ' ' + res.getBody();
            if(ctc!=null) {
                ctc.new_email__c = newEmail;
                ctc.email_change_status_code__c =  returnValue.left(250);
                update ctc;
            } else {
                acc.new_email__c = newEmail;
                acc.email_change_status_code__c =  returnValue.left(250);
                update acc;
            }
            if (res != null && res.getStatusCode() == 200) {
                return 'SUCCESS';  
            } else {
                if(res.getBody().contains('USERNAME_ALREADY_IN_USE')) {
                    return 'USERNAME_ALREADY_IN_USE';
                }
                return res.getStatus();
            }

        } catch(Exception e) {    
            System.debug('#### HDAK Exception lors de l\'appel a WBE (changement email): ' + e.getMessage());
            return 'ERROR';
        }
    }

    // Lorsque le user approuve le changement de mail, le nouveau mail est synchronisé vers SF
    public static void emailChangeCompletedPart(List<Account> accList, map<id, Account> oldMap) {
        for(Account acc : accList) {
            if(acc.IsPersonAccount == true && acc.PersonEmail != oldMap.get(acc.id).PersonEmail &&
                acc.PersonEmail == acc.new_email__c) {
                    acc.email_change_status_code__c = 'COMPLETED';
            }
        }
    }
    public static void emailChangeCompletedPro(List<Contact> ctcList, map<id, Contact> oldMap) {
        for(Contact ctc : ctcList) {
            if(ctc.Email__c != oldMap.get(ctc.id).Email__c) {
                ctc.Email = ctc.email__c;
                if(ctc.Email__c == ctc.new_email__c) {
                    ctc.email_change_status_code__c = 'COMPLETED';
                }
            }
        }
    }

    // Recupere de statut FRont Pro Part du projet:
    @AuraEnabled
    public static String callProjectPlaceFrontProjectStatus(id recordId, String objectApiName) {
        try {   
            String status = 'Statut visible par le ';
            String wbeProjectId = null;
            String wbeUserId = null;
            if(objectApiName == 'Projet_LMSG__c') {
                status += 'Part : ';
                Projet_LMSG__c project = [SELECT id, Identifiant_PP__c,  Particulier__r.External_ID__c FROM Projet_LMSG__c WHERE id=:recordId];
                wbeProjectId = project==null ? null : project.Identifiant_PP__c;
                wbeUserId = (project==null || project.Particulier__r==null || project.Particulier__r.External_ID__c==null) ? null : project.Particulier__r.External_ID__c.substringAfter('part_');
            }
            if(objectApiName == 'Mise_en_relation__c') {
                status += 'Pro : ';
                Mise_en_relation__c mer = [SELECT id, Projet_LMSG__c,WBE_Id__c, Projet_LMSG__r.Identifiant_PP__c, Compte_Pro__c, Compte_Pro__r.Contact_principal__r.External_Contact_Id__c
                                           FROM Mise_en_relation__c WHERE id=:recordId];
                if(mer!=null && mer.Projet_LMSG__c!=null) {
                    wbeProjectId = mer.Projet_LMSG__r.Identifiant_PP__c;
                    wbeUserId = (mer.Compte_Pro__c==null || mer.Compte_Pro__r.Contact_principal__r==null)? null : mer.Compte_Pro__r.Contact_principal__r.External_Contact_Id__c;
                }
            } 

            if(wbeProjectId == null || wbeProjectId == '' || wbeUserId == null || wbeUserId == '') {
                return status + 'AUCUN';
            }
            System.debug('#### HDAK callProjectPlaceFrontProjectStatus recordId ' + wbeProjectId + ' from Object = ' + objectApiName);

            String tokenStr = '';
            if(!Test.isRunningTest()) {
                Map<WBE_Token__c, Boolean> TokenMap = matchMethods.getToken();
                List<WBE_Token__c> token = new List<WBE_Token__c> (TokenMap.keySet());

                if(token.isEmpty() || token[0] == null) {
                    return status + 'AUCUN';
                }
                tokenStr = token[0].Token__c;
                System.debug('#### HDAK callProjectPlaceFrontProjectStatus : Token   ' +  token[0]);
            }
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.Label.WBE_Endpoint + '/crc/project-status?projectId=' + wbeProjectId + '&userId=' + wbeUserId);
            req.setMethod('GET'); 
            req.setTimeout(20000);
            req.setHeader('Authorization', 'Bearer ' + tokenStr);
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('#### HDAK callProjectPlaceFrontProjectStatus : response   ' + res.getStatusCode());
            System.debug('#### HDAK callProjectPlaceFrontProjectStatus : response   ' + res.getStatus());
            System.debug('#### HDAK callProjectPlaceFrontProjectStatus : response   ' + res.getBody());
            
            if (res != null && res.getStatusCode() == 200) {
                if(objectApiName == 'Projet_LMSG__c') {
                    return status + getStatusPartValue(res.getBody().remove('"'));
                } else {
                    return status + getStatusProValue(res.getBody().remove('"'));
                }
            }
            return status + 'AUCUN';

        } catch(Exception e) {    
            System.debug('#### HDAK Exception lors de l\'appel a WBE (statut front projet): ' + e.getMessage());
            return e.getMessage();
        }
    }

    // Statut Front du projet pour le part
    private static String getStatusPartValue(String apiName) {
        map<String, String> mappingStatus = new Map<String, String> {
                'PROJECT_DRAFT' => 'SAUVEGARDÉ',
                'PROJECT_VALIDATING' => 'À L\'ÉTUDE PAR NOS CONSEILLERS',
                'PROJECT_CANCELED' => 'ANNULÉ',
                'RELATIONSHIP_MEETING_SCHEDULED' => 'PROFESSIONNEL EN COURS DE SÉLECTION',
                'RELATIONSHIP_MET' => 'PROFESSIONNEL EN COURS DE SÉLECTION',
                'RELATIONSHIP_NONE' => 'EN ATTENTE DE PROFESSIONNELS',
                'RELATIONSHIP_POSITIONED' => 'PROFESSIONNEL EN COURS DE SÉLECTION',
                'RELATIONSHIP_CANCELED' => 'EN ATTENTE DE PROFESSIONNELS',
                'RELATIONSHIP_REFUSED' => 'EN ATTENTE DE PROFESSIONNELS',
                'RELATIONSHIP_ACCEPTED' => 'PROFESSIONNEL EN COURS DE SÉLECTION',
                'QUOTE_PENDING' => 'PROFESSIONNEL EN COURS DE SÉLECTION',
                'QUOTE_REFUSED' => 'PROFESSIONNEL EN COURS DE SÉLECTION',
                'QUOTE_SIGNED' => 'DEVIS SIGNÉ',
                'AMENDMENT_PENDING' => 'AVENANT EN ATTENTE',
                'DOWN_PAYMENT_PENDING' => 'ACOMPTE À PAYER',
                'START_WORKS_PENDING' => 'EN ATTENTE DE DÉMARRAGE TRAVAUX',
                'WORKS_IN_PROGRESS' => 'TRAVAUX EN COURS',
                'INTERIM_PAYMENT_PENDING' => 'FACTURE À PAYER',
                'WORKS_ACCEPTANCE_AND_INTERIM_PAYMENT_PENDING' => 'PV À VALIDER - FACTURE À PAYER',
                'WORKS_FINISHED_AND_INTERIM_PAYMENT_PAID' => 'PV VALIDÉ - FACTURE PAYÉE',
                'WORKS_ACCEPTANCE_AND_FINAL_PAYMENT_PENDING' => 'PV À VALIDER - SOLDE À PAYER',
                'FINAL_PAYMENT_PENDING' => 'SOLDE À PAYER',
                'PROJECT_FINISHED' => 'CHANTIER TERMINÉ'};
    
        String value = mappingStatus.get(apiName);
        if(value==null)
            return 'AUCUN';
        return value;
    }
    private static String getStatusProValue(String apiName) {
        map<String, String> mappingStatus = new Map<String, String> {
                'MATCH_CREATED' => 'NOUVEAU',
                'PROJECT_CANCELED' => 'ANNULÉ',
                'RELATIONSHIP_MEETING_SCHEDULED' => 'RDV PRÉVU',
                'RELATIONSHIP_MET' => 'DEVIS À ENVOYER',
                'RELATIONSHIP_POSITIONED' => 'EN ATTENTE DE RETOUR',
                'RELATIONSHIP_CANCELED' => 'ANNULÉ',
                'RELATIONSHIP_REFUSED' => 'NON SELECTIONNÉ',
                'RELATIONSHIP_ACCEPTED' => 'EN ATTENTE DE RDV',
                'RELATIONSHIP_NOT_RETAINED' => 'NON RETENU',
                'QUOTE_PENDING' => 'DEVIS ENVOYÉ',
                'QUOTE_REFUSED' => 'DEVIS REFUSÉ',
                'QUOTE_NOT_RETAINED' => 'NON RETENU',
                'QUOTE_SIGNED' => 'DEVIS SIGNÉ - FACTURE À ENVOYER',
                'AMENDMENT_PENDING' => 'AVENANT ENVOYÉ',
                'DOWN_PAYMENT_PENDING' => 'EN ATTENTE DE PAIEMENT ACOMPTE',
                'START_WORKS_PENDING' => 'EN ATTENTE DE DÉMARRAGE TRAVAUX',
                'WORKS_IN_PROGRESS' => 'TRAVAUX EN COURS',
                'INTERIM_PAYMENT_PENDING' => 'EN ATTENTE DE PAIEMENT',
                'WORKS_ACCEPTANCE_AND_INTERIM_PAYMENT_PENDING' => 'EN ATTENTE VALIDATION PV ET PAIEMENT',
                'WORKS_FINISHED_AND_INTERIM_PAYMENT_PAID' => 'PV VALIDÉ - FACTURE PAYÉE',
                'WORKS_ACCEPTANCE_AND_FINAL_PAYMENT_PENDING' => 'EN ATTENTE VALIDATION PV ET PAIEMENT',
                'FINAL_PAYMENT_PENDING' => 'EN ATTENTE DE PAIEMENT',
                'PROJECT_FINISHED' => 'SOLDE DE TOUT COMPTE PAYÉ'
        };
        String value = mappingStatus.get(apiName);
        if(value==null)
            return 'AUCUN';
        return value;
    }
}