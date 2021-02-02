/**
 * @File Name          : AccountMethods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 01-16-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/8/2020   Hassan Dakhcha     Initial Version
**/
public class AccountMethods 
{
    // Version generate token unitaire
    public static String generateToken(String login, Integer validity, Integer nUsages, String email)
    {
        String res = '';
        //String hash = '';
        
        Blob targetBlob = Blob.valueOf(login + Datetime.now().getTime());
        Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
        String hash = EncodingUtil.convertToHex(hashBlob);
        //System.debug('>>>>>>>>>>>>>>>>>> hash = ' + hash);
        Account acc;
        if (login != null && login.length() > 0)
            acc = [SELECT id, login__c, Mail_de_facturation__c FROM Account WHERE login__c = :login LIMIT 1];
        //System.debug('Account ' + acc);
        try {
            Token__c token = new Token__c(
                Name = hash,
                Compte__c = acc.Id,
                Validite__c = validity,
                Nombre_d_usage_token_restant__c = nUsages,
                Type_de_token__c = email,
                URL_redirection__c = Label.URL_web_pour_email + hash,
                Email_du_compte__c = (email == 'Quote' ? acc.Mail_de_facturation__c : acc.login__c)
            );
            insert token;
            res = token.URL_redirection__c;
            //System.debug('res token' + res);
        } catch (Exception e) {}
        //System.debug('>>>>>>>>>>>>>>>>>> URL = ' + res);
        return res;
        //return 'http://www.pointp.com/'+ hash;
    }
    
    // Version generate token "bulkifié"
    public static List<Token__c> generateToken(List <String> logins, Integer validity, Integer nUsages, String email)
    {
        Integer j = 0;
        while (j < logins.size()) {
            if(logins.get(j) == null) {
                logins.remove(j);
            }else {
                j++;
            }
        }   
        List<Account> AccListToUpdate = new List<Account>();  
        List<Account> accList = [SELECT id, login__c, Mail_de_facturation__c FROM Account WHERE login__c IN :logins];
        List<Token__c> TokenList = new List<Token__c>();
        
        try {
            for (Account Acc : accList) {
                
                if  (Acc.login__c != null) {
                    
                    Blob targetBlob = Blob.valueOf(Acc.login__c + Datetime.now().getTime());
                    Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
                    String hash = EncodingUtil.convertToHex(hashBlob);
                    
                    Token__c token = new Token__c(
                        Name = hash,
                        Compte__c = acc.Id,
                        Validite__c = validity,
                        Nombre_d_usage_token_restant__c = nUsages,
                        Type_de_token__c = email,
                        URL_redirection__c = Label.URL_web_pour_email + hash,
                        Email_du_compte__c = (email == 'Quote' ? acc.Mail_de_facturation__c : acc.login__c)
                    );
                    TokenList.add(token);
                }
            }
            insert TokenList;       
        }
        
        catch (Exception e) {}
        
        return TokenList;
    }
    
    public static Boolean checkSiret(String SIRET)
    {
        system.debug('>>>>>>>>>>>>>> SIRET: ' + SIRET);
        //if (pays != 'France'){ return true; }
        if (SIRET == null || SIRET.length() != 14 || !SIRET.isNumeric()){ return false; }
        
        else {
            Integer sum = 0;
            Integer tmp;
            for (Integer count = 0; count < SIRET.length(); count++){
                String letter = SIRET.substring(count,count+1);
                Integer cpt = Integer.valueOf(letter);
                if (Math.mod(count,2) == 0) {
                    tmp = cpt * 2;
                    if (tmp > 9) { tmp = tmp - 9; }
                }
                else {
                    tmp = cpt;
                }
                sum = sum + tmp;
            }
            if (Math.mod(sum,10) == 0) { return true; }
            else { return false; }
        }
        
    }
    
    public static void setUserInfoBySGI(List<Account> comptes, List<Projet__c> projets, Boolean manuel, User currentUser)
    {
        List<String> nSGI = new List<String>();
        List<User> lUsers = new List<User>();
        User projUser = new User(); 
        //User currentUser = [SELECT id, Name, FederationIdentifier, Phone, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        
        if (projets != null) {
            
            for (Projet__c proj : projets){
                if (proj.Numero_SGI__c != null && proj.Numero_SGI__c != ''){ nSGI.add(proj.Numero_SGI__c); }
                else { proj.Numero_SGI__c = ''; proj.Identite_SGI__c = ''; proj.Phone_SGI__c = ''; proj.Adresse_mail__c = ''; }
            }
            
            lUsers = [SELECT id, Name, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE FederationIdentifier IN :nSGI];
            
            for (Projet__c proj : projets){
                if ((proj.Numero_SGI__c == null || proj.Numero_SGI__c == '') && ( proj.Canal__c =='ITCS')) 
                { 
                    projUser = currentUser;
                }
                else{
                    for (User us : lUsers)
                    {
                        if (us.FederationIdentifier == proj.Numero_SGI__c) 
                        { 
                            projUser = us; 
                            
                        }
                    }
                }
                proj.Numero_SGI__c = (proj.Numero_SGI__c == '' ? projUser.FederationIdentifier : proj.Numero_SGI__c);
                proj.Phone_SGI__c = projUser.Phone;
                proj.Identite_SGI__c = projUser.Name;
                proj.Adresse_mail__c = projUser.Email;
                proj.Type_de_source__c = (proj.Type_de_source__c== '' ? projUser.UserRole.Name : proj.Type_de_source__c);
                //System.debug(' >>>>>>>>>> USERNAME APRES MAJ ? ' + proj.Identite_SGI__c + ' USERPHONE APRES MAJ ? ' + proj.Phone_SGI__c);
            }
            
        }
        
        if (comptes != null){
            
            if (manuel){
                for (Account cpt : comptes){
                    cpt.Vendeur_source_pr_inscription_SGI__c = currentUser.FederationIdentifier;
                    cpt.Tel_vendeur_source_pr_inscription__c = currentUser.Phone;
                    cpt.Nom_pr_nom_vendeur_source_pr_inscript__c = currentUser.Name;
                    cpt.Adresse_mail__c = currentUser.Email;
                    cpt.Type_de_source_pr_inscription__c = currentUser.UserRole.Name;
                    //cpt.Source_pr_inscription__c = 'CRM';
                    //cpt.Canal_pr_inscription__c = 'ITCS';
                }
            }
            
            /*else {
for (Account cpt : comptes) {
if (cpt.Vendeur_source_pr_inscription_SGI__c != '' && cpt.Vendeur_source_pr_inscription_SGI__c != null){ nSGI.add(cpt.Vendeur_source_pr_inscription_SGI__c); }
}
lUsers = [SELECT id, Name, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE FederationIdentifier IN :nSGI];
for (Account cpt : comptes){
if (cpt.Vendeur_source_pr_inscription_SGI__c != '' && cpt.Vendeur_source_pr_inscription_SGI__c != null){
cpt.Tel_vendeur_source_pr_inscription__c = '';
cpt.Nom_pr_nom_vendeur_source_pr_inscript__c = '';
cpt.Adresse_mail__c = '';
//cpt.Type_de_source_pr_inscription__c = '';
for (User us : lUsers){
if (us.FederationIdentifier == cpt.Vendeur_source_pr_inscription_SGI__c){
//cpt.Vendeur_source_pr_inscription_SGI__c = us.FederationIdentifier;
cpt.Tel_vendeur_source_pr_inscription__c = us.Phone;
cpt.Nom_pr_nom_vendeur_source_pr_inscript__c = us.Name;
cpt.Adresse_mail__c = us.Email;
cpt.Type_de_source_pr_inscription__c = (cpt.Type_de_source_pr_inscription__c == '' ? us.UserRole.Name : cpt.Type_de_source_pr_inscription__c);
}
}
}
}
}*/
            
        }
        
    }
    
    public static void setDefaultAccountTeam(List<Account> lAcc, User creatorUser)
    {
        // Get the creator => Current User
        //User creatorUser = [SELECT Id, Title FROM User WHERE Id =: UserInfo.getUserId() ];
        
        // Create the default member
        List<AccountTeamMember> laccTeamMember = new List<AccountTeamMember>();
        for (Account acc : lAcc)
        {
            if (creatorUser != null)
            {
                AccountTeamMember member = new AccountTeamMember();
                member.UserId = creatorUser.Id;
                member.AccountId = acc.Id;
                member.TeamMemberRole = creatorUser.Title;
                laccTeamMember.add(member);
            }
        }
        system.debug('>>>>>>>> laccTeamMember: ' + laccTeamMember);
        
        if (laccTeamMember != null && laccTeamMember.size() > 0)
            insert laccTeamMember;
        
        // Recalculate the TC Référent
        List<Account> lAccToUpdate = new List<Account>();
        Set<id> accSet = new Set<id> ();
        for(Account acc : lAcc) {
            accSet.add(acc.id);
        }
        
        lAccTeamMember = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accSet];
        Map<id, List<AccountTeamMember>> mapAccTeamMemList = new Map<id, List<AccountTeamMember>>();
        for(AccountTeamMember tm : laccTeamMember) {
            List<AccountTeamMember> tmList = mapAccTeamMemList.get(tm.AccountId);
            if(tmList == null) {
                tmList = new List<AccountTeamMember>();
                mapAccTeamMemList.put(tm.AccountId, tmList);
            }
            tmList.add(tm);
        }

        for (Account acc : lAcc)
        {
            Account accUpdated = AccountTeam_Utils.Account_calculateTCReference(acc.Id, mapAccTeamMemList.get(acc.id), acc.Pro_ou_Part__c, false);
            if (accUpdated != null)
                lAccToUpdate.add(accUpdated);
        }
        if (lAccToUpdate != null && lAccToUpdate.size() > 0)
            update lAccToUpdate;
    }
    
    public static void setListeEnseignes(List<Account> lAccounts, Boolean nameToCode, List<Reference__c> lEnseignes){
        
        if (lAccounts != null) {
            
            //List<Reference__c> lEnseignes = [SELECT id, Name, key__c FROM Reference__c WHERE RecordType.DeveloperName = 'Enseigne'];
            Map<String, String> enseigneCode = new Map<String, String>();
            
            if (nameToCode){
                for (Reference__c enseigne : lEnseignes){
                    enseigneCode.put(enseigne.Name, enseigne.key__c);
                }
                
                //if (lAccounts != null){
                for (Account compte : lAccounts){
                    String res = '';
                    if (compte.Liste_des_enseignes_de_gestion_o_il_est__c != null){
                        for (String s : compte.Liste_des_enseignes_de_gestion_o_il_est__c.split(';')) {
                            if (s != null && s != '') { res = res + enseigneCode.get(s) + ';'; }
                        }
                    }
                    compte.Flux_code_Enseigne__c = res;
                }
                //   }
                
            }
            else {
                for (Reference__c enseigne : lEnseignes){
                    enseigneCode.put(enseigne.key__c, enseigne.Name);
                }
                
                //   if (lAccounts != null){
                for (Account compte : lAccounts){
                    String res = '';
                    if (compte.Flux_code_Enseigne__c != null){
                        for (String s : compte.Flux_code_Enseigne__c.split(';')) {
                            if (s != null && s != '') { res = res + enseigneCode.get(s) + ';'; }
                        }
                    }
                    compte.Liste_des_enseignes_de_gestion_o_il_est__c = res;
                } 
                //  }
                
            }
        }
        
    }
    
    public static void setMailAssurances(List<Account> lAccounts){
        
        Set<ID> lID = new Set<ID>();
        //System.debug('>>>>> COMPTES = ' + lAccounts);
        
        if (lAccounts != null) {
            
            for (Account cpt : lAccounts){ lID.add(cpt.id); }
            
            List<Document_Assurance__c> lAssurances = [SELECT id, contact_principal__c, Compte__c FROM Document_Assurance__c WHERE Compte__c IN :lID];
            //System.debug('>>>>> ASSURANCES = ' + lAssurances);
            for (Account cpt : lAccounts) {
                
                for (Document_Assurance__c assurance : lAssurances){
                    
                    if (assurance.Compte__c == cpt.id) { assurance.contact_principal__c = cpt.Login__c; }
                    
                }
            }
            
            update lAssurances;
            
        }
    }
    
    
    public static String generateCodeClient(List<Account> lAccounts, String lastCode){
        
        Map<Integer, String> allChar = new Map<Integer, String>();
        allChar.put(0,'0');
        allChar.put(1,'1');
        allChar.put(2,'2');
        allChar.put(3,'3');
        allChar.put(4,'4');
        allChar.put(5,'5');
        allChar.put(6,'6');
        allChar.put(7,'7');
        allChar.put(8,'8');
        allChar.put(9,'9');
        allChar.put(10,'B');
        allChar.put(11,'C');
        allChar.put(12,'D');
        allChar.put(13,'F');
        allChar.put(14,'G');
        allChar.put(15,'H');
        allChar.put(16,'J');
        allChar.put(17,'K');
        allChar.put(18,'L');
        allChar.put(19,'M');
        allChar.put(20,'N');
        allChar.put(21,'P');
        allChar.put(22,'Q');
        allChar.put(23,'R');
        allChar.put(24,'S');
        allChar.put(25,'T');
        allChar.put(26,'V');
        allChar.put(27,'W');
        allChar.put(28,'X');
        allChar.put(29,'Z');
        
        for (Account compte : lAccounts){
            if (Test.isRunningTest() && compte.Code_client__c !=null) {
                return null;
            } else {
                lastCode = increment(lastCode, allChar);
                compte.code_client__c = lastCode;
            }
        }
        
        return lastCode;
        
    }
    
    public static String increment(String code, Map<Integer, String> allChar){
        
        String c0 = code.substring(0,1);
        String c1 = code.substring(1,2);
        String c2 = code.substring(2,3);
        String c3 = code.substring(3,4);
        String c4 = code.substring(4,5);
        
        Integer i=0;
        String res = '';
        
        while (c4 != allChar.get(i)){
            i++;
        }
        
        if (i!=29) {
            //for (Integer i=0; i<allChar.size(); i++){
            //if ( c4 == allChar.get(i) ) {
            // if (i!=29) { 
            c4 = allChar.get(i+1); 
            res = c0+c1+c2+c3+c4; 
        }
        else {
            c4 = '0';
            Integer j=0;
            while (c3 != allChar.get(j)){
                j++;
            }
            if (j!=29){
                c3 = allChar.get(j+1);
                res = c0+c1+c2+c3+c4;
            }
            else {
                c3 = '0';
                Integer k=0;
                while (c2 != allChar.get(k)){
                    k++;
                }
                if (k!=29){
                    c2 = allChar.get(k+1);
                    res = c0+c1+c2+c3+c4;
                }
                else {
                    c2 = '0';
                    Integer l=0;
                    while (c1 != allChar.get(l)){
                        l++;
                    }
                    if (l!=29){
                        c1 = allChar.get(l+1);
                        res = c0+c1+c2+c3+c4;
                    }
                    else {
                        c1 = '0';
                        Integer m=0;
                        while (c0 != allChar.get(m)){
                            m++;
                        }
                        if (m!=29){
                            c0 = allChar.get(m+1);
                            res = c0+c1+c2+c3+c4;
                        }
                    }
                }
            }
        }
        //System.debug('>>>>>> nouveau code client = ' + res);
        return res;
        
    }


    /**
    * @author Clement Musabimana
    * @date 23/12/2019
    * @description fonction permettant de recuprer un token d'activation de mail
    **/
    @future (callout=true)
    public static void callProjectPlaceActivationToken(String email,Id accId) {

        String jsonResp = '';
        //System.debug('callProjectPlaceActivationToken* Label.URL_ProjectPlaceActivationAccountEndpointToken '+ Label.URL_ProjectPlaceActivationAccountEndpointToken);
        //System.debug('callProjectPlaceActivationToken* Label.URL_ProjectPlaceActivationAccountEndpointTokenGenereate '+Label.URL_ProjectPlaceActivationAccountEndpointTokenGenereate);
        //System.debug('callProjectPlaceActivationToken* Label.URL_ProjectPlaceActivationAccountUser '+Label.URL_ProjectPlaceActivationAccountUser);
        //System.debug('callProjectPlaceActivationToken* Label.URL_ProjectPlaceActivationAccountPassword '+Label.URL_ProjectPlaceActivationAccountPassword);
        //System.debug('callProjectPlaceActivationToken* email '+email);
        //System.debug('callProjectPlaceActivationToken* accId '+accId);
        String urlEndPoint = Label.URL_ProjectPlaceActivationAccountEndpointToken+Label.URL_ProjectPlaceActivationAccountEndpointTokenGenereate+email+'&idClient='+accId;
        Blob headerValue = Blob.valueOf(Label.URL_ProjectPlaceActivationAccountUser + ':' + Label.URL_ProjectPlaceActivationAccountPassword);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(urlEndPoint);
        HttpResponse res;

        //System.debug('callProjectPlaceActivationToken* authorizationHeader '+authorizationHeader);
        //System.debug('callProjectPlaceActivationToken* headerValue '+headerValue);
        
        //System.debug('callProjectPlaceActivationToken email ' + email);
        if (!Test.isRunningTest()){
            //System.debug('callProjectPlaceActivationToken envoi ok ');
            if(email != ''){
                res = h.send(req);
                jsonResp = res.getBody();
            }
        }
        else{
            jsonResp = '{"token":"2123546fa665a26e36a1800cbf3b24a5c044ffdb302195e946a8f73e16654331","email":"clem.demonstrationcmu_test08112019@gmail.com","path":"/pp/account/verify?email=clem.demonstration cmu_test08112019@gmail.com&token=2123546fa665a26e36a1800cbf3b24a5c044ffdb302195e946a8f73e16654331"}';
        }
        
        
        //System.debug('callProjectPlaceActivationTokenres.getBody() ' + jsonResp);
        if ((res != null && res.getStatusCode() == 200) || Test.isRunningTest()){
            Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonResp);
            String token = (String)mBody.get('token');
            String path = (String)mBody.get('path');
            //System.debug('callProjectPlaceActivationToken* token '+token);
            //System.debug('callProjectPlaceActivationToken* path '+path);
            //System.debug('callProjectPlaceActivationToken retour ok ');
            Account accToUpdate = new Account();
            accToUpdate.Id = accId;
            accToUpdate.URL_validation_Email__c = Label.URL_ProjectPlaceActivationAccountEndpointHost+path;
            accToUpdate.Statut_activation__c = 'En_attente_activation';
            update accToUpdate;
        }

 
    }
    
    //public static void checkActifPro(List<Account> accs) {
    //    List<Account> accResi = new List<Account>();
    //    List<Account> accFill = new List<Account>();
    
    //    for (Account a : accs) {
    //        if (a.Statut_de_la_souscription__c == 'Cancelled') {
    //            accResi.add(a);
    //        }
    //    }
    
    //    if (accResi.size() > 0) {
    //        for (Account a : [SELECT Id, Remise_consommee__c FROM Account WHERE Parrain__c IN :accResi AND Remise_consommee__c = false]) {
    //            a.Remise_consommee__c = true;
    //            accFill.add(a);
    //        } 
    //        update accFill;
    //    }
    //}
    
    //public static String beGodSon(List<Account> accs, Map<Id, Account> oldAccs) {
    //    Account fill;
    
    //    if (accs.size() == 1) {
    //        for (Account a : accs) {
    
    //            fill = a;
    //        }
    
    //        if (fill.Parrain__c != oldAccs.get(fill.Id).Parrain__c &&
    //            fill.Parrain__c != null) {
    
    //            if ([SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__c = :fill.Id AND (Zuora__Status__c = 'Active' OR Zuora__Status__c = 'Pending Activation')].size() != 0) {
    //                return 'Vous ne pouvez pas rattacher de parrain à ce compte.';
    //            }
    //            Date d = Date.today().addMonths(-3);
    //            if ([SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__c = :fill.Id AND Zuora__SubscriptionEndDate__c >= :d ORDER BY Zuora__SubscriptionEndDate__c DESC LIMIT 1].size() != 0) {
    //                return 'Le compte est résilié depuis moins de 3 mois, vous ne pouvez pas rattacher de parrain à ce compte.';
    //            }
    
    //            fill.Premiere_souscription__c = 'NEW';
    //            Contact fillcon = [SELECT Id, Name FROM Contact WHERE Id = :fill.contact_principal__c LIMIT 1];
    //            OrgWideEmailAddress oa = [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%' LIMIT 1];
    //            Account parrain =  [SELECT Id, Contact_principal__c, Contact_principal__r.Name, Contact_principal__r.Email FROM Account WHERE Id = :fill.Parrain__c LIMIT 1];
    
    //            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //            mail.setToAddresses(new String[] {parrain.Contact_principal__r.Email});
    //            mail.setSubject('Homly You : merci pour votre parrainage');
    //            mail.setBccSender(false);
    //            mail.setHtmlBody(MailHelper.PARRAINAGE_mailremerciement(parrain.Contact_principal__r.Name, fillcon.name, fill.Name));
    //            //mail.setTargetObjectId(parrain.Contact_principal__c);
    //            //mail.setSaveAsActivity(false);
    //            mail.setOrgWideEmailAddressId(oa.Id);
    //            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    //        }
    //    }
    //    return null;
    //}
    
    
    // public static void subscribeGodSon(List<Account> accs, Map<Id, Account> oldAccs) {
    //    Account fill;
    
    //    if (accs.size() == 1) {
    //        for (Account a : accs) 
    //            fill = a;
    
    //        if (fill.Parrain__c == oldAccs.get(fill.Id).Parrain__c &&
    //            fill.Parrain__c != null && 
    //            fill.Statut_de_la_souscription__c != oldAccs.get(fill.Id).Statut_de_la_souscription__c &&
    //            fill.Statut_de_la_souscription__c == 'Active' &&
    //            fill.Premiere_souscription__c == 'NEW') {
    
    //            fill.Premiere_souscription__c = 'OLD';
    //            Contact fillcon = [SELECT Id, Name FROM Contact WHERE Id = :fill.contact_principal__c LIMIT 1];
    //            OrgWideEmailAddress oa = [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%' LIMIT 1];
    //            Account parrain =  [SELECT Id, Contact_principal__c, Contact_principal__r.Name, Contact_principal__r.Email FROM Account WHERE Id = :fill.Parrain__c LIMIT 1];
    
    //            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //            mail.setToAddresses(new String[] {parrain.Contact_principal__r.Email});
    //            mail.setSubject('Homly You : votre filleul s\'est inscrit');
    //            mail.setBccSender(false);
    //            mail.setHtmlBody(MailHelper.PARRAINAGE_mailinscrit(parrain.Contact_principal__r.Name, fillcon.name, fill.Name));
    //            //mail.setTargetObjectId(parrain.Contact_principal__c);
    //            //mail.setSaveAsActivity(false);
    //            mail.setOrgWideEmailAddressId(oa.Id);
    //            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    //        }
    //    }
    
    // }

    public static void setIsUpdatedBySF(List<Account> accList, Map<id, Account> oldMAp, Boolean isInsert) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(Account acc : accList) {
            // Transaction id for synchro :
            acc.tech_transaction_id__c = transaction_id;

            if(System.isBatch() || System.isQueueable()) {
                acc.last_updated_by_sf__c = false;
            } else {
                acc.last_updated_by_sf__c = sfUser;
            }
            if( ( (acc.Compte_Nouvelles_Offres__c == true && (acc.Pro_Pilote__c == true || acc.isPersonAccount == true || acc.Nat_To_Sync__c== true)) 
                  || acc.compte_standalone__c ==true)
                &&
               ( isInsert== true 
                 || (oldMap.get(acc.id).Compte_Nouvelles_Offres__c != acc.Compte_Nouvelles_Offres__c)
                 || (oldMap.get(acc.id).compte_standalone__c != acc.compte_standalone__c))) {
                acc.Fire_Trigger__c = Datetime.now();
            }
        }
    }

    // After Update only
    public static void triggerPushTopicOnProObjects(Map<id, Account> accMap, Map<id, Account> oldMap) {
        Set<id> ctcSet = new Set<id>();
        Set<id> accSet = new Set<id>();
        Map<id, boolean> onlyStandaloneMap = new Map<id, boolean>();
        for(id accId : accMap.keySet()) {
            Account acc = accMap.get(accId);
            onlyStandaloneMap.put(acc.id, false);
            if(acc.isPersonAccount == false 
                && (acc.Fire_Trigger__c!= null && (oldMap.get(acc.id).Fire_Trigger__c != acc.Fire_Trigger__c))) {
                    Boolean isOnlyStandalone = acc.Compte_Nouvelles_Offres__c == oldMap.get(acc.id).Compte_Nouvelles_Offres__c &&
                                               acc.compte_standalone__c != oldMap.get(acc.id).compte_standalone__c;
                    onlyStandaloneMap.put(acc.id, isOnlyStandalone);
                    if( ((acc.Pro_Pilote__c == true || acc.Nat_To_Sync__c == true) && acc.Compte_Nouvelles_Offres__c == true ) 
                          || acc.compte_standalone__c == true) {
                            ctcSet.add(acc.Contact_principal__c);
                            accSet.add(acc.id); 
                        }
            }
        }
        
        if(accSet.isEmpty()) {
            return;
        }

        List<sObject> allObjects = new List<sObject>();
        Datetime timeValue = Datetime.now();
        for(Id ctc : ctcSet) {
            allObjects.add(new Contact(id=ctc, Fire_Trigger__c = timeValue));
        }

        for(id accId : onlyStandaloneMap.keySet()) {
            // if only stand alone remove them from the Sets
            if(onlyStandaloneMap.get(accId)) {
                accSet.remove(accId);
                ctcSet.remove(accMap.get(accId).Contact_principal__c);
            }
        }

        // Trigger pushtopic on objects related to Contact Principal (dpt/metier/prestation)
        List<Departement__c> dptList = [SELECT id, Fire_Trigger__c FROM Departement__c WHERE Contact__c IN :ctcSet ];
        List<Prestation_Contact__c> pcList = [SELECT id, Fire_Trigger__c FROM Prestation_Contact__c WHERE Contact__c IN :ctcSet];
        List<Metier__c> mtList = [SELECT id, Fire_Trigger__c FROM Metier__c WHERE Contact__c IN :ctcSet];
        List<Document__c> docList = [SELECT id, Fire_Trigger__c FROM Document__c WHERE Compte_Pro__c IN : accSet];
            
        for(Departement__c dpt : dptList) {
            dpt.Fire_Trigger__c = timeValue;
        }
        allObjects.addAll((List<SObject>)dptList);
        for(Prestation_Contact__c pc : pcList) {
            pc.Fire_Trigger__c = timeValue;
        }
        update pcList;
        for(Metier__c mt : mtList) {
            mt.Fire_Trigger__c = timeValue;
        }
        allObjects.addAll((List<SObject>)mtList);
        for(Document__c doc : docList) {
            doc.Fire_Trigger__c = timeValue;
        }
        allObjects.addAll((List<SObject>)docList);
        
        // Commit all objects in a single DML
        Database.update(allObjects, false);      
    }

    public static void proResilieActivated(List<Account> newList, Map<id, Account> oldMAp) {
        Boolean userServiceWeb = UserInfo.getLastName() == 'Service Web';
        for(Account acc : newList) {
            if( userServiceWeb == true && oldMap.get(acc.id).Statut_activation__c != acc.Statut_activation__c) {
                    // do not activate :
                    acc.Statut_activation__c = oldMap.get(acc.id).Statut_activation__c;
                }
        }
    }

    public static void updatePhoneOnProjetLMSG(Map<id, Account> newMap, Map<id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        for(Id accId : newMap.keySet()) {
            if(newMap.get(accId).PersonMobilePhone != oldMap.get(accId).PersonMobilePhone || 
                (newMap.get(accId).PersonMobilePhone ==null && newMap.get(accId).Phone!=oldMap.get(accId).Phone)) {
                accIds.add(accId);
            }
        }
        if(accIds.isEmpty()) {
            return;
        }
        List<Projet_LMSG__c> prjList = new List<Projet_LMSG__c> ([ SELECT id, Telephone_Mobile__c, particulier__c 
                                                                  FROM Projet_LMSG__c 
                                                                  WHERE particulier__c IN :accIds]);
        for(Projet_LMSG__c prj : prjList) {
            prj.Telephone_Mobile__c = newMap.get(prj.particulier__c).PersonMobilePhone!=null? newMap.get(prj.particulier__c).PersonMobilePhone : newMap.get(prj.particulier__c).Phone;
        }
        Database.SaveResult[] results = Database.update(prjList, false);
        for(DataBase.SaveResult res : results) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  :updatePhoneOnProjetLMSG Update des projet a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }
}