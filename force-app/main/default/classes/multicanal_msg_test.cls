/**
 * @File Name          : multicanal_msg_test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/12/2020, 10:44:55 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/12/2020   Hassan Dakhcha     Initial Version
**/
global class multicanal_msg_test {
    
    @future(callout = true)
    webservice static void sendSMSSelectionTest(Id idCtc, String proPhoneNumber, String proName){
        /*
        Contact ContactPro = [SELECT id FROM Contact WHERE id = :idCtc LIMIT 1];

        String body = '';
        body = 
                + 'HOMLY YOU.  XX   XXXXX  souhaite faire appel à vos services pour son projet à   XXXX.\n \n'
                + 'Descriptif du projet :  XXXX  \n \n'
                + 'Coordonnées du particulier : \n' 
                + 'XXXXX\n'
                + 'XXXXX\n'
                + 'XXXXX\n \n'
                + 'Prenez contact dès maintenant pour mettre toutes les chances de votre côté et gagner ce chantier ! \n \n'
                + 'Plus de détails sur XXXXXX\n \n'
                + 'À très vite sur Homly You !';
                
        OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(proPhoneNumber, body);
        System.debug('>>>>>> RESULTAT WS01_OdigoSms = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));
        
        ContactPro.Resultat_test_SMS__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
        //ContactPro.SMS_test__c = (result.isSuccess() ? body : 'Erreur lors de l\'envoi du SMS');
        update ContactPro;
        */
    
    }

    @future(callout = true)
    webservice static void generateEmailTest(ID ContactId, ID WhatId){
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'Selection_du_pro_test_mail_du_pro'];
		List<OrgWideEmailAddress> lstEmailAddress = [SELECT Id from OrgWideEmailAddress where DisplayName = 'Homly-You'];
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(lstEmailTemplates[0].Id);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(ContactId); // The ID of the contact, lead, or user to which the email will be sent
		mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
        
        mail.setWhatId(WhatId); // Enter your record Id whose merge field you want to add in template
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('>>>>>> RESULTAT = ' + (resultMail[0]));

        
    }
    

}