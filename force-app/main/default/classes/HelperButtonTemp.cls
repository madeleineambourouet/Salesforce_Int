/**
 * @File Name          : HelperButtonTemp.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/11/2020, 4:22:15 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
**/
public without sharing class HelperButtonTemp {
    
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
    
    
    
}