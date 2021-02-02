/**
 * @File Name          : HelperButton.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/11/2020, 4:21:04 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
 * @Last Modified By   : Leila BOUAIFEL 07/07/2020
**/
public without sharing class HelperButton {
    
    
    public HelperButton (ApexPages.StandardSetController setCon) {
        
    }

    @AuraEnabled
    public static Boolean reinitMDP (Account acc) {
        Account a = [SELECT Id, Name FROM Account WHERE Id = :acc.Id];
        acc.Reinitialisation_mdp__c = true;
        update acc;
        return acc.Reinitialisation_mdp__c;
    }
    
    @AuraEnabled
    public static Account seConnecter(String accId) {
        //Account acc = [SELECT Id, IsPersonAccount, Last_URL_redirection__c FROM Account WHERE Id = :accId LIMIT 1];
        Account acc = new Account();
        acc.Id = accId;
        acc.Login_as__c = true;
        update acc;

        Account accUpdated = [SELECT Id, IsPersonAccount, Last_URL_redirection__c FROM Account WHERE Id = :accId LIMIT 1];
        System.debug('seConnecter accUpdated'+accUpdated);
        return accUpdated;
    }
    
    @AuraEnabled
    public static String selectionPro(String intId) {
        Intermediation__c inter =[SELECT Id, Competence__c, Statut_Selection__c, Non_selectionnable__c, IsModified__c, Selection_demandee_a__c FROM Intermediation__c WHERE Id = :intId LIMIT 1];
        String errorMsg;
        if (inter.Competence__c != null ) {
            if (inter.Statut_Selection__c == null || inter.Statut_Selection__c == '') {
                if (inter.Non_selectionnable__c == false) {
                    if (inter.IsModified__c == false) {
                        inter.Statut_Selection__c = 'Demandee';
                        inter.Selection_demandee_a__c = datetime.now();
                        inter.selection_par__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
                        
                        update inter;
                        return '';
                    } else {
                        return 'Vous avez déjà sélectionné un pro.';
                    }
                } else {
                    return 'Ce pro est non sélectionnable.';
                }
            } else {
                return 'La demande de sélectionner ce pro est déjà fait à ' + inter.Selection_demandee_a__c.format();
            }
        } else {
            return 'Vous devez assigner une compétence à une mise en relation avant sa sélection!';
        }
    }
    
    @AuraEnabled
    public static String annulerMatching(String intId) {
        Intermediation__c inter =[SELECT Id, Competence__c, Statut_Selection__c, Non_selectionnable__c, IsModified__c, Selection_demandee_a__c, recredit_quote__c FROM Intermediation__c WHERE Id = :intId LIMIT 1];
        
        if (inter.recredit_quote__c == null ) {
            inter.Matching_rejete__c = null;
            inter.Matching_rejete_date__c = null;
            inter.Matching_rejete_par__c = null;
            update inter;
            return 'Cette mise en relation n\'a pas fait l\'objet d\'un recrédit!';
            
        } else {
           List<zqu__Quote__c> quo = [SELECT Id, Name, zqu__Status__c FROM zqu__Quote__c WHERE Name = :inter.recredit_quote__c AND (zqu__Status__c != 'Sent to Z-Billing' AND zqu__Status__c != 'Envoyée')];
            if (quo.size() ==0) {
                return 'Erreur: La proposition commerciale ne peut pas être annulée - recrédit déjà effectué';
            } else {
                IntermediationTriggerUtils.CancelAmendmentWS(inter.Id, quo[0].Id);
                return '';
            }
        }
    }
    
    @AuraEnabled
    public static String getInvoiceNumber(String invId) {
        Zuora__ZInvoice__c inv = [SELECT Id, Name FROM Zuora__ZInvoice__c WHERE Id = :invId];
        return inv.Name;
    }
    
    @AuraEnabled
    public static String validerProposition(String quoId) {

        zqu__Quote__c quo = [SELECT Id, zqu__Status__c, Type_de_geste__c, PM_BillingCountry__c, PM_CardHolderName__c, PM_CreditCardType__c, PM_Email__c, PM_ExpirationMonth__c, PM_ExpirationYear__c, PM_SecondTokenId__c, PM_TokenId__c, zqu__SoldToContact__r.Salutation, zqu__BillToContact__r.Salutation FROM zqu__Quote__c WHERE Id = :quoId];
        List<Attachment> pj = [SELECT Id FROM Attachment WHERE ParentId = :quoId];
        Map<Id, Profile> prolist = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE NOT Name IN ('Service Client','Administrateur système','Administrateur fonctionnel','Service Commercial ITCS')]);

        if (quo.zqu__SoldToContact__r != null && quo.zqu__SoldToContact__r.Salutation != 'M.' && quo.zqu__SoldToContact__r.Salutation != 'Mme') {
            return 'La civilité du contact principal n\'est pas valide. Merci de choisir Mme ou M.';
        } else if (quo.zqu__BillToContact__r != null && quo.zqu__BillToContact__r.Salutation != 'M.' && quo.zqu__BillToContact__r.Salutation != 'Mme') {
            return 'La civilité du contact de facturation n\'est pas valide. Merci de choisir Mme ou M.';
        } else if (quo.zqu__Status__c != 'New' && quo.zqu__Status__c != 'Sent to Z-Billing') {
            return 'La proposition commerciale doit être "A valider" afin de valider la proposition.';
        } else if (pj.size() == 0 && quo.Type_de_geste__c != 'Geste commercial post-résiliation') {
            return 'Pour valider la proposition, le PDF doit être généré.';
        } else if (prolist.containsKey(UserInfo.getProfileId())) {
            return 'Votre profil '+prolist.get(UserInfo.getProfileId()).Name+' ne vous permet pas de valider des propositions.';
        } else if ( (quo.PM_BillingCountry__c == null || quo.PM_CardHolderName__c == null || quo.PM_CreditCardType__c == null || quo.PM_Email__c == null || quo.PM_ExpirationMonth__c == null || quo.PM_ExpirationYear__c == null || quo.PM_SecondTokenId__c == null || quo.PM_TokenId__c == null ) &&
                quo.Type_de_geste__c != 'Geste commercial post-résiliation') {
            return 'Les informations de paiement sont manquantes. Merci de contacter votre administrateur.';
        } else {
            ApprovalQuote.Approve(quoId);
            return '';
        }
    }

    @AuraEnabled   
    public static String validerModification(String quoId, String typeQ) {
        zqu__Quote__c quo = [SELECT Id, zqu__Status__c, Type_de_geste__c, PM_BillingCountry__c, PM_CardHolderName__c, PM_CreditCardType__c, PM_Email__c, PM_ExpirationMonth__c, PM_ExpirationYear__c, PM_SecondTokenId__c, PM_TokenId__c, zqu__SoldToContact__r.Salutation, zqu__BillToContact__r.Salutation, zqu__StartDate__c  FROM zqu__Quote__c WHERE Id = :quoId];
        Map<Id, Profile> prolist = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE NOT Name IN ('Service Client','Administrateur système','Administrateur fonctionnel','Service Commercial ITCS')]);

        if (quo.zqu__Status__c != 'New') {
            return 'La proposition commerciale doit être "A valider" afin de valider la proposition.';
        } else if (prolist.containsKey(UserInfo.getProfileId())) {
            if (typeQ == 'modif')
                return 'Votre profil '+prolist.get(UserInfo.getProfileId()).Name+' ne vous permet pas de valider des propositions.';
            else
                return 'Votre profil '+prolist.get(UserInfo.getProfileId()).Name+' ne vous permet pas de valider la résiliation. ';

        } else {
            ApprovalQuote.Approve(quoId);
            if (typeQ == 'modif')
                quo.Modification_offres__c = true;
            else
                quo.Resiliation_offres__c = true;

            if (quo.zqu__StartDate__c < Date.today()) {
                quo.zqu__StartDate__c = Date.today();
            }

            update quo;
            return '';
        }

    }


    @AuraEnabled
    @RemoteAction
    public static string creerModifQuote(String accId) {
        List<Account> accs = [SELECT Id, Agence_User__c, Enseignes_de_gestion_Client__c, Statut_de_paiement__c, SIRET_texte__c, Code_NAF_APE_societe_declarante__c, Adresse1__c, Login__c, Code_client__c FROM Account WHERE Id = :accId];
        List<Contact> cons = [SELECT Id, Pays_lkp__c, Code_postal_lkp__c, Phone, MobilePhone  FROM Contact WHERE Contact.AccountId = :accId AND Contact.Contact_Principal_O_N__c = true];
        Map<Id, Profile> prolist = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN ('Service Consommateur')]);

        Account acc = accs[0];
        Contact con;
        System.debug('creerModifQuote acc.SIRET_texte__c '+acc.SIRET_texte__c);

        if (cons.size() != 0)
            con = cons[0];

        if (prolist.containsKey(UserInfo.getProfileId())) {
            return 'Votre profil ne vous permet pas de créer de proposition commerciale.';
        } else if (acc.Statut_de_paiement__c == 'A mettre en recouvrement' || acc.Statut_de_paiement__c == 'Client transmis au recouvrement') {
            return 'Vous ne vous pouvez pas de créer de proposition commerciale, le statut de paiement est en recouvrement.';
        } else if ((acc.SIRET_texte__c != '' && acc.SIRET_texte__c != null) && acc.Code_NAF_APE_societe_declarante__c == null ) {
            return 'Le code NAF doit être renseigner.';
        } else if ( acc.Adresse1__c == '' || acc.Adresse1__c == null) {
            return 'Vous ne vous pouvez pas créer de proposition commerciale, veuillez renseigner l\'adresse du compte.';
            
       } else if ( acc.Agence_User__c == null ||  acc.Enseignes_de_gestion_Client__c == null) {
           System.debug('acc.Agence_User__c agence '+acc.Agence_User__c);
           System.debug('acc.Enseignes_de_gestion_Client__c ENS '+acc.Enseignes_de_gestion_Client__c);
           
           return 'Vous ne vous pouvez pas créer de proposition commerciale, veuillez renseigner l\'agence pilote et l\'enseigne de gestion principale.';      
        
                      
        } else if (con == null) {
            return 'Veuillez sélectionner (ou créer) un contact de facturation avant de créer une nouvelle proposition commerciale.';
        } else if (acc.Login__c == '' || 
            (con.Phone == null && con.MobilePhone == null) ||
            con.Pays_lkp__c == null ||
            con.Code_postal_lkp__c == null){
            return 'Vous ne pouvez pas créer de proposition commerciale :  vous devez entrer une adresse E-mail, un téléphone valide, un code postal et Pays sur le contact.';
        } else {

            List<zqu__Quote__c> quos = [SELECT Id, Name, zqu__Status__c FROM zqu__Quote__c WHERE  zqu__Account__c = :accId AND (NOT zqu__Status__c IN ('Sent to Z-Billing','Abandonnée'))];
            if (quos.size() != 0) {
                return 'Vous ne pouvez pas créer de nouvelle proposition. Vous avez déjà la proposition N° '+ quos[0].Name +' non finalisée.';
            }

            return '';
        }

        
    }

    @RemoteAction
    @AuraEnabled
    public static string getUrl(String accId) {
        List<Account> accs = [SELECT Id, Code_client__c FROM Account WHERE Id =:accId];
        String BillingAccount_Id = Zuora_Query.getBillingAccountId(accs[0].Code_client__c);
        String subscription; 

        if (BillingAccount_Id == '')
            return '/apex/VF_Quote_Step1_Creation?crmAccountId=' + accId + '&quoteType=Subscription&retUrl=/{'+accId+'&stepNumber=1';
        else {
            subscription = Zuora_Query.getSubscriptionID(billingAccount_Id);
            String[] subs = subscription.split(',');
            if (subscription == '') {
                return '/apex/VF_Quote_Step1_Creation?billingAccountId='+BillingAccount_Id+'&crmAccountId='+accId+'&quoteType=Subscription&retUrl=/'+accId+'&stepNumber=1';
            } else {
                if (subs[1]=='Active') {
                    return '/apex/VF_Quote_Step1_Creation?billingAccountId='+BillingAccount_Id+'&crmAccountId='+accId+'&quoteType=Amendment&retUrl=/'+accId+'&stepNumber=1&subscriptionId='+subs[0] +'&SubscriptionTermStartDate='+subs[3];
                } else {
                    return 'Vous ne pouvez pas créer de nouvelle proposition. Vous avez la souscription '+subs[2]+' au statut '+subs[1]+'.';
                }
            }
        }
    }


    @RemoteAction
    @AuraEnabled
    public static String resilierSouscription(String accId) {
        Map<Id, Profile> prolist = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN ('Service Consommateur')]);
        List<Account> accs = [SELECT Id, Code_client__c FROM Account WHERE Id =:accId];
        List<Contact> cons = [SELECT Id, Pays_lkp__c, Code_postal_lkp__c, Phone, MobilePhone  FROM Contact WHERE Contact.AccountId = :accId AND Contact.Contact_Principal_O_N__c = true];

        Account acc = accs[0];
        Contact con;

        if (cons.size() != 0)
            con = cons[0];

        if (prolist.containsKey(UserInfo.getProfileId())) {
            return 'Votre profil ne vous permet pas de créer de proposition commerciale.';
        } else if (con == null) {
            return 'Veuillez sélectionner (ou créer) un contact de facturation avant de créer une nouvelle proposition commerciale.';
        } else {
            String BillingAccount_Id = Zuora_Query.getBillingAccountId(acc.Code_client__c);
            List<zqu__Quote__c> quos = [SELECT Id, Name, zqu__Status__c FROM zqu__Quote__c WHERE  zqu__Account__c = :accId AND (NOT zqu__Status__c IN ('Sent to Z-Billing','Abandonnée'))];

            if (quos.size() != 0)
                return 'Vous ne pouvez pas créer de nouvelle proposition. Vous avez déjà la proposition N° '+ quos[0].Name +' non finalisée.';

            if (BillingAccount_Id == '') {
                return 'Pas de résiliation possible. Il existe aucun compte de facturation actif.';
            } else {
                String subscription = Zuora_Query.getSubscriptionID(BillingAccount_Id);
                String[] subs = subscription.split(',');
                if (subscription == '') {
                    return 'Pas de résiliation possible. Il existe aucune souscription active';
                } else {
                    if (subs[1] == 'Active') {
                        System.debug('resilierSouscription: ** /apex/zqu__ZQCancellation?billingAccountId='+BillingAccount_Id+'&crmAccountId='+accId+'&quoteType=Cancellation&retUrl=/'+accId+'&stepNumber=1&subscriptionId='+subs[0]);
                        return '/apex/zqu__ZQCancellation?billingAccountId='+BillingAccount_Id+'&crmAccountId='+accId+'&quoteType=Cancellation&retUrl=/'+accId+'&stepNumber=1&subscriptionId='+subs[0];
                    } else {
                        return 'Pas de résiliation possible. Vous avez la souscription '+subs[2]+' au statut '+subs[1]+'.';
                    }
                }
            }
        }


    }

    @AuraEnabled
    public static String callFermerPreinscrit (String leadId) {
        String message = '';
        Lead lead = [SELECT Id, Status FROM Lead WHERE Id = :leadId];
        lead.Status = 'Fermée';
        lead.Bypass_Validation_Rule__c = true;
        try {    
            update lead;
        } 
        catch (DMLException ex) {    
            //message = (String)ex.;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                if(message ==''){
                   message = ex.getDmlMessage(i); 
                }
                else{                
                    message = message + ' '+ex.getDmlMessage(i);
                }
                // Process exception here
                System.debug(ex.getDmlMessage(i)); 
            }
            System.debug('The exception came here and thats all, our code ended');   
        }
        return message;
    }
    
    @AuraEnabled
    public static String callGenerationArtisanService (String accId) {
        List<String> listResult = new List<String>();
        String message = '';
        System.debug('HelperButton ehllo');
        System.debug('HelperButton accId '+accId);
        Account acc = [SELECT Id, Code_client_Point_P__c FROM Account WHERE Id = :accId];
        if(acc != null){
            listResult = GenerationArtisanService.serviceGenerationArtisan(acc.Id,acc.Code_client_Point_P__c);
        }
        if(listResult.size() > 0){
            message = listResult[0];
        }
        else{
            message = 'Le compte a été mis à jour';
        }
        return message;
    }
    
    @AuraEnabled
    public static String callLoginCheck (String email,String leadId) {
        List<String> listResult = new List<String>();
        Boolean message = true;
        System.debug('callLoginCheck ehllo');
        System.debug('callLoginCheck email '+email);
        System.debug('callLoginCheck leadId '+leadId);
        if(email == null ||  email == ''){
            message = false;
        }
        else {
            List<Account> accList = [SELECT id FROM Account WHERE Login__c = :email];
            System.debug('callLoginCheck accList '+accList);
            if(accList != null && accList.size() > 0){
                message = false;
            }
        }
        Lead lead = [SELECT Id, Nombre_de_comptes_existants__c,Type_de_doublon__c FROM Lead WHERE Id = :leadId];
        return message+':'+lead.Nombre_de_comptes_existants__c+':'+lead.Type_de_doublon__c;
    }
    
    @AuraEnabled
    public static String callConvertirPiste (String leadId) {
        String message = '';
        Lead lead = [SELECT Id, Status FROM Lead WHERE Id = :leadId];
        lead.Status = 'Qualifiée';
        lead.Bypass_Validation_Rule__c = true;
        try {    
            update lead;
            Lead leadUpdated = [SELECT Id, ConvertedAccountId FROM Lead WHERE Id = :leadId];
            if(leadUpdated.ConvertedAccountId != null){
                message = 'leadConvertedAccountId:'+leadUpdated.ConvertedAccountId;
            }
            else{
                message = 'La piste n\'a pas pu être convertie.';
            }
        } 
        catch (DMLException ex) {    
            //message = (String)ex.;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                if(message ==''){
                   message = ex.getDmlMessage(i); 
                }
                else{                
                    message = message + ' '+ex.getDmlMessage(i);
                }
                // Process exception here
                System.debug(ex.getDmlMessage(i)); 
            }
            System.debug('The exception came here and thats all, our code ended');   
        }
        return message;
    }
    
    @AuraEnabled
    public static String callUpdateprojetMatching (String projetId) {
        String message = '';
        Projet__c updateprojet = new Projet__c();
        updateprojet.Id = projetId;
        updateprojet.Matching_Demande__c = true;
        updateprojet.flag_runOnce__c = false;
        updateprojet.DateTimeDerniereDemandeMatching__c = date.today();
        try {    
            update updateprojet;
            message = '';
        } 
        catch (DMLException ex) {    
            //message = (String)ex.;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                if(message ==''){
                   message = ex.getDmlMessage(i); 
                }
                else{                
                    message = message + ' '+ex.getDmlMessage(i);
                }
                // Process exception here
                System.debug(ex.getDmlMessage(i)); 
            }
            System.debug('The exception came here and thats all, our code ended');   
        }
        return message;
    }
    
    @AuraEnabled
    public static String callAnnulerRappel (String rappelId) {
        String message = '';
        /*
        System.debug('callAnnulerRappel rappelId '+rappelId);
        Rappel__c rappel = [SELECT Id, CallBack_Reference__c FROM Rappel__c WHERE Id = :rappelId];
        String callbackId = rappel.CallBack_Reference__c;
        System.debug('callAnnulerRappel callbackId '+callbackId);
        try {       
            RappelUpdateWS.changeStatusCallBackOdigoWS(rappelId, callbackId);
        } 
        catch (Exception ex) {   
            message = ex.getMessage(); 
            System.debug('The exception came here and thats all, our code ended');   
        } 
        */
        return message;
    }
    
    @AuraEnabled
    public static String callVerifierQuoteDateActivation (String quoteId) {
        String message = '';
        System.debug('callVerifierQuoteDateActivation quoteId '+quoteId);
        zqu__Quote__c quote = [SELECT Id, zqu__Status__c, Type__c, zqu__StartDate__c, zqu__Account__c FROM zqu__Quote__c WHERE Id = :quoteId];
        Zuora__Subscription__c  subcrptA  = null;
        Zuora__Subscription__c  subcrptP   = null;
        Id userId = userinfo.getUserId();
        Date startDate = null;
        if(quote != null){
            for(Zuora__Subscription__c zsa : [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND Zuora__Account__c = :quote.zqu__Account__c] ){
                subcrptA = zsa;
            }
            for(Zuora__Subscription__c zsp : [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Pending Activation' AND Zuora__Account__c = :quote.zqu__Account__c] ){
                subcrptP = zsp;
            }
            startDate = quote.zqu__StartDate__c;
        }
        User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userId ];
        Date todayDate = Date.today();
        System.debug('callVerifierQuoteDateActivation startDate '+startDate);
        System.debug('callVerifierQuoteDateActivation todayDate '+todayDate);
        System.debug('callVerifierQuoteDateActivation quote '+quote);
        System.debug('callVerifierQuoteDateActivation subcrptA '+subcrptA);
        System.debug('callVerifierQuoteDateActivation subcrptP '+subcrptP);
        if(subcrptA != null){
            message = 'Vous ne pouvez pas effectuer cette action avec une souscription active sur le compte parent !';
        }
        else if(subcrptP == null){
            message = 'Vous devez disposer d\'au moins une souscription en \'Pending Activation\'';
        }
        else if(userDetails.UserRole.Name != 'TC Service Client Part'){
            if (quote != null && quote.Type__c == 'Création de souscription'){ 
                if (quote.zqu__Status__c != 'Sent to Z-Billing') { 
                    message = 'La proposition commerciale doit être validé.'; 
                } else if (startDate < todayDate) { 
                    message = 'La date de début est inférieure a la date du jour!'; 
        
                } else { 
                    message = ''; 
                } 
            } else { 
                message = 'La proposition commerciale doit être de type création'; 
            }
        }
        else{
           message = 'Vous n\'avez pas accès a ce bouton !';  
        }
        System.debug('callVerifierQuoteDateActivation message '+message);
        return message;
    }
    
    @AuraEnabled
    public static String callVerifierQuoteRenoncerActivation (String quoteId) {
        String message = '';
        System.debug('callVerifierQuoteRenoncerActivation quoteId '+quoteId);
        zqu__Quote__c quote = [SELECT Id, zqu__Status__c, Type__c, zqu__Account__c FROM zqu__Quote__c WHERE Id = :quoteId];
        Zuora__Subscription__c  subcrptA  = null;
        Zuora__Subscription__c  subcrptP   = null;
        Id userId = userinfo.getUserId();
        if(quote != null){
            for(Zuora__Subscription__c zsa : [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active' AND Zuora__Account__c = :quote.zqu__Account__c] ){
                subcrptA = zsa;
            }
            for(Zuora__Subscription__c zsp : [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Pending Activation' AND Zuora__Account__c = :quote.zqu__Account__c] ){
                subcrptP = zsp;
            }
        }
        User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userId ];
        System.debug('callVerifierQuoteRenoncerActivation quote '+quote);
        System.debug('callVerifierQuoteRenoncerActivation subcrptA '+subcrptA);
        System.debug('callVerifierQuoteRenoncerActivation subcrptP '+subcrptP);
        if(subcrptA != null){
            message = 'Vous ne pouvez pas effectuer cette action avec une souscription active sur le compte parent !';
        }
        else if(subcrptP == null){
            message = 'Vous devez disposer d\'au moins une souscription en \'Pending Activation\'';
        }
        else if(userDetails.UserRole.Name != 'TC Service Client Part'){
            if (quote != null && quote.Type__c == 'Création de souscription'){ 
                if (quote.zqu__Status__c != 'Sent to Z-Billing') { 
                    message = 'La proposition commerciale doit être validé.'; 
                } else { 
                    message = ''; 
                } 
            } else { 
                message = 'La proposition commerciale doit être de type création'; 
            }
        }
        else{
           message = 'Vous n\'avez pas accès a ce bouton !';  
        }
        System.debug('callVerifierQuoteRenoncerActivation message '+message);
        return message;
    }
    
    @AuraEnabled
    public static String callRegenererPdf (String quoteId) {
        String message = '';
        System.debug('callRegenererPdf quoteId '+quoteId);
        for(Attachment att :[SELECT Id FROM Attachment WHERE ParentId = :quoteId]){
            message = 'Le PDF a déjà été généré.';
        }
        if(message == ''){
            zqu__Quote__c quote = [SELECT Id, zqu__Status__c FROM zqu__Quote__c WHERE Id = :quoteId];
            if(!(quote.zqu__Status__c=='Envoyée' || quote.zqu__Status__c=='New')){
                message = 'Le statut ne permet pas de générer un nouveau PDF.';
            }
        }
        return message;
    }
    
    @AuraEnabled
    public static String callGenererPdf (String quoteId) {
        String message = '';
        System.debug('callRegenererPdf quoteId '+quoteId);
        zqu__Quote__c quote = [SELECT id, zqu__Status__c, Intermediation__c, PXS_Nb_Geocat__c FROM zqu__Quote__c WHERE Id = :quoteId];
        if(quote.Intermediation__c == true && quote.PXS_Nb_Geocat__c == 0){
            message = 'Vous devez créer les Geocat et Compétence sur le contact avant de pouvoir générer le document.';
        }
        else if(message == ''){
            if(quote.zqu__Status__c!='En cours'){
                message = 'La proposition commerciale doit être En Cours afin de générer le document PDF.';
            }
            else{
                zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
                quoteToUpdate.Id = quote.Id;
                quoteToUpdate.Envoi_mail_generate_PDF__c = true;
                quoteToUpdate.zqu__Status__c = 'Envoyée'; 
                try {    
                    update quoteToUpdate;
                    message = '';
                } 
                catch (DMLException ex) {    
                    //message = (String)ex.;
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                        if(message ==''){
                            message = ex.getDmlMessage(i); 
                        }
                        else{                
                            message = message + ' '+ex.getDmlMessage(i);
                        }
                        // Process exception here
                        System.debug(ex.getDmlMessage(i)); 
                    }
                    System.debug('The exception came here and thats all, our code ended');   
                }
            }
        }
        return message;
    }
    
    @AuraEnabled
    public static String callAbandonnerProposition (String quoteId) {
        String message = '';
        System.debug('callAbandonnerProposition quoteId '+quoteId);
        RecordType recordType = null;
        zqu__Quote__c quote = [SELECT id, RecordTypeName__c FROM zqu__Quote__c WHERE Id = :quoteId];
        System.debug('callAbandonnerProposition quote.RecordTypeName__c '+quote.RecordTypeName__c);  
        String recordTypeName='ReadOnly';
        String strCurrentRType = quote.RecordTypeName__c; 
        if(strCurrentRType == 'Amendment'){
            recordTypeName = 'Amendment_ReadOnly';
        }
        else if(strCurrentRType == 'Renewal'){
            recordTypeName = 'Renewal_ReadOnly';
        }
        else if(strCurrentRType == 'Cancellation'){
            recordTypeName = 'Cancellation_ReadOnly';
        }
        else if(strCurrentRType == 'Default'){
            recordTypeName = 'ReadOnly';
        }
        else {
            recordTypeName = 'ReadOnly'; 
        }
        
        for (RecordType rt : [SELECT DeveloperName,Id,Name,SobjectType FROM RecordType WHERE SobjectType = 'zqu__Quote__c' AND DeveloperName = :recordTypeName]){
            recordType = rt;
        }
        System.debug('callAbandonnerProposition recordType '+recordType);
        if(recordType != null){
 
            zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
            quoteToUpdate.Id = Id.valueOf(quoteId);
            quoteToUpdate.RecordTypeId = recordType.Id;
            quoteToUpdate.zqu__Status__c = 'Abandonnée';
            try {    
                update quoteToUpdate;
                message = '';
            } 
            catch (DMLException ex) {    
                //message = (String)ex.;
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    if(message ==''){
                        message = ex.getDmlMessage(i); 
                    }
                    else{                
                        message = message + ' '+ex.getDmlMessage(i);
                    }
                    // Process exception here
                    System.debug(ex.getDmlMessage(i)); 
                }
                System.debug('The exception came here and thats all, our code ended');   
            }
        }
        else{
            message = 'le type d\'enregistrement n\'est pas reconnu';
        }
        return message;
    }


}