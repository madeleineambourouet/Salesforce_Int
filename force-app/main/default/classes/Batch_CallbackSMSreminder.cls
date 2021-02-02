/**
 * @File Name          : Batch_CallbackSMSreminder.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/11/2020, 2:31:59 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
**/
//
// Batch pour envoi de SMS pour rappel imminent de callback par le CRC. 
// Note: Le Batch doit être lancé 1h avant les rappels ciblés. 
// Note; Batch_SMSreminder_Period (en heures) définit le délais entre 2 batchs 
// 13/11/2017, xavier templet, creation
//

public with sharing class Batch_CallbackSMSreminder implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable  {
    
    String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        

		Integer Period = Integer.valueOf(Label.Batch_SMSreminder_Period);
        // DateTime.now() returns the current Datetime based on a GMT calendar
		DateTime time1 = DateTime.now();
        System.debug('>>>>> Batch_CallbackSMSreminder NOW: ' + time1);
		time1 = time1.addMinutes(50);
		DateTime time2 = time1.addMinutes(Period * 60 + 05);

		//List<Rappel__c> ListRappel = 
		query = 'Select Projet__c,	Projet__r.Particulier__c, Projet__r.Particulier__r.Salutation, Projet__r.Particulier__r.Name, '+ 
			'Projet__r.Particulier__r.PersonMobilePhone, Projet__r.Particulier__r.PersonEmail, Projet__r.Titre__c, Projet__r.Statut_Projet__c, Projet__r.Etat__c, Projet__r.Flux_Categorie__c, ' + 
				'Date_Horaire__c, No_de_Rappel__c, Type_de_demande__c, Queue_Odigo__c, SMSreminder__c FROM Rappel__c '+ 
					'WHERE Type_de_demande__c = \'WCB Créneau\' AND Date_Horaire__c >= :time1 AND Date_Horaire__c < :time2 '+ 
 						'AND Statut_CTI__c = \'Planifié\' AND (SMSreminder__c = null OR SMSreminder__c = \'\')'; 
						//AND Queue_Odigo__c = \'accueil_client_part\'
						 
        if(test.Isrunningtest()){
            // query = 
        }
             
        //system.debug('>>>>> Batch_CallbackSMSreminder query: ' + query);      
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Rappel__c> scope) {
    try {
        System.debug('>>>>> Batch_CallbackSMSreminder scope ' + scope);
        System.debug('>>>>> Batch_CallbackSMSreminder scope.size() ' + scope.size());

/*Créer un template de mail
		EmailTemplate template = new EmailTemplate();
		template.FolderId = '00l3E000000I2mVQAS';
		template.TemplateType = 'text';
 		template.Name = 'Rappel RDV WCB';
 		template.developername = 'Rappel_RDV_WCB';
 		template.Body = 'Bonjour {!Account.Name},'+
			'Comme prévu, un de nos conseillers Homly You va vous appeler dans 1h environ du 07 56 78 03 69 '+
			'pour vous proposer les meilleurs artisans pour votre projet "{!Projet__c.Flux_Categorie__c}". A tout à l’heure !';
		insert template;
*/		
		EmailTemplate template = [select id, name, body from EmailTemplate where developername = 'Rappel_RDV_WCB']; 
		System.debug('>>>>> Batch_CallbackSMSreminder template = ' + template); 
		List<String> bodies = new List<String>();
		bodies.add(template.Body);
		
		//List<OdigoSms.WS01_OdigoSms.Input> inputList = new List<OdigoSms.WS01_OdigoSms.Input>();
		List<SMSinput> inputList = new List<SMSinput>();
		for(Rappel__c r : scope){
			//OdigoSms.WS01_OdigoSms.Input input = new OdigoSms.WS01_OdigoSms.Input();
			SMSinput input = new SMSinput();
			List<Messaging.RenderEmailTemplateBodyResult> RenderResult = new List<Messaging.RenderEmailTemplateBodyResult>();
			if (r.No_de_Rappel__c.left(2) == '06' || r.No_de_Rappel__c.left(2) == '07' || r.No_de_Rappel__c.left(4) == '+336' || r.No_de_Rappel__c.left(4) == '+337') {
                //System.debug('>>>>> Batch_CallbackSMSreminder No de Rappel ' + r.No_de_Rappel__c);

				//public static List<Messaging.RenderEmailTemplateBodyResult> renderEmailTemplate(String whoId, String whatId, List<String> bodies)
				RenderResult = Messaging.renderEmailTemplate(r.Projet__r.Particulier__r.Id, r.Projet__r.Id, bodies);
				System.debug('>>>>> Batch_CallbackSMSreminder SMS body = ' + RenderResult); 
				input.phoneNumber = r.No_de_Rappel__c; // Format: 0ZABPQMCDU, +33ZABPQMCDU
				input.textMessage = RenderResult[0].getMergedBody(); // Format: 1-640 c.
				//input.templateId = template.Id;
				//input.templateTargetObjectId = r.Projet__r.Particulier__r.Id;
				//input.templateWhatId = r.Projet__r.Id;
				//input.saveAsActivity // Enable Task save
				//input.taskWhoId // Lookup(Contact,Lead)
				//input.taskWhatId // Lookup(Contract,Order,Campaign,Account,Opportunity,…)
				//input.taskOwnerId // Lookup(User,Calendar)
				//input.taskType // Call, Meeting, Other, Email, SMS
				//input.taskSubject // if empty write default SMS sent on 0630481372 at 13/11/2014 11:44:47
				inputList.add(input);

                //OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(r.No_de_Rappel__c, RenderResult[0].getMergedBody());
                //System.debug('>>>>> Batch_CallbackSMSreminder RESULTAT = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));
                //r.SMSreminder__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);

			}
		}
        System.debug('>>>>> Batch_CallbackSMSreminder JSON Input = ' + JSON.serialize(inputList));
		/*OdigoSms.WS01_OdigoSms.Result result = new OdigoSms.WS01_OdigoSms.Result();
		result = OdigoSms.WS01_OdigoSms.sendTextMessages(JSON.serialize(inputList));
        System.debug('>>>>> Batch_CallbackSMSreminder RESULTAT = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));
		for(Rappel__c r : scope) r.SMSreminder__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
		update scope;
		*/
		
		
	} catch (Exception e) {
            System.debug('Apex Class : Batch_CallbackSMSreminder, An error occurred during the batch execution: ' + e.getMessage());
        }

	}

	private class SMSinput {
		String phoneNumber;
		String textMessage;
	}
	
    public void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute(SchedulableContext context) {
        Batch_CallbackSMSreminder b = new Batch_CallbackSMSreminder(); 
        database.executebatch(b);
    }
    
}