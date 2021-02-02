/**
* @author Clement Musabimana
* @date 25/07/2018
* @description classe de test pour le service VFC_Search_ProgrammesFidelite
**/
@isTest
public class VFC_Search_ProgrammesFideliteTest {
	static testMethod void testGetContactsFromGenerationArtisanErreur(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
		insert pays; insert CP; insert NAF; insert enseigne; insert agence;

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel.Code_client_Point_P__c = 'ccpp1234';

		List<Account> listAccounts = new List<Account>();
		listAccounts.add(professionnel);
		insert listAccounts;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro; 

		ProgrammeFidelite__c pf = new ProgrammeFidelite__c(); 
		pf.CustomerId__c = '1000170547';
		pf.Code_client_groupe__c = '110ccpp1234';		
		pf.Enseigne_partenaire__c = GenerationArtisanService.ENSEIGNE_PARTENAIRE;
		pf.DateEntree__c =  Date.parse('01/06/2018'); 
		pf.Agence_Pilote__c = agence.Id;
		pf.Compte__c = professionnel.Id;
		insert pf;

		PageReference pageRef = Page.VF_Search_ProgrammesFidelite;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSessionConsole','1');

		VFC_Search_ProgrammesFidelite searchPF = new VFC_Search_ProgrammesFidelite();
		searchPF.codeClientP = 'ccpp1234';
		searchPF.getContactsFromGenerationArtisan();

        Test.stopTest();
    }  
	static testMethod void testGetContactsFromGenerationArtisanOk(){ 
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
        Reference__c ZWE = TestFactory.createReference('pays', 'zimbabwe','ZWE','zimbabwe');

        insert ZWE;
		insert pays; insert CP; insert NAF; insert enseigne; insert agence;

		ID RTAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1].Id;

        Reference__c agence2 = new Reference__c(RecordTypeId = RTAgence, Name = 'DINARD POINT P', key__c = '1907');
        insert agence2;

		List<Account> listAccounts = new List<Account>();
		PageReference pageRef = Page.VF_Search_ProgrammesFidelite;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('isSessionConsole','1');

		VFC_Search_ProgrammesFidelite searchPF = new VFC_Search_ProgrammesFidelite();
		searchPF.codeClientP = 'ccpp1234'; 
		searchPF.getContactsFromGenerationArtisan();

        Test.stopTest();
    } 
}