/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 01-17-2021
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   01-14-2021   Hassan Dakhcha   Initial Version
**/
public with sharing class Code_RGE_Qualibat_Methods {

    @invocableMethod(Label ='Créer les codes RGE Qualibat')
    public static List<String> addRGECodes(List<String> codes) {
        List<String> results = new List<String>();
        if(codes.isEmpty()) {
            results.add('Aucun code saisie !');
            return results;
        }
		
        Map<id, Set<String>> docCodesMap = new Map<id, Set<String>>();
        Set<String> fullSet = new Set<String>();
        Set<String> fullSetUnsonsored = new Set<String>();
        for(String arg : codes) {
            List<String> codeList = codes[0].split(';');
            if(codeList==null || codeList.isEmpty() || codeList[0]=='' || codeList.size()<2) {
                continue;
            }
            Id documentID = codeList[0];
            codeList.remove(0); // remove record ID
            Set<String> codeSet = new Set<String>();
            for(String str : codeList) {
                fullSetUnsonsored.add(str);
                if(str!=null && str!='' && str.isNumeric()) {
                    codeSet.add(str);
                } 
            }
            docCodesMap.put(documentID, codeSet);
            fullSet.addAll(codeSet);
        }
        Map<id,Reference__c> refMap = new Map<id, Reference__c>([SELECT id, sku__c FROM Reference__c
                                                                 WHERE sku__c IN :fullSet 
                                                                 AND recordType.DeveloperName='Codes_RGE_Qualibat']);
        if(refMap.isEmpty()) {
            results.add('Le(s) code(s) : ' + fullSetUnsonsored + ' ne sont pas valides ou n\'existent pas dans le référentiel!');
            return results;
        }
        
        Map<String, id> codeRefMap = new Map<String, id>();
        for(id ref : refMap.keySet()) {
            codeRefMap.put(refMap.get(ref).sku__c, refMap.get(ref).id);
            fullSetUnsonsored.remove(refMap.get(ref).sku__c);
        }
        // contacts found attach them to the agence if needed
        List<Code_Certif_RGE_Qualibat__c> jointList = [SELECT ID,Document__c,Code_RGE__c  FROM Code_Certif_RGE_Qualibat__c 
                                                        WHERE Code_RGE__c IN :refMap.keySet() AND Document__c=:docCodesMap.keySet()];
        if(!jointList.isEmpty()) {
            for(Code_Certif_RGE_Qualibat__c jnt : jointList) {
                docCodesMap.get(jnt.document__c).remove(refMap.get(jnt.Code_RGE__c).sku__c);
            }
        }

        List<Code_Certif_RGE_Qualibat__c> joinToInsert = new List<Code_Certif_RGE_Qualibat__c>();
        // Existing Email not attached :
        for(id doc : docCodesMap.keySet()) {
            Set<String> codeSet = docCodesMap.get(doc);
            for(String code : codeSet) {
                joinToInsert.add(new Code_Certif_RGE_Qualibat__c(document__c=doc, code_rge__c=codeRefMap.get(code)));
            }
        }
        
        if(!joinToInsert.isEmpty()) {
            database.insert(joinToInsert, false);
        }
        if(!fullSetUnsonsored.isEmpty()) {
        	results.add('Le(s) code(s) : ' + fullSetUnsonsored + ' ne sont pas valides ou n\'existent pas dans le référentiel!');
        } else {
            results.add('Tous les codes ont été ajoutés!');
        }
        
        return results;
    }

    // JSON
    public Class JsonCodes {
        public List<String> codes;
        public JsonCodes(List<String> ls)  { codes = ls;}
    }

    public static void handleCodes(List<Code_Certif_RGE_Qualibat__c> codeList, Boolean isUpdate) {
        // We do not allow update on codes you need to delete them
        if(isUpdate) {
            for(Code_Certif_RGE_Qualibat__c elem : codeList) {
                elem.addError('Vous ne pouvez pas modifier les code de qualification, Merci de le supprimer et de creer un nouveau');
            }
            return;
        }

        // Reevaluate codes on the document :
        Set<Id> documentSet = new Set<Id>();
        for(Code_Certif_RGE_Qualibat__c elem : codeList) {
            documentSet.add(elem.document__c);
        }

        List<Code_Certif_RGE_Qualibat__c> fullCodeList = [SELECT ID, document__c, Code_RGE__r.sku__c FROM Code_Certif_RGE_Qualibat__c WHERE Document__c IN :documentSet];
        Map<id, Set<String>> docCodeMap = new Map<id, Set<String>>();
        for(Code_Certif_RGE_Qualibat__c elem : fullCodeList) {
            Set<String> cSet = docCodeMap.get(elem.document__c);
            if(cSet==null) {
                cSet = new Set<String>();
                docCodeMap.put(elem.document__c, cSet);
            }
            cSet.add(elem.Code_RGE__r.sku__c);
        }

        // for each document analyze update the code list :
        List<Document__c> docToUpdate = new List<Document__c>();
        for(id doc : documentSet) {
            if(!docCodeMap.containsKey(doc)) {
                docToUpdate.add(new Document__c(id = doc, Details__c= '{"codes":[]}'));
            } else {
                JsonCodes jc = new JsonCodes(new List<String>(docCodeMap.get(doc)));
                docToUpdate.add(new Document__c(id = doc, Details__c= JSON.serialize(jc)));
            }
        }

        if(!docToUpdate.isEmpty()) {
            database.update(docToUpdate, false);
        }
    }

    public static void processCodes(List<Document__c> docList, Map<id, Document__c> oldMap) {
        if(UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place') {
            return;
        }

        Map<id, List<String> > docCodesMap = new Map<id, List<String>>();
        Set<String> codeSet = new Set<String>();
        JsonCodes codeObj;
        for(Document__c doc : docList) {
            // New record :
            codeObj = null;
            if(oldMap==null) {
                if(doc.details__c!=null) {
                    codeObj = (JsonCodes)JSON.deserialize(doc.details__c, JsonCodes.class);
                }
            } else if(doc.details__c!= null && doc.details__c!=oldMap.get(doc.id).details__c) {
                codeObj = (JsonCodes)JSON.deserialize(doc.details__c, JsonCodes.class);
            }
            if(codeObj!=null) {
                docCodesMap.put(doc.id, codeObj.codes);
                codeSet.addAll(codeObj.codes);
            }
        }
        
        if(docCodesMap.isEmpty()) {
            return;
        }
        
        Map<id, List<Code_Certif_RGE_Qualibat__c>> docRgeMap = new Map<id, List<Code_Certif_RGE_Qualibat__c>>();
        if(oldMap!=null) {
            List<Code_Certif_RGE_Qualibat__c> rgeCodes = new List<Code_Certif_RGE_Qualibat__c> ();
            rgeCodes = [ SELECT ID, Document__c, Code_RGE__c, Code_RGE__r.sku__c  FROM Code_Certif_RGE_Qualibat__c 
                         WHERE Document__c IN : docCodesMap.keySet()];

            for(Code_Certif_RGE_Qualibat__c code : rgeCodes) {
                List<Code_Certif_RGE_Qualibat__c> codeList = docRgeMap.get(code.Document__c);
                if(codeList==null) {
                    codeList = new List<Code_Certif_RGE_Qualibat__c>();
                    docRgeMap.put(code.Document__c, codeList);
                }
                codeList.add(code);
            }
        }

        Map<String, id> codeRefMap = new Map<String,Id>();
        if(!docCodesMap.values().isEmpty()) {
            List<Reference__c> refList = [SELECT id, sku__c FROM Reference__c WHERE sku__c IN:codeSet AND recordType.developerName = 'Codes_RGE_Qualibat'];
            for(Reference__c ref : refList) {
                codeRefMap.put(ref.sku__c, ref.id);
            }
        }
        
        // Skip existing codes and or remove others :
        List<Code_Certif_RGE_Qualibat__c> insertList = new List<Code_Certif_RGE_Qualibat__c>();
        List<Code_Certif_RGE_Qualibat__c> deleteList = new List<Code_Certif_RGE_Qualibat__c>();
        for(id doc : docCodesMap.keySet()) {
            List<String> newCodes = docCodesMap.get(doc);
            if(oldMap==null) { // insert just add codes
                List<String> codeList = docCodesMap.get(doc);
                for(String codeNum : codeList) {
                    insertList.add(new Code_Certif_RGE_Qualibat__c(document__c = doc, Code_RGE__c = codeRefMap.get(codeNum)));
                }
            } else {
                // create only the non existing
                List<Code_Certif_RGE_Qualibat__c> existingCodes = docRgeMap.get(doc);
                List<String> codeList = docCodesMap.get(doc);
                Set<String> addSet = new Set<String>();
                for(String codeNum : codeList) {
                    addSet.add(codeNum);
                }
                if(existingCodes!=null) {
                    for(Code_Certif_RGE_Qualibat__c actCode : existingCodes) {
                        if(codeList.contains(actCode.Code_RGE__r.sku__c)) {
                            addSet.remove(actCode.Code_RGE__r.sku__c);
                        } else {
                            deleteList.add(actCode);
                        }
                    }
                }
                for(String codeNum : addSet) {
                    insertList.add(new Code_Certif_RGE_Qualibat__c(document__c = doc, Code_RGE__c = codeRefMap.get(codeNum)));
                }
            }
        }

        if(!insertList.isEmpty()) {
            Database.insert(insertList, false);
        }
        if(!deleteList.isEmpty()) {
            Database.delete(deleteList, false);
        }
    }
}