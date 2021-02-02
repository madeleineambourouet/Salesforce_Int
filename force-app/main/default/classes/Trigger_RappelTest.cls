// 
// Classe de test pour le système de webcallback
// 24/04/2017, xavier templet, création   
//


@isTest //(SeeAllData=false)
private class Trigger_RappelTest {
	
 private static testMethod void Test1_Trigger_Rappel() {

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
        Creneau__c creneau = new Creneau__c (Reference_du_Creneau__c = DefName.id, Reservations__c = 1, Date_Horaire__c = Date.today(), Quota__c = 3, Groupe_Odigo__c = 'Accueil Client Part.');
        insert creneau; 

		//Test.setMock(WebServiceMock.class, new WSodigoMock.CallBackWSmock());
		Test.startTest();
    	//WSodigoMock.SelectMock = 'SaveCallBack2';
//Créer un rappel     
        Rappel__c rappel1 = new Rappel__c( Date_Horaire__c = Date.today(), Reference_du_Creneau__c = DefName.id, No_de_Rappel__c = '0600000000', Type_de_demande__c ='WCB Créneau', Projet__c = projet.id, Compte__c = compte.id, Queue_Odigo__c = 'accueil_client_part');
        insert rappel1;          
    
        Rappel__c rappel2 = new Rappel__c( Date_Horaire__c = Date.today(), Reference_du_Creneau__c = DefName.id, No_de_Rappel__c = '0600000001', Type_de_demande__c ='Click2Call', Projet__c = projet.id, Compte__c = compte.id,  Queue_Odigo__c = 'accueil_client_part');
        insert rappel2;          
    
        Rappel__c rappel3 = new Rappel__c( Date_Horaire__c = null, Reference_du_Creneau__c = DefName.id, No_de_Rappel__c = '0600000001', Type_de_demande__c ='WCB Journée', Projet__c = null, Compte__c = null,  Queue_Odigo__c = 'accueil_client_part');
        insert rappel3;          
    
        Rappel__c rappel4 = new Rappel__c( Date_Horaire__c = null, Reference_du_Creneau__c = DefName.id, No_de_Rappel__c = '0600000002', Type_de_demande__c ='WCB Auto', Projet__c = null, Compte__c = null,  Queue_Odigo__c = null);
        insert rappel4; 
        
        rappel1.Statut_CTI__c = 'Planifié';
        update rappel1;
        //system.assert(Integer.ValueOf(projet.Nombre_de_rappels__c)==1);
        rappel1.Statut_CTI__c = 'Supprimé';
        update rappel1;
        //system.assert(Integer.ValueOf(projet.Nombre_de_rappels__c)==0);
        rappel1.Statut_CTI__c = 'Déjà Existant';
        update rappel1;
        //system.assert(Integer.ValueOf(projet.Nombre_de_rappels__c)==0);

//Supprimer un rappel     
    	//WSodigoMock.SelectMock = 'changeStatusCallBack';
        rappel2.Statut_CTI__c = 'Planifié';
    	rappel2.CallBack_Reference__c = '99';
        update rappel2;
 		List<Rappel__c> rlst = [select Id from Rappel__c limit 10];
		if (rlst != null) delete rlst;
  	
		Test.stopTest();
    		      
 }
 
  private static testMethod void Test2_Trigger_Rappel() {

		Test.setMock(WebServiceMock.class, new WSodigoMock.CallBackWSmock());
    	WSodigoMock.SelectMock = 'SaveCallBack2';

		RappelUpdateWS.Result result = new RappelUpdateWS.Result ();

		String phoneNumber='0600000000';
		String skillKeyWord='accueil_client_part';
		String TypeDemande='WCB Créneau';
		String data='testData1';

		// appel aux webservices Odigo par notre classe
		List<String> wcbID = new List<String>();  
		result = RappelUpdateWS.saveCallback2(phoneNumber, skillKeyWord, data, DateTime.newInstance(2018,4,4,11,33,00), TypeDemande, wcbID);
		system.assert(result.isSuccess() == true);
		System.debug('Result: ('+ result.Code +') '+ result.message);
		System.debug('WebCallBack ID: '+ wcbID[0]);

    	WSodigoMock.SelectMock = 'changeStatusCallBack';
		List<Integer> callbackIdList = new List<Integer>(); 
		List<Integer> callBackIdErrorList = new List<Integer>();
		callbackIdList.add(Integer.valueOf(wcbID[0]));
		result = RappelUpdateWS.changeStatusCallBack(callbackIdList, callBackIdErrorList);
		system.assert(result.isSuccess() == true);
		System.debug('Result: ('+ result.Code +') '+ result.message);
		System.debug('callBackIdErrorList '+ callBackIdErrorList);
		
		Test.startTest();
			RappelUpdateWS.changeStatusCallBackOdigo(null,'99');
		Test.stopTest();


  }

 
}