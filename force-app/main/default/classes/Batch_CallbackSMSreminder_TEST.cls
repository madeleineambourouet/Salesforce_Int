/**
 * @File Name          : Batch_CallbackSMSreminder_TEST.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 5/20/2020, 9:30:19 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/20/2020   Hassan Dakhcha     Initial Version
**/
// 
// Test du Batch pour l'envoi de SMS de rappel de callback
// 17/11/2017, xavier templet, version initiale   
//

//@isTest
@isTest(seeAllData=false)
private class Batch_CallbackSMSreminder_TEST {

	
 public static String CRON_EXP = '0 08 11 14 11 ? 2100';
 
 private static testMethod void Test1_Batch_CallbackSMSreminder() {


// Créer un compte pro
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                         Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte; 
     

// Creer un compte particulier pour le projet
        Account Part = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          PersonEmail='toto@gmail.com');
        
        insert Part;
        
//Créer un projet affilié à Part et l'insert
        Projet__c projet = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= Part.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                              Description__c='description test youhou');
        
        insert projet;
        
 
//Créer un définition de créneau
       Def_Creneau__c DefName = new  Def_Creneau__c( Heure_Debut__c = '08h00', Jour_de_la_semaine__c ='Lundi');
        insert DefName;        
        
//Créer un créneau
		DateTime Time1 = DateTime.now();
		Time1 = Time1.addMinutes(90);
        Creneau__c creneau = new Creneau__c (Reference_du_Creneau__c = DefName.id, Reservations__c = 1, Date_Horaire__c = Time1, Quota__c = 3, Groupe_Odigo__c = 'Accueil Client Part.' );
        insert creneau; 

		//Créer un rappel     
        Rappel__c rappel1 = new Rappel__c( Date_Horaire__c = Time1, Reference_du_Creneau__c = DefName.id, No_de_Rappel__c = '0600000000', Type_de_demande__c ='WCB Créneau', Projet__c = projet.id, Compte__c = compte.id, Queue_Odigo__c = 'accueil_client_part');
        insert rappel1;          
        
        rappel1.Statut_CTI__c = 'Planifié';
        update rappel1;
  	
		Test.startTest();
		//Test.setMock(WebServiceMock.class, new WSodigoMock.CallBackWSmock());
    	//WSodigoMock.SelectMock = 'SendSMS';
		String jobId = System.schedule('Scheduled_Batch_CallbackSMSreminder_TEST',CRON_EXP, new Batch_CallbackSMSreminder());         
        Batch_CallbackSMSreminder b = new Batch_CallbackSMSreminder(); 
        database.executebatch(b);
  	
		//System.assert(rappel1.SMSreminder__c == 'OK');
  	
		Test.stopTest();
    		      
 	}
 
}