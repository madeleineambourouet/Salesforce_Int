/**
 * @File Name          : PrestationContactMethods.cls
 * @Description        : handels some logic for prestation contact object
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-30-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/26/2019       Hassan Dakhcha          Initial Version
**/

public class PrestationContactMethods {
     
    // Set update flag
    public static void setIsUpdatedBySF(List<Prestation_Contact__c> pcList) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(Prestation_Contact__c pc : pcList) {
            // Transaction id for synchro :
            pc.tech_transaction_id__c = transaction_id;
            pc.last_updated_by_sf__c = sfUser;
        }
    }

    // Method : AttachHKConnectPCToContact
    // Test Method : HerokuConnectTest
    // Description : Methode qui verifie si la prestation contact va etre cree par HK Connect et si il n est pas attaché a un contact
    //               elle cherche alors le contact par l'adresse email et le rattache dessus.
    //               (pour plus de details cf : https://confluence.pointp.saint-gobain.net/display/HYB/Synchronisation+PP+%3C--%3E+Replicapp%3C--%3E+Salesforce ) 
    //               
    public static void AttachHKConnectPCToContact(List<Prestation_Contact__c> PCList) {
        
        if( UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place') {
            return;
        }
        //System.debug('### HDAK : attaching Prestation contact to correct contact');
        
        Set<String> emails = new Set<String>();
        for(Prestation_Contact__c pc : PCList) {
            pc.last_updated_by_sf__c = false;
            if(pc.Contact__c == null && pc.Email_cle_prestation__c != '') 
                emails.add((pc.Email_cle_prestation__c).substringBeforeLast('_'));
        }
        //System.debug('### HDAK : email Set =' + emails);                    
        
        Map<String, Id> mapEmailContactId = new Map<String, Id> ();
        for(Contact ct : [SELECT id, Email__c FROM Contact Where Email__c IN :emails] )
            mapEmailContactId.put(ct.Email__c, ct.id);
        
        for(Prestation_Contact__c pc : PCList) {
            if(pc.Contact__c == null && pc.Email_cle_prestation__c != '') {
                pc.Contact__c = mapEmailContactId.get((pc.Email_cle_prestation__c).substringBeforeLast('_'));
               //System.debug('### HDAK : Attached Prestation contact '+ pc.Email_cle_prestation__c + ' To contact ' + pc.Contact__c);
            }
        }
    }

    public static void initKey(List<Prestation_Contact__c> PCList) {
        Set<Id> contactSet = new Set<Id> ();
        Set<Id> prestaRefSet = new Set<Id> ();
        for(Prestation_Contact__c pc : PCList) {    
            contactSet.add(pc.Contact__c);
            prestaRefSet.add(pc.Prestation__c);
        }
        if(contactSet.isEmpty() || prestaRefSet.isEmpty())
            return;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT id , Email, Fire_Trigger__c FROM Contact WHERE id IN :contactSet]);
        Map<Id, Reference__c> refMap = new Map<Id, Reference__c>([SELECT id, key__c FROM Reference__c WHERE Id IN :prestaRefSet]);
        Datetime now = Datetime.now();
        
        for(Prestation_Contact__c pc : PCList) {    
            contact ctc = contactMap.get(pc.Contact__c);
            Reference__c ref = refMap.get(pc.Prestation__c);
            if(ctc!=null && ref!=null) {
                pc.Email_cle_prestation__c = ctc.Email + '_' + ref.key__c;
            }
            //system.debug('#### HDAK email_cle_presta: '+pc.Email_cle_prestation__c);
            if(ctc!=null && ctc.Fire_Trigger__c != null)
                pc.Fire_Trigger__c = now;
        }
    }

    // Called by the delete trigger ; We want to delete all PC with same PSKU:
    public static void deleteSamePSKU(Set<id> PCTodelete) {
        if(!RecursiveTriggerHandler.isFirstTime)
            return;
        
        RecursiveTriggerHandler.isFirstTime = false;
        // Must query prestation__r.sku__c !!
        List<Prestation_Contact__c> pcList = [SELECT prestation__r.sku__c, contact__c FROM Prestation_Contact__c WHERE id IN : PCTodelete];

        Set<String> deletedSet = new Set<String>();
        Set<id> ids = new Set<id>();
        Set<id> ctcIds = new Set<id>();
        for(Prestation_Contact__c pc : pcList) {
            //system.debug('#### HDAK : ' + pc.prestation__r.sku__c);
            if(pc.prestation__r.sku__c!=null && pc.prestation__r.sku__c!='') {
                deletedSet.add(pc.prestation__r.sku__c);
            }
            ids.add(pc.id);
            ctcIds.add(pc.contact__c);
        }

        pcList.clear();
        pcList = [  SELECT id, prestation__r.sku__c 
                    FROM Prestation_Contact__c 
                    WHERE prestation__r.sku__c!= null 
                      AND prestation__r.sku__c IN :deletedSet 
                      AND id NOT IN : ids 
                      AND contact__c IN :ctcIds];

        DataBase.DeleteResult[] deleteResults = DataBase.delete(pcList, false);
        for(DataBase.DeleteResult res : deleteResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : deleteSamePSKU delete des PC a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }

    // Called by the LWC that to get map of <Categories, List<Prestation>>
    @AuraEnabled(cacheable = true)
    public static Map<String, List<Reference__c>> getCategoryPrestationMap(Id contactId) {
        List<reference__c> refList = [SELECT id, Name, Key__c, Parent__c
                                      FROM Reference__c
                                      WHERE recordType.developerName='Prestation'
                                      ];
        
        // filtrer les prestations deja rajoutées pour ce pro :
        List<Prestation_Contact__c> PCList = [SELECT id, Prestation__c, Prestation__r.key__c, Contact__c
                                              FROM Prestation_Contact__c
                                              WHERE Contact__c =: contactId];
        Set<String> refExistant = new Set<String> ();
        for(Prestation_Contact__c pc : PCList) {
            refExistant.add(pc.Prestation__r.key__c);
        }

        // enter categories :
        Map<String, List<reference__c>> catPrestMap = new Map<String, List<Reference__c>>(); 
        Map<String, String> keyCategoryMap = new Map<String, String> ();
        for(reference__c ref : refList ) {
            if((ref.parent__c == '' || ref.parent__c == null) && catPrestMap.get(ref.Name) == null) {
                catPrestMap.put(ref.Name , new List<reference__c> ());
                keyCategoryMap.put(ref.key__c, ref.Name);
            }
        }
       // enter prestations :
        for(reference__c ref : refList ) {
            if(ref.parent__c != '') {
                String category =  keyCategoryMap.get(ref.parent__c);
                if(category != null && !refExistant.contains(ref.key__c)) {
                    catPrestMap.get(category).add(ref);
                }
            }
        }
        return catPrestMap;
    }

    // Called by the LWC to create the prestation contacts
    @AuraEnabled
    public static String createPrestationContact(Id contactId, List<Id> prestaList) {
        System.debug('### HDAK CTCT ID: ' + contactId);                    
        System.debug('### HDAK PREST LIST : ' + prestaList);                    

        if(prestaList==null)
            return 'EMPTY LIST';

        List<Prestation_Contact__c> PCList = new List<Prestation_Contact__c> ();
        for(id presta : prestaList) {
            // System.debug('### HDAK PRESTA : ' + presta);                    
            PCList.add(new Prestation_Contact__c(Contact__c = contactId, Prestation__c = presta, Statut__c = 'POS'));
        }

        DataBase.SaveResult[] updateResults = DataBase.insert(PCList, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                return 'FAILED';
            }
        }
        return 'SUCCESS';
    }
}