/**
* @author Clement Musabimana
* @date 14/06/2018
* @description classe de test pour le service NotationAcquittementWS
**/
@isTest
public class NotationAcquittementWSTest {

	static testMethod void testDoPost(){
        Test.startTest();
      	List<Reference__c> listReferences = new List<Reference__c>();
      	List<Account> listAccounts = new List<Account>(); 
      	List<Projet__c> listProjets = new List<Projet__c>();
		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
		Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);
		//insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;      listReferences.add(CP);
		insert TV;
	    listReferences.add(competence);
	    listReferences.add(NAF);
	    listReferences.add(enseigne);
	    listReferences.add(CP);
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
		listProjets.add(project);
		listProjets.add(projectMM2);   
		insert listProjets;
		projectMM2.Adresse_mail__c = 'test@gmail.com';
		projectMM2.Demande_du_Part__c = 'Artisans qualifiés'; 
		project.Statut_Projet__c = 'Qualifié';
		project.Etat__c = 'ODC ouverte';
		project.Adresse_mail__c = 'test@gmail.com';
		project.Demande_du_Part__c = 'Artisans qualifiés';   
		//update project;
		//update projectMM2; 
		update listProjets;    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/projetsEligiblesNotationAcquittement/';  
        req.httpMethod = 'POST';
        String JSONMsg = '{"projetsId":['+project.Id+'"}';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res;
		
        List<String> projetsId = new List<String>();
        projetsId.add(project.Id);
		System.debug('projetsId :' + projetsId);
        NotationAcquittementWS.notation_acquittement(projetsId);

		System.debug('project :' + project);
		System.debug('RestContext.response :' + RestContext.response);
		System.assertEquals(RestContext.response.statusCode,200);
		

       	//Verification des donnees en retour

        Test.stopTest();
        

    }   

}