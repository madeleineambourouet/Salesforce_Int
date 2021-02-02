@isTest
global with sharing class PartnershipWSTest {
	@isTest
	global static void test_method() {
		ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
		ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
		ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
		ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;

		Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'Zimbabwe', key__c = 'ZWE');
        insert FR;
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = '1310');
        insert enseigne;
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Name = 'Reims', key__c = '51100_51454');
        insert CP;
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA', key__c = '6920Z'); 
        insert NAF;

		List<PartnershipWS.PartnershipWSobject> testList = new List<PartnershipWS.PartnershipWSobject>();
		List<PartnershipWS.PartnershipWSobject> testList2 = new List<PartnershipWS.PartnershipWSobject>();
		testList = DatasetClass.getTestMade(null,null,true);
		testList2 = DatasetClass.getTestMade(6,'passage',false);
		Integer i = 1;

		for (PartnershipWS.PartnershipWSobject pso : testList) {
			if (i == 1)
				pso.siret = '83893931200016';
			if (i == 2)
				pso.siret = '50938297400012';
			if (i == 3)
				pso.siret = '50232631700018';
			if (i == 4)
				pso.siret = '49395661900016';
			if (i == 5)
				pso.siret = '49467411200011';
			i++;
		}

		PartnershipWS.traitement_data(testList);
		PartnershipWS.traitement_data(testList);

		i = 1;

		for (PartnershipWS.PartnershipWSobject pso : testList) {
			if (i == 1)
				pso.customer_id = 'change0000test';
			if (i == 2) {
				pso.customer_id = 'change0000test';
				pso.code_client_groupe = 'change0000test';
			}
			if (i == 3) {
				pso.customer_id = 'change0000test2';
				pso.code_client_groupe = 'change0000test2';
				pso.siret = '50232631700017';
			}
			i++;
			/*if (i == 4) {
				pso.customer_id = 'change0000test3';
				pso.code_client_groupe = 'change0000test3';
				pso.siret = '49395661900015';
			}
			if (i == 5) {
				pso.customer_id = 'change0000test3';
				pso.code_client_groupe = 'change0000test3';
				pso.siret = '49395661900017';
			}*/
		}

		PartnershipWS.traitement_data(testList);
		//PartnershipWS.traitement_data(testList);
	}


}