/**
* @author Hassan Dakhcha
* @date 31/12/2019
* @description :  Mandatory Documents StatusSetter: MAJ des flag/statut sur le compte et les prestations
*				  Doc Updated to Validé : la classe analyse tous les doc du compte : flag si tous les doc sont valid et modifie le statut si necessaire.
*                 TODO : rajouter les autres cas 
*                 
* Test : MandatoryDocumentsTest
**/ 

public class MandatoryDocs_StatusSetter {
    
 
    /**
    * @description : Révalue le positionnement des prestations contact par rapport a la liste des jonctions donnée en entrée
    * @author Hassan Dakhcha | 2/20/2020 
    * @param jontcionPC_Doc 
    * @return void 
    **/
    /*public static void evaluatePCStatus_ForJonction(List<Jointure_Documents_Prestations__c> jontcionPC_Doc ) {
        // Map de Presta vers Set de Document
        List<Prestation_Contact__c> pcNotPosi = new List<Prestation_Contact__c>();                             
        for(Jointure_Documents_Prestations__c jct : jontcionPC_Doc) {
            // add only the non validates documents
            if(jct.Tech_key_doc_status__c != 'VALIDATED') {
                pcNotPosi.add(new Prestation_Contact__c(id=jct.Prestation__c, Statut__c = 'NOT_POS'));
            }
        }
        // update statut on prestations : 
        commitUpdatePC(pcNotPosi, '### HDAK evaluatePCStatus_ForJonction: MAJ des prestation a echouée erreur : ');
    }*/


    /**
    * @description : Re_evalue le positionnement des prestation contact qui sont liées aux documents en argument, mais par rapport a tous leurs documents
    * @author Hassan Dakhcha | 2/20/2020 
    * @param docSet
    * @return void 
    **/
    public static void evaluatePCStatuts_ForAllPC(Set<id> pcSet) {
        List<Jointure_Documents_Prestations__c> jctList = [ SELECT id, prestation__c, document__c, Statut_Document__c,Tech_key_doc_status__c, prestation__r.prestation__c,
                                                            Type_de_document_value__c, prestation__r.prestation__r.Code_RGE_Qualibat__c, document__r.details__c
                                                            FROM Jointure_Documents_Prestations__c
                                                            WHERE prestation__c IN : pcSet];   
        evaluatePCStatus_ForJct(jctList);   
    }


    /**
    * @description : Re_evalue le positionnement des prestation contact qui sont liées aux documents en argument, mais par rapport a tous leurs documents
    * @author Hassan Dakhcha | 2/20/2020 
    * @param docSet
    * @return void 
    **/
    /*public static void evaluatePCStatuts_ForAllDocs(Set<id> docSet) {
        List<Jointure_Documents_Prestations__c> jctList = [SELECT id, prestation__c, document__c, Statut_Document__c, Tech_key_doc_status__c
                                                           FROM Jointure_Documents_Prestations__c
                                                           WHERE document__c IN : docSet];   
        if(jctList.isEmpty()){ 
            return;
        }
        Set<id> prestaSet = new Set<id>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            prestaSet.add(jct.Prestation__c);
        }

        List<Jointure_Documents_Prestations__c> allJctList = [SELECT id, prestation__c, document__c, Statut_Document__c, Tech_key_doc_status__c
                                                              FROM Jointure_Documents_Prestations__c
                                                              WHERE prestation__c IN :prestaSet];
        evaluatePCStatus_ForJct(jctList);   
    }*/
    Class Codes {
        public List<String> codes;
    }
    private static void evaluatePCStatus_ForJct(List<Jointure_Documents_Prestations__c> jctList) {
        if(jctList.isEmpty())
            return;
        /*
        Map<id, Set<String>> pcDocStatusMap = new Map<id, Set<String>>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            Set<String> docStatusSet = pcDocStatusMap.get(jct.Prestation__c);
            if(docStatusSet == null) {
                docStatusSet = new Set<String>();
                pcDocStatusMap.put(jct.Prestation__c, docStatusSet);
            }
            docStatusSet.add(jct.Tech_key_doc_status__c != 'VALIDATED' ? 'NOT_VALID' : 'VALID');
        } 
        List<Prestation_Contact__c> pcToUpdate = new List<Prestation_Contact__c>();
        for(Id pc : pcDocStatusMap.keySet()) {
            Set<String> statusSet = pcDocStatusMap.get(pc);
            pcToUpdate.add(new Prestation_Contact__c(id=pc, Statut__c = statusSet.contains('NOT_VALID') ? 'NOT_POS' : 'POS'));
        }
        */

        Map<id, Map<String, Set<String>>> pcDocTypeStatusMap = new Map<id, Map<String, Set<String>>>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            Map<String, Set<String>> docStatusSet = pcDocTypeStatusMap.get(jct.Prestation__c);
            if(docStatusSet == null) {
                docStatusSet = new Map<String, Set<String>>();
                pcDocTypeStatusMap.put(jct.Prestation__c, docStatusSet);
            }
            Set<String> typeStatusSet = docStatusSet.get(jct.Type_de_document_value__c);
            if(typeStatusSet == null) {
                typeStatusSet = new Set<String>();
                docStatusSet.put(jct.Type_de_document_value__c, typeStatusSet);
            }
            Boolean rge_qualibat_valid = true;
            if(jct.Type_de_document_value__c == 'cert_rge_qualibat' && jct.prestation__c!=null && jct.prestation__r.prestation__c!=null 
                && jct.prestation__r.prestation__r.code_rge_qualibat__c!=null && jct.prestation__r.prestation__r.code_rge_qualibat__c!='') {
                List<String> codePresta = jct.prestation__r.prestation__r.code_rge_qualibat__c.split(';');
                Codes codeDoc = null;
                if(jct.document__c!= null && jct.document__r.details__c!=null && jct.document__r.details__c!='') {
                    codeDoc = (Codes)JSON.deserialize(jct.document__r.Details__c, Codes.Class);
                }
                if(!codePresta.isEmpty()) {
                    rge_qualibat_valid = false;
                    if(codeDoc != null && codeDoc.codes != null && !codeDoc.codes.isEmpty()) {
                        for(String str : codeDoc.codes) {
                            if(codePresta.contains(str)) {
                                rge_qualibat_valid = true;
                                break;
                            }
                        }
                    }
                }
            }
            typeStatusSet.add(rge_qualibat_valid && jct.Tech_key_doc_status__c == 'VALIDATED' ? 'VALID' : 'NOT_VALID');
        } 

        List<Prestation_Contact__c> pcToUpdate = new List<Prestation_Contact__c>();
        for(Id pc : pcDocTypeStatusMap.keySet()) {
            Map<String, Set<String>> typeStatusSet = pcDocTypeStatusMap.get(pc);
            Boolean valid = true;
            Boolean hasRGE = false;
            Boolean hasValidRGE = false;
            for(String type : typeStatusSet.keySet()) {
                if(type.contains('cert_rge')) {
                    hasRGE = true;
                    if(typeStatusSet.get(type).contains('VALID')){
                        hasValidRGE = true;
                    }
                } else {
                    if(!typeStatusSet.get(type).contains('VALID')) {
                        valid = false;
                        break;
                    }
                }
            }
            pcToUpdate.add(new Prestation_Contact__c(id=pc, Statut__c = (valid && ((hasRGE && hasValidRGE) || !hasRGE)) ? 'POS' : 'NOT_POS'));
        }

        // Update Prestation Status :
        commitUpdatePC(pcToUpdate, '### HDAK evaluatePCStatuts_ForAllDocs: MAJ des prestation a echouée erreur : ');
    }

    /**
    * @description : Compte pro passe en proActif : alors verifier si ses prestations sont toutes positionnables
    * @author Hassan Dakhcha | 2/20/2020 
    * @param AccPutInProActifList : list des comptes qui on basculé en pro-Actif
    * @return void 
    **/
    public static void setAccToPos_NoCommit(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Map<id, Account> accMap = new Map<id, Account>();
        for(id acc : newMap.keySet()){
            if( oldMap.get(acc).Statut_activation__c != newMap.get(acc).Statut_activation__c && newMap.get(acc).Statut_activation__c == 'Pro_actif') {
                if(oldMap.get(acc).Statut_activation__c != 'Pro_actif_positionnable') {
                    accMap.put(acc, newMap.get(acc));
                } else if (UserInfo.getFirstName() == 'Project' && UserInfo.getLastName() == 'Place' && newMap.get(acc).Tech_ModifyBySalesforceTrigger__c == false) {
                    // filter the Project Place set to Actif if positionnable
                    newMap.get(acc).Statut_activation__c = 'Pro_actif_positionnable';
                }
            }
        }
  
        if(accMap.isEmpty()) {
            return;
        }
    
        List<Jointure_Documents_Prestations__c> jctList = [ SELECT id, Statut_prestations__c,Compte_Pro__c
                                                            FROM Jointure_Documents_Prestations__c
                                                            WHERE Compte_Pro__c IN : accMap.keySet()];  
        if(jctList.isEmpty()) {
            return;
        }
        Map<id, Set<String>>  idAccStatusMap = new Map<id, Set<String>>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            Set<String> statusSet = idAccStatusMap.get(jct.Compte_Pro__c);
            if(statusSet==null) {
                statusSet = new Set<String>();
                idAccStatusMap.put(jct.Compte_Pro__c, statusSet);
            }
            statusSet.add(jct.Statut_prestations__c);
        }
        // check the prestation status modify the
        for(Id accId : idAccStatusMap.keySet()) {
            Set<String> statusSet = idAccStatusMap.get(accId);
            if(statusSet.contains('Positionnable')) {
                accMap.get(accId).Statut_activation__c = 'Pro_actif_positionnable'; 
                accMap.get(accId).Date_client_positionnable__c=Datetime.now();
            }
        }
    }
/*
    public static void setAccToNonPos_Commit(Set<id> accSet) {
        // on met les pro en pro Actif seulement si le statut du pro est positionnable
        if(accSet.isEmpty()) {
            return;
        }
        Map<id, Account> accMap = new Map<id, Account>([SELECT id, Statut_activation__c 
                                                        FROM Account 
                                                        WHERE id IN:accSet AND Statut_activation__c='Pro_actif_positionnable']);
        
        List<Jointure_Documents_Prestations__c> jctList = [ SELECT id, Statut_prestations__c, Compte_Pro__c
                                                            FROM Jointure_Documents_Prestations__c
                                                            WHERE Compte_Pro__c IN : accMap.keySet()];  
        if(jctList.isEmpty()) {
            return;
        }

        Map<id, Set<String>>  idAccStatusMap = new Map<id, Set<String>>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            Set<String> statusSet = idAccStatusMap.get(jct.Compte_Pro__c);
            if(statusSet==null) {
                statusSet = new Set<String>();
                idAccStatusMap.put(jct.Compte_Pro__c, statusSet);
            }
            statusSet.add(jct.Statut_prestations__c);
        }
        // check the prestation status modify the
        List<Account> accToSetAsActif = new List<Account>();
        for(Id accId : idAccStatusMap.keySet()) {
            Set<String> statusSet = idAccStatusMap.get(accId);
            if(!statusSet.contains('POS')) {
                accToSetAsActif.add(new Account(id = accId, Statut_activation__c='Pro_actif'));
            }
        }
        if(!accToSetAsActif.isEmpty())
            commitUpdateAcc(accToSetAsActif, 'setAccToNonPos_Commit');
    }
*/
    public static void setAccSatutus_Commit(Set<id> ctcSet) {
        if(ctcSet.isEmpty()) 
            return;
        
        Map<id, Account> accMap = new Map<id, Account>([SELECT id, Statut_activation__c, Contact_principal__c
                                                        FROM Account 
                                                        WHERE 
                                                        Contact_principal__c IN:ctcSet 
                                                        AND 
                                                        (Statut_activation__c='Pro_actif_positionnable' 
                                                        OR Statut_activation__c='Pro_actif')]);
        if(accMap.isEmpty())
            return;

        List<Jointure_Documents_Prestations__c> jctList = [ SELECT id, Statut_prestations__c, Compte_Pro__c
                                                            FROM Jointure_Documents_Prestations__c
                                                            WHERE Compte_Pro__c IN : accMap.keySet()];  
        if(jctList.isEmpty()) 
            return;

        Map<id, Set<String>>  idAccStatusMap = new Map<id, Set<String>>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            Set<String> statusSet = idAccStatusMap.get(jct.Compte_Pro__c);
            if(statusSet==null) {
                statusSet = new Set<String>();
                idAccStatusMap.put(jct.Compte_Pro__c, statusSet);
            }
            statusSet.add(jct.Statut_prestations__c);
        }

        // check the prestation status modify the
        List<Account> accStatutModif = new List<Account>();
        for(Id accId : idAccStatusMap.keySet()) {
            Set<String> statusSet = idAccStatusMap.get(accId);
            if(!statusSet.contains('Positionnable') && accMap.get(accId).Statut_activation__c=='Pro_actif_positionnable') {
                accStatutModif.add(new Account(id = accId, Statut_activation__c='Pro_actif',Tech_ModifyBySalesforceTrigger__c=true));
            } else if(statusSet.contains('Positionnable') && accMap.get(accId).Statut_activation__c=='Pro_actif') {
                accStatutModif.add(new Account(id = accId, Statut_activation__c='Pro_actif_positionnable',
                                                Date_client_positionnable__c=Datetime.now()));
            }

        }
        if(!accStatutModif.isEmpty())
            commitUpdateAcc(accStatutModif, 'setAccSatutus_Commit');

    }

    /**
    * @description : evalue le passage du pro a positionnable lorsque le contact principal change
    *                Compte change sur un contact : Delete des Jonction Prest / Doc encien compte ,
    *                                               MAJ des jontcions des presta / nouveau doc du nouveau compte
    * @author Hassan Dakhcha | 2/20/2020 
    * @param oldMap 
    * @param newMap 
    * @return void 
    **/
    public static void evaluatePCOnContact(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        Map<id , id> accountMap = new Map<id ,id>();
        Set<id> contactSet = new Set<id>();
        for(id ctcId : newMap.keySet()) {
            if((oldMap.get(ctcId).Contact_Principal_O_N__c != newMap.get(ctcId).Contact_Principal_O_N__c) 
                && newMap.get(ctcId).Contact_Principal_O_N__c==true) {
              
                accountMap.put(newMap.get(ctcId).AccountId, ctcId);
                contactSet.add(ctcId);
            }
        }
        // delete old jonctions :
        List<Jointure_Documents_Prestations__c> jctListToDelete = [ SELECT id, Compte_Pro__c
                                                                    FROM Jointure_Documents_Prestations__c
                                                                    WHERE Compte_Pro__c IN : accountMap.keySet()]; 
        if(!jctListToDelete.isEmpty())
            commitDelete(jctListToDelete, 'evaluatePCOnContact: delete des jointure Presta/Doc a echouée erreur : ');
        
        // Upate contact principal on the Documents:
        List<Document__c> docList = [SELECT id, Contact_principal__c,Compte_Pro__c FROM Document__c WHERE Compte_Pro__c IN : accountMap.keySet()];
        for(Document__c doc : docList)
            doc.Contact_principal__c = accountMap.get(doc.Compte_Pro__c);
        if(!docList.isEmpty())
            MandatoryDocs_JctDocManager.commitUpdateDoc(docList, 'evaluatePCOnContact');

        // Create new jonctions :
        Map<id, Prestation_Contact__c> pcMap = new Map<id, Prestation_Contact__c> ([SELECT id, Tech_Liste_Doc_Obligatoires_PP__c, Contact__c
                                                                                    FROM Prestation_Contact__c
                                                                                    WHERE Contact__c IN :contactSet]);
        if(!pcMap.isEmpty()) {
            // create jonctions
            MandatoryDocs_Synthesizer.createJunctionAndNewDocs(pcMap.values());
            MandatoryDocs_StatusSetter.evaluatePCStatuts_ForAllPC(pcMap.keySet());
        }
    }

    // Commit the update
    public static void commitUpdatePC(List<Prestation_Contact__c> listToUpdate, String msg) {
        DataBase.SaveResult[] updateResults = DataBase.update(listToUpdate, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug(msg);                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Champs du compte origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }

     // Commit the update
     private static void commitUpdateAcc(List<Account> listToUpdate, String msg) {
        DataBase.SaveResult[] updateResults = DataBase.update(listToUpdate, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug(msg);                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Champs du compte origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }
    // Commit the delete
    private static void commitDelete(List<Jointure_Documents_Prestations__c> jctList, String msg) {
        DataBase.DeleteResult[] deleteResults = DataBase.delete(jctList, false);
        for(DataBase.DeleteResult res : deleteResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug(msg);                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Champs du compte origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }
}