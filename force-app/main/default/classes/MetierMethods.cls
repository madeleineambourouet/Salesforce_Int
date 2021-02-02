/**
 * @File Name          : MetierMethods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-30-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/9/2020   Hassan Dakhcha     Initial Version
**/
public class MetierMethods {
    public static void FillInFields(List<Metier__c> newList, Map<id, Metier__c> oldMap, Boolean isInsert) {

        Set<id> idCtcSet = new Set<id> ();
        Set<id> idRefSet = new Set<id> ();
        List<Metier__c> metierToUpdate = new List<Metier__c> ();
        for(Metier__c mt : newList) {
            if(isInsert 
                || (mt.Contact__c != oldMap.get(mt.id).Contact__c || mt.Metier__c != oldMap.get(mt.id).Metier__c) ) {
                idCtcSet.add(mt.contact__c);
                idRefSet.add(mt.Metier__c);
                metierToUpdate.add(mt);
            }
        }
        Map<id, Contact> contactMap = new Map<id, Contact> ([SELECT id, Email, Fire_Trigger__c FROM Contact WHERE Id IN : idCtcSet]);
        Map<id, Reference__c> refMap = new Map<id, Reference__c> ([SELECT id, key__c FROM Reference__c WHERE Id IN : idRefSet]);

        for(Metier__c mt : metierToUpdate) {
            Contact ctc = contactMap.get(mt.Contact__c);
            Reference__c ref = refMap.get(mt.Metier__c);
            mt.Email_cle_metier__c = (ctc!=null? ctc.Email : '') + '_' + (ref!=null? ref.key__c : '');
            if(isInsert && ctc.Fire_Trigger__c!=null ) {
                 mt.Fire_Trigger__c = Datetime.now();
            }
        }
    }

    public static void AttachHKConnectMetierToContact(List<Metier__c> metierList) {
        
        if( UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place')
            return;
                
        Set<String> emails = new Set<String>();
        for(metier__c mt : metierList) {
            mt.last_updated_by_sf__c = false;
            if(mt.Contact__c == null && mt.Email_cle_metier__c != '') 
                emails.add((mt.Email_cle_metier__c).substringBeforeLast('_'));
        }        
        
        Map<String, Id> mapEmailContactId = new Map<String, Id> ();
        for(Contact ct : [SELECT id, Email__c FROM Contact Where Email__c IN :emails] )
            mapEmailContactId.put(ct.Email__c, ct.id);
        
        for(metier__c mt : metierList) {
            if(mt.Contact__c == null) {
                mt.Contact__c = mapEmailContactId.get((mt.Email_cle_metier__c).substringBeforeLast('_'));
            }
        }
    }

    public static void setIsUpdatedBySF(List<metier__c> mtList) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(metier__c mt : mtList) {
            // Transaction id for synchro :
            mt.tech_transaction_id__c = transaction_id;
            mt.last_updated_by_sf__c = sfUser;
        }
    }

}