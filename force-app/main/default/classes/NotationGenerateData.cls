public class NotationGenerateData {

	public static final ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
    public static final ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 

    public static void generateData(String particulier_email, String baseName, String date_selection, Integer nbProjetsUseCase)
    {
       	Reference__c pays = [SELECT Id FROM Reference__c WHERE Key__c = 'BEL' LIMIT 1];
		Reference__c CP = [SELECT Id FROM Reference__c WHERE Lov_Type__c = 'CP_Ville' LIMIT 1];
		Reference__c competence = [SELECT Id FROM Reference__c WHERE Lov_Type__c = 'competence' LIMIT 1];
		Reference__c NAF = [SELECT Id FROM Reference__c WHERE Lov_Type__c = 'NAF_Libelle' LIMIT 1];
		Reference__c enseigne = [SELECT Id, Name,key__c FROM Reference__c WHERE Lov_Type__c = 'enseigne' LIMIT 1];
		Reference__c categorie = [SELECT Id FROM Reference__c WHERE Lov_Type__c = 'categorie' LIMIT 1];
		User us = new User();
		us.Id = UserInfo.getUserId();
		
		Account particulier = createAccount(false, pays, CP, null, null);
		particulier.PersonEmail = particulier_email;
        particulier.LastName = baseName+'_Test';
        particulier.FirstName = baseName+'_Test';
        particulier.Salutation = 'M.';
        particulier.PersonMobilePhone = '+33635136116';
		insert particulier;
		Account professionnel = createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Name = baseName+'_AccountPro_Test';
        professionnel.Phone = '+33635136116';
        //professionnel.SIRET_texte__c = '32212091600208';
		insert professionnel;
		Contact contactPro = createContact(professionnel,baseName);
		insert contactPro;

		List<Projet__c> projets = new List<Projet__c>();
		for(Integer count = 0; count < nbProjetsUseCase; count++) {
			Projet__c projet = createProject(particulier, CP, pays, us, baseName);
			projet.Statut_Projet__c = 'Qualifié';
			projet.Etat__c = 'ODC ouverte';
            projet.Source__c = 'VANN';
			projet.Adresse_mail__c = particulier_email;
			projet.Demande_du_Part__c = 'Artisans qualifiés';  
			projet.Categorie_lkp__c = categorie.Id; 
			projets.add(projet);
		}
		insert projets;
		
		List<Intermediation__c> mers = new List<Intermediation__c>();
		for (Projet__c prj : projets)  {
			Intermediation__c miseEnRelation = createMiseEnRelation(contactPro, competence, prj);
			//miseEnRelation.Statut_Selection__c = 'Demandee';
			miseEnRelation.Statut_Selection__c = 'Validee';
			miseEnRelation.Date_de_s_lection__c = date.parse(date_selection);// Date.today().addDays(-1);
			System.debug('miseEnRelation.Statut_Selection__c :' + miseEnRelation.Statut_Selection__c);
			mers.add(miseEnRelation);
		}

		insert mers;
		
    }

    public static void deleteData(String baseName)
    {
    	String searchValue = baseName + '_';
       	//List<Account> accountToDelete = [SELECT Id FROM Account WHERE Name LIKE '%AZERTY005_%'];
        List<Account> accountToDelete = [SELECT Id FROM Account WHERE Name LIKE :baseName];
		delete accountToDelete;
    }

    public static Account createAccount(Boolean isPro, Reference__c pays, Reference__c codePostal, Reference__c enseigne, Reference__c NAF){
        
        Account compte = new Account();
        if (isPro) {
            compte.RecordTypeId = RTComptePro;
            compte.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
            compte.Flux_code_Enseigne__c = enseigne.key__c;
            compte.Code_NAF_APE_societe_declarante__c = NAF.id;
            compte.A_ne_jamais_rappeler__c = false;
        }
        else {
            compte.RecordTypeId = RTComptePart;
        }
        compte.Pays_LKP__c = pays.id;
        compte.Code_postal__c = codePostal.id;
        
        return compte;
        
    }
    public static Contact createContact(Account compte, String baseName ){
        
        return new Contact(Salutation = 'M.', FirstName = baseName+'_Test', LastName = baseName+'_Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, AccountId = compte.id, DoNotCall = true, Phone = '+33635136116');
        
    }

    public static Projet__c createProject(Account particulier, Reference__c codePostal, Reference__c pays, User us, String baseName){
        
        return new Projet__c(Particulier__c = particulier.id, Sous_Activite__c = 'Isolation', Code_postal__c = codePostal.id, Pays_LKP__c = pays.id, Description__c = baseName+'_Test_Volumetrie',
                                Numero_SGI__c = us.FederationIdentifier);
        
    }
    
    public static Intermediation__c createMiseEnRelation(Contact contactPro, Reference__c competence, Projet__c projet){
        
        return new Intermediation__c(Contact__c = contactPro.id, Competence__c = competence.id, ID_COMPETENCE__c = competence.id, Prospect__c = false, Projet__c = projet.id, Date_de_matching__c = Date.today());
        
    }
}