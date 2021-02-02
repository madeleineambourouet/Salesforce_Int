@isTest
public with sharing class HelperButtonTest3 {
	
	@isTest
	public static void HelperTest() {
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = TestFactory.createUser('0123456789', sysAdm);

		Reference__c pays = TestFactory.createReference('pays', 'congo', '007','Congo');
		Reference__c CP = TestFactory.createReference('CP', '51100', '51100_51110','Reims');
		Reference__c ens = TestFactory.createReference('enseigne', 'PBC', '75019','Bar');
		Reference__c NAF = TestFactory.createReference('NAF', 'Alcool', '10z02','La boisson');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');

		List<Reference__c> referenceList = new List<Reference__c>();
		referenceList.add(pays);
		referenceList.add(CP);
	    referenceList.add(NAF);
	    referenceList.add(ens); 
	    referenceList.add(competence); 
    	insert referenceList;

		Account acc = TestFactory.createAccount(true, pays, CP, ens, NAF);
		acc.Adresse1__c = 'adresse';
		acc.Code_client_Point_P__c = '12A34';
		insert acc;

		Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
    	insert particulier;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

    	Lead l = new Lead(Salutation = 'M.', FirstName = 'Zubizuba', LastName = 'Zuber', SIRET__c = '77566343801906', Company = 'Zuber Man', Status = 'Ouverte', Code_NAF__c = NAF.Id, Email = 'zuzuzu@gmail.com', Phone = '+33123412341', MobilePhone = '+33612341234');
    	insert l;

    	List<Projet__c> projList = new List<Projet__c>();
    	Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
   		projList.add(project);
   		insert projList;

   		Def_Creneau__c DefName = new  Def_Creneau__c( Heure_Debut__c = '08h00', Jour_de_la_semaine__c ='Lundi');
        insert DefName; 

   		Rappel__c rappel1 = new Rappel__c( Date_Horaire__c = Date.today(), Reference_du_Creneau__c = DefName.id, No_de_Rappel__c = '0600000000', Type_de_demande__c ='WCB Créneau', Projet__c = project.id, Compte__c = acc.id, Queue_Odigo__c = 'accueil_client_part');
        insert rappel1;  
        
        Test.startTest();
    	HelperButton.creerModifQuote(acc.id);
    	HelperButton.getUrl(acc.Id);
    	HelperButton.resilierSouscription(acc.Id);

    	HelperButton.callFermerPreinscrit(l.Id);
    	HelperButton.callGenerationArtisanService(acc.Id);
    	HelperButton.callLoginCheck('mail@mai.ma', l.Id);
    	HelperButton.callConvertirPiste(l.Id);
    	HelperButton.callUpdateprojetMatching(project.Id);
    	HelperButton.callAnnulerRappel(rappel1.Id);
    	Test.stopTest();
	}
}