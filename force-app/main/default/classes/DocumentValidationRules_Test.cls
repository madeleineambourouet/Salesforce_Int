/**
 * @description       : Tests sur les règles de validation sur les Document__c
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 10-20-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-15-2020   Hassan Dakhcha   Initial Version
**/
@isTest
private class DocumentValidationRules_Test{

	/*	
		Rajout d'une valeur a Valider
		Modif RV :
			Interdire la modif des KYB validé par hipay (Sauf admin)
			Interdire la mise a Validé des KYB par SF (Sauf Admin)
			Interdire 'A valider' pour les docs non KYB 
			Interdire la supression lorsque le KYB est a A valider
	*/
	@isTest static void KYB_VALIDABLE() {
		
		Test.startTest();

		List<User> users = [SELECT id, username FROM User];
		Map<String, User> usersMap = new Map<String, User> ();
		for(User u : users) {
			usersMap.put(u.username, u);
		}
		User BD = usersMap.get('usersgdbf@testclasssgdbf.com');
		
		List<Document__c> docList = [ SELECT id, Statut__c, Statut__r.Key__c, Date_de_validite__c, Motif_de_refus__c, idDocument__c,Type_de_document__c
									  FROM Document__c ];

		List<Reference__c> refStatut = [SELECT id, key__c FROM Reference__c WHERE RecordType.developerName = 'Statut_Document'];
		Map<String, id> mapStatut = new Map<String, id>();
		for(Reference__c ref : refStatut) {
			mapStatut.put(ref.key__c, ref.id);
		}
		Map<String, Document__c> typeDocMap = new Map<String, Document__c>();
		for(Document__c doc : docList)	{
			typeDocMap.put(doc.Type_de_document__c, doc);
		}				  
	 	System.runAs(BD) {
			try {
				typeDocMap.get('rib').Statut__c = mapStatut.get('VALIDABLE');
				update typeDocMap.get('rib');
			} catch (DmlException e) {
				System.assertEquals('Merci d\'ajouter les détails du RIB via le bouton (Remplir les données du RIB)',
									e.getDmlMessage(0), ' RIB doit avoir les details rempli');
			}

			try {
				typeDocMap.get('id').Statut__c = mapStatut.get('VALIDABLE');
				update typeDocMap.get('id');
			} catch (DmlException e) {
				System.assertEquals('La date de validité doit être obligatoire pour le statut &quot;Validé&quot;, &quot;A valider&quot; et le statut &quot;Expiré&quot;',
									e.getDmlMessage(0), ' id doit avoir une date de validité');
			}

			try {
				typeDocMap.get('contractor_quality_chart').Statut__c = mapStatut.get('VALIDABLE');
				update typeDocMap.get('contractor_quality_chart');
			} catch (DmlException e) {
				System.assertEquals('Le statut \'A valider\' n\'est pas autorisé pour ce type de document',
									e.getDmlMessage(0), ' doc hors KYB ne peut etre mis a A valider');
			}
			
			for(String type : typeDocMap.keySet()) {
				try {
					typeDocMap.get(type).Statut__c = mapStatut.get(type=='contractor_quality_chart' ? 'VALIDATED' : 'VALIDABLE');
					if(type=='rib') {
						typeDocMap.get(type).details__c = 'JSON IBAN';
					}
					typeDocMap.get(type).Date_de_validite__c = System.now().date() + 44;
					update typeDocMap.get(type);
				} catch (DmlException e) {
					System.assert(false, e.getDmlMessage(0));
				}
			}

			for(String type : typeDocMap.keySet()) {
				if(type == 'contractor_quality_chart') {
					continue;
				}
				String exceptMsg = '';
				try {
					delete typeDocMap.get(type);
				} catch (DmlException e) {
					exceptMsg = e.getDmlMessage(0);
				}
				System.assertEquals('Vous ne pouvez pas supprimer un document KYB en attente de validation ou Validé.',
									exceptMsg, '');
			}
			for(String type : typeDocMap.keySet()) {
				if(type == 'contractor_quality_chart') {
					continue;
				}
				String exceptMsg = '';
				try {
					typeDocMap.get(type).Statut__c = mapStatut.get('NEW');
					update typeDocMap.get(type);
				} catch (DmlException e) {
					exceptMsg = e.getDmlMessage(0);
				}
				System.assertEquals('Un document KYB (Pièce d\'identité, RIB, KBIS, Statuts, Justificatif de domicile) au statut "à valider Hipay" ne peut pas être modifié',
									exceptMsg, '');
			}
		}

		User PP = usersMap.get('hkconnecttest@testorg.com');
		System.runAs(PP) {
			for(String type : typeDocMap.keySet()) {
				if(type == 'contractor_quality_chart') {
					continue;
				}
				try {
					typeDocMap.get(type).Statut__c = mapStatut.get('VALIDATED');
					update typeDocMap.get(type);
				} catch (DmlException e) {
					System.assert(false, e.getDmlMessage(0));
				}
			}
		}

		System.runAs(BD) {
			for(String type : typeDocMap.keySet()) {
				if(type == 'contractor_quality_chart') {
					continue;
				}
				String exceptMsg = '';
				try {
					typeDocMap.get(type).Statut__c = mapStatut.get('NEW');
					update typeDocMap.get(type);
				} catch (DmlException e) {
					exceptMsg = e.getDmlMessage(0);
				}
				System.assertEquals('Un document KYB (Pièce d\'identité, RIB, KBIS, Statuts, Justificatif de domicile) validé par le paiement ne peut pas être modifié',
									exceptMsg, '');
			}
		}

		Test.stopTest();
	}

	@isTest static void KYB_VALIDATED() {
	
		Test.startTest();

		List<User> users = [SELECT id, username FROM User];
		Map<String, User> usersMap = new Map<String, User> ();
		for(User u : users) {
			usersMap.put(u.username, u);
		}
		User BD = usersMap.get('usersgdbf@testclasssgdbf.com');
		
		List<Document__c> docList = [ SELECT id, Statut__c, Statut__r.Key__c, Date_de_validite__c, Motif_de_refus__c, idDocument__c,Type_de_document__c
									  FROM Document__c ];

		List<Reference__c> refStatut = [SELECT id, key__c FROM Reference__c WHERE RecordType.developerName = 'Statut_Document'];
		Map<String, id> mapStatut = new Map<String, id>();
		for(Reference__c ref : refStatut) {
			mapStatut.put(ref.key__c, ref.id);
		}
							  
		// check VR : mettre le rib a validé sans id SDS :
		for(Document__c doc : docList)	{
			doc.Statut__c = mapStatut.get('VALIDATED');
		}				   
		
		System.runAs(BD) {
			Database.SaveResult[] results = Database.update(docList, false);
			System.assertEquals(6, results.size(), 'On doit avoir 6 erreurs de validation');
			for(DataBase.SaveResult res : results) {
				for(Database.Error err : res.getErrors()) {    
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, err.getStatusCode(), ' Erreurs de regles de validation' );
					System.assertEquals('Un document KYB (Pièce d\'identité, RIB, KBIS, Statuts, Justificatif de domicile) doit être mis au statut \'A valider\' ',
										 err.getMessage(), ' KYB ne peuvent pas etre mis a Validé');
				}
			}
		}
	
		// La PP a le droit de mettre le statut validé sur les KYB
		User PP = usersMap.get('hkconnecttest@testorg.com');
		System.runAs(PP) {
			for(Document__c doc : docList)	{
				doc.Statut__c = mapStatut.get('VALIDATED');
				doc.Date_de_validite__c = System.now().date() + 44;
			}	
			Database.SaveResult[] results = Database.update(docList, false);
			for(DataBase.SaveResult res : results) {
				if(!res.isSuccess()) {
					for(Database.Error err : res.getErrors()) {  
						System.assert(false, err.getStatusCode() + err.getMessage());
					}
				}
			}
		}

		Test.stopTest();

	}

	@testSetup static void setup() {
		List<Reference__c> listReferences = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        listReferences.add(CP);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        
        insert listReferences;
        
        Account compte = new Account();
        compte.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        compte.Name = 'Test account';
        compte.Phone = '+33635136116';
        compte.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
        compte.Flux_code_Enseigne__c = enseigne.key__c;
        compte.SIRET_texte__c = '32212091600208';
        compte.Code_NAF_APE_societe_declarante__c = NAF.id;
        compte.A_ne_jamais_rappeler__c = false;
        
        compte.Pays_LKP__c = pays.id;
        compte.Code_postal__c = CP.id;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = false;
        compte.Statut_activation__c = 'Nouveau';
        compte.Login__c = 'mail1@testorg.com';
        compte.Code_client__c = '1111';
        compte.profile_id__c  = '1111';
		insert compte;
		
        Contact ctcPrincipal = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                           Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
										   email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = compte.id);
		
		List<Reference__c> refs = new List<Reference__c>();
        refs.add(TestFactory.createReference('StatutDocument', 'Manquant','MISSING','Manquant'));
		refs.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
		refs.add(TestFactory.createReference('StatutDocument', 'A valider','VALIDABLE','A valider'));
        refs.add(TestFactory.createReference('StatutDocument', 'Expiré','EXPIRED','Expiré'));
        refs.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        refs.add(TestFactory.createReference('StatutDocument', 'Refusé','REFUSED','Refusé'));
        refs.add(TestFactory.createReference('StatutDocument', 'Doublon','DUPLICATED','Doublon'));
		insert refs;
		 
		// Create KYB Documents:
		id newDoc = [SELECT id FROM Reference__c WHERE Key__c ='NEW'].id;
		List<Document__c> docList = new List<Document__c>();
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'rib',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'id',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'kbis',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'address_proof',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'company_status',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		docList.add(new Document__c(Compte_Pro__c = compte.id,
									Type_de_document__c = 'contractor_quality_chart',
									idDocument__c = String.valueOf(Math.random() * 100),
									Statut__c = newDoc));
		insert docList;

		// user itcs
		Profile BD = TestFactory.getProfilByName('Service Commercial ITCS');
        User userBD = new User( Alias='myAlias', Email='usersgdbf@testclasssgdbf.com', EmailEncodingKey='UTF-8', LastName='BD',LanguageLocaleKey='fr',
                            	LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@testclasssgdbf.com',ProfileId=BD.Id,
                            	FederationIdentifier='1234567890', Title = 'TC Service Client PRO');
		insert userBD;
	
		// user HK
		Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User HKconnectUser = new User(  Alias = 'HKC', Email='HKConnectTest@testorg.com', 
										EmailEncodingKey='UTF-8', LastName='Heroku', FirstName ='Connect' ,languageLocaleKey='en_US', 
										LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',
										TimeZoneSidKey='America/Los_Angeles', UserName='HKConnectTest@testorg.com');
		insert HKConnectuser;
	}
}