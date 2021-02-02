/**
* @author Clement Musabimana
* @date 01/06/2018
* @description classe de test pour le service NotationWS
**/
@isTest
public class NotationWSTest {

	static testMethod void testDoPost(){
        Test.startTest();
      
	    List<Reference__c> listReferences = new List<Reference__c>();
	    List<Account> listAccounts = new List<Account>();
		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);
		//insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;

		listReferences.add(CP);
		listReferences.add(competence);
		listReferences.add(NAF);
		listReferences.add(enseigne);
		listReferences.add(pays);
		insert listReferences;

		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
		particulier.PersonEmail = 'test@notation.fr';
		//insert particulier;
		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		//insert professionnel;

		listAccounts.add(particulier);
		listAccounts.add(professionnel);
		insert listAccounts;		
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro;

		Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
		//insert project;
		Projet__c projectMM2 = TestFactory.createProject(particulier, CP, pays, us);
		//insert projectMM2;

		List<Projet__c> listProjets = new List<Projet__c>();
		listProjets.add(project); 
		listProjets.add(projectMM2);
		insert listProjets;


		
		project.Statut_Projet__c = 'Qualifié';
		project.Etat__c = 'ODC ouverte';
		project.Adresse_mail__c = 'test@gmail.com';
		project.Demande_du_Part__c = 'Artisans qualifiés';   
		//update project;

		projectMM2.Adresse_mail__c = 'test@gmail.com';
		projectMM2.Demande_du_Part__c = 'Artisans qualifiés';    
		//update projectMM2;   
		update listProjets; 

		Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
		//miseEnRelation.Statut_Selection__c = 'Demandee';
		miseEnRelation.Statut_Selection__c = 'Validee';
		miseEnRelation.Date_de_s_lection__c = date.parse('13/03/2018');// Date.today().addDays(-1);
		System.debug('miseEnRelation.Statut_Selection__c :' + miseEnRelation.Statut_Selection__c);
		insert miseEnRelation;

		System.debug('miseEnRelation :' + miseEnRelation);
 		String JSONMsg = '{"dateTraitement" : "13/03/2018"}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/projetsEligiblesNotation/';   
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res;


        NotationWS.notation_data('13/03/2018');

		System.debug('RestContext.response :' + RestContext.response);
		System.assertEquals(RestContext.response.statusCode,200);
		//String blobToString = RestContext.response.responseBody;
		//System.debug('blobToString :' + blobToString);
		string bodyToString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(RestContext.response.responseBody)).toString();
		System.debug('ResponseBody bodyToString:' + bodyToString);
	
		Map<String,Object> bodyMapResults = (Map<String,Object>)JSON.deserializeUntyped(bodyToString);
		List<Object> bodyResultslist = (List<Object>)bodyMapResults.get('projets');

       	//Verification des donnees en retour
		System.debug('ResponseBody bodyMapResults:' + bodyMapResults);
		System.debug('ResponseBody bodyResultslist:' + bodyResultslist[0]);
		Map<String,Object> bodyMapResultsData = (Map<String,Object>)bodyMapResults;
		System.debug('ResponseBody bodyMapResultsData:' + bodyMapResultsData);
		List<Object> bodyMapResultsDataProjet = (List<Object>)bodyMapResultsData.get('projets');
		//Objet bodyMapResultsDataProjet = bodyMapResults.get('projets');
		System.debug('ResponseBody bodyMapResultsDataProjet:' + bodyMapResultsDataProjet);
		Map<String,Object> bodyMapResultsDataProjetData = (Map<String,Object>)bodyMapResultsDataProjet[0];
		System.assertEquals(bodyMapResultsDataProjetData.get('email'),'test@notation.fr'); 

        Test.stopTest();
        

    }   

}