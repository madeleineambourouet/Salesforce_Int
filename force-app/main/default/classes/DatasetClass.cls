@RestResource(urlMapping='/ok_pour_le_get/')
global without sharing class DatasetClass {
	
	/*@HttpGet
	global static Integer test_get() {
		return 5;
	}

	/*@HttpPost
	global static List<MyUserDefinedClass> tests_get(List<MyUserDefinedClass> ok) {
		
		return ok;
	}

	global class MyUserDefinedClass {
		global String ok1;
		global String test_chps;
	}*/

	@httpPost
	global static List<PartnershipWS.PartnershipWSobject> getTestMade(Integer nbr, String baseName, Boolean agence) {
		if (nbr == null || nbr < 0)
			nbr = 5;

		if (baseName == null)
			baseName = 'test';

		
		List<PartnershipWS.PartnershipWSobject> objectlist = new List<PartnershipWS.PartnershipWSobject>();
		for(Integer count = 0; count < nbr; count++) {
			PartnershipWS.PartnershipWSobject pws = new PartnershipWS.PartnershipWSobject();
			pws.name = baseName + count;
			pws.insee_cp = '51100_51454';
			pws.code_naf = '6920Z';
			pws.adresse1 = 'rue de ' + baseName;
			pws.adresse2 = 'batiment ' + baseName;
			pws.enseigne_gestion = 'POINT P';
			if (agence) {
				pws.code_agence = '1310';
				pws.agence_pilote = '1310';
			} else {
				pws.nom_agence = 'agence0000' + count;
				pws.code_agence = '0000000' + count;
				pws.agence_pilote = '0000000' + count;
			}
			pws.code_client_p = 'CODECLIENT' + count;
			pws.lastname = 'last'+baseName;
			pws.firstname = 'first'+baseName;
			pws.civilite = 'M.';
			pws.email = baseName + '+' + count + '@test.fr';
			pws.phone = '+33111111111';
			pws.code_client_groupe = '00000000ABC' + count;
			pws.date_entree = '01/01/2018';
			pws.date_sortie = '01/01/2118';
			pws.enseigne_partenaire = 'POINT P';
			pws.customer_id = count + '000Z' + baseName + count;
			objectlist.add(pws);
		}

		return objectlist;
	}
}