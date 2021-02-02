/**
 * @File Name          : Odigo_SMS.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 7/1/2020, 11:18:05 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/18/2020   Hassan Dakhcha     Initial Version
**/
global class Odigo_SMS {
    
    webservice static void generateTokenSMS(Id IDMeR, String proPhoneNumber, String proName, String partName, String partPhoneNumber, 
                                            String partMail, String projetName, String projetcategorie, String projetDescription,
                                            String projetLieu, String proLogin, String projetPartCivilite) {

        Intermediation__c miseEnRelation = [SELECT id FROM Intermediation__c WHERE id = :IDMeR LIMIT 1];
        if(miseEnRelation != null) {
            String token = AccountMethods.generateToken(proLogin, 31, 5, '');
            miseEnRelation.url_token__c = Label.URL_web_pour_email + 'pro/mon-espace#/project/' + IDMeR + '/' + token.substringAfter(Label.URL_web_pour_email);
            update miseEnRelation;
        } 

        //sendSMSSelection(IDMeR, proPhoneNumber, proName, partName, partPhoneNumber, partMail, projetName, projetcategorie, projetDescription, projetLieu, urlToken, projetPartCivilite);
    }
    /*
    @future(callout = true)
    webservice static void sendSMSSelection(Id IDMeR, String proPhoneNumber, String proName, String partName, String partPhoneNumber, 
                String partMail, String projetName, String projetcategorie, String projetDescription, String projetLieu, String token, String projetPartCivilite){
        
        Intermediation__c miseEnRelation = [SELECT id FROM Intermediation__c WHERE id = :IDMeR LIMIT 1];
        
        String urlToken = Label.URL_web_pour_email + 'pro/mon-espace#/project/' + IDMeR + '/' + token.substringAfter(Label.URL_web_pour_email);
        
        String body = '';
        body = 
                + 'HOMLY YOU. ' + projetPartCivilite + ' ' + partName.toUpperCase() + ' souhaite faire appel à vos services pour son projet à ' + projetLieu + '.\n \n'
                + 'Descriptif du projet : ' + projetcategorie + '\n \n'
                + 'Coordonnées du particulier : \n' 
                + partName.toUpperCase() + '\n'
                + partPhoneNumber + '\n'
                + partMail + '\n \n'
                + 'Prenez contact dès maintenant pour mettre toutes les chances de votre côté et gagner ce chantier ! \n \n'
                + 'Plus de détails sur ' + urlToken + '\n \n'
                + 'À très vite sur Homly You !';
                
        OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(proPhoneNumber, body);
        System.debug('>>>>>> RESULTAT = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));
        
        //miseEnRelation.Date_de_s_lection__c = Date.Today(); 
        //miseEnRelation.selection_par__c = UserInfo.getName(); 
    
        System.debug('>>>>> RESULT ? = ' + result.isSuccess());
        miseEnRelation.Resultat_envoi_SMS__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
        miseEnRelation.SMS_envoye__c = (result.isSuccess() ? body : 'Erreur lors de l\'envoi du SMS');
        miseEnRelation.url_token__c = urlToken;
        update miseEnRelation;
        
        //update miseEnRelation;
        /*if (result.isSuccess()) {
            return '';
        } else {
            return 'Error '+result.message;
        }
    }*/

}