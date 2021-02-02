/*
* DocumentMethods : handels some logic for document__c object
* Test Method : HerokuConnectTest
* Created by   : Hassan
* Created Date : 26 Dec 2019
*/

public class DocumentMethods {
     
    // Method : AttachHKConnectDocToAccount
    // Test Method : HerokuConnectTest
    // Description : Methode qui verifie si le document va etre cree par HK Connect et si il n est pas attaché a un compte
    //               elle cherche alors le compte par l'adresse email et le rattache au document.
    //               (pour plus de details cf : https://confluence.pointp.saint-gobain.net/display/HYB/Synchronisation+PP+%3C--%3E+Replicapp%3C--%3E+Salesforce ) 
    //   

    public static void AttachHKConnectDocToAccount(List<Document__c> documentList) {
        
        if( UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place')
            return;
                
        Set<String> emails = new Set<String>();
        for(Document__c doc : documentList) {
            doc.last_updated_by_sf__c = false;
            if(doc.Compte_Pro__c == null && doc.Email_cle_document__c !=null && doc.Email_cle_document__c !='') 
                emails.add((doc.Email_cle_document__c).substringBeforeLast('_'));
         }

        Map<String, Id> mapEmailCompteId= new Map<String, Id> ();
        for(Account acc : [SELECT id, Login__c FROM Account Where Login__c IN :emails] ) {
            //System.debug('### HDAK : Found account ' + acc);
            String key = acc.Login__c;
            mapEmailCompteId.put(key.toLowerCase(), acc.id);
        }
                
        for(Document__c doc : documentList) {
            if(doc.Compte_Pro__c == null && doc.Email_cle_document__c !=null && doc.Email_cle_document__c !='') {
                doc.Compte_Pro__c = mapEmailCompteId.get(((doc.Email_cle_document__c).substringBeforeLast('_')).toLowerCase());
            }
        }
    }  

    public static void setIsUpdatedBySF(List<Document__c> docList) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
          for(Document__c doc : docList) {
            // Transaction id for synchro :
            doc.tech_transaction_id__c = transaction_id;
            doc.last_updated_by_sf__c = sfUser;
        }
    }

    public static void validateKYBChange(Document__c oldDoc, Document__c newDoc, Map<String, id> keyIdStatus) {
        // If KYB then SF users cannot set VALIDATED 
        // IF KYB && VALIDATED : SF User cannot invalidate or modify it
        // IF Expired then permit the modification
        if ( oldDoc.Type_de_document__c == 'id'   || newDoc.Type_de_document__c == 'id'   || 
             oldDoc.Type_de_document__c == 'kbis' || newDoc.Type_de_document__c == 'kbis' || 
             oldDoc.Type_de_document__c == 'rib'  ||  newDoc.Type_de_document__c == 'rib'  || 
             oldDoc.Type_de_document__c == 'address_proof' ||  newDoc.Type_de_document__c == 'address_proof' || 
             oldDoc.Type_de_document__c == 'company_status' || newDoc.Type_de_document__c == 'company_status') {
            
            String profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
            Boolean isAdmin = profileName =='System Administrator' || profileName == 'Administrateur système';

            // IF KYB && VALIDATED : SF User cannot invalidate or modify it
            if(!isAdmin && oldDoc.Statut__c == keyIdStatus.get('VALIDATED')) {
                newDoc.addError('Un document KYB (Pièce d\'identité, RIB, KBIS, Statuts, Justificatif de domicile) validé par le paiement ne peut pas être modifié');
            }
            if(!isAdmin && oldDoc.Statut__c == keyIdStatus.get('VALIDABLE')) {
                newDoc.addError('Un document KYB (Pièce d\'identité, RIB, KBIS, Statuts, Justificatif de domicile) au statut "à valider Hipay" ne peut pas être modifié');
            }
            if(!isAdmin && !System.isBatch() && oldDoc.Statut__c != newDoc.Statut__c && newDoc.Statut__c == keyIdStatus.get('VALIDATED')) {
                newDoc.addError('Un document KYB (Pièce d\'identité, RIB, KBIS, Statuts, Justificatif de domicile) doit être mis au statut \'A valider\' ');
            }
        } else { // Not a KYB Doc do not allow 'A Valider'
            if(oldDoc.Statut__c != newDoc.Statut__c && newDoc.Statut__c == keyIdStatus.get('VALIDABLE')) {
                newDoc.addError('Le statut \'A valider\' n\'est pas autorisé pour ce type de document');
            }
        }
    }

    public static List<Document__c> validateDeletion(List<Document__c> deletingList) {
        // Avoid deleting KYB doc when it is has VALIDABLE status
        Map<String, id> keyIdStatus = null;
        String profileName = null;
        Set<Document__c> docToDelete = new Set<Document__c>(deletingList);
        for(Document__c doc : deletingList) {
            if (doc.Type_de_document__c == 'id'   || doc.Type_de_document__c == 'kbis' || doc.Type_de_document__c == 'rib'  ||
                doc.Type_de_document__c == 'address_proof' || doc.Type_de_document__c == 'company_status') {
                    
                    if(keyIdStatus == null) {
                        List<reference__c> refList = [SELECT id,Key__c FROM reference__c WHERE recordType.DeveloperName = 'Statut_Document'];
                        keyIdStatus = new Map<String, id>();
                        for(Reference__c ref : refList) {
                            keyIdStatus.put(ref.key__c, ref.id);
                        }
                    }

                    if( doc.Statut__c == keyIdStatus.get('VALIDABLE') || doc.Statut__c == keyIdStatus.get('VALIDATED') ) {
                        if(profileName==null) {
                            profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
                        }
                        if(profileName !='System Administrator' && profileName != 'Administrateur système') {
                            doc.addError('Vous ne pouvez pas supprimer un document KYB en attente de validation ou Validé.');
                            docToDelete.remove(doc);
                        }
                    }
            }  
        }
        return new List<Document__c>(docToDelete);
    }

    // Checks the iban and returns < ture/false , 'Contry Code'>
    @InvocableMethod
    public static List<String> checkIban(List<String> ibanList) {

        String IBAN = ibanList[0];
        Map<String, String> mapCodeLetters = new Map<String, String>{'A'=> '10', 'B'=> '11', 'C'=> '12', 'D'=> '13', 'E'=> '14', 'F'=> '15', 'G'=> '16', 'H'=> '17', 'I'=> '18',
                                                                       'J'=> '19', 'K'=> '20', 'L'=> '21', 'M'=> '22', 'N'=> '23', 'O'=> '24', 'P'=> '25', 'Q'=> '26', 'R'=> '27',
                                                                       'S'=> '28', 'T'=> '29', 'U'=> '30', 'V'=> '31', 'W'=> '32', 'X'=> '33', 'Y'=> '34', 'Z'=> '35'};
        // Replace void
        String IBAN_2 ='';
        for(Integer i = 0 ; i < IBAN.length() ; i++) {
            if(IBAN.substring(i,i+1) != ' ') {
              IBAN_2 += IBAN.substring(i,i+1);
            }
        }
        //System.debug('##### HDAK IBAN_2 ' + IBAN_2);

        IBAN = IBAN_2;
        List<String> result = new List<String>();
        if(IBAN.length() != 27 && IBAN.length() != 25) {
            result.add('FALSE');
            return result;
        }

        String country_code = IBAN.substring(0,2);
        if(!country_code.isAlpha()) {
            result.add('FALSE');
            return result;
        }
        country_code = country_code.toUpperCase();
        String iban_key = IBAN.substring(2,4);
        String numValue = IBAN.substring(4);
        numValue += country_code+iban_key;

        //System.debug('##### HDAK country_code ' + country_code);
        //System.debug('##### HDAK iban_key ' + iban_key);
        //System.debug('##### HDAK numValue ' + numValue);

        // replace chars in value
        String newValue ='';
        for(Integer i=0 ; i<numValue.length(); i++) {
            if(mapCodeLetters.get(numValue.substring(i,i+1)) == null) {
                newValue += numValue.substring(i,i+1);
            } else {
                newValue += mapCodeLetters.get(numValue.substring(i,i+1));
            }
        }
 
        // Modulo 97
        Long moduCst = 97;
        String subStr = '';
        Long div = 0;
        for(Integer i=0 ; i<= 27 ; i=i+9 ) {
            subStr = newValue.length()<=9 ?  newValue : newValue.substring(0,9);
            
            //System.debug('##### HDAK substr  #' + subStr + '#');

            div = math.mod(Long.valueOf(subStr), moduCst);
            String res = String.valueOf(div);
            //System.debug('##### HDAK  res  #' + res + '#');
            if(newValue.length()<=9)
                break;
            newValue = res + newValue.substring(9);
        }
    
        if(div == 1)  {
            result.add(country_code);
       } else {
           result.add('FALSE');
       }

       return result;
     
    }
}