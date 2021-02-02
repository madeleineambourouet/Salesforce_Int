/**
 * @File Name          : MatchTestClass.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-02-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/6/2020   Hassan Dakhcha     Initial Version
**/
@isTest
private class MatchTestClass{

	@isTest static void getMatchForAccountTest() {
		Test.startTest();
		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);

		// Get Match for the ACC1 / PRO1


		Account pro1 = [SELECT id, External_ID__c, Name, Contact_principal__r.External_Contact_id__c FROM Account WHERE Login__c = 'mail1@testorg.com'];

		String endPointArgs = 'userIds=' + pro1.Contact_principal__r.External_Contact_id__c + '&projectIds=' + '&archived=false'; 
		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408232","positionable":true,"positionedCount":0},'+
							   '{"projectId":"P002","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T13:11:01.170462","positionable":true,"positionedCount":0},'+
							   '{"projectId":"P003","userId":"CONTACT1_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
							   '{"projectId":"P004","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';
		mock.setResponseBody(responseBody);
		mock.setEndPointArgs(endPointArgs);

		Map<id, Projet_LMSG__c> prjMap = new Map<id, Projet_LMSG__c>([SELECT id, Name, Identifiant_PP__c FROM Projet_LMSG__c]);
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' ;
		List<MatchObjectClass> lMatch = MatchMethods.getMatchForSObject(pro1.id);
		List<String> idPP = new List<String> {'P001', 'P002','P003','P004'};
		System.assertEquals(4, lMatch.size(), 'Must get 4 Matches for PRO1' );
		System.assertEquals(MatchMethods.getMatchNumber(pro1.id), '  Nombre total de matchs : ' + String.valueOf(lMatch.size()), 'Must get 4 Matches for PRO1' );

		for(MatchObjectClass match : lMatch) {
			String idPrjFromMatch = match.ProjectURL.substringBetween(baseURL, '/view?0.source=alohaHeader');
			Projet_LMSG__c project = prjMap.get(idPrjFromMatch);
			System.assertEquals(project.id, idPrjFromMatch,  'Id of project' );
			System.assertEquals(true, idPP.contains(project.Identifiant_PP__c), 'Correct PP Id of project' );
			System.assertEquals(project.Identifiant_PP__c =='P003'? 'Positionné' : 'Nouveau', match.Status, 'Match Status' );

			String idAccFromMatch = match.AccountURL.substringBetween(baseURL, '/view?0.source=alohaHeader');
			System.assertEquals(pro1.id, idAccFromMatch,  'Id of Account pro1' );
			System.assertEquals(pro1.Name, match.AccountName,  'Id of Account pro1' );
		}
		Test.stopTest();
	}

	@isTest static void getMatchForProjectTest() {
		Test.startTest();
		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);

		// Get Match for the ACC1 / PRO1
		List<Account> proList = [SELECT id, External_ID__c, Contact_principal__r.External_Contact_id__c, Name FROM Account];
		Projet_LMSG__c prjP001 = [SELECT id, Name, Identifiant_PP__c, nombre_de_match_Visibles__c FROM Projet_LMSG__c WHERE Identifiant_PP__c='P001' ];

		String endPointArgs = 'userIds=' +'&projectIds='+prjP001.Identifiant_PP__c + '&archived=false'; 
		mock.setEndPointArgs(endPointArgs);

		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408232","positionable":true,"positionedCount":0},'+
							   '{"projectId":"P001","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';
		mock.setResponseBody(responseBody);

		List<MatchObjectClass> lMatch = MatchMethods.getMatchForSObject(prjP001.Id);

		System.assertEquals(2, lMatch.size(), 'P001 have only 2 matchs' );
		prjP001 = [SELECT id, Name, Identifiant_PP__c, nombre_de_match_Visibles__c FROM Projet_LMSG__c WHERE Identifiant_PP__c='P001' ];
		System.assertEquals(prjP001.nombre_de_match_Visibles__c , 2, 'num match on project updated' );
		
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' ;
		for(MatchObjectClass match : lMatch) {
			String idPrjFromMatch = match.ProjectURL.substringBetween(baseURL, '/view?0.source=alohaHeader');
			System.assertEquals(prjP001.id, idPrjFromMatch,  'Id of project' );

			String idAccFromMatch = match.AccountURL.substringBetween(baseURL, '/view?0.source=alohaHeader');
			System.assertEquals(true,  idAccFromMatch==proList[0].id || idAccFromMatch==proList[1].id,  'Id of Account pro' );
		}
		Test.stopTest();
	}
	
	
	@isTest static void batchAccountTest() {
	
		Test.startTest();
		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);
		
		// Get Match for the ACC1 / PRO1
		List<Account> pros = [SELECT id, External_ID__c, Name, Contact_principal__r.External_Contact_id__c FROM Account WHERE isPersonAccount = false];
		String endPointArgs = 'userIds=';
		for(Account acc : pros) {
			endPointArgs +=  acc.Contact_principal__r.External_Contact_id__c +',';
		}
		mock.setEndPointArgs(endPointArgs.substringBeforeLast(',') + '&projectIds=' + '&archived=true');
		System.debug('#### HDAK endPoint' + endPointArgs.substringBeforeLast(',') + '&projectIds=');

		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408232","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T13:11:01.170462","positionable":true,"positionedCount":0},'+
								'{"projectId":"P003","userId":"CONTACT1_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P001","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT2_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P004","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';

		mock.setResponseBody(responseBody);

		for(Account acc : pros)
			acc.nombre_de_match_Visibles__c = 0;
		update pros;

		List<Account> accLISST = [SELECT id, External_ID__c, Name, nombre_de_match_Visibles__c FROM Account WHERE Compte_Nouvelles_Offres__c=true AND External_ID__c!='' AND isPersonAccount = false];
		for(Account acct : accLISST) {
			System.debug('#### acc name' + acct.Name + 'Num match= ' + acct.nombre_de_match_Visibles__c);
			System.assertEquals(0,  acct.nombre_de_match_Visibles__c,  'Must have 0 match' );
		}
		MatchCounterBatch b = new MatchCounterBatch ('ACCOUNT', false, false, 0); 
        database.executebatch(b);
		Test.stopTest();

		pros = [SELECT id, External_ID__c, Name, nombre_de_match_Visibles__c FROM Account  WHERE isPersonAccount = false];
		Map<String, Integer> AccNumMatch = new Map<String, Integer> {'PRO1' => 4 , 'PRO2' => 2 , 'Albert Heinestein' => null};
		for(Account acc : pros) {
			System.debug('#### acc name' + acc.Name + 'Num match= ' + acc.nombre_de_match_Visibles__c);
			System.assertEquals(AccNumMatch.get(acc.Name)==null? 0 : AccNumMatch.get(acc.Name),  acc.nombre_de_match_Visibles__c,  'Must have correct match number' );
		}
	}	


	@isTest static void batchProjectTest() {
		
		Test.startTest();
		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);
		
		List<Projet_LMSG__c> prjList = [SELECT id, Identifiant_PP__c, nombre_de_match_Visibles__c FROM Projet_LMSG__c WHERE Identifiant_PP__c!=''];
		String endPointArgs = 'userIds=&projectIds=';
		for(Projet_LMSG__c project : prjList) {
			endPointArgs += project.Identifiant_PP__c+',';
		}
		mock.setEndPointArgs(endPointArgs.substringBeforeLast(',') + '&archived=true');

		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408232","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T13:11:01.170462","positionable":true,"positionedCount":0},'+
								'{"projectId":"P003","userId":"CONTACT1_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P001","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT2_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P004","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';

		mock.setResponseBody(responseBody);

		for(Projet_LMSG__c prj : prjList)
			prj.nombre_de_match_Visibles__c = 0;
		update prjList;

		MatchCounterBatch b = new MatchCounterBatch ('PROJET_LMSG__C', false, false, 0); 
		database.executebatch(b);
		Test.stopTest();

		prjList = [SELECT id, Name, Identifiant_PP__c, nombre_de_match_Visibles__c FROM Projet_LMSG__c];
		for(Projet_LMSG__c prj : prjList)
			System.assertEquals((prj.Identifiant_PP__c == 'P001' || prj.Identifiant_PP__c == 'P002')? 2 : 1 ,prj.nombre_de_match_Visibles__c);

	}

	@isTest
	static void checkEnqueueJobsPro() {
		Test.startTest();
		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);
		
		// Get Match for the ACC1 / PRO1
		List<Account> pros = [SELECT id, External_ID__c, Name, Contact_principal__r.External_Contact_id__c FROM Account WHERE isPersonAccount = false];
		String endPointArgs = 'userIds=';
		for(Account acc : pros) {
			endPointArgs +=  acc.Contact_principal__r.External_Contact_id__c +',';
		}
		mock.setEndPointArgs(endPointArgs.substringBeforeLast(',') + '&projectIds=' + '&archived=true');

		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408232","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T13:11:01.170462","positionable":false,"positionedCount":1},'+
								'{"projectId":"P003","userId":"CONTACT1_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":2},'+
								'{"projectId":"P001","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT2_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":false,"positionedCount":0},'+
								'{"projectId":"P004","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';

		mock.setResponseBody(responseBody);

		List<Account> accList = [ SELECT id, External_ID__c, Name, nombre_de_match_Visibles__c, Nombre_de_matchs_Pros_positionnables__c
								  FROM Account
								  WHERE Compte_Nouvelles_Offres__c=true AND External_ID__c!='' AND isPersonAccount = false ];
		for(Account acct : accList) {
			System.debug('#### acc name' + acct.Name + 'Num match= ' + acct.nombre_de_match_Visibles__c);
			System.assertEquals(true,  acct.nombre_de_match_Visibles__c==null || acct.nombre_de_match_Visibles__c==0,  'Must have 0 match' );
			System.assertEquals(true,  acct.Nombre_de_matchs_Pros_positionnables__c==null || acct.Nombre_de_matchs_Pros_positionnables__c==0,  'Must have 0 match' );
		}

		MatchCounterBatch b = new MatchCounterBatch ('ACCOUNT', true, false, 10); 
		database.executebatch(b);

		Test.stopTest();

		pros = [ SELECT id, External_ID__c, Name, nombre_de_match_Visibles__c, Nombre_de_matchs_Pros_positionnables__c
				 FROM Account  WHERE isPersonAccount = false ];
		
		Map<String, Integer> refNombreMatchVisible = new Map<String, Integer> {'PRO1' => 4 , 'PRO2' => 2 };
		Map<String, Integer> refPositionnable = new Map<String, Integer> {'PRO1' => 3 , 'PRO2' => 1 };

		for(Account acc : pros) {
			System.assertEquals( refNombreMatchVisible.get(acc.Name), acc.nombre_de_match_Visibles__c, 'Must have correct match number');
			System.assertEquals( refPositionnable.get(acc.Name), acc.Nombre_de_matchs_Pros_positionnables__c, 'Must have correct match positionnable');
		}
	}

	@isTest
	static void checkEnqueueJobsProjets() {

		Test.startTest();
		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);
		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39Z","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T13:11:01.170462","positionable":false,"positionedCount":1},'+
								'{"projectId":"P003","userId":"CONTACT1_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":2},'+
								'{"projectId":"P001","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT2_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":false,"positionedCount":0},'+
								'{"projectId":"P004","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';
		mock.setResponseBody(responseBody);

		List<Projet_LMSG__c> projectList = [SELECT id, Identifiant_PP__c, nombre_de_match_Visibles__c, Nombre_de_matchs_Pros_positionnables__c FROM Projet_LMSG__c ];
		String endPointArgs = 'userIds=&projectIds=';
		for(Projet_LMSG__c prj : projectList) {
			endPointArgs += prj.Identifiant_PP__c + ',';
		}
		mock.setEndPointArgs(endPointArgs.substringBeforeLast(',') + '&archived=true');
		
		MatchCounterBatch b = new MatchCounterBatch ('PROJET_LMSG__C', true, false, 10); 
		database.executebatch(b);

		Test.stopTest();

		Map<String, Integer> refNombreMatchVisible = new Map<String, Integer> {'P001' => 2, 'P002' => 2, 'P003' => 1, 'P004' => 1};
		Map<String, Integer> refPositionnable = new Map<String, Integer> {'P001' => 2, 'P002' => 0, 'P003' => 1, 'P004' => 1};

		projectList = [SELECT id, Identifiant_PP__c, nombre_de_match_Visibles__c, Nombre_de_matchs_Pros_positionnables__c FROM Projet_LMSG__c ];
		for(Projet_LMSG__c prj : projectList) {
			System.assertEquals(refNombreMatchVisible.get(prj.Identifiant_PP__c), prj.nombre_de_match_Visibles__c , 'Must have correct match number');
			System.assertEquals(refPositionnable.get(prj.Identifiant_PP__c), prj.Nombre_de_matchs_Pros_positionnables__c , 'Must have correct positionedCount');
		}
	}

	@testSetup static void setup(){
		createRef();
		Profile BD = TestFactory.getProfilByName('Service Commercial ITCS');
        User userBD = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=BD.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
        insert userBD;
        System.assertEquals(false, String.isEmpty(userBD.id), 'User BD created' );

		Account PRO1;
		Account PRO2;
        System.runAs(userBD) {
			PRO1 = createAccount('mail1@testorg.com', '1111', '1111', 'PRO1', '32212091600208', 'ACC1' /* wbeId*/);
			Contact ctc1 = new Contact( Salutation = 'M.', FirstName = 'Test3', LastName = 'Test3', Contact_Principal_O_N__c = true,
										email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = PRO1.id, External_Contact_Id__c = 'CONTACT1_id');
			insert ctc1;
			PRO2 = createAccount('mail2@testorg.com', '2222', '2222', 'PRO2', '37887802900016', 'ACC2' /* wbeId*/ );
			Contact ctc2 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 2', LastName = 'test', Contact_Principal_O_N__c = true,
										email = 'mail2@testorg.com', Email__c = 'mail2@testorg.com', AccountId = PRO2.id, External_Contact_Id__c = 'CONTACT2_id');
			insert ctc2;
			List<Prestation_Contact__c> pcList = new List<Prestation_Contact__c>();			
			for(Reference__c prest : [SELECT id , key__c, SKU__c FROM reference__c WHERE recordType.developerName='Prestation']) {
				pcList.add(new Prestation_Contact__c(Contact__c = ctc1.id, Email_cle_prestation__c = ctc1.Email__c  + '_' + prest.Key__c, Prestation__c = prest.id)); 
				if(prest.SKU__c == 'B1001' || prest.SKU__c == 'B1002') {
					pcList.add(new Prestation_Contact__c(Contact__c = ctc2.id, Email_cle_prestation__c = ctc2.Email__c  + '_' + prest.Key__c, Prestation__c = prest.id)); 
				}
			}
			insert pcList;
		}

		Account PART = new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail3@testorg.com' );
        insert PART;

		// Create projects :
		List<Projet_LMSG__c> prjList = new List<Projet_LMSG__c>();
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c='P001', Chiffrage_bsku__c = 'B1001', Chiffrage_maximum__c = 10500, Date_de_debut_de_chantier__c = system.today() + 5, Date_de_fin_de_chantier__c = system.today() + 30, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c='P002', Chiffrage_bsku__c = 'B1002', Chiffrage_maximum__c = 10200, Date_de_debut_de_chantier__c = system.today() + 10, Date_de_fin_de_chantier__c = system.today() + 35, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c='P003', Chiffrage_bsku__c = 'B1003', Chiffrage_maximum__c = 45000, Date_de_debut_de_chantier__c = system.today() + 15, Date_de_fin_de_chantier__c = system.today() + 40, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
        prjList.add( new Projet_LMSG__c( Identifiant_PP__c='P004', Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 80000, Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45, Particulier__c = PART.id, Statut__c = 'PUBLISHED'));
		insert prjList;
        
		WBE_Token__c wbeToken = WBE_Token__c.getOrgDefaults();
        wbeToken.Name = 'WBE Token';
        wbeToken.Token__c = '4f428f16-f24e-4d62-b885-0489c7e8f512';
        wbeToken.Expire_Date__c = datetime.now();
        upsert wbeToken;
	}

	static Account createAccount(String email, String codeClient, String profileId, String Name, String Siret, String wbeId) {       
        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = Name;
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c =  [SELECT id, Name FROM reference__c WHERE Name='ACS'].Name;
        compte.Flux_code_Enseigne__c =  [SELECT id, key__c FROM reference__c WHERE Name='ACS'].key__c;
        compte.SIRET_texte__c = Siret;
        compte.Code_NAF_APE_societe_declarante__c = [SELECT id FROM reference__c WHERE Name='AAA'].id;
        compte.A_ne_jamais_rappeler__c = false;
        compte.External_ID__c = 'pro_'+wbeId;
        compte.Pays_LKP__c = [SELECT id FROM reference__c WHERE Name='France'].id;
        compte.Code_postal__c = [SELECT id FROM reference__c WHERE Name='75017'].id;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = true;
        compte.Statut_activation__c = 'Pro_Actif';
        compte.Login__c = email;
        compte.Code_client__c = codeClient;
        compte.profile_id__c  = profileId;
		insert compte;
	    return compte;
	}
	
	static void createRef() {
        List<Reference__c> refList = new List<Reference__c>();
		refList.add(TestFactory.createReference('pays', 'France','FRA','France'));
        refList.add(TestFactory.createReference('CP', '75017','75017','Paris'));
        refList.add(TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'));
        refList.add(TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'));
		
		List<String> listDoc = new List<String> ();
		reference__c presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un chauffe-eau','92278f', 'P100', 0, listDoc);
		presta.SKU__c = 'B1001';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un plancher chauffant à eau chaude','c5be38', 'P200', 0 , listDoc);
		presta.SKU__c = 'B1002';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un plancher chauffant électrique','a4bc1e', 'P300', 0 , listDoc);
		presta.SKU__c = 'B1003';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un poêle à bois','fd6898', 'P400', 0 , listDoc);
		presta.SKU__c = 'B1004';
		refList.add(presta);
		insert refList;
	}
}