// 
// WebService for a partner to create a lead 
// 31/10/2017, xavier templet, version initiale   
//

global with sharing class NewLeadFromPartner {

	class MyNewLead {
	    public String Civilite;
	    public String Nom;
	    public String Prenom;
	    public String Fonction;
	    public String Adresse1;
	    public String Adresse2;
	    public String CodePostal;
	    public String Pays;
	    public String Email;
	    public String TelMobile;
	    public String Competences;
	    public String SOCIETE;
	    public String Identification;
	    public String Code;
	    public String Web;
	    public String Description;
	    public String Agence;

    
    	MyNewLead(String cvlt, String nm, String pnm, String fctn, String adr1, String adr2, String cp, String py, String em, String tmob, String comptnce, String soc, String id, String cde, String wb, String descrpt, String agce) {
			Civilite = cvlt;
			Nom = nm;
			Prenom = pnm;
			Fonction = fctn;
			Adresse1 = adr1;
			Adresse2 = adr2;
			CodePostal = cp;
			Pays = py;
			Email = em;
			TelMobile = tmob;
			Competences = comptnce;
			SOCIETE = soc;
			Identification = id;
			Code = cde;
			Web = wb;
			Description = descrpt;
			Agence = agce;
	    }
	}

	
	webservice static String SendLeadDetails(String Partner, String jsonStr) {

try{

/*
    String jsonStr = 
        '{"LeadList":[' +
        '{"Civilité":"Mr.","Nom":"Pollux","Prenom":"XXX","Fonction":"Adjoint","Adresse1":"","Adresse2":"","CodePostal":"","Pays":"","Email":"","TelMobile":"+3311111","Competences":"","SOCIETE":"","Identification":"","Code":"","Web":"","Description":"","Agence":""},' +
        '{"Civilité":"Mme.","Nom":"Pollux","Prenom":"YYY","Fonction":"Chef de Chantier","Adresse1":"","Adresse2":"","CodePostal":"","Pays":"","Email":"","TelMobile":"+3322222","Competences":"","SOCIETE":"","Identification":"","Code":"","Web":"","Description":"","Agence":""}' +
        ']}';

*/

/*
	
		if(Test.isRunningTest()) 
				curProject = [select Id, Mises_en_relation_selectionnees__c, Proprietaire_du_projet__c, Proprietaire_du_projet__r.Name, 
			Name, Sous_statut__c, Statut_Projet__c, Date_de_Qualification__c, Date_de_debut_ODC_ouverte__c, Date_de_fin_ODC_ouverte__c, 
				Type_de_reference__c, Source__c, Etat__c, ClosedBy__c, Souhaite_participer_au_jeu_concours__c,Partenaire_eligible__c, Categorie_lkp__c 
					from Projet__c where Adresse_mail__c = 'test@gmail.com' ];
		else
		
*/		
		
	    // Parse entire JSON response.
	    List<MyNewLead> nlfpList = new List<MyNewLead>();
	    List<String> LastNameList = new List<String>();
	    List<String> SocieteList = new List<String>();
    	JSONParser parser = JSON.createParser(jsonStr);
    	while (parser.nextToken() != null) {
	        // Start at the array of Leads.
    	    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        	    while (parser.nextToken() != null) {
            	    // Advance to the start object marker to
                	//  find next lead statement object.
                	if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    	// Read entire lead object.
                    	MyNewLead mylead = (MyNewLead)parser.readValueAs(MyNewLead.class);
                    	nlfpList.add(mylead); LastNameList.add(mylead.Nom); SocieteList.add(mylead.SOCIETE);
                    	//system.debug('MyLead TelMobile: ' + mylead.TelMobile);
                    	// For debugging purposes, serialize again to verify what was parsed.
                    	//String s = JSON.serialize(mylead);
                    	//system.debug('Serialized mylead: ' + s);

                    	// Skip the child start array and start object markers.
                    	parser.skipChildren();
                	}
            	}
        	}
    	}

		

		// Je fais une recherche pour savoir si le contact / PRO existe déjà
		// pour construire une map qui associe new lead à un contactID et une map qui associe new lead à un AccountID	
		Map<String, Id> Lead2Contact = new Map<String, Id>();
		Map<String, Id> Lead2Account = new Map<String, Id>();
		
		List<Contact> ContactList = [SELECT Id, AccountID, Salutation, FirstName, LastName, Email, 	Phone, MobilePhone, Adresse1__c, Fonction__c, Code_postal_Compte__c, SIREN_Compte__c, SIRET_Compte__c 
										FROM Contact WHERE LastName IN :LastNameList];

		List<Account> AccntListDetails = [SELECT Id, Name, Phone, Adresse1__c, Code_postal_texte__c, Flux_Code_NAF__c, Libell_d_agence_pilote__c, SIRET__c, SIREN__c 
											FROM Account WHERE Name IN :SocieteList];

		//List<Account> AccntList = new List<Account>();
		for (MyNewLead nlfp : nlfpList) {
			for (Contact c : ContactList) {
				
				if (c.LastName == nlfp.Nom && c.FirstName == nlfp.Prenom && c.Code_postal_Compte__c == nlfp.CodePostal) {
					//AccntList.add(c.AccountID);	
					Lead2Contact.put(nlfp.Prenom+nlfp.Nom+nlfp.SOCIETE, c.Id);
					break;				
				}
			}
			for (Account accnt : AccntListDetails) {
				
				if (accnt.Name == nlfp.SOCIETE && accnt.SIRET__c.contains(nlfp.Identification)) {
					Lead2Account.put(nlfp.Prenom+nlfp.Nom+nlfp.SOCIETE, accnt.Id);
					break;				
				}

			}
		}



		// Pour trouver l' ITC du PRO je dois chercher dans la table de correspondance 
		
		
		

		// Pour les xxxxxx  ou si ... il y a création d'une requête pour étudier le cas
		List<Case> CaseList = new List<Case>(); 
		string message;
		Reference__c Motif = [Select Id from Reference__c where Name = 'Recrédit à rattraper'];

		for(MyNewLead nlfp : nlfpList) {
			message = '';
				// création d'une requête
				Case rc = new Case();

				if (Lead2Contact.containsKey(nlfp.Prenom+nlfp.Nom+nlfp.SOCIETE)) rc.ContactId = Lead2Contact.get(nlfp.Prenom+nlfp.Nom+nlfp.SOCIETE);
				if (Lead2Account.containsKey(nlfp.Prenom+nlfp.Nom+nlfp.SOCIETE)) rc.AccountId = Lead2Account.get(nlfp.Prenom+nlfp.Nom+nlfp.SOCIETE);
				
				rc.Origin = 'TC Service Client pro';
				rc.Subject = 'Demande de contact en provenance de ' + Partner;
				rc.Description_interne__c = 'xxxxxxxxxxxxxxxxxxx';
				rc.Status = 'Nouvelle';
				rc.Priority = 'Moyenne';
				//rc.Type Problème
				//rc.Projet__c = Pas de projet en particulier car ce sont des problèmes liés au compte du PRO
				//rc.Origine_Requ_te__c
				//rc.Type_Contact__c
				rc.Motif__c = Motif.Id;
				CaseList.add(rc);
				
		} System.debug('NewLeadFromPartner >>>>> CaseList :' + CaseList);	
		if (CaseList != null && CaseList.size()>0) insert CaseList;



		
		
/*		
        system.debug('>>>>> NewLeadFromPartner :  xxxx  = ' + xxxxx);



		if (!test1ok || !test2ok) return 'NOK';
		else return 'OK';
*/

} catch (Exception e) {
          System.assert(false, 'NewLeadFromPartner: Exception occured. Exception Details: ' + e.getMessage());
}

		return 'NOK';
		
	}  

	
}