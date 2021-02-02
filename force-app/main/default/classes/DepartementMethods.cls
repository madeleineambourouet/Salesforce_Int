/*
* departementMethods : handels some logic for departement__c object
* Test Method : HerokuConnectTest
* Created by   : Hassan
* Created Date : 26 Dec 2019
*/

public class DepartementMethods {
    
     
    // Method : AttachHKConnectDepToContact
    // Test Method : HerokuConnectTest
    // Description : Methode qui verifie si le departement va etre creer par HK Connect et si il n est pas attaché a un contact
    //               elle cherche alors le contact par l'adresse email et le rattache au departement.
    //               (pour plus de details cf : https://confluence.pointp.saint-gobain.net/display/HYB/Synchronisation+PP+%3C--%3E+Replicapp%3C--%3E+Salesforce ) 
    //               
    public static void AttachHKConnectDepToContact(List<Departement__c> departementList) {
        
        if( UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place')
            return;
                
        Set<String> emails = new Set<String>();
        for(Departement__c dep : departementList) {
            dep.last_updated_by_sf__c = false;
            if(dep.Contact__c == null && dep.Email_cle_departement__c != '') 
                emails.add((dep.Email_cle_departement__c).substringBeforeLast('_'));
        }        
        
        Map<String, Id> mapEmailContactId = new Map<String, Id> ();
        for(Contact ct : [SELECT id, Email__c FROM Contact Where Email__c IN :emails] )
            mapEmailContactId.put(ct.Email__c, ct.id);
        
        for(Departement__c dep : departementList) {
            if(dep.Contact__c == null) {
                dep.Contact__c = mapEmailContactId.get((dep.Email_cle_departement__c).substringBeforeLast('_'));
            }
        }
    }

    public static void setIsUpdatedBySF(List<Departement__c> dptList) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(Departement__c dep : dptList) {
            // Transaction id for synchro :
            dep.tech_transaction_id__c = transaction_id;
            dep.last_updated_by_sf__c = sfUser;
        }
    }

    public static void initKey(List<Departement__c> depList, Map<id, Departement__c> oldMap, Boolean isInsert) {
        Set<Id> contactSet = new Set<Id> ();
        Set<Id> depRefSet = new Set<Id> ();
        List<Departement__c> depToUpdate = new List<Departement__c>();
        for(Departement__c dep : depList) {  
            if(isInsert || (dep.Contact__c != oldMap.get(dep.id).Contact__c || dep.Departement__c != oldMap.get(dep.id).Departement__c) ) {  
                contactSet.add(dep.Contact__c);
                depRefSet.add(dep.Departement__c);
                depToUpdate.add(dep);
            }
        }
        if(contactSet.isEmpty() || depRefSet.isEmpty())
            return;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT id , Email, Fire_Trigger__c FROM Contact WHERE id IN :contactSet]);
        Map<Id, Reference__c> refMap = new Map<Id, Reference__c>([SELECT id, key__c FROM Reference__c WHERE Id IN :depRefSet]);
        
        for(Departement__c dep : depToUpdate) {    
            contact ctc = contactMap.get(dep.Contact__c);
            Reference__c ref = refMap.get(dep.Departement__c);
            if(ctc!=null && ref!=null) {
                dep.Email_cle_departement__c = ctc.Email + '_' + ref.key__c;
            }
            if(ctc!=null && ctc.Fire_Trigger__c!=null) {
                dep.Fire_Trigger__c = Datetime.now();
            }
        }
    }
}