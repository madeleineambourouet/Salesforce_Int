/**
 * @File Name          : Odigo_SMS_Archi.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/18/2020, 4:57:43 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/18/2020   Hassan Dakhcha     Initial Version
**/
global class Odigo_SMS_Archi {
  /*         
    public static void intermediaire (Id IDMeR, Date DateMerArchi, String proPhoneNumber, String partName, String partPhoneNumber, String partMail, String projetLieu, Id projetId) {
        sendSMSMerArchi(IDMeR, DateMerArchi, proPhoneNumber, partName, partPhoneNumber, partMail, projetLieu, projetId);
    }
    
    
    @future(callout = true)
      webservice static void sendSMSMerArchi(Id IDMeR, Date DateMerArchi, String proPhoneNumber, String partName, String partPhoneNumber, String partMail, String projetLieu, Id projetId){
          
        Intermediation__c miseEnRelation = [SELECT id,Date_MER_Architecte__c,RecordType.Name  FROM Intermediation__c WHERE id = :IDMeR LIMIT 1];
        Projet__c projet;
        for ( Projet__c p : [select id, Particulier__r.Salutation,TEXTELIBRE__c from  Projet__c  where id = :projetId]) {
        	projet = p;
        }
        
        String body = '';
        body = 
                + 'Mon Maître Carré et son partenaire HOMLY YOU, vous proposent un projet.\n \n'
                + projet.Particulier__r.Salutation + ' ' + partName.toUpperCase() + ' souhaite faire appel à vos services pour son projet à ' + projetLieu + '.\n \n'
                + 'Descriptif du projet : ' + projet.TEXTELIBRE__c + '.\n \n'
                + 'Coordonnées du particulier : \n' 
                + partName.toUpperCase() + '\n'
                + partPhoneNumber + '\n'
                + partMail + '\n \n'
                + 'Prenez contact dès maintenant. \n \n'
                + 'À très bientôt !';
                
        //miseEnRelation.Resultat_envoi_SMS_Archi__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
        
        
        OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(proPhoneNumber, body);
        System.debug('>>>>>> RESULTAT = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));
                   
        System.debug('>>>>> RESULT ? = ' + result.isSuccess());
        miseEnRelation.Resultat_envoi_SMS_Archi__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
        miseEnRelation.SMS_envoye_a_Archi__c = (result.isSuccess() ? body : 'Erreur lors de l\'envoi du SMS');
        update miseEnRelation;
        
          }*/
  }