/**
* @author Hassan Dakhcha
* @date 31/12/2019
* @description :  Mandatory Documents  : MAJ de l'objet Document et gestion de la jointure :
*                 Doc Insert : la class le tope Obligatoire si necessaire                        
*                 Doc delete : la classe relance la verification du Compte                         
*                 Doc non existant : la classe cree des docs obligatoire vide                      
*                 Doc update : Si type de doc change alors revalue si il est obligatoire 
*                 
* Test : MandatoryDocumentsTest
**/   

public class MandatoryDocs_JctDocManager {
    
    /**
    * @description at insert of a document analyze and join it with prestations
    * @author hassan dakhcha | 2/21/2020 
    * @param docList 
    * @return void 
    **/
    public static void docInserted(List<Document__c> docList) {
        List<Reference__c> docM = [SELECT id FROM reference__c WHERE Key__c = 'MISSING' AND recordType.DeveloperName = 'Statut_Document'];
        if(docM == null || docM.isEmpty())
            return;

        Map<id, List<Document__c>> ctcDocMap = new Map<id, List<Document__c>>();
        for(Document__c doc : docList) {
            if(doc.Statut__c == docM[0].id || doc.Type_de_document__c == null || doc.Type_de_document__c == '')
                continue;

            List<Document__c> dl = ctcDocMap.get(doc.Contact_principal__c);
            if(dl == null) {
                dl = new List<Document__c>();
                ctcDocMap.put(doc.Contact_principal__c, dl);
            }
            dl.add(doc);
        }

        if(ctcDocMap.isEmpty())
            return;

        // Analyze the type de document VS prestation mandatory docs 
        List<Prestation_Contact__c> PCList = [SELECT id, Tech_Liste_Doc_Obligatoires_PP__c, Contact__c, Prestation__c, Prestation__r.Surcategorie__c
                                              FROM Prestation_Contact__c
                                              WHERE Contact__c IN :ctcDocMap.keySet()   
                                              AND Tech_Liste_Doc_Obligatoires_PP__c !=''    
                                              AND Prestation__r.Surcategorie__c !='' ]; // filtrer les catégories   
    
        if(PCList.isEmpty())                                 
            return;

        Map<id, List<Prestation_Contact__c>> ctcPCMap = new Map<id, List<Prestation_Contact__c>>();
        for(Prestation_Contact__c pc : PCList) {
            List<Prestation_Contact__c> pcl = ctcPCMap.get(pc.Contact__c);
            if(pcl == null) {
                pcl = new List<Prestation_Contact__c>();
                ctcPCMap.put(pc.Contact__c, pcl);
            }
            pcl.add(pc);
        }
        // Map Prestation Contact vers Set<type de doc obligatoire>
        Map<id , Set<String>> pcDocTypeMap = new Map<id , Set<String>>();
        for(Prestation_Contact__c pc : PCList) {
            if(pc.Tech_Liste_Doc_Obligatoires_PP__c==null || pc.Tech_Liste_Doc_Obligatoires_PP__c=='')
                continue;
                
            Set<String> setDoc = pcDocTypeMap.get(pc.id);
            if(setDoc == null){
                setDoc = new Set<String> ();
                pcDocTypeMap.put(pc.id, setDoc);
            }
            setDoc.addAll(pc.Tech_Liste_Doc_Obligatoires_PP__c.split(';'));
        }

        // iter on each doc and check PC of its account
        Map<id, String> docTypeMap = new Map<id, String>();
        Map<id, id> pcDocMap = new Map<id, id>();
        Set<id> docNeededByPrestaSet = new Set<id>();
        for(id ctc : ctcDocMap.keySet()) {
            List<Prestation_Contact__c> presList = ctcPCMap.get(ctc);
            if(presList == null)
                continue;
            for(Document__c doc : ctcDocMap.get(ctc)) {
                for(Prestation_Contact__c pc : presList) {
                    if(pcDocTypeMap.get(pc.id).contains(doc.Type_de_document__c)) {
                        pcDocMap.put(pc.id, doc.id);
                        docNeededByPrestaSet.add(doc.id);
                        docTypeMap.put(doc.id, doc.Type_de_document__c);
                    }
                }
            }
        }

        List<Jointure_Documents_Prestations__c> jctList = new List<Jointure_Documents_Prestations__c>();
        for(id pcId : pcDocMap.keySet()) {
            jctList.add(new Jointure_Documents_Prestations__c(prestation__c = pcId,  document__c = pcDocMap.get(pcId),
                                                              document_id_indexed__c =  pcDocMap.get(pcId),
                                                              Type_de_document_value__c = docTypeMap.get(pcDocMap.get(pcId)))); 
        }
        if(!jctList.isEmpty())
            commitInsertJct(jctList, 'MandatoryDocs_JctDocManager::docInserted');

        List<Document__c> docToUpdate = new List<Document__c>();
        for(id docNeeded : docNeededByPrestaSet) {
            docToUpdate.add(new Document__c(id = docNeeded, Obligatoire_Presta__c = true));
        }
        commitUpdateDoc(docToUpdate, 'MandatoryDocs_JctDocManager::docInserted');

    }
 
    /**
    * @description : type de document change sur un document : called from Jonction trigger
    *                MAJ les jonctions et révaluer le positionnement des prestations
    * @author hassan dakhcha | 2/24/2020 
    * @param docList 
    * @return void 
    **/
    public static void docTypeChanged(set<id> docSet) {
        List<Jointure_Documents_Prestations__c> jctList = [SELECT id, prestation__c, document__c,Tech_Liste_Doc_Obligatoires__c,Type_de_document__c, Type_de_document_value__c
                                                           FROM Jointure_Documents_Prestations__c
                                                            WHERE document__c IN :docSet];
        
        Set<String> docObligTypes = new Set<String>();
        Set<id> pcSet = new Set<id>();
        List<Jointure_Documents_Prestations__c> jctToRemoveList = new List<Jointure_Documents_Prestations__c>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            String docOblig = jct.Tech_Liste_Doc_Obligatoires__c;
            if(docOblig == null || docOblig == '') {
                // remove the jonction
                jctToRemoveList.add(jct);
            } else {
                docObligTypes.addAll(docOblig.split(';'));
                if(!docObligTypes.contains(jct.Type_de_document__c)) {
                    jctToRemoveList.add(jct);
                } else {
                    jct.Type_de_document_value__c = jct.Type_de_document__c;
                }
                docObligTypes.clear();
            }
            pcSet.add(jct.Prestation__c);
        }
        // delete jonctions
        if(!jctToRemoveList.isEmpty())
            commitDeleteJct(jctToRemoveList, 'MandatoryDocs_JctDocManager::docTypeChanged');

        // Update the list of PC :
        List<Prestation_Contact__c> pcList =  [ SELECT id, Tech_Liste_Doc_Obligatoires_PP__c, Contact__c
                                                FROM Prestation_Contact__c Where id IN :pcSet];

        MandatoryDocs_Synthesizer.createJunctionAndNewDocs(pcList);
        
        //run the analysis :
        MandatoryDocs_StatusSetter.evaluatePCStatuts_ForAllPC(pcSet);
    }
    
    /**
    * @description : called from the document trigger when a document is deleted
    * @author Hassan Dakhcha | 2/24/2020 
    * @param docMap 
    * @return void 
    **/
    public static void docDeleted(Map<id, Document__c> docMap) {
        Set<id> docIdsSet = new Set<id> ();
        for(id doc : docMap.keySet()) {
            docIdsSet.add(doc);
        }
        List<Jointure_Documents_Prestations__c> jctList = [ SELECT id, prestation__c, document__c
                                                            FROM Jointure_Documents_Prestations__c
                                                            WHERE document_id_indexed__c IN :docIdsSet]; 

        if(jctList.isEmpty())
            return;
        Set<id> pcSet = new Set<id>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            pcSet.add(jct.Prestation__c);
        }
        // delete the jonctions :
        commitDeleteJct(jctList, 'MandatoryDocs_JctDocManager::docDeleted');

        List<Prestation_Contact__c> pcList = [SELECT id, Tech_Liste_Doc_Obligatoires_PP__c,
                                              Contact__c
                                             FROM Prestation_Contact__c WHERE id IN:pcSet];
    
        MandatoryDocs_Synthesizer.createJunctionAndNewDocs(pcList);
        MandatoryDocs_StatusSetter.evaluatePCStatuts_ForAllPC(pcSet);
    }

    public static void docStatusChanged(Set<id> docSet) {
        // triatement des Jonction dont les doc passe a VALIDATED :
        List<Jointure_Documents_Prestations__c> jctList = [SELECT id, prestation__c, document__c,Tech_Liste_Doc_Obligatoires__c,Type_de_document__c
                                                           FROM Jointure_Documents_Prestations__c
                                                            WHERE document__c IN :docSet];
  
        Set<id> pcSet = new Set<id>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            pcSet.add(jct.Prestation__c);
        }
        //System.debug('###### HDAK docStatusChanged pcSet' + pcSet);
        MandatoryDocs_StatusSetter.evaluatePCStatuts_ForAllPC(pcSet);
    }

    public static void pcDeleted(Map<id, Prestation_Contact__c> pcMap) {
        List<Jointure_Documents_Prestations__c> jctList = [SELECT id, prestation__c, Statut_prestations__c, Document__c
                                                           FROM Jointure_Documents_Prestations__c
                                                           WHERE prestation__c IN :pcMap.keySet()];
                                                            
        Set<id> ctcSet = new Set<id>();
        Set<id> fullDocSet = new Set<id>();
        for(Jointure_Documents_Prestations__c jct : jctList) {
            if(jct.Statut_prestations__c== 'Positionnable')
                ctcSet.add(pcMap.get(jct.Prestation__c).Contact__c);

            // get the full doc List
            fullDocSet.add(jct.Document__c);
        }
        // delete the jonctions :
        commitDeleteJct(jctList, 'MandatoryDocs_JctDocManager::pcDeleted');

        // if the document is not referenced by an other PC then reset the flag 'Obligatoire pour cetaines presta'
        List<Jointure_Documents_Prestations__c> jctListDoc = [SELECT id, Document__c
                                                              FROM Jointure_Documents_Prestations__c
                                                              WHERE Document__c IN :fullDocSet];
        Set<id> docToReset = new Set<id>(fullDocSet);
        for(Jointure_Documents_Prestations__c jct : jctListDoc) {
            if(fullDocSet.contains(jct.Document__c)){
                docToReset.remove(jct.Document__c);
            }
        }
        
        if(!docToReset.isEmpty()){
            List<Document__c> updateDocList = new List<Document__c>();
            for(id doc : docToReset) {
                updateDocList.add(new Document__c(id=doc, Obligatoire_Presta__c = false));
            }
            commitUpdateDoc(updateDocList, 'MandatoryDocs_JctDocManager::pcDeleted');
        }
        // evaluate Account 
        MandatoryDocs_StatusSetter.setAccSatutus_Commit(ctcSet);
    }


    public static void purgeJonction(Set<id> pcSet) {
        List<Jointure_Documents_Prestations__c> jcList = [SELECT id , Prestation__c
                                                          FROM Jointure_Documents_Prestations__c
                                                          WHERE Prestation__c IN : pcSet];

        commitDeleteJct(jcList, 'purgeJonction');
    }

    public static void commitDeleteJct(List<Jointure_Documents_Prestations__c> jctList, String fct) {
        //System.debug('#### HDAK deleting JCT List = ' + jctList);
        DataBase.DeleteResult[] deleteResults = DataBase.delete(jctList, false);
        for(DataBase.DeleteResult res : deleteResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : ' + fct + ' delete des jonctions a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }

    public static void commitInsertJct(List<Jointure_Documents_Prestations__c> jctList, String fct) {
        //System.debug('#### HDAK inserting JCT List = ' + jctList);
        //System.debug('#### HDAK inserting num JCT = ' + jctList.size());

        DataBase.SaveResult[] insertResults = DataBase.insert(jctList, false);
        for(DataBase.SaveResult res : insertResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : ' + fct + ' creation des jonctions a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }
    public static void commitUpdateDoc(List<Document__c> docList, String fct) {
        DataBase.SaveResult[] updateResults = DataBase.update(docList, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : ' + fct + ' update de docuements a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }
}