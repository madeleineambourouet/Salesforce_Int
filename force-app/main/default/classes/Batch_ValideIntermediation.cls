/**
* @author Qiuyan Liu
* @date 27/01/2017
*
* @description 
*/
global with sharing class Batch_ValideIntermediation implements Database.Batchable<sObject>, 
   Database.AllowsCallouts {
    public String query;
    public Static Integer VALIDITY = 31;
    public Static Integer N_USAGES = 5;
    public Static String EMAIL = '';
    public Static String EMAIL_PART ='Part Sélectionné';
    public Static Integer LOT_SIZE = 40;
    public Boolean Batch_Valide_Finish = false;
    
    //global Batch_ValideIntermediation() {
    //    query = 'SELECT Id, Statut_Selection__c FROM Intermediation__c WHERE Statut_Selection__c = \'Validee\' LIMIT ' + LOT_SIZE;
    //}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        query = 'SELECT Id, Statut_Selection__c FROM Intermediation__c WHERE Statut_Selection__c = \'Validee\' LIMIT ' + LOT_SIZE;
        
        //if(test.Isrunningtest()){
        //    query = 'SELECT Id, Statut_Selection__c FROM Intermediation__c WHERE Statut_Selection__c = \'Validee\'';
        //}

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Token__c> tokenList = new List<Token__c>();
        Map<Id, Projet__c> projetUpdateMap = new Map<Id,Projet__c>();
        List<Intermediation__c> merScopeList = (List<Intermediation__c>)scope;
        List<Intermediation__c> merList = [SELECT Id, Contact__c, Contact__r.AccountId, Contact__r.Account.Login__c, Contact__r.Account.Mail_de_facturation__c, Contact__r.Name, Contact__r.MobilePhone, 
                                            Projet__c, Projet__r.Particulier__r.PersonMobilePhone, Projet__r.Particulier__r.Phone, Projet__r.Particulier__r.PersonOtherPhone, 
                                            Projet__r.Particulier__r.PersonEmail, Projet__r.Particulier__r.Name, Projet__r.Titre__c, Projet__r.Description__c, Projet__r.Code_postal__r.Name, 
                                            Projet__r.Ville_formule__c, Projet__r.Flux_Categorie__c, Projet__r.Particulier__r.Salutation, Projet__r.Statut_Projet__c, Projet__r.Etat__c, 
                                            Projet__r.Mises_en_relation_selectionnees__c, Projet__r.Particulier__c, Projet__r.Particulier__r.Login__c
                                           FROM Intermediation__c WHERE Id in: merScopeList];
        //Avoid the execution of trigger Generate_token_Part_selectionne on Intermediation__c
        checkRecursiveSFDC.runOnce();
        try {
            for (Intermediation__c mer : merList) {
                
                Blob targetBlob = Blob.valueOf(mer.Contact__r.Account.Login__c + Datetime.now().getTime());
                Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
                String hash = EncodingUtil.convertToHex(hashBlob);
                //System.debug('>>>>>>>>>>>>>>>>>> hash = ' + hash);
                
                /*//token part, same function as Apex trigger : Generate_token_Part_selectionne
                Blob targetBlobPart = Blob.valueOf(mer.Projet__r.Particulier__r.Login__c + Datetime.now().getTime());
                Blob hashBlobPart = Crypto.generateDigest('MD5', targetBlob);
                String hashPart = EncodingUtil.convertToHex(hashBlob);*/
                
                
                
                //token pro
                Token__c token = new Token__c(Name = hash, Compte__c = mer.Contact__r.AccountId, Validite__c = VALIDITY,Nombre_d_usage_token_restant__c = N_USAGES,
                                              Type_de_token__c = EMAIL, URL_redirection__c = Label.URL_web_pour_email + hash, 
                                              Email_du_compte__c = (EMAIL == 'Quote' ? mer.Contact__r.Account.Mail_de_facturation__c : mer.Contact__r.Account.login__c));
                tokenList.add(token);
                
                /*//token part, same function as Apex trigger : Generate_token_Part_selectionne
                Token__c tokenPart = new Token__c(Name = hashPart, Compte__c = mer.Projet__r.Particulier__c, Validite__c = VALIDITY,Nombre_d_usage_token_restant__c = N_USAGES,
                                              Type_de_token__c = EMAIL_PART, URL_redirection__c = Label.URL_web_pour_email + hashPart, 
                                              Email_du_compte__c = mer.Projet__r.Particulier__r.Login__c);
                tokenList.add(tokenPart); */
                
               
                String urlToken = Label.URL_web_pour_email + 'pro/mon-espace#/project/' + mer.Id + '/' + hash;
               
                //System.debug('mer token' + token.URL_redirection__c);
               
                String projetPartPhone = mer.Projet__r.Particulier__r.PersonMobilePhone != null ? mer.Projet__r.Particulier__r.PersonMobilePhone : 
                                                                                                  (mer.Projet__r.Particulier__r.Phone != null ? mer.Projet__r.Particulier__r.Phone : 
                                                                                                                                                mer.Projet__r.Particulier__r.PersonOtherPhone); 
                
                String body = 'HOMLY YOU. ' + mer.Projet__r.Particulier__r.Salutation + ' ' + mer.Projet__r.Particulier__r.Name.toUpperCase() + ' souhaite faire appel à vos services pour son projet à ' 
                            + mer.Projet__r.Ville_formule__c + '(' + mer.Projet__r.Code_postal__r.Name + ')' + '.\n \n' 
                            + 'Descriptif du projet : ' + mer.Projet__r.Flux_Categorie__c + '\n \n'
                            + 'Coordonnées du particulier : \n' 
                            + mer.Projet__r.Particulier__r.Name.toUpperCase() + '\n'
                            + projetPartPhone + '\n'
                            + mer.Projet__r.Particulier__r.PersonEmail + '\n \n'
                            + 'Prenez contact dès maintenant pour mettre toutes les chances de votre côté et gagner ce chantier ! \n \n'
                            + 'Plus de détails sur ' + urlToken + '\n \n'
                            + 'À très vite sur Homly You !';
                //System.debug('>>>>>>>>>>>>>>>>> SMS body ' + body);

                //OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(mer.Contact__r.MobilePhone, body);
                //System.debug('>>>>>> RESULTAT = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));

                //mer.Resultat_envoi_SMS__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
                //mer.SMS_envoye__c = (result.isSuccess() ? body : 'Erreur lors de l\'envoi du SMS');
                mer.url_token__c = urlToken;
                //mer.Token_Part_Selectionne__c = hashPart;
                mer.Statut_Selection__c = 'Effectuee';
                
                System.debug('mer.Projet__r.Mises_en_relation_selectionnees__c ' + mer.Projet__r.Mises_en_relation_selectionnees__c);
                System.debug('mer.Projet__r ' + mer.Projet__r);
                
                if (!projetUpdateMap.containsKey(mer.Projet__c) && 
                    (mer.Projet__r.Mises_en_relation_selectionnees__c != null && mer.Projet__r.Mises_en_relation_selectionnees__c > 0)  &&
                    (mer.Projet__r.Statut_Projet__c == 'Pas de pros à suivre' || mer.Projet__r.Statut_Projet__c =='Qualifié') && 
                    (mer.Projet__r.Etat__c == 'ODC ouverte' || mer.Projet__r.Etat__c == 'ODC réouverte')) {
                    projetUpdateMap.put(mer.Projet__c, new Projet__c(Id=mer.Projet__c, Statut_Projet__c = 'En attente de suivi'));
                }
                
            }
            update merList;
            
            if (!projetUpdateMap.isEmpty()) {
                update projetUpdateMap.values();
            }

            if (tokenList.size() > 0) {
                insert tokenList;
            }

            
        
        } catch (Exception e) {
            Batch_Valide_Finish = true;
            System.debug('Apex Class : Batch_ValideIntermediation, An error occurred during the batch execution: ' + e.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC) {
    	Integer size = [SELECT Id, Statut_Selection__c FROM Intermediation__c WHERE Statut_Selection__c = 'Validee'].size();
    	
    	System.debug('size ' + size);
    	System.debug('Batch_Valide_Finish ' + Batch_Valide_Finish);

        if (Batch_Valide_Finish == false && [SELECT Id, Statut_Selection__c FROM Intermediation__c WHERE Statut_Selection__c = 'Validee'].size()>0){
            Batch_ValideIntermediation batch = new Batch_ValideIntermediation();
            Database.executeBatch(batch);
        }
    }
}