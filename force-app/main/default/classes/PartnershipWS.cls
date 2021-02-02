@RestResource(urlMapping='/partner/upsert/')
global without sharing class PartnershipWS {
	
	@HttpPost
	global static PF_List_Wrapper traitement_data(List<PartnershipWSobject> upserts){
		PF_List_Wrapper pf_list = new PF_List_Wrapper(upserts);
		return pf_list;
	}

	// Classe qui définit les champs JSON a traité
	global class PartnershipWSobject {
		global string name;
		global string siret; // a verif
		global string insee_cp; // a verif SOQL
		global string code_naf; // a verif SOQL
		global string adresse1;
		global string adresse2;
		global string enseigne_gestion;
		global string code_agence; // a verif SOQL
		global string nom_agence;
		global string code_client_p;
		global string lastname;
		global string firstname;
		global string civilite;
		global string email; //a verif
		global string phone;
		global string code_client_groupe;
		global string agence_pilote;
		global string date_entree;
		global string date_sortie;
		global string enseigne_partenaire;
		global string customer_id;
		global String error;
		global String tech;
		global String siren;
	}

	// Classe Wrapper qui contient 
	//global class PF_Wrapper {
	//	PartnershipWSobject JSON;
	//	Account acc;
	//	Contact con;
	//	ProgrammeFidelite__c pf;
	//	Boolean acc_ok;
	//	Boolean con_ok;
	//}

	global class PF_List_Wrapper {

		List<PartnershipWSobject> success;
		List<PartnershipWSobject> reject;

		global PF_List_Wrapper(List<PartnershipWSobject> Json) {
			//ALLJSON = Json;
			this.success = new List<PartnershipWSobject>();
			this.reject = new List<PartnershipWSobject>();
			get_PF(Json);
		}

		global void get_PF(List<PartnershipWSobject> upserts) {
			Map<String, PartnershipWSobject> siret_MAP = new Map<String, PartnershipWSobject>();
			Map<String, PartnershipWSobject> siren_MAP = new Map<String, PartnershipWSobject>();
			Map<String, PartnershipWSobject> ccg_MAP = new Map<String, PartnershipWSobject>();
			Map<String, PartnershipWSobject> cus_MAP = new Map<String, PartnershipWSobject>();
			Map<String, Reference__c> agence_MAP = new Map<String, Reference__c>();
			Map<String, Reference__c> agence_SF = new Map<String, Reference__c>();
			Map<String, Integer> count_cus = new Map<String, Integer>();
			Map<String, Integer> count_ccg = new Map<String, Integer>();
			Map<String, Integer> count_siren = new Map<String, Integer>();
			List<String> emailList = new List<String>(); //CMU: 14/09/18



			RecordType rtAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1];
			RecordType rtpro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1];

			for (PartnershipWSobject pso : upserts) {
				// verif phone, siret, mail,
				pso.siren = pso.siret.left(9);

				pso.error = '';

				if (!validateEmail(pso.email))
					pso.error += 'MAIL;';

				if (!validatePhone(pso.phone))
					pso.error += 'PHONE;';

				//if (pso.siret.length() != 14 && pso.siret.length() != 9)
				//	pso.error = 'SIRET;'

				if (!AccountMethods.checkSiret(pso.siret))
					pso.error += 'SIRET;';

				if (!validateCP(pso.insee_cp) ) 
					pso.error += 'CP;';

				if (isNullOrEmpty(pso.name)) 
					pso.error += 'NAME;';

				if (isNullOrEmpty(pso.code_agence)) 
					pso.error += 'CODE_AGENCE;';

				if (isNullOrEmpty(pso.customer_id)) 
					pso.error += 'CUSTOMER_ID;';

				if (isNullOrEmpty(pso.lastname)) 
					pso.error += 'LASTNAME;';

				if (isNullOrEmpty(pso.firstname)) 
					pso.error += 'FIRSTNAME;';

				if (isNullOrEmpty(pso.civilite)) 
					pso.error += 'CIVILITE;';

				if (isNullOrEmpty(pso.code_client_groupe)) 
					pso.error += 'CODE_CLIENT_GROUPE;';

				if (isNullOrEmpty(pso.agence_pilote)) 
					pso.error += 'AGENCE_PILOTE;';

				siret_MAP.put(pso.siret, pso);
				cus_MAP.put(pso.customer_id, pso);
				ccg_MAP.put(pso.code_client_groupe, pso);
				siren_MAP.put(pso.siren, pso);


				if (pso.code_agence != null)
					agence_MAP.put(pso.code_agence, new Reference__c(Name=pso.nom_agence, Key__c = pso.code_agence, RecordTypeId = rtAgence.Id));

				if (pso.email != null)
					emailList.add(pso.email);


			}

			List<Reference__c> agence_insert = new List<Reference__c>();
			if (agence_MAP.size() > 0){
				
				//verification la l'existance des agences
				for ( Reference__c r : [SELECT Id, Key__c FROM Reference__c WHERE Key__c IN :agence_MAP.keyset() AND RecordTypeId = :rtAgence.Id]) {
					agence_SF.put(r.Key__c, r);
				}

				//selecttion les agenc
				for (String ca : agence_MAP.keyset()) {
					if (!agence_SF.containsKey(ca) ) {
						agence_insert.add(agence_MAP.get(ca));
					}
				}


				if (agence_insert.size() > 0 )
					insert agence_insert;

			}

			Map<String, Reference__c> all_agence = new Map<String, Reference__c>();
			for ( Reference__c r : [SELECT Id, Key__c FROM Reference__c WHERE Key__c IN :agence_MAP.keyset() AND RecordTypeId = :rtAgence.Id]) {
				all_agence.put(r.Key__c,r);
			}


			system.debug('cus_MAP*** = '+cus_MAP);
			List<ProgrammeFidelite__c> pf_check_cus = [SELECT Id, Name, Compte__r.SIRET_texte__c, CustomerId__c, Code_client_groupe__c, Compte__c, Compte__r.Enseignes_de_gestion_Client__c,Compte__r.Login__c FROM ProgrammeFidelite__c WHERE CustomerId__c IN :cus_MAP.keyset()];
			List<AggregateResult> pf_count_cus = [SELECT COUNT(Id) nbr, CustomerId__c FROM ProgrammeFidelite__c WHERE  CustomerId__c IN :cus_MAP.keyset() GROUP BY CustomerId__c];
			List<ProgrammeFidelite__c> pf_check_ccg = [SELECT Id, Name, Compte__r.SIRET_texte__c, CustomerId__c, Code_client_groupe__c, Compte__c, Compte__r.Enseignes_de_gestion_Client__c FROM ProgrammeFidelite__c WHERE Code_client_groupe__c IN :ccg_MAP.keyset()];
			List<AggregateResult> pf_count_ccg = [SELECT COUNT(Id) nbr, Code_client_groupe__c FROM ProgrammeFidelite__c WHERE  Code_client_groupe__c IN :ccg_MAP.keyset() GROUP BY Code_client_groupe__c];
			List<Account> cus_check_loginEmail = [SELECT Id, Login__c,SIRET_texte__c FROM Account WHERE Login__c IN :emailList]; 
			
			
			List<String> pf_up = new List<String>();
			Map<String, PartnershipWSobject> idAccToCheck = new Map<String, PartnershipWSobject>();
			Map<String, PartnershipWSobject> idAccToCheckcus = new Map<String, PartnershipWSobject>();
			Map<String, PartnershipWSobject> idAccToCheckccg = new Map<String, PartnershipWSobject>();


			List<SObject> all_update = new List<SObject>();
			List<SObject> all_insert = new List<SObject>();
			List<Contact> update_contact = new List<Contact>();
			List<Contact> insert_contact = new List<Contact>();
			List<Account> update_account = new List<Account>();
			List<Account> insert_account = new List<Account>();
			List<ProgrammeFidelite__c> update_prog = new List<ProgrammeFidelite__c>();
			List<ProgrammeFidelite__c> insert_prog = new List<ProgrammeFidelite__c>();

			List<PartnershipWSobject> partner_insert = new List<PartnershipWSobject>();
			Map<String, Account> insert_accountExistMap = new Map<String, Account>(); //CMU 11/09/18
			Map<String, String> emailSiretMap = new Map<String, String>(); //CMU 14/09/18

			for (AggregateResult ar : pf_count_cus) {
				count_cus.put( (String) ar.get('CustomerId__c'), (Integer) ar.get('nbr'));
			}

			for (ProgrammeFidelite__c pf : pf_check_cus) {
				system.debug('count_cus.get(pf.CustomerId__c) = ' + count_cus.get(pf.CustomerId__c));
				if (count_cus.get(pf.CustomerId__c) == 1) {
					cus_MAP.get(pf.CustomerId__c).tech = 'DONE';
					pf.CustomerId__c = cus_MAP.get(pf.CustomerId__c).customer_id;
					pf.Code_client_groupe__c = cus_MAP.get(pf.CustomerId__c).code_client_groupe;
					//pf.putSObject('Agence_Pilote__r', new Reference__c(Key__c = cus_MAP.get(pf.CustomerId__c).agence_pilote));
					pf.Agence_Pilote__c = all_agence.get(cus_MAP.get(pf.CustomerId__c).agence_pilote).Id;
					pf.DateEntree__c = getDate(cus_MAP.get(pf.CustomerId__c).date_entree);
					pf.DateSortie__c = getDate(cus_MAP.get(pf.CustomerId__c).date_sortie);
					pf.Enseigne_partenaire__c = cus_MAP.get(pf.CustomerId__c).enseigne_partenaire;
					pf_up.add(cus_MAP.get(pf.CustomerId__c).siret);
					this.success.add(cus_MAP.get(pf.CustomerId__c));
					all_update.add(pf);
					update_prog.add(pf);
					system.debug('cus_MAP.get(pf.CustomerId__c).enseigne_partenaire = ' + cus_MAP.get(pf.CustomerId__c).enseigne_partenaire);
					system.debug('pf.Compte__r.Enseignes_de_gestion_Client__c = ' + pf.Compte__r.Enseignes_de_gestion_Client__c);

					if (cus_MAP.get(pf.CustomerId__c).enseigne_partenaire == pf.Compte__r.Enseignes_de_gestion_Client__c) {
						idAccToCheck.put(pf.Compte__c, cus_MAP.get(pf.CustomerId__c));
						idAccToCheckcus.put(pf.Compte__c, cus_MAP.get(pf.CustomerId__c));

						system.debug('Je suis idAccToCheck');
					}
				} else {
					if(pf.CustomerId__c != null && cus_MAP.get(pf.CustomerId__c) != null){
						cus_MAP.get(pf.CustomerId__c).error += 'SEVERAL CUSTOMER ID IN SALESFORCE;';
						this.reject.add(cus_MAP.get(pf.CustomerId__c));
					}
				}


			}

			system.debug('cus_check_loginEmail*** = '+cus_check_loginEmail);
			//CMU:14/09/18: creation de la map email => siret. permet de verifier si un email existe deja dans SF sur un compte ayant un siret different
			for (Account acc : cus_check_loginEmail) {
				if (acc.Login__c != null && emailSiretMap.get(acc.Login__c) == null) {
					if(acc.SIRET_texte__c != null){
						emailSiretMap.put(acc.Login__c,acc.SIRET_texte__c);
					}
					else {
						emailSiretMap.put(acc.Login__c,'');
					}
				}
			}


			for (AggregateResult ar : pf_count_ccg) {
				count_ccg.put( (String) ar.get('Code_client_groupe__c'), (Integer) ar.get('nbr'));
			}

			for (ProgrammeFidelite__c pf : pf_check_ccg) {
				system.debug('pf_up = ' + pf_up);
				system.debug('count_ccg.get(pf.Code_client_groupe__c)) = ' + count_ccg.get(pf.Code_client_groupe__c));

				if (pf.Code_client_groupe__c !=null && ccg_MAP.get(pf.Code_client_groupe__c) != null && !pf_up.contains(ccg_MAP.get(pf.Code_client_groupe__c).siret) ){
					system.debug('ko siret');
					if (count_ccg.get(pf.Code_client_groupe__c) == 1) {

						if (ccg_MAP.get(pf.Code_client_groupe__c).enseigne_partenaire == pf.Compte__r.Enseignes_de_gestion_Client__c || pf.Compte__r.Enseignes_de_gestion_Client__c == null) {
							
							ccg_MAP.get(pf.Code_client_groupe__c).tech = 'DONE';
							pf.CustomerId__c = ccg_MAP.get(pf.Code_client_groupe__c).customer_id;
							pf.Code_client_groupe__c = ccg_MAP.get(pf.Code_client_groupe__c).code_client_groupe;
							//pf.putSObject('Agence_Pilote__r', new Reference__c(Key__c = ccg_MAP.get(pf.Code_client_groupe__c).agence_pilote));
							pf.Agence_Pilote__c = all_agence.get(ccg_MAP.get(pf.Code_client_groupe__c).agence_pilote).Id;
							pf.DateEntree__c = getDate(ccg_MAP.get(pf.Code_client_groupe__c).date_entree);
							pf.DateSortie__c = getDate(ccg_MAP.get(pf.Code_client_groupe__c).date_sortie);
							pf.Enseigne_partenaire__c = ccg_MAP.get(pf.Code_client_groupe__c).enseigne_partenaire;
							pf_up.add(ccg_MAP.get(pf.Code_client_groupe__c).siret);
							this.success.add(ccg_MAP.get(pf.Code_client_groupe__c));
							idAccToCheck.put(pf.Compte__c, ccg_MAP.get(pf.Code_client_groupe__c));
							idAccToCheckccg.put(pf.Compte__c, ccg_MAP.get(pf.Code_client_groupe__c));
						}
						all_update.add(pf);
						update_prog.add(pf);
					} else {
						if (!ccg_MAP.get(pf.Code_client_groupe__c).error.contains('SEVERAL CODE')) {
							ccg_MAP.get(pf.Code_client_groupe__c).error += 'SEVERAL CODE GROUPE CLIENT IN SALESFORCE;';
							this.reject.add(ccg_MAP.get(pf.Code_client_groupe__c));
						}
					}
				}
			}

			List<Account>acc_check_siret = [SELECT Id, Name, SIRET_texte__c, Enseignes_de_gestion_Client__c, (SELECT Id FROM zqu__Accounts__r) FROM Account WHERE SIRET_texte__c IN :siret_MAP.keyset() ];
			List<Account>acc_check_siren = [SELECT Id, Name, SIRET_texte__c, SIREN__c, Enseignes_de_gestion_Client__c, (SELECT Id FROM zqu__Accounts__r) FROM Account WHERE SIREN__c IN :siren_MAP.keyset() ];
			/*List<AggregateResult> acc_count_siren = [SELECT COUNT(Id) nbr, SIREN__c FROM Account WHERE SIREN__c IN :siren_MAP.keyset() GROUP BY SIREN__c];
			for (AggregateResult ar : acc_count_siren) {
				count_siren.put((String) ar.get('SIREN__c'),(Integer) ar.get('nbr'));
			}*/

			for (Account a : acc_check_siret) {
				system.debug('for siret 1');
				//system.debug('count_cus.get(siret_MAP.get(a.SIRET_texte__c).customer_id) = ' + count_cus.get(siret_MAP.get(a.SIRET_texte__c).customer_id));
				//system.debug('count_ccg.get(siret_MAP.get(a.SIRET_texte__c).code_client_groupe) = ' + count_ccg.get(siret_MAP.get(a.SIRET_texte__c).code_client_groupe));
				system.debug('count_ccg = ' + count_ccg);
				if(a.SIRET_texte__c != null && insert_accountExistMap.get(a.SIRET_texte__c) == null){ //CMU 12/09/18
					insert_accountExistMap.put(a.SIRET_texte__c,a); //CMU 12/09/18
				}
				system.debug('acc_check_siret :: a.SIRET_texte__c = ' + a.SIRET_texte__c);
				system.debug('acc_check_siret :: siret_MAP.get(a.SIRET_texte__c) = ' + siret_MAP.get(a.SIRET_texte__c));
				//if ( (count_ccg.isEmpty() || count_cus.isEmpty()) || (count_ccg.get(siret_MAP.get(a.SIRET_texte__c).code_client_groupe) == null && count_cus.get(siret_MAP.get(a.SIRET_texte__c).customer_id) == null)) {
				if ( (count_ccg.isEmpty() || count_cus.isEmpty()) || (a.SIRET_texte__c != null && siret_MAP.get(a.SIRET_texte__c) != null && count_ccg.get(siret_MAP.get(a.SIRET_texte__c).code_client_groupe) == null && count_cus.get(siret_MAP.get(a.SIRET_texte__c).customer_id) == null)) { //CMU: 12/09/18
						system.debug('for siret');
						system.debug(siret_MAP.get(a.SIRET_texte__c));
						system.debug(a.SIRET_texte__c);

					//if (!pf_up.contains(a.SIRET_texte__c) ) { // CMU:11/09/18
					if (a.SIRET_texte__c != null && !pf_up.contains(a.SIRET_texte__c) ) { // CMU:11/09/18
						system.debug('check siret');
						// Insertion programme de fidèlité
						ProgrammeFidelite__c pf = new ProgrammeFidelite__c();
						System.debug('PartnershipWS *** a.SIRET_texte__c ='+a.SIRET_texte__c);
						System.debug('PartnershipWS *** siret_MAP.get(a.SIRET_texte__c) ='+siret_MAP.get(a.SIRET_texte__c));
						System.debug('PartnershipWS *** siret_MAP.get(a.SIRET_texte__c).tech ='+siret_MAP.get(a.SIRET_texte__c).tech);
						siret_MAP.get(a.SIRET_texte__c).tech = 'DONE';
						pf.CustomerId__c = siret_MAP.get(a.SIRET_texte__c).customer_id;
						pf.Code_client_groupe__c = siret_MAP.get(a.SIRET_texte__c).code_client_groupe;
						pf.Compte__c = a.Id;
						pf.Agence_Pilote__c = all_agence.get(siret_MAP.get(a.SIRET_texte__c).agence_pilote).Id;
						pf.DateEntree__c = getDate(siret_MAP.get(a.SIRET_texte__c).date_entree);
						pf.DateSortie__c = getDate(siret_MAP.get(a.SIRET_texte__c).date_sortie);
						pf.Enseigne_partenaire__c = siret_MAP.get(a.SIRET_texte__c).enseigne_partenaire;
						pf_up.add(siret_MAP.get(a.SIRET_texte__c).siret);
						this.success.add(siret_MAP.get(a.SIRET_texte__c));

						all_insert.add(pf);
						insert_prog.add(pf);

						if (siret_MAP.get(a.SIRET_texte__c).enseigne_partenaire == a.Enseignes_de_gestion_Client__c) {
							a.Code_client_Point_P__c = siret_MAP.get(a.SIRET_texte__c).code_client_p;
							a.Agence_User__c = all_agence.get(siret_MAP.get(a.SIRET_texte__c).agence_pilote).Id;
							if (a.zqu__Accounts__r.size() == 0) {
								a.Name = siret_MAP.get(a.SIRET_texte__c).name;
								a.Adresse1__c = siret_MAP.get(a.SIRET_texte__c).adresse1;
								a.Adresse2__c = siret_MAP.get(a.SIRET_texte__c).adresse2;
								a.Code_client_Point_P__c = siret_MAP.get(a.SIRET_texte__c).code_client_p;
								//a.Code_postal__r.Key__c = pso.insee_cp;
								if (String.isNotEmpty(siret_MAP.get(a.SIRET_texte__c).insee_cp))
									a.putSObject('Code_postal__r', new Reference__c(Key__c = siret_MAP.get(a.SIRET_texte__c).insee_cp));

								// PAYS par défaut
								//(Test.isRunningTest() == false ) ? a.putSObject('Pays_LKP__r', new Reference__c(Key__c = 'FRA')) : a.putSObject('Pays_LKP__r', new Reference__c(Key__c = 'ZWE'));
								if (!Test.isRunningTest()) {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'FRA')));} else {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'ZWE')));}
								//a.Code_NAF_APE_societe_declarante__r.Key__c = pso.code_naf;
								if (String.isNotEmpty(siret_MAP.get(a.SIRET_texte__c).code_naf))
									a.putSObject('Code_NAF_APE_societe_declarante__r', new Reference__c(Key__c = siret_MAP.get(a.SIRET_texte__c).code_naf));
								//a.Agence_User__r.Key__c = pso.code_agence;
								//a.putSObject('Agence_User__r', new Reference__c(Key__c = pso.code_agence));
							}

							all_update.add(a);
							update_account.add(a);
						} 

					}
				}
			}

			// SIREN
			Map<String, Integer> sirenList = new Map<String, Integer>();
			for (Account a : acc_check_siren) {
				if (sirenList.containsKey(a.SIREN__c)) {
					sirenList.put(a.SIREN__c, (Integer) (sirenList.get(a.SIREN__c)) + 1);
				} else {
					sirenList.put(a.SIREN__c, 1);
				}
			}
			for (Account a : acc_check_siren) {
				if (sirenList.get(a.SIREN__c) == 1) {
					if (!pf_up.contains(a.SIRET_texte__c) && count_ccg.get(siren_MAP.get(a.SIREN__c).code_client_groupe) == null && count_cus.get(siren_MAP.get(a.SIREN__c).customer_id) == null) {
						// Insertion programme de fidèlité
						ProgrammeFidelite__c pf = new ProgrammeFidelite__c();
						siren_MAP.get(a.SIREN__c).tech = 'DONE';
						pf.CustomerId__c = siren_MAP.get(a.SIREN__c).customer_id;
						pf.Code_client_groupe__c = siren_MAP.get(a.SIREN__c).code_client_groupe;
						pf.Compte__c = a.Id;
						pf.Agence_Pilote__c = all_agence.get(siren_MAP.get(a.SIREN__c).agence_pilote).Id;
						pf.DateEntree__c = getDate(siren_MAP.get(a.SIREN__c).date_entree);
						pf.DateSortie__c = getDate(siren_MAP.get(a.SIREN__c).date_sortie);
						pf.Enseigne_partenaire__c = siren_MAP.get(a.SIREN__c).enseigne_partenaire;
						pf_up.add(siren_MAP.get(a.SIREN__c).siret);
						this.success.add(siren_MAP.get(a.SIREN__c));
						all_insert.add(pf);
						insert_prog.add(pf);
						if (siren_MAP.get(a.SIREN__c).enseigne_partenaire == a.Enseignes_de_gestion_Client__c) {
							a.Code_client_Point_P__c = siren_MAP.get(a.SIREN__c).code_client_p;
							a.Agence_User__c = all_agence.get(siren_MAP.get(a.SIREN__c).agence_pilote).Id;
							if (a.zqu__Accounts__r.size() == 0) {
								a.Name = siren_MAP.get(a.SIREN__c).name;
								a.Adresse1__c = siren_MAP.get(a.SIREN__c).adresse1;
								a.Adresse2__c = siren_MAP.get(a.SIREN__c).adresse2;
								a.Code_client_Point_P__c = siren_MAP.get(a.SIREN__c).code_client_p;
								//a.Code_postal__r.Key__c = pso.insee_cp;
								if (String.isNotEmpty(siren_MAP.get(a.SIREN__c).insee_cp))
									a.putSObject('Code_postal__r', new Reference__c(Key__c = siren_MAP.get(a.SIREN__c).insee_cp));
								// PAYS par défaut
								if (!Test.isRunningTest()) {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'FRA')));} else {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'ZWE')));}
								//a.Code_NAF_APE_societe_declarante__r.Key__c = pso.code_naf;
								if (String.isNotEmpty(siren_MAP.get(a.SIREN__c).code_naf))
									a.putSObject('Code_NAF_APE_societe_declarante__r', new Reference__c(Key__c = siren_MAP.get(a.SIREN__c).code_naf));
								//a.Agence_User__r.Key__c = pso.code_agence;
								//a.putSObject('Agence_User__r', new Reference__c(Key__c = pso.code_agence));
							}
							all_update.add(a);
							update_account.add(a);
						} 
					}
				} else {
					System.debug('PartnershipWS *** a.SIREN__c ='+a.SIREN__c);
					//if (!siren_MAP.get(a.SIREN__c).error.contains('SEVERAL SIREN')) { //CMU 11/09/18
					if (a.SIREN__c != null && !siren_MAP.get(a.SIREN__c).error.contains('SEVERAL SIREN')) { //CMU 11/09/18
						siren_MAP.get(a.SIREN__c).error += 'SEVERAL SIREN IN SALESFORCE;';
						this.reject.add(siren_MAP.get(a.SIREN__c));
					}
				}
			}

				
			for (Account a : [SELECT Id, SIRET_texte__c, (SELECT Id FROM zqu__Accounts__r) FROM Account WHERE Id IN :idAccToCheck.keyset()]) {
				

				a.Code_client_Point_P__c = idAccToCheck.get(a.Id).code_client_p;
				a.Agence_User__c = all_agence.get(idAccToCheck.get(a.Id).agence_pilote).Id;
				PartnershipWSobject pso = new PartnershipWSobject();

				if (idAccToCheckcus.containsKey(a.Id))
					pso = idAccToCheckcus.get(a.Id);
				else if (idAccToCheckccg.containsKey(a.Id))
					pso = idAccToCheckccg.get(a.Id);
				
				if (a.zqu__Accounts__r.size() == 0 &&
					(!idAccToCheck.get(a.Id).error.contains('SIRET') || !pso.error.contains('CP')) && 
					( count_ccg.get(pso.code_client_groupe) == null || count_ccg.get(pso.code_client_groupe) == 1) &&
					(count_cus.get(pso.customer_id) == null || count_cus.get(pso.customer_id) == 1)) {
					a.Name = pso.name;
					a.Adresse1__c = pso.adresse1;
					a.Adresse2__c = pso.adresse2;
					a.SIRET_texte__c = pso.siret;
					//a.Code_postal__r.Key__c = pso.insee_cp;
					if (String.isNotEmpty(pso.insee_cp)) { 
						a.putSObject('Code_postal__r', new Reference__c(Key__c = pso.insee_cp));
					}

					// PAYS par défaut
					if (!Test.isRunningTest()) {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'FRA')));} else {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'ZWE')));}
					//a.Code_NAF_APE_societe_declarante__r.Key__c = pso.code_naf;
					if (String.isNotEmpty(pso.code_naf))
						a.putSObject('Code_NAF_APE_societe_declarante__r', new Reference__c(Key__c = pso.code_naf));
					//a.Agence_User__r.Key__c = pso.code_agence;
					//a.putSObject('Agence_User__r', new Reference__c(Key__c = pso.code_agence));
				}
				all_update.add(a);
				update_account.add(a);
			}


			//List<Account> insert_acc = new List<Account>();
			//List<Contact> insert_acc = new List<Contact>();
			//List<ProgrammeFidelite__c> insert_acc = new List<ProgrammeFidelite__c>();

			for (PartnershipWSobject pso : upserts) {

				Boolean once = false;
				system.debug('pso = ' + pso);
				system.debug('pso.error = ' + pso.error);
				system.debug('pso.error.contains(\'PHONE\') = ' + pso.error.contains('PHONE'));

				//CMU: 14/09/18 on verifie que l'email en entrée n'existe pas sur un compte dans SF avec un siret different. Si oui, on remonte une erreur
				system.debug('pso.email = ' + pso.email);
				system.debug('emailSiretMap = ' + emailSiretMap);
				String emailPso = pso.email != null ? (pso.email).toLowerCase() : null;
				system.debug('emailSiretMap.get(pso.email) = ' + emailSiretMap.get(pso.email));
				if(emailPso != null && emailSiretMap.get(emailPso) != null && emailSiretMap.get(emailPso) != pso.siret){
					pso.error += 'SEVERAL EMAIL IN SALESFORCE;';
				}

				if (!pf_up.contains(pso.siret) && !pso.error.contains('SIRET') &&  !pso.error.contains('PHONE') && !pso.error.contains('MAIL') && !pso.error.contains('NAME') && !pso.error.contains('CODE_AGENCE') && !pso.error.contains('CUSTOMER_ID') && !pso.error.contains('LASTNAME') && !pso.error.contains('FIRSTNAME')  && !pso.error.contains('CIVILITE')  && !pso.error.contains('CODE_CLIENT_GROUPE')  && !pso.error.contains('AGENCE_PILOTE') && !pso.error.contains('SEVERAL EMAIL IN SALESFORCE')) {
					system.debug('insertion ko');
					if(pso.siret != null && insert_accountExistMap.get(pso.siret) == null){ //CMU 12/09/18 : Si le meme compte est récupéré avec differents contacts, alors on prend les données du premier compte 
						Account a = new Account();
						Contact c = new Contact();
						ProgrammeFidelite__c pf = new ProgrammeFidelite__c();

						a.Name = pso.name;

						a.SIRET_texte__c = pso.siret;
						a.Adresse1__c = pso.adresse1;
						a.Adresse2__c = pso.adresse2;
						a.Code_client_Point_P__c = pso.code_client_p;
						//a.Code_postal__r.Key__c = pso.insee_cp;
						if (String.isNotEmpty(pso.insee_cp)) {
							a.putSObject('Code_postal__r', new Reference__c(Key__c = pso.insee_cp));
							c.putSObject('Code_postal_lkp__r', new Reference__c(Key__c = pso.insee_cp));

						}

						// PAYS par défaut
						if (!Test.isRunningTest()) {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'FRA')));} else {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'ZWE')));}
						//a.Code_NAF_APE_societe_declarante__r.Key__c = pso.code_naf;
						if (String.isNotEmpty(pso.code_naf))
							a.putSObject('Code_NAF_APE_societe_declarante__r', new Reference__c(Key__c = pso.code_naf));
						a.Enseignes_de_gestion_Client__c = pso.enseigne_gestion;
						//a.Agence_User__r.Key__c = pso.code_agence;
						//a.putSObject('Agence_User__r', new Reference__c(Key__c = pso.code_agence));
						a.Agence_User__c = all_agence.get(pso.code_agence).Id;
						a.RecordTypeId = rtpro.Id;

						pf.CustomerId__c = pso.customer_id;
						pf.Code_client_groupe__c = pso.code_client_groupe;
						//pf.Compte__r = a;
						pf.Compte__r = new Account(SIRET_texte__c = pso.siret);
						pf.DateEntree__c = getDate(pso.date_entree);
						pf.DateSortie__c =getDate(pso.date_sortie);
						pf.Enseigne_partenaire__c = pso.enseigne_partenaire;
						pf.Agence_Pilote__c = all_agence.get(pso.agence_pilote).Id;
						//pf.putSObject('Agence_Pilote__r', new Reference__c(Key__c = pso.agence_pilote));

						c.Account = new Account(SIRET_texte__c = pso.siret);
						c.Email = pso.email;
						c.Phone = pso.phone;
						c.Salutation = pso.civilite;
						//c.Adresse1__c = pso.adresse1;
						//c.Code_postal_lkp__r.Key__c = pso.insee_cp;

						c.Contact_Principal_O_N__c = true;
						c.LastName = pso.lastname;
						c.FirstName = pso.firstname;

						all_insert.add(a);
						all_insert.add(c);
						all_insert.add(pf);

						insert_account.add(a);
						insert_contact.add(c);
						insert_prog.add(pf);

						insert_accountExistMap.put(a.SIRET_texte__c,a); //CMU 12/09/18
					}
					this.success.add(pso);
					once = true;
				}

				system.debug('pso = ' + pso);
				if (!once && pso.error.length() > 0 && !this.reject.contains(pso) && !pf_up.contains(pso.siret))
					this.reject.add(pso);

			}

			if (all_update.size() > 0) {
				update update_account;
				update update_contact;
				update update_prog;
				//update all_update;
			}
			system.debug('all_insert.size() = ' + all_insert.size());
			system.debug('insert_account.size() = ' + insert_account.size());
			system.debug('insert_contact.size() = ' + insert_contact.size());
			system.debug('insert_prog.size() = ' + insert_prog.size());
			if (all_insert.size() > 0){
				//insert all_insert;
				system.debug('insert_account = ' + insert_account);
				system.debug('insert_contact = ' + insert_contact);
				system.debug('insert_prog = ' + insert_prog);
				for( account x:insert_account){
					system.debug('insert_account***= ' + x);
				}
				insert insert_account;
				insert insert_contact;
				insert insert_prog;
			}

		}

		global Date getDate(String date_param){
			Date d = null;
			if (date_param != null) {
				String[] param = date_param.split('/');
				if (param.size() == 3 && param[0].isNumeric() && param[1].isNumeric() && param[2].isNumeric()) {
					d = date.newinstance(Integer.valueOf(param[2]), Integer.valueOf(param[1]),Integer.valueOf(param[0]));
				}
			}
			return d;

		}

		global Boolean validateEmail(String email) { 

			Boolean res = true;
			String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
			Pattern MyPattern = Pattern.compile(emailRegex);
			Matcher MyMatcher = MyPattern.matcher(email);

			if (!MyMatcher.matches()) 
			    res = false;
			return res;	
		}


		global Boolean validatePhone(String phone) {

			Boolean res = true;
			String phoneRegex = '^[+]33[1-9]{1}[0-9]{8}$';
			Pattern MyPattern = Pattern.compile(phoneRegex);
			Matcher MyMatcher = MyPattern.matcher(phone);
			system.debug('MyMatcher.matches() = ' + MyMatcher.matches());
			if (!MyMatcher.matches()) 
			    res = false;
			return res;	
		}

		global Boolean validateCP(String cp) {

			Boolean res = true;
			Pattern MyPattern;
			Matcher MyMatcher;

			if (cp != null) {
				String cpRegex = '^[0-9]{5}_[0-9]{5}$';
				MyPattern = Pattern.compile(cpRegex);
				MyMatcher = MyPattern.matcher(cp);
			}

			if (MyMatcher == null || !MyMatcher.matches() || cp == null) 
			    res = false;

			return res;	
		}

		global Boolean isNullOrEmpty(String string_param){
			Boolean res = true;
			if (string_param != null && string_param.deleteWhitespace() != '' ) {
				res = false;
			}
			return res;	

		}

	}

}