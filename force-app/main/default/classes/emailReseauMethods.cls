/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-15-2020   Hassan Dakhcha   Initial Version
**/
public class emailReseauMethods {

    @invocableMethod(Label ='Creer les contacts d\'agence')
    public static List<String> emailReseauMethods(List<String> emails) {
        if(emails.isEmpty()) {
            return null;
        }

        List<String> emailList = emails[0].split(';');
        if(emailList==null || emailList.isEmpty() || emailList[0]=='' || emailList.size()<2) {
            return null;
        }
        Id agenceId = emailList[0];
        String sentList = emailList[1];

        Set<String> emailAdrSet = new Set<String>();
        for(String str : emailList) {
            if(str!=null && str!='' && str.contains('@') && str.contains('.')){
                emailAdrSet.add(str.toLowerCase().remove(' '));
            }
        }

        Map<id,Contact> ctcMap = new Map<id, Contact>([SELECT id, email, Contact_Agence_Pilote__c 
                                                       FROM Contact WHERE email IN :emailAdrSet AND Contact_Agence_Pilote__c=true]);
        if(!ctcMap.isEmpty()) {
            // contacts found attach them to the agence if needed
            List<Agence_Contact_Join_Table__c> jointList = [SELECT ID, contact__c FROM Agence_Contact_Join_Table__c 
                                                            WHERE Contact__c IN :ctcMap.keySet() AND Agence_pilote__c=:agenceId];
            if(!jointList.isEmpty()) {
                for(Agence_Contact_Join_Table__c jnt : jointList) {
                    emailAdrSet.remove(ctcMap.get(jnt.contact__c).email);
                    ctcMap.remove(jnt.contact__c);
                }
            }
        }

        List<Agence_Contact_Join_Table__c> joinToInsert = new List<Agence_Contact_Join_Table__c>();
        // Existing Email not attached :
        if(!ctcMap.isEmpty()) {
            for(id ctc : ctcMap.keySet()) {
                joinToInsert.add(new Agence_Contact_Join_Table__c(contact__c=ctc, Agence_pilote__c=agenceId, Liste_d_envoi__c=sentList, Envoi_email_active__c=true));
                emailAdrSet.remove(ctcMap.get(ctc).email);
            }
        }
        // Add Non existing Contacts :
        List<contact> agencyCtc = new List<Contact>();
        for(String emailStr : emailAdrSet) {
            agencyCtc.add(new Contact(email = emailStr, lastName = emailStr, Contact_Agence_Pilote__c = true));
        }

        insert agencyCtc;
        for(Contact ctc : agencyCtc) {
            joinToInsert.add(new Agence_Contact_Join_Table__c(contact__c=ctc.id, Agence_pilote__c=agenceId, Liste_d_envoi__c=sentList, Envoi_email_active__c=true));
        }

        insert joinToInsert;

        return null;
    }

    // Envoi les emails aux agences pilote lorsqu'un devis est signé 
    public static void notifySignedQuote(Map<id, Devis_LMSG__c> quoteMap, Map<id, id> devisAgenceMap, Map<id, String> devisBDMap) {
        // get all contacts active for signed quote:
        List<Agence_Contact_Join_Table__c> ctcList = [SELECT id, Liste_d_envoi__c, Contact__c, Contact__r.Contact_Agence_Pilote__c, Contact__r.email, Agence_pilote__c, Agence_Pilote__r.Obsolete__c
                                                      FROM Agence_Contact_Join_Table__c 
                                                      WHERE Envoi_email_active__c=true 
                                                      AND (Liste_d_envoi__c='PROJECT_SIGNED' OR Liste_d_envoi__c='ALL' OR Liste_d_envoi__c='CC_ALL' OR Liste_d_envoi__c ='CC_PROJECT_SIGNED')
                                                      AND Agence_Pilote__r.Obsolete__c=false AND Agence_pilote__c IN:devisAgenceMap.values()];
        if(ctcList.isEmpty())
            return;

        Map<id, List<Agence_Contact_Join_Table__c>> agenceContactMap = new Map<id, List<Agence_Contact_Join_Table__c>>();
        for(Agence_Contact_Join_Table__c ctc : ctcList) {
            List<Agence_Contact_Join_Table__c> listCtc = agenceContactMap.get(ctc.Agence_pilote__c);
            if(listCtc==null) {
                listCtc = new List<Agence_Contact_Join_Table__c>();
                agenceContactMap.put(ctc.Agence_pilote__c, listCtc);
            }
            listCtc.add(ctc);
        }

        List<Contact> sendToContacts = new List<Contact>();
        Map<id, List<Agence_Contact_Join_Table__c>> devisContactMap = new Map<id, List<Agence_Contact_Join_Table__c>>();
        for(id quote : devisAgenceMap.keySet()) {
            List<Agence_Contact_Join_Table__c> listctc = agenceContactMap.get(devisAgenceMap.get(quote));
            if(listctc==null) {
                continue;
            }
            devisContactMap.put(quote, listctc);
            
            // build list to contact
            String emailAgencePilote = quoteMap.get(quote).Template_Email_agence_pilote__c;
            String info_Relance = quoteMap.get(quote).Template_Email_info_chantier_signe__c;
            String account_owner = quoteMap.get(quote).Template_Email_proprietaire_du_compte__c;
            Set<id> uniqueContactSet = new Set<id>();                
            for(Agence_Contact_Join_Table__c ctc : listctc) {
                if(!uniqueContactSet.contains(ctc.contact__c)) {
                    Contact toUpdate = new Contact( id = ctc.Contact__c, Template_Email_agence_pilote__c = emailAgencePilote,
                                                    Template_Email_info_relance__c = info_Relance,
                                                    Template_Email_BD_du_compte__c = account_owner,
                                                    MC_Envoyer_Mail_Agence__c = Label.Comm_Agence_Pilote_Tool == 'MC',
                                                    MC_Nature_Relance__c = 'PROJECT_SIGNED');
                    sendToContacts.add(toUpdate);
                    uniqueContactSet.add(ctc.Contact__c);
                }
            }
        }

        Database.update(sendToContacts, false);

        // get email template for signed projects :
        Id emailTemplate = [SELECT id FROM EmailTemplate WHERE DeveloperName ='Auto_DEVIS_LMSG_Comm_Agence_chantier_sign'].id;

        String instanceName = [SELECT IsSandbox,Name,InstanceName FROM Organization].InstanceName;
        Id OrgMail =null;
        switch on instanceName {
            when 'CS173' { // INT
                OrgMail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE address=:Label.Comm_Agence_Pilote_Org_Address LIMIT 1].id;
            }
            when 'CS174' { // REC
                OrgMail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE address=:Label.Comm_Agence_Pilote_Org_Address LIMIT 1].id;
            }
            when 'EU19' { // PROD
                OrgMail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE address=:Label.Comm_Agence_Pilote_Org_Address LIMIT 1].id;
            }
        }
        sendTheEmail(devisContactMap, devisBDMap, emailTemplate, OrgMail);
    }

    // Envoi les emails aux agences pilote lorsqu'un pro est selectioné avec un montant estimation max du projet sup ou egale a 5000€
    public static void notifySelectedPro(Map<id, Mise_en_relation__c> newMap, Map<id, Mise_en_relation__c> oldMap) {
        
        Set<id> selectedMers = new Set<id>();
        for(id mer : newMap.keySet()) {
            if(newMap.get(mer).Statut__c == 'Pro_selectionne' && (oldMap==null || oldMap.get(mer).Statut__c!=newMap.get(mer).Statut__c)) {
                selectedMers.add(mer);
            }
        }
        if(selectedMers.isEmpty())
            return;

        // Keep only Projects with budjet >= 5000€
        List<Mise_en_relation__c> merSelected = [SELECT id, Compte_Pro__r.owner.email, Compte_Pro__r.Agence_User__c
                                                 FROM Mise_en_relation__c WHERE Projet_LMSG__r.Chiffrage_maximum__c >=5000 AND ID IN:selectedMers];
        if(merSelected.isEmpty())
            return;
        
        Map<Id, Id> merAgenceMap = new Map<id, id>();
        Map<Id, String> merBDMailMap = new Map<id, String>();
        for(Mise_en_relation__c mer : merSelected) {
            merAgenceMap.put(mer.id, mer.Compte_Pro__r.Agence_User__c);
            merBDMailMap.put(mer.id, mer.Compte_Pro__r.owner.email);
        }

        List<Agence_Contact_Join_Table__c> ctcList = [SELECT id, Liste_d_envoi__c, Contact__c, Contact__r.Contact_Agence_Pilote__c, Contact__r.email, Agence_pilote__c, Agence_Pilote__r.Obsolete__c
                                                      FROM Agence_Contact_Join_Table__c 
                                                      WHERE Envoi_email_active__c=true 
                                                      AND (Liste_d_envoi__c='PRO_SELECTED' OR Liste_d_envoi__c='ALL' OR Liste_d_envoi__c='CC_ALL' OR Liste_d_envoi__c ='CC_PRO_SELECTED')
                                                      AND Agence_Pilote__r.Obsolete__c=false AND Agence_pilote__c IN:merAgenceMap.values()];
        if(ctcList.isEmpty())
            return;

        Map<id, List<Agence_Contact_Join_Table__c>> agenceContactMap = new Map<id, List<Agence_Contact_Join_Table__c>>();
        for(Agence_Contact_Join_Table__c ctc : ctcList) {
            List<Agence_Contact_Join_Table__c> listCtc = agenceContactMap.get(ctc.Agence_pilote__c);
            if(listCtc==null) {
                listCtc = new List<Agence_Contact_Join_Table__c>();
                agenceContactMap.put(ctc.Agence_pilote__c, listCtc);
            }
            listCtc.add(ctc);
        }

        List<Contact> sendToContacts = new List<Contact>();
        Map<id, List<Agence_Contact_Join_Table__c>> merContactMap = new Map<id, List<Agence_Contact_Join_Table__c>>();
        for(id mer : merAgenceMap.keySet()) {
            List<Agence_Contact_Join_Table__c> listctc = agenceContactMap.get(merAgenceMap.get(mer));
            if(listctc==null) {
                continue;
            }
            merContactMap.put(mer, listctc);
            
            // build list to contact
            String emailAgencePilote = newMap.get(mer).Template_Email_agence_pilote_Mer__c;
            String info_Relance = newMap.get(mer).Template_Email_mise_en_relation_accepte__c;
            String account_owner = newMap.get(mer).Template_Email_proprietaire_compte_MER__c;
            Set<id> uniqueContactSet = new Set<id>();
            for(Agence_Contact_Join_Table__c ctc : listctc) {
                if(!uniqueContactSet.contains(ctc.contact__c)) {
                    Contact toUpdate = new Contact( id = ctc.Contact__c, Template_Email_agence_pilote__c = emailAgencePilote,
                                                    Template_Email_info_relance__c = info_Relance,
                                                    Template_Email_BD_du_compte__c = account_owner,
                                                    MC_Envoyer_Mail_Agence__c = Label.Comm_Agence_Pilote_Tool == 'MC',
                                                    MC_Nature_Relance__c = 'PRO_SELECTED');
                    sendToContacts.add(toUpdate);
                    uniqueContactSet.add(ctc.contact__c);
                }
            }
        }

        Database.update(sendToContacts, false);

        // get email template for signed projects :
        Id emailTemplate = [SELECT id FROM EmailTemplate WHERE DeveloperName ='Auto_MER_LMSG_Pro_Comm_Agence_Pro_Selectionne'].id;
        String instanceName = [SELECT IsSandbox,Name,InstanceName FROM Organization].InstanceName;
        Id OrgMail =null;
        switch on instanceName {
            when 'CS173' { // INT
                OrgMail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE address like 'contact.hy.int@gmail.com' LIMIT 1].id;
            }
            when 'CS174' { // REC
                OrgMail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE address like 'contact-pre@homly-you.com' LIMIT 1].id;
            }
            when 'EU19' { // PROD
                OrgMail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName like 'LMSG Service Pro' LIMIT 1].id;
            }
        }
        sendTheEmail(merContactMap, merBDMailMap, emailTemplate, OrgMail);
    }

    public static void sendTheEmail(map<id, List<Agence_Contact_Join_Table__c>> objectContactMap, map<id, String> objectBDMap, Id emailTemplate, Id OrgMail) {
        List<Messaging.SingleEmailMessage> theEmails = new List<Messaging.SingleEmailMessage>();
        for( Id quoteId : objectContactMap.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddress = new List<String>(); 
            List<String> ccAddress = new List<String>();
            Id ctcId = null;
            for(Agence_Contact_Join_Table__c ctc : objectContactMap.get(quoteId)) {
                if(!ctc.Liste_d_envoi__c.contains('CC')) {
                    if(ctc.Contact__r.email!=null && ctc.Contact__r.email!='') {
                        toAddress.add(ctc.Contact__r.email);
                    } 
                    if(ctcId==null) {
                        ctcId = ctc.Contact__c;
                    }
                } else {
                    if(ctc.Contact__r.email!=null && ctc.Contact__r.email!='')
                        ccAddress.add(ctc.Contact__r.email);
                }
            }
            mail.setToAddresses(toAddress);
            //mail.setTreatBodiesAsTemplate(true);
            mail.setCcAddresses(ccAddress);
            mail.setBccAddresses(new String[]{objectBDMap.get(quoteId)});
            mail.setTargetObjectId(ctcId);
            mail.setWhatId(quoteId);
            mail.setUseSignature(false);
            mail.setorgWideEmailAddressId(OrgMail);
            mail.setTemplateId(emailTemplate);

            theEmails.add(mail);
            System.debug('********* MAIL = ' + mail);
        }
        
        if(!theEmails.isEmpty() &&  Label.Comm_Agence_Pilote_Tool == 'SC') {
            Messaging.sendEmail(theEmails);
            for(Messaging.SingleEmailMessage mail : theEmails) {
                System.debug('******* set Email = ' + mail);
            }
        }
    }
}