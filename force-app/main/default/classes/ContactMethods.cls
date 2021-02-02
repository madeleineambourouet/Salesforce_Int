/**
 * @File Name          : ContactMethods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-30-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/8/2020   Hassan Dakhcha     Initial Version
**/
public class ContactMethods {
    
    /* public static void setDoNotCall(List<Contact> lContacts){

Set<ID> lAccID = new Set<ID>();
Set<ID> lCtcID = new Set<ID>();
for (Contact ctc : lContacts){
if(ctc.AccountId != null){lAccID.add(ctc.AccountId);}
lCtcID.add(ctc.id);
}

//List<Account> lAccounts = [SELECT id FROM Account WHERE id IN :lAccID];
List<Account> lAccounts = [SELECT id, A_ne_jamais_rappeler__c FROM Account WHERE id IN :lAccId];
List<Contact> allContacts = [SELECT id, AccountId, DoNotCall FROM Contact WHERE AccountId IN :lAccID];

Map<Account, List<Contact>> accountContacts = new Map<Account, List<Contact>>();
for (Account cpt : lAccounts){
List<Contact> accContacts = new List<Contact>();
for (Contact ctc : allContacts){
if (ctc.AccountId == cpt.Id) { accContacts.add(ctc); }
}
accountContacts.put(cpt, accContacts);
}

for (Account cpt : lAccounts){
List<Contact> contacts = accountContacts.get(cpt);
System.debug('>>>>>>>>>>>> NE PAS RAPPELER CONTACTS ' + contacts);
for (Contact ctc : contacts){
if (ctc.DoNotCall == true) { cpt.A_ne_jamais_rappeler__c = true; break; }
else { cpt.A_ne_jamais_rappeler__c = false; }
}
}

update lAccounts;

}
*/
    
    public static void setAccountDoNotCall(List<Contact> lContacts){
        
        System.debug('>>>>>>>>>>> A NE PAS RAPPELER ?' + lContacts[0].DoNotCall);
        
        Map<ID, Boolean> doNotCallID = doNotCallAccounts(lContacts);
        List<Account> doNotCall = [SELECT id, A_ne_jamais_rappeler__c FROM Account WHERE id IN :doNotCallID.keySet()];
        System.debug('>>>>>>>>>>>>> COMPTE A UPDATER = ' + doNotCallID.get(lContacts[0].AccountID));
        for (Account cpt : doNotCall){
            if (doNotCallID.get(cpt.id) == true) { cpt.A_ne_jamais_rappeler__c = true; }
            else { cpt.A_ne_jamais_rappeler__c = false; }
        }
        
        update doNotCall;
        
    }
    
    public static Map<ID, Boolean> doNotCallAccounts(List<Contact> lContacts){
        
        Set<ID> lAccID = new Set<ID>();
        for (Contact ctc : lContacts){
            if(ctc.AccountId != null){lAccID.add(ctc.AccountId);}
        }
        
        List<Contact> allContacts = [SELECT id, AccountId, DoNotCall FROM Contact WHERE AccountId IN :lAccID];
        
        Map<Contact, List<Contact>> accountContacts = new Map<Contact, List<Contact>>();
        for (Contact ctc : lContacts){
            List<Contact> accContacts = new List<Contact>();
            for (Contact ctcIT : allContacts){
                if (ctcIT.AccountId == ctc.AccountId && ctcIT.Id != ctc.Id) { accContacts.add(ctcIT); }
            }
            System.debug('>>>>>>>>>>> MEME COMPTE = ' + accContacts);
            accountContacts.put(ctc, accContacts);
        }
        
        Map<ID, Boolean> doNotCall = new Map<ID, Boolean>();
        
        for (Contact ctc : lContacts){
            if (ctc.DoNotCall == true) { doNotCall.put(ctc.AccountId, true); }
            else {
                List<Contact> contacts = accountContacts.get(ctc);
                System.debug('>>>>>>>>>>>> NE PAS RAPPELER CONTACTS ' + contacts);
                for (Contact ctcIT : contacts){
                    if (ctcIT.DoNotCall == true) { doNotCall.put(ctc.AccountId, true); break; }
                }
            }
            if (doNotCall.get(ctc.AccountId) == null) { doNotCall.put(ctc.AccountId, false); }
            System.debug('>>>>>>>>>>>> DO NOT CALL ? ' + doNotCall.get(lContacts[0].AccountID));
        }
        
        return doNotCall;
        
    }
    
    public static void checkContactPrincipal(List<Contact> lContacts){
        
        Set<ID> lAccID = new Set<ID>();
        for (Contact ctc : lContacts){
            if(ctc.AccountId != null){lAccID.add(ctc.AccountId);}
        }
        
        List<Account> lAccounts = [SELECT id, Login__c, Mail_de_facturation__c,Contact_principal__c FROM Account WHERE id IN :lAccID];
        List<Contact> allContacts = [SELECT id, Salutation, FirstName, LastName, AccountId, Contact_Principal_O_N__c FROM Contact WHERE AccountId IN :lAccID];
        
        for (Contact ctc : lContacts){
            
            List<Contact> lSameParent = new List<Contact>();
            for (Contact same : allContacts){
                if (same.AccountId == ctc.AccountId && same.Id != ctc.Id && same.Salutation != null && same.FirstName != null){ lSameParent.add(same); }
            }
            System.debug('>>>>>>>>>>>>>>>>>>>>>> sameParent = ' + lSameParent + ' SIZE = ' + lSameParent.size());
            
            if (lSameParent.size() == 0) { 
                ctc.Contact_Principal_O_N__c = true;
                ctc.Contact_de_facturation__c = true;
                for (Account cpt : lAccounts) {
                    if (cpt.Id == ctc.AccountId){
                        cpt.Login__c = ctc.Email;
                        cpt.Mail_de_facturation__c = ctc.Email;
                        cpt.Contact_principal__c = ctc.id;
                        
                    } 
                    System.debug('>>>>>>>>>>> cpt = ' + cpt);
                } 
                System.debug('>>>>>>>>>>> ctc = ' + ctc);
            } 
            
            
            else {
                if (ctc.Contact_Principal_O_N__c == true) {
                    for (Contact same : lSameParent) {
                        same.Contact_Principal_O_N__c = false;
                        System.debug(' >>>>>>>>>>>>> Contact modifié = ' + same + ' IS NOW PRINCIPAL ? ' + same.Contact_Principal_O_N__c );
                    }
                    for (Account cpt : lAccounts) {
                        if (cpt.Id == ctc.AccountId){
                            cpt.Login__c = ctc.Email;
                            cpt.Contact_principal__c = ctc.id;
                        }
                    }
                }
                if (ctc.Contact_de_facturation__c == true){
                    for (Contact same : lSameParent) {
                        same.Contact_de_facturation__c = false;
                        System.debug(' >>>>>>>>>>>>> Contact modifié = ' + same + ' IS NOW FACTURATION ? ' + same.Contact_de_facturation__c );
                    }
                    for (Account cpt : lAccounts) {
                        if (cpt.Id == ctc.AccountId){
                            cpt.Mail_de_facturation__c = ctc.Email;
                        }
                    }
                }
            }
            update lSameParent;
            System.debug('>>>>>>>>>>> lSameParent = ' + lSameParent);
        }
        update lAccounts;
        System.debug('>>>>>>>>>>> lAccounts = ' + lAccounts);
        
    }
    //AJOUT LEILA
    public static void InsertContactPrincipal(List<Contact> lContacts){
        
        Set<ID> ids = new Set<ID>();
        for (Contact ctci : lContacts){
            ids.add(ctci.AccountId); 
        }
        
        List<Account> ACT = [SELECT id, Login__c, Mail_de_facturation__c,Contact_principal__c FROM Account WHERE id IN :ids];
        List<Account> newchild = new List<Account>();
        
        for (Contact ctci : lContacts){
            
            if (ctci.Contact_Principal_O_N__c == true) { 
                for (Account cpt1 : ACT) {
                    if (cpt1.Id == ctci.AccountId){
                        
                        cpt1.Contact_principal__c = ctci.id;
                        //newchild.add(cpt1);
                    }
                    System.debug('>>>>>>>>>>> ACT = ' + ACT);
                }        
            }                                 
        }
        
        update ACT;       
    }
    

    public static void copyMailAdress(List<Contact> newContactsList, boolean isInsert) {
        Set<id> accSet = new Set<id>();
        Map<id, String> ctcMailMap = new Map<id, String>();
        for(Contact ctc : newContactsList) {
            accSet.add(ctc.AccountId);
            if(ctc.Email!=null && ctc.Email!='') {
                ctc.Email__c = ctc.Email;
                // check the cle_email on the related objects
                if(isInsert == false) {
                    ctcMailMap.put(ctc.id, ctc.email__c);
                }
            } else if(ctc.Email__c!=null && ctc.Email__c!=''){
                ctc.Email = ctc.Email__c;
            }
        }
        if(isInsert == false) {
            // change eali_cle 
            updateEmailCle(ctcMailMap);
            return;
        }
            
        Map<id, Account> accMap = new Map<id, Account> ([ SELECT id , Compte_Nouvelles_Offres__c, Fire_Trigger__c 
                                                          FROM Account WHERE id In : accSet AND Compte_Nouvelles_Offres__c=true ]);
        for(Contact ctc : newContactsList) {
            Account acc = accMap.get(ctc.AccountId);
            if(acc!=null && acc.Compte_Nouvelles_Offres__c==true && acc.Fire_Trigger__c!=null) {
                ctc.Fire_Trigger__c = Datetime.now();
            }
        }
    }

    public static void setIsUpdatedBySF(List<Contact> ctcList) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(Contact ctc : ctcList) {
            // Transaction id for synchro :
            ctc.tech_transaction_id__c = transaction_id;
            ctc.last_updated_by_sf__c = sfUser;
        }
    }


    // Method : AttachHKConnectContactToAccount
    // Test Method : HerokuConnectTest
    // Description : Methode qui verifie si le contact va etre creer par HK Connect et si il n est pas attaché a un compte
    //               elle cherche alors le ccompte par l'adresse email et le rattache dessus.
    //               (pour plus de details cf : https://confluence.pointp.saint-gobain.net/display/HYB/Synchronisation+PP+%3C--%3E+Replicapp%3C--%3E+Salesforce ) 
    public static void AttachHKConnectContactToAccount(List<Contact> newContactsList) {
        
        if( UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place')
            return;
       // System.debug('### HDAK : Start attaching contact to correct account ');
        
        Set<String> emails = new Set<String>();
        for(contact ct : newContactsList) {
            ct.last_updated_by_sf__c = false;
            if(ct.AccountId == null)
                emails.add(ct.Email__c);
        }
        Map<String, Id> mapEmailAccountId = new Map<String, Id> ();
        for(Account acc : [SELECT id, Login__c FROM Account Where Login__c IN :emails] ) {
            //System.debug('### HDAK : Found account ' + acc);
            mapEmailAccountId.put(acc.Login__c, acc.id);
            
        }
       // System.debug('### HDAK : MAP email / accountid =  ' + mapEmailAccountId);
        
        for(contact ct : newContactsList) {
            if(ct.AccountId == null) {
                ct.AccountId = mapEmailAccountId.get(ct.Email__c);
               // System.debug('### HDAK : Attached contact '+ ct.Email__c + ' To account ' + ct.AccountId);
            }
        }
    }  

    public static void updateEmailCle(Map<id, String> ctcMailMap) {
        // Check Metier 
        List<Metier__c> mList = [ SELECT id, email_cle_metier__c, contact__c, metier__r.key__c 
                                  FROM Metier__c WHERE Contact__c IN :ctcMailMap.keySet()];
        for(Metier__c mt : mList) {
            mt.email_cle_metier__c = ctcMailMap.get(mt.contact__c) + '_' + mt.metier__r.key__c;
        }
        Database.SaveResult[] results = Database.update(mList, false);
        for(DataBase.SaveResult res : results) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : updateEmailCle sur les metiers a échouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }

        List<Departement__c> dptList = [ SELECT id, email_cle_departement__c, contact__c, departement__r.key__c 
                                         FROM Departement__c WHERE Contact__c IN :ctcMailMap.keySet()];
        for(Departement__c dpt : dptList) {
            dpt.email_cle_departement__c = ctcMailMap.get(dpt.contact__c) + '_' + dpt.departement__r.key__c;
        }
        results = Database.update(dptList, false);
        for(DataBase.SaveResult res : results) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : updateEmailCle sur les departements a échouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }

        List<Prestation_Contact__c> pcList = [ SELECT id, email_cle_prestation__c, contact__c, prestation__r.key__c 
                                               FROM Prestation_Contact__c WHERE Contact__c IN :ctcMailMap.keySet()];
        for(Prestation_Contact__c pc : pcList) {
            pc.email_cle_prestation__c =  ctcMailMap.get(pc.contact__c) + '_' + pc.Prestation__r.key__c;
        }
        results = Database.update(pcList, false);
        for(DataBase.SaveResult res : results) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : updateEmailCle sur les prestations a échouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }
}