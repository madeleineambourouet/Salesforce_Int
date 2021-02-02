/**
 * @File Name          : Synchronization_Data_Checker.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/5/2020, 7:39:59 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/28/2020   Hassan Dakhcha     Initial Version
**/
public class Synchronization_Data_Checker implements Database.Batchable<SObject>, Database.Stateful {

    // DATA ckecker : Pour les Compte Nouvelles Offres / Pilote ou pas 
    // check si le Account.login__c est le meme que le contact principal
    // Check si le  champs email__c est egal au champ email qui est bien rempli
    // Check si le Departement / Prestation Contact / Metier on une clé Cohérente avec le mail du Contact 
    // Check si pas de null_ dans les clés
    // Check si id WBE est bien rempli sur les Comptes et contacts
    
    // Pour le PART Nouvelle Offres :
    // Check si le PART a un email et numero de telephone valide
    // Check si l'id WBE est rempli sur le part
    
    // Pour les Projet LMSG :
    // Check de ID WBE du projet
    // Projet creer sur un part non Nouvelles offres !
    // Projet dont le statut est publié sur un part non actif !! 


    public String objectName;
    public Map<String, List<String>> idInfoMsgMap;
    public Synchronization_Data_Checker(String objectName) {
        this.objectName = objectName;
        idInfoMsgMap = new Map<String, List<String>>();
    }

    // Start
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStr = '';
        if(this.objectName == 'ACCOUNT')
            queryStr = Label.Query_Synchronization_Data_Checker_Account;
        if(this.objectName == 'CONTACT')
            queryStr = Label.Query_Synchronization_Data_Checker_Contact;
        if(this.objectName == 'METIER')
            queryStr = Label.Query_Synchronization_Data_Checker_Metier;
        if(this.objectName == 'DEPARTEMENT')
            queryStr = Label.Query_Synchronization_Data_Checker_Departement;
        if(this.objectName == 'PRESTATION')
            queryStr = Label.Query_Synchronization_Data_Checker_Prestation;
        if(this.objectName == 'PART')
            queryStr = Label.Query_Synchronization_Data_Checker_Part;
        if(this.objectName == 'PROJET')
            queryStr = Label.Query_Synchronization_Data_Checker_ProjetLMSG;

        return Database.getQueryLocator(queryStr);
    }

    public void execute(Database.BatchableContext bctx, List<sObject> records) {
        if(this.objectName == 'ACCOUNT')
            VerifyAccountData(records);
        if(this.objectName == 'CONTACT')
            verifyContactData(records);
        if(this.objectName == 'METIER')
            verifyMetierData(records);
        if(this.objectName == 'DEPARTEMENT')
            verifyDepartementData(records);
        if(this.objectName == 'PRESTATION')
            verifyPrestationData(records);
        if(this.objectName == 'PART')
            verifyPartData(records);
        if(this.objectName == 'PROJET')
            verifyProjectData(records);
    }

    public void VerifyAccountData(List<sObject> records) {
        Account acc;
        for(sObject record : records) {
            acc = (Account) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- Compte PRO : ID = ' + acc.id + ' Pro = ' + acc.name + ' Login = ' + acc.Login__c + '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // if pro_pilote = true ==> External id doit etre rempli
            if(acc.pro_Pilote__c == true && (acc.External_ID__c==null || acc.External_ID__c=='' || !acc.External_ID__c.startsWith('pro_'))) {
                idInfoMsgMap.get(keyStr).add('Pro pilote sans id WBE ! == External id doit etre rempli et perfixé par pro_ ');
            }
            // Check du statut
            if(acc.pro_Pilote__c == true && (acc.Statut_activation__c  == '' || acc.Statut_activation__c  == 'Nouveau')) {
                idInfoMsgMap.get(keyStr).add('Pro pilote avec le statut activation = ' + acc.Statut_activation__c );
            }
            // check Statut_Juridique 
            if(acc.Statut_Juridique__c  == null) {
                idInfoMsgMap.get(keyStr).add('Pro sans statut juridique !');
            }
            if(acc.pro_Pilote__c==true && acc.Statut_activation__c =='Pro_resilie') {
                idInfoMsgMap.get(keyStr).add('Pro pilote Résilié !! ');
            }
        }
    }

    public void VerifyContactData(List<sObject> records) {
        Contact ctc;
        for(sObject record : records) {
            ctc = (Contact) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- Contact PRO : ID = ' + ctc.id + ' Name = ' + ctc.name + ' Email = ' + ctc.email + ' contact principal= ' + ctc.Contact_Principal_O_N__c + '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // if pro_pilote = true ==> External id doit etre rempli
            if(ctc.Account.pro_Pilote__c == true && (ctc.External_Contact_Id__c  ==null || ctc.External_Contact_Id__c=='')) {
                idInfoMsgMap.get(keyStr).add('Pro pilote avec id WBE null !!');
            }
            // Check de l'email
            if(ctc.email != ctc.email__c && ctc.Contact_Principal_O_N__c == true) {
                idInfoMsgMap.get(keyStr).add('Contact avec email__c different de l\'email !! ');
            }
              
            // check du mobile phone
            if(ctc.MobilePhone  == null || ctc.MobilePhone=='') {
                idInfoMsgMap.get(keyStr).add('Contact sans mobilePhone !');
            }
        }
    }

    public void VerifyMetierData(List<sObject> records) {
        Metier__c mt;
        for(sObject record : records) {
            mt = (Metier__c) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- Metier PRO : ID = ' + mt.id + ' Name = ' + mt.name + ' Email Cle = ' + mt.Email_cle_metier__c + '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // Check de l'email
            if(mt.Contact__r.email != mt.Contact__r.email__c) {
                idInfoMsgMap.get(keyStr).add('Metier sur un Contact avec email__c ('+ mt.Contact__r.email__c + ') different de l\'email (' + mt.Contact__r.email + ')');
            }
              
            // check du mobile phone
            if(mt.Email_cle_metier__c  == null || mt.Email_cle_metier__c=='' || mt.Email_cle_metier__c.contains('null')) {
                idInfoMsgMap.get(keyStr).add('Metier avec une CLE incorrecte ('+ mt.Email_cle_metier__c+')');
            } else if(mt.Email_cle_metier__c.substringBeforeLast('_') != mt.Contact__r.email) {
                idInfoMsgMap.get(keyStr).add('metier avec une CLE contenant un email different du contact (Cle = '+ mt.Email_cle_metier__c + ') (Email = ' + mt.Contact__r.email + ')');
            }
             // Check de l'email
            if(mt.Contact__r.Contact_Principal_O_N__c == false) {
                idInfoMsgMap.get(keyStr).add('Metier sur un Contact qui n\'est pas Principal !! ');
            }
            System.debug('##### HDAK : fill map = ' +idInfoMsgMap);
        }
    }
    public void VerifyDepartementData(List<sObject> records) {
        Departement__c dpt;
        for(sObject record : records) {
            dpt = (Departement__c) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- Departement PRO : ID = ' + dpt.id + ' Name = ' + dpt.name + ' Email Cle = ' + dpt.Email_cle_departement__c+ '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // Check de l'email
            if(dpt.Contact__r.email != dpt.Contact__r.email__c) {
                idInfoMsgMap.get(keyStr).add('departement sur un Contact avec email__c ('+ dpt.Contact__r.email__c + ') different de l\'email ('+ dpt.Contact__r.email + ') ');
            }
              
            // check du mobile phone
            if(dpt.Email_cle_departement__c  == null || dpt.Email_cle_departement__c=='' || dpt.Email_cle_departement__c.contains('null')) {
                idInfoMsgMap.get(keyStr).add('departement avec une CLE incorrecte ('+ dpt.Email_cle_departement__c + ') !');
            } else if(dpt.Email_cle_departement__c.substringBeforeLast('_') != dpt.Contact__r.email) {
                idInfoMsgMap.get(keyStr).add('departemet avec une CLE contenant un email different du contact (Cle = '+ dpt.Email_cle_departement__c + ') (Email = ' + dpt.Contact__r.email + ')');
            }
             // Check de l'email
            if(dpt.Contact__r.Contact_Principal_O_N__c == false) {
                idInfoMsgMap.get(keyStr).add('departement sur un Contact qui n\'est pas Principal !! ');
            } 
        }
    }

    public void VerifyPrestationData(List<sObject> records) {
        Prestation_Contact__c pc;
        for(sObject record : records) {
            pc = (Prestation_Contact__c) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- Prestation PRO : ID = ' + pc.id + ' Name = ' + pc.name + ' Email Cle = ' + pc.Email_cle_Prestation__c + '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // Check de l'email
            if(pc.Contact__r.email != pc.Contact__r.email__c) {
                idInfoMsgMap.get(keyStr).add('Prestation sur un Contact avec email__c ('+ pc.Contact__r.email__c + ') different de l\'email ('+ pc.Contact__r.email + ') ');
            }
              
            // check du mobile phone
            if(pc.Email_cle_Prestation__c  == null || pc.Email_cle_Prestation__c=='' || pc.Email_cle_Prestation__c.contains('null')) {
                idInfoMsgMap.get(keyStr).add('Prestation avec une CLE incorrecte ('+ pc.Email_cle_Prestation__c + ')');
            } else if(pc.Email_cle_Prestation__c.substringBeforeLast('_') != pc.Contact__r.email) {
                idInfoMsgMap.get(keyStr).add('Prestation avec une CLE contenant un email different du contact (Cle = '+ pc.Email_cle_Prestation__c + ') (Email = ' +pc.Contact__r.email + ')');
            }
             // Check de l'email
            if(pc.Contact__r.Contact_Principal_O_N__c == false) {
                idInfoMsgMap.get(keyStr).add('Prestation sur un Contact qui n\'est pas Principal !! ');
            } 
        }
    }
    public void VerifyPartData(List<sObject> records) {
        Account acc;
        for(sObject record : records) {
            acc = (Account) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- PART : ID = ' + acc.id + ' Part = ' + acc.name + ' Login = ' + acc.personEmail + '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // if pro_pilote = true ==> External id doit etre rempli
            if(acc.External_ID__c==null || acc.External_ID__c=='' ) {
                idInfoMsgMap.get(keyStr).add('Part nouvelles offres sans id WBE ! == External id doit etre rempli');
            }
            // Check du statut
            if(acc.Statut_activation__c  == '' || acc.Statut_activation__c  == 'Nouveau') {
                idInfoMsgMap.get(keyStr).add('Part Nouvelles Offres avec le statut activation  = ' + acc.Statut_activation__c);
            }
            // check Statut_Juridique 
            if(acc.personEmail  == null || acc.personEmail=='') {
                idInfoMsgMap.get(keyStr).add('Part sans email !');
            }
            if(acc.PersonMobilePhone == null ||acc.PersonMobilePhone == '') {
                idInfoMsgMap.get(keyStr).add('Part sans PersonMobilePhone ! ');
            }
        }
    }
    public void VerifyProjectData(List<sObject> records) {
        Projet_LMSG__c prj;
        for(sObject record : records) {
            prj = (Projet_LMSG__c) record;
            List<String> strList = new List<String>();
            strList.clear();
            String keyStr = '---- Projet : ID = ' + prj.id + ' Projet = ' + prj.name + '<br/>';
            idInfoMsgMap.put(keyStr, strList);

            // if pro_pilote = true ==> External id doit etre rempli
            if(prj.Identifiant_PP__c==null || prj.Identifiant_PP__c=='' ) {
                idInfoMsgMap.get(keyStr).add('Projet LMSG sans id WBE ! == Identifiant_PP__c id doit etre rempli');
            }
            // Check du statut
            if(prj.Particulier__r.Statut_activation__c== null || prj.Particulier__r.Statut_activation__c  == '' || prj.Particulier__r.Statut_activation__c  == 'Nouveau') {
                idInfoMsgMap.get(keyStr).add('Projet Lié à un Part Nouvelles Offres avec le statut activation nouveau ou vide !');
            }

            if(prj.Particulier__r.Compte_Nouvelles_Offres__c  == false) {
                idInfoMsgMap.get(keyStr).add('Projet crée sur un Part NON Nouvelles Offres !');
            }
    
            if(prj.Statut__c  == 'PUBLISHED' && (prj.Particulier__r.Statut_activation__c!='Part_actif')) {
                idInfoMsgMap.get(keyStr).add('Projet Publié sur un part non actif !');
            }
        }
    }


    public void sendReport(String subject, String Report) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String email = System.Label.DL_SGDBF_supervision_processus;
        //String email = UserInfo.getUserEmail();
        mail.setUseSignature(false);
        mail.setToAddresses(new String[] {email}); 
        mail.setSubject(subject);
        mail.setHtmlBody(report); 

        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    public void finish(Database.BatchableContext bctx) {
        Boolean sendReport = FALSE;
        String report ='####  Data Checker : Rapport :' + this.objectName + ' #### <br/><br/>';
        for(String key : idInfoMsgMap.keySet()) {
            List<String> msgList = idInfoMsgMap.get(key);
            if(msgList == null || msgList.isEmpty())
                continue;
            
            sendReport = TRUE;
            report += key;
            for(String msg : msgList)
                report += msg + ' <br/>';
            
            report +=  '----------------------------------------------------------------------------- <br/><br/>';
        }
    
        if(!sendReport)
            return;
        
        report = '<html><body>' + report + '</body></html>';
        sendReport('Batch de verification Data Nouvelles Offres : ' + this.objectName , report);
    }

}