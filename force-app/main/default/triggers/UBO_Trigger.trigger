/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-30-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-24-2020   Hassan Dakhcha   Initial Version
**/
trigger UBO_Trigger on UBO__c (before insert, after insert, before update, after update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        Map<id, RecordType> RTMap = new  Map<id, RecordType>([SELECT id, developerName FROM RecordType WHERE SobjectType='UBO__c']);
        Set<id> accSet = new Set<id> ();
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(UBO__c ubo : Trigger.new) {
            // Transaction id for synchro :
            ubo.tech_transaction_id__c = transaction_id;
            
            ubo.Record_Type_Name__c = RTMap.get(ubo.recordTypeId).developerName;
            accSet.add(ubo.Account__c);
        }

        Map<id, Account> accMap = new Map<id, Account> ([SELECT id, Name, Statut_UBO__c, nbr_ubo__c, nbr_ubo_pm__c FROM ACCOUNT WHERE id IN :accSet]);
        for(UBO__c ubo : Trigger.new) {
            if(accMap.get(ubo.Account__c).statut_UBO__c == 'VALIDABLE' || accMap.get(ubo.Account__c).statut_UBO__c == 'VALIDATED') {
                ubo.addError('Le compte Pro à été soumi à la validation Hipay, vous ne pouvez pas declarer des bénéficaires effectifs, Merci de contacter le support IT');
            }
            String prefix = '';
            if(ubo.Record_Type_Name__c == 'PM') {
                ubo.Statut__c = 'INVALIDABLE';
                prefix = ubo.denomination__c;
            }
            if(ubo.Record_Type_Name__c == 'PP') {
                String fName = ubo.firstName__c != null ? ubo.firstName__c.left(15) : '';
                String lName = ubo.lastName__c != null ? ubo.lastName__c.left(15) : '';
                prefix = fName + ' ' + lName;
            }
           
            ubo.Name = 'UBO-' + ubo.Record_Type_Name__c + '- ' + prefix + ' - ' + accMap.get(ubo.Account__c).Name.left(15);
   
        }
    }

    if(Trigger.isAfter && Trigger.isInsert) {

        Set<id> accIds = new Set<id>();
        for(UBO__c ubo : Trigger.new) {
            accIds.add(ubo.Account__c);
        }

        // Update counter on account : 
        List<Account> updateAccountCounter = new List<Account> ();
        Map<Id,Account> accounts = new Map<Id,Account> ([SELECT id, Statut_UBO__c FROM Account WHERE id in:accIds]);
        for(id accId : accIds) {
            String statut = accounts.get(accId).statut_UBO__c;
            if(statut == null || statut == 'MISSING') {
                statut='TO_COMPLETE';
            }
            updateAccountCounter.add(new Account(id = accId, Statut_UBO__c = statut));
        }
        Database.update(updateAccountCounter, false);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        Set<Id> uboToSendIds = new Set<Id>();
        Set<UBO__c> uboToSend = new Set<UBO__c>();
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(UBO__c ubo : Trigger.new) {
            // Transaction id for synchro :
            ubo.tech_transaction_id__c = transaction_id;

            if(ubo.Statut__c == 'VALIDABLE' && ubo.Statut__c != Trigger.oldMap.get(ubo.id).Statut__c) {
                ubo.retour_hipay__c = '';
                uboToSend.add(ubo);
                uboToSendIds.add(ubo.id);
            }
        }

        // Check les docs attachés au ubos
        if(!uboToSend.isEmpty()) {
            List<Document__c> docList = [SELECT id, Statut__r.key__c, UBO__c, Type_de_document__c  FROM Document__c WHERE UBO__c IN :uboToSendIds];
            Map<id, List<Document__c>> uboDocMap = new  Map<id, List<Document__c>>();
            for(Document__c doc : docList) {
                List<Document__c> listDocs = uboDocMap.get(doc.UBO__c);
                if(listDocs == null) {
                    listDocs = new List<Document__c>();
                    uboDocMap.put(doc.UBO__c, listDocs);
                }
                listDocs.add(doc);
            }

            for(UBO__c ubo : uboToSend) {
                Boolean idOk = false;
                Boolean addressProofOk = false;
                List<Document__c> docs = uboDocMap.get(ubo.id);
                if(ubo.share__c == null) {
                    ubo.addError('L\'UBO ne peut pas avoir un Pourcentage d\'action vide');
                    continue;
                }

                if(docs == null) {
                    ubo.addError('L\'UBO doit avoir un document pièce d\'identité et un document justificatif de domicile au statut \'Validé\' ou \'A valider Hipay\'');
                    continue;
                }
                for(Document__c doc : docs) {
                    if(doc.Type_de_document__c == 'id' 
                        && (doc.Statut__r.key__c == 'VALIDATED' || doc.Statut__r.key__c == 'VALIDABLE')) {
                        idOk = true;
                    }
                    if(doc.Type_de_document__c =='address_proof'
                        && (doc.Statut__r.key__c == 'VALIDATED' || doc.Statut__r.key__c == 'VALIDABLE')) {
                        addressProofOk = true;
                    }
                }
                if(!idOk) {
                    ubo.addError('L\'UBO doit avoir un document pièce d\'identité au statut \'Validé\' ou \'A valider Hipay\'');
                }
                if(!addressProofOk) {
                    ubo.addError('L\'UBO doit avoir un document justificatif de domicile au statut \'Validé\' ou \'A valider Hipay\'');
                }
            }
        }
    }
/*
    if(Trigger.isAfter && Trigger.isUpdate) {
        //List<UBO__c> uboList = new List<UBO__c> ();
        Set<Id> accSet = new Set<Id>();
        for(UBO__c ubo : Trigger.new) {
            if( ubo.Statut__c != Trigger.oldMap.get(ubo.Id).Statut__c &&
                ubo.Statut__c =='VALIDABLE') {
                //uboList.add(ubo);
                accSet.add(ubo.Account__c);
            }
        }
        
        if(accSet.isEmpty()){
            return;
        }
        List<UBO__c> uboList = [SELECT id, Account__c, Statut__c FROM UBO__c 
                                WHERE Account__c IN :accSet 
                                      AND RecordType.developerName='PP'
                                      AND Statut__c != 'VALIDABLE' 
                                      AND Statut__c != 'VALIDATED'];

        for(UBO__c ubo : uboList) {
            accSet.remove(ubo.Account__c);
        }

        if(!accSet.isEmpty()) {
            List<Account> accList = new List<Account> ();
            for(Id accId : accSet) {
                accList.add(new Account(id=accId, Statut_UBO__c='VALIDABLE'));
            }
            Database.SaveResult[] results = Database.update(accList, false);
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('### UBO  : Erreur update statut UBO sur le compte ');                   
                        System.debug('### UBO : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### UBO Champs origine de l\'erreur : '  + err.getFields());
                    }
                }
            }
        }
    }
*/
}