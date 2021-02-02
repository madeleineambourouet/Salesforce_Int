/**
* @author Hassan Dakhcha
* @date 30/12/2019
* @description : MandatoryDoecs : Synthesizer : Calcul est MAJ Doc Obligatoire sur le compte  
*                Si Insert/Update sur la Prestation Contact   
*                Si la modification du compte sur le Contact   
* Test : MandatoryDocumentsTest
**/   
public class MandatoryDocs_Synthesizer {
    
    /**
    * @description : Fonction utlisée par le flow de rajout de prestations
    * @author Hassan Dakhcha 2/11/2020 
    * @param inputList : (contactId, key1, key2, ...)
    * @return List<String> : 'SUCCESS' 'Error'
    **/
    @invocableMethod
    public static List<String> injectPrestationContact(List<String> inputList) {
        
        // InputList contient la liste des noms des prestations
        List<String> results = new List<String> ();
        if(inputList.isEmpty()) {
            results.add('Error');
            return results;
        }
        //System.debug('#### HDAK list input : ' + inputList);
        
        List<String> splitedList = new List<String> (inputList[0].split(';'));
        String ctcId = splitedList.remove(0);
        Set<String> keySet = new Set<String> ();
        for(String str : splitedList)   
            keySet.add(str.trim());
        
        List<reference__c> refList = [SELECT id, key__c FROM reference__c WHERE key__c IN :keySet ];
        List<Prestation_Contact__c> PCList = new List<Prestation_Contact__c> ();
        for(reference__c ref : refList) {
            PCList.add(new Prestation_Contact__c( Contact__c = ctcId, Prestation__c = ref.id ,  Cle_Prestation__c = ref.key__c));
            
        }
        
        DataBase.SaveResult[] insertResults = DataBase.insert(PCList, false);
        for(DataBase.SaveResult res : insertResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK checkAllDocuments :  MAJ des document a echouée erreur : ');                   
                    System.debug('### HDAK ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs du document origine de l\'erreur : ' + err.getFields());
                    results.add(err.getMessage());
                }
            }
        }

        if(results.isEmpty())
            results.add('Success');
        return results;     
    }
    
    // Method : initAtInsert
    // Description : At insert of prestation_Contact init their mandatory documents list and statut
    //
   
    public static void setDocList(List<Prestation_Contact__c> pcList) {
        Set<Id> setPrestaRef = new Set<Id> ();
        for(Prestation_Contact__c pc : pcList) {
                setPrestaRef.add(pc.Prestation__c);
        }
        // get the mandatory doc list from ref :
        Map<Id, reference__c> prestationRefMap= new Map<id, Reference__c> ([SELECT id , Document_obligatoire__c 
                                                                            FROM reference__c
                                                                            WHERE id IN :setPrestaRef]);
        for(Prestation_Contact__c pc : pcList) {
            Reference__c prestRef = prestationRefMap.get(pc.Prestation__c);
            //pc.Statut__c = 'NON POS';
            if(prestRef == null) {
                pc.Tech_Liste_Doc_Obligatoires_PP__c = '';
            } else {
                pc.Tech_Liste_Doc_Obligatoires_PP__c = prestRef.Document_obligatoire__c;
            }
        }
    }

    public static void createJunctionAndNewDocs(List<Prestation_Contact__c> pcList) {
        // get all Doc types 
        Map<Id, Set<String>> allDocTypesMap = new Map<Id, Set<String>>();
        Set<id> ctcPrincipalSet = new Set<id>();
        for(Prestation_Contact__c pc : pcList) {
            if(pc.Tech_Liste_Doc_Obligatoires_PP__c==null || pc.Tech_Liste_Doc_Obligatoires_PP__c=='')
                continue;
                
            allDocTypesMap.put(pc.id, new Set<String> (pc.Tech_Liste_Doc_Obligatoires_PP__c.split(';')));
            ctcPrincipalSet.add(pc.Contact__c);
        }
        System.debug('### HDAK PC/Doctype' + allDocTypesMap);
        
        // Query the documents related to the contact principal
        List<Document__c> documentList = [SELECT id, Compte_Pro__c, Type_de_document__c, Statut__c,
                                         Statut__r.key__c, Obligatoire_Presta__c, Contact_principal__c
                                         FROM Document__c 
                                         WHERE Contact_principal__c IN :ctcPrincipalSet];

        List<Jointure_Documents_Prestations__c> existingJctList = [ SELECT id, Prestation__c, Document__c
                                                                    FROM Jointure_Documents_Prestations__c WHERE Prestation__c IN :pcList];
        Map<id, List<Jointure_Documents_Prestations__c>> mapExistingPrestJonctions = new Map<id, List<Jointure_Documents_Prestations__c>>();
        for(Jointure_Documents_Prestations__c jct : existingJctList) {
            List<Jointure_Documents_Prestations__c> jctList = mapExistingPrestJonctions.get(jct.Prestation__c);
            if(jctList==null) {
                jctList = new List<Jointure_Documents_Prestations__c>();
                mapExistingPrestJonctions.put(jct.Prestation__c, jctList);
            }
            jctList.add(jct);
        }

        // order docs by ctc_principal
        Map<Id, List<Document__c>> CtcDocMap = new Map<Id, List<Document__c>>();
        for(Document__c doc : documentList) {
            List<Document__c> listDoc = CtcDocMap.get(doc.Contact_principal__c);
            if(listDoc == null) {
                listDoc = new List<Document__c>();
                CtcDocMap.put(doc.Contact_principal__c, listDoc);
            }
            listDoc.add(doc);
        }
        System.debug('### HDAK doc map' + CtcDocMap);
        // Join PC to it's doc types
        List<Jointure_Documents_Prestations__c> PcDocJonction = new List<Jointure_Documents_Prestations__c>();
        Map< id, List<Document__c>>  newPcDocMap= new Map<id, List<Document__c>>();
        reference__c docManquant =null;
        if(Test.isRunningTest()) {
            List<Reference__c> docM = [SELECT id FROM reference__c WHERE Key__c = 'MISSING' AND recordType.DeveloperName = 'Statut_Document'];
            if(docM == null || docM.size() == 0 ) {
                docManquant= TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant');
            } else {
                docManquant = docM[0];
            }
        } else {
            docManquant = [SELECT id FROM reference__c WHERE Key__c = 'MISSING' AND recordType.DeveloperName = 'Statut_Document'];
        }
        Map<Id, Contact> listContactPrincipal = new Map<Id, Contact> ([SELECT id, AccountId FROM Contact WHERE id IN :ctcPrincipalSet]);

        List<Document__c> flagDocsAsMandatory = new List<Document__c>();
        Map<String, List<id>> DocTypeToBeCreated = new Map<String, List<id>>();
        for(Prestation_Contact__c pc : pcList) {
            Set<String> docTypes = allDocTypesMap.get(pc.Id);
            if(docTypes == null)
                continue;

            List<Document__c> docList = CtcDocMap.get(pc.Contact__c);
            //System.debug('### HDAK doc types 1 = ' + docTypes);

            if(docList!=null) {
                Set<String> existingTypes = new Set<String>();
                for(Document__c doc : docList) {
                    if(docTypes.contains(doc.Type_de_document__c)) {

                        // check if the jonction exists :
                        Boolean skip = false;
                        List<Jointure_Documents_Prestations__c> jctList = mapExistingPrestJonctions.get(pc.id);
                        if(jctList!=null) {
                            for(Jointure_Documents_Prestations__c jct : jctList) {
                                if(jct.Document__c == doc.id) {
                                    skip = true;
                                }
                            }
                        }
                        
                        if(skip==false) {
                            PcDocJonction.add(new Jointure_Documents_Prestations__c(Prestation__c = pc.id, Document__c = doc.id,
                                                                                    document_id_indexed__c = doc.id,
                                                                                    Type_de_document_value__c = doc.Type_de_document__c));
                        }
                        existingTypes.add(doc.Type_de_document__c);
                        if(doc.Obligatoire_Presta__c==false) {
                            doc.Obligatoire_Presta__c = true;
                            flagDocsAsMandatory.add(doc);
                        }
                    }
                }
                docTypes.removeAll(existingTypes);
            }
            for(String tobeCreatedType : DocTypeToBeCreated.keySet()) {
                if(docTypes.contains(tobeCreatedType)) {
                    DocTypeToBeCreated.get(tobeCreatedType).add(pc.id);
                    docTypes.remove(tobeCreatedType);
                }
            }

            //System.debug('### HDAK doc types 2 = ' + docTypes);
            // Create document for the remaining document types
            List<Document__c> newDocList = newPcDocMap.get(pc.id);
            if(newDocList ==null) {
                newDocList = new List<Document__c>();
                newPcDocMap.put(pc.id, newDocList);
            }
            for(String docType : docTypes) {
                Document__c nDoc = new Document__c( Compte_Pro__c = listContactPrincipal.get(pc.Contact__c).AccountId, 
                                                    Contact_principal__c = pc.Contact__c,
                                                    Obligatoire_Presta__c = true,
                                                    Type_de_document__c = docType,
                                                    Statut__c = docManquant.Id);
                newDocList.add(nDoc);

                List<id> listPC = DocTypeToBeCreated.get(docType);
                if(listPC==null) {
                    listPC = new List<id>();
                    DocTypeToBeCreated.put(docType, listPC);
                }
            }
        }
        System.debug('### HDAK newDoc number = ' + newPcDocMap.size());
        List<Document__c> fullList = new List<Document__c>();
        for(id pcId : newPcDocMap.keySet())
           fullList.addAll(newPcDocMap.get(pcId));

        System.debug('### HDAK fullList = ' + fullList);

        DataBase.SaveResult[] insertDocResults = DataBase.insert(fullList, false);
        for(DataBase.SaveResult res : insertDocResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  :  creation des document a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs du document origine de l\'erreur : ' + err.getFields());
                }
            }
        }
        
        for(Document__c doc : fullList) {
            List<id> pcL = DocTypeToBeCreated.get(doc.Type_de_document__c);
            if(pcL!=null && !pcL.isEmpty()) {
                for(id pcId : pcL ) {
                   // System.debug('### HDAK  1 :  adding JCT <pcid , docType > : ' + pcId + ' ' + doc.Type_de_document__c + ' id ' + doc.id );   
                    PcDocJonction.add(new Jointure_Documents_Prestations__c(Prestation__c = pcId, Document__c = doc.id,
                                                                            document_id_indexed__c = doc.id,
                                                                            Type_de_document_value__c = doc.Type_de_document__c));
                }
            }
        }

        // add jonction for the new documents
       for(id pcId : newPcDocMap.keySet()) {
            List<Document__c> docList = newPcDocMap.get(pcId);
            for(Document__c doc : docList) {
               // System.debug('### HDAK  :  adding JCT <pcid , docType > : ' + pcId + ' ' + doc.Type_de_document__c + ' id ' + doc.id );   
                PcDocJonction.add(new Jointure_Documents_Prestations__c(Prestation__c = pcId, Document__c = doc.id, 
                                                                        document_id_indexed__c = doc.id,
                                                                        Type_de_document_value__c = doc.Type_de_document__c));
            }
        }
        if(!PcDocJonction.isEmpty())
            MandatoryDocs_JctDocManager.commitInsertJct(PcDocJonction, 'createJunctionAndNewDocs');

        if(!flagDocsAsMandatory.isEmpty())
            MandatoryDocs_JctDocManager.commitUpdateDoc(flagDocsAsMandatory, 'createJunctionAndNewDocs');
    }
    
}