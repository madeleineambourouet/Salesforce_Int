/*
* Document Trigger : handels some logic for the document__c object
* Test Method : HerokuConnectTest / MandatoryDocmentsTest
* Created by : Hassan
* Created Date : 26 Dec 2019
*/

trigger DocumentTrigger on Document__c (before insert, after insert, before update, after update, before delete, after delete) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        DocumentMethods.setIsUpdatedBySF(Trigger.new);
        // Heroku connect : si document inseré sans Id du compte le rataché au bon compte
        DocumentMethods.AttachHKConnectDocToAccount(Trigger.New);
        
        // Mkting cloud remplir le contact pricipal si compte_pro est rempli et n'est pas un person Account
        Set<Id> accSet = new Set<Id> ();
        Set<Id> checkUboDocSet = new Set<id>();
        for (Document__c doc : Trigger.New) {
            if(doc.Compte_Pro__c != null) {
                accSet.add(doc.Compte_Pro__c);
            }
            if(doc.ubo__c != null) {
                checkUboDocSet.add(doc.ubo__c);
                if(doc.Type_de_document__c != 'id' && doc.Type_de_document__c !='address_proof') {
                    doc.addError('Les seuls documents possibe sur un ubo sont : La pièce d\'identité et le justificatif de domicile)');
                }
                doc.Fire_Trigger__c = Datetime.now();
            }
        }

        if (!checkUboDocSet.isEmpty()) {
            List<Document__c> uboDocs = [SELECT id, UBO__c, Type_de_document__c FROM Document__c WHERE UBO__c IN:checkUboDocSet];
            Map<id, List<Document__c>> uboDocMap = new Map<id, List<Document__c>>();
            for(Document__c doc : uboDocs ) {
                List<Document__c> docList = uboDocMap.get(doc.UBO__c);
                if(docList == null) {
                    docList = new List<Document__c>();
                    uboDocMap.put(doc.UBO__c, docList);
                }
                docList.add(doc);
            }
            for (Document__c doc : Trigger.New) {
                List<Document__c> docList = uboDocMap.get(doc.UBO__c);
                if(docList == null)
                    continue;
                for(Document__c curDoc : docList) {
                    if(doc.Type_de_document__c == curDoc.Type_de_document__c) {
                        doc.addError('Un document du même type existe deja pour l\'ubo');
                    }
                }
            }
        }

        if(!accSet.isEmpty()) {
            Map<Id, Account> accMap = new Map<Id, Account> ([SELECT id, IsPersonAccount, Contact_principal__c, Login__c,
                                                             Compte_Nouvelles_Offres__c, Fire_trigger__c FROM Account Where id IN :accSet]);
            for(Document__c doc : Trigger.New) {
               Account acc = accMap.get(doc.Compte_Pro__c);
                if(acc != null) {
                    if(doc.Email_cle_document__c ==null || doc.Email_cle_document__c =='') {
                        doc.Email_cle_document__c = acc.Login__c + '_' + doc.idDocument__c;
                    }
                    if(acc.IsPersonAccount == false) {
                        doc.Contact_principal__c = acc.Contact_principal__c;
                    }
                    if(acc.Compte_Nouvelles_Offres__c == true && acc.Fire_trigger__c != null) {
                        doc.Fire_Trigger__c = Datetime.now();
                    }
                }
            }
        }
    } 
  
    if(Trigger.isAfter && Trigger.isInsert) {
        MandatoryDocs_JctDocManager.docInserted(Trigger.New);

        // update paiement indicators on accounts
        Indicateur_LMSG.docPaiement(Trigger.new, null);
        Code_RGE_Qualibat_Methods.processCodes(Trigger.new, null);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
        // set flag uodated by SF
        DocumentMethods.setIsUpdatedBySF(Trigger.new);

        List<reference__c> refList = [SELECT id,Key__c FROM reference__c WHERE recordType.DeveloperName = 'Statut_Document'];
        Map<String, id> keyIdStatus = new Map<String, id>();
        for(Reference__c ref : refList) {
            keyIdStatus.put(ref.key__c, ref.id);
        }

        List<Document__c> docUpdateKey = new List<Document__c> ();
        // MAJ des document obligatoire si necessaire
        for(Document__c doc : Trigger.new) {    
            // validation Rules
            DocumentMethods.validateKYBChange(Trigger.oldMap.get(doc.Id), doc, keyIdStatus);

            //Update key
            if(Trigger.newMap.get(doc.Id).idDocument__c != Trigger.oldMap.get(doc.Id).idDocument__c)
                docUpdateKey.add(doc);
            
            if(Trigger.oldMap.get(doc.Id).Type_de_document__c != doc.Type_de_document__c)
                doc.Obligatoire_Presta__c = false;

            // Document RIB validated :
            if( doc.Type_de_document__c=='rib' && doc.details__c != null 
                && (doc.details__c != Trigger.oldMap.get(doc.Id).details__c) && doc.details__c.contains('****')) {
                    doc.iban_details_status__c = 'Approved';
            }

            // Document RIB validated :
            if( doc.Type_de_document__c=='rib' && doc.Statut__c == keyIdStatus.get('REFUSED') 
                && Trigger.oldMap.get(doc.Id).Statut__c != keyIdStatus.get('REFUSED') ) {
                    doc.iban_details_status__c = 'Rejected';
            }

            if(doc.Fire_Trigger__c==null && doc.ubo__c != Trigger.oldMap.get(doc.Id).ubo__c) {
                doc.Fire_Trigger__c = Datetime.now();
            }
        }
        
        if(!docUpdateKey.isEmpty()) {
            for(Document__c doc : docUpdateKey) {
                if(doc.Email_cle_document__c != null && doc.Email_cle_document__c != '') {
                    doc.Email_cle_document__c = (doc.Email_cle_document__c).substringBeforeLast('_') + '_' + doc.idDocument__c;
                }
                if( keyIdStatus.get('NEW') != null && keyIdStatus.get('MISSING')!=null && doc.Statut__c == keyIdStatus.get('MISSING') 
                    && doc.idDocument__c != null && doc.idDocument__c != '') {
                    doc.Statut__c = keyIdStatus.get('NEW');
                }
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        List<reference__c> refStatus = [SELECT id,Key__c FROM reference__c WHERE (Key__c = 'VALIDATED' OR key__c='EXPIRED' ) AND recordType.DeveloperName = 'Statut_Document'];
        id validateRef;
        id expiredRef;
        for(reference__c ref : refStatus) {
            if(ref.key__c=='VALIDATED') {
                validateRef = ref.id;
            }
            if(ref.key__c=='EXPIRED') {
                expiredRef = ref.id;
            }
        }
        Set<id> typeDocChangedSet = new Set<id>();
        Set<id> statusDocChangedSet = new Set<Id>();
        Boolean tolerateExpired = Label.DocTolerateExpired!='0';
        for(id docId : Trigger.newMap.keySet()) {
            if(Trigger.oldMap.get(docId).Type_de_document__c != Trigger.newMap.get(docId).Type_de_document__c) {
                typeDocChangedSet.add(docId);
            }

            Boolean statusChanged = Trigger.oldMap.get(docId).Statut__c != Trigger.newMap.get(docId).Statut__c;
            Boolean changedToValidate = Trigger.newMap.get(docId).Statut__c == validateRef;
            Boolean changedFromValidate = Trigger.oldMap.get(docId).Statut__c == validateRef;
            Boolean changedToExpired = Trigger.newMap.get(docId).Statut__c == expiredRef;
            Boolean evaluate_Expired = Trigger.newMap.get(docId).Evaluate_Expired__c==true && Trigger.oldMap.get(docId).Evaluate_Expired__c==false;

            if( (statusChanged && 
                    ( changedToValidate // Doc Validé
                      || (changedFromValidate && !changedToExpired) // Doc Invalidé mais pas expiré
                      || (changedFromValidate && changedToExpired && !tolerateExpired))) // Doc Expiré
                || evaluate_Expired==true 
                || (Trigger.newMap.get(docId).Type_de_document__c.contains('cert_rge') && Trigger.oldMap.get(docId).details__c != Trigger.newMap.get(docId).details__c)) { 
                statusDocChangedSet.add(docId);
            }
        }
   
        if(!typeDocChangedSet.isEmpty()) {
            MandatoryDocs_JctDocManager.docTypeChanged(typeDocChangedSet);
        }
        if(!statusDocChangedSet.isEmpty()) {
            MandatoryDocs_JctDocManager.docStatusChanged(statusDocChangedSet);
        }
        
        // update paiement indicators on accounts
        Indicateur_LMSG.docPaiement(Trigger.new, null);
        Code_RGE_Qualibat_Methods.processCodes(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isBefore && Trigger.isDelete) {

        // Validation Rule on KYB :
        List<Document__c> docToDelete = DocumentMethods.validateDeletion(Trigger.old);
        
        // Clean the sds documents:
        if(!docToDelete.isEmpty()) {
            DocumentServiceSDS.removeFile(Trigger.old);
        }
    }

    if(Trigger.isAfter && Trigger.isDelete) {
        MandatoryDocs_JctDocManager.docDeleted(Trigger.oldMap);
        // update paiement indicators on accounts
        Indicateur_LMSG.docPaiement(Trigger.old, null);
    }

}