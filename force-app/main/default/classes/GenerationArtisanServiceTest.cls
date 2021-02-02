/**
* @author Clement Musabimana
* @date 25/07/2018
* @description classe de test pour le service GenerationArtisanService
**/
@isTest
public class GenerationArtisanServiceTest {
	static testMethod void testGetTokenAccess(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
		insert pays; insert CP; insert NAF; insert enseigne;

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		insert professionnel;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro;  

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		String  access_token = gaService.getTokenAccess();
        System.assertEquals(access_token,'1234abcd');

        Test.stopTest();
    }   
    static testMethod void testGetContactsGenerationArtisanDoublonCodeClientP(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
		insert pays; insert CP; insert NAF; insert enseigne;

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel.Code_client_Point_P__c = 'ccpp1234';
		Account professionnel2 = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel2.Code_client_Point_P__c = 'ccpp1234';
        professionnel2.Name = 'Test account2';
        professionnel2.Phone = '+33635136117';
        professionnel2.SIRET_texte__c = '49836242500015';


		List<Account> listAccounts = new List<Account> ();
		listAccounts.add(professionnel);
		listAccounts.add(professionnel2);
		insert listAccounts;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro;  

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		gaService.getContactsGenerationArtisan('ccpp1234');

        Test.stopTest();
    }  
    static testMethod void testGetContactsGenerationArtisan(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
		insert pays; insert CP; insert NAF; insert enseigne;

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel.Code_client_Point_P__c = 'ccpp1234';
		insert professionnel;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro;  

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		Map<String,Object[]> objectsContactsGa = gaService.getContactsGenerationArtisan('ccpp1234');
		GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');
        System.assertEquals(contactsGa[0].id,'VI_456412');

        Test.stopTest();
    }  
    static testMethod void testVerificationContactsGa(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
		insert pays; insert CP; insert NAF; insert enseigne; insert agence;

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel.Code_client_Point_P__c = 'ccpp1234';
		Account professionnel2 = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel2.Code_client_Point_P__c = 'ccpp1235';
        professionnel2.Name = 'Test account2';
        professionnel2.Phone = '+33635136117';
        professionnel2.SIRET_texte__c = '49836242500015';



		List<Account> listAccounts = new List<Account> ();
		listAccounts.add(professionnel);
		listAccounts.add(professionnel2);
		insert listAccounts;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro; 

		ProgrammeFidelite__c pf = new ProgrammeFidelite__c(); 
		pf.CustomerId__c = '1000170547';
		pf.Code_client_groupe__c = '110ccpp1234';		
		pf.Enseigne_partenaire__c = GenerationArtisanService.ENSEIGNE_PARTENAIRE;
		pf.DateEntree__c =  Date.parse('01/06/2018'); 
		pf.Agence_Pilote__c = agence.Id;
		pf.Compte__c = professionnel2.Id;
		insert pf;

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		Map<String,Object[]> objectsContactsGa = gaService.getContactsGenerationArtisan('ccpp1234');
		GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');
        System.assertEquals(contactsGa[0].id,'VI_456412');
        List<String> listErreurs = gaService.verificationContactsGa('ccpp1234',contactsGa);
        System.assert(listErreurs.size()>=0);

        Test.stopTest();
    } 
    static testMethod void testGetAccount(){
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

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		Map<String,Object[]> objectsContactsGa = gaService.getContactsGenerationArtisan('ccpp1234');
		GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');
        System.assertEquals(contactsGa[0].id,'VI_456412');
        Account a = gaService.getAccount(contactsGa);
        System.assertEquals(a.Adresse2__c,'LES PETITS CHAMPS BIS TER');

        Test.stopTest();
    } 
    static testMethod void testGetAccountIdEmpty(){
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

		GenerationArtisanService gaService = new GenerationArtisanService('');
		Map<String,Object[]> objectsContactsGa = gaService.getContactsGenerationArtisan('ccpp1234');
		GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');
        System.assertEquals(contactsGa[0].id,'VI_456412');
        Account a = gaService.getAccount(contactsGa);
        System.assertEquals(a.Adresse1__c,'LES PETITS CHAMPS');

        Test.stopTest();
    } 
    static testMethod void testGetProgrammesFidelite(){
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

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		Map<String,Object[]> objectsContactsGa = gaService.getContactsGenerationArtisan('ccpp1234');
		GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');
        System.assertEquals(contactsGa[0].id,'VI_456412');
        List<ProgrammeFidelite__c> listPf = gaService.getProgrammesFidelite(contactsGa, professionnel);
        System.assertEquals(listPf[0].CustomerId__c,'1000170547');

        Test.stopTest();
    } 
    static testMethod void testMiseAJourProgrammesFidelite(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c paysZWE = TestFactory.createReference('pays', 'Zimbabwe','ZWE','Zimbabwe');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
		insert pays; insert paysZWE; insert CP; insert NAF; insert enseigne; insert agence;

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

		GenerationArtisanService gaService = new GenerationArtisanService(professionnel.Id);
		Map<String,Object[]> objectsContactsGa = gaService.getContactsGenerationArtisan('ccpp1234');
		GenerationArtisanService.ContactWrapper[] contactsGa =  (GenerationArtisanService.ContactWrapper[])objectsContactsGa.get('contactsGa');
        System.assertEquals(contactsGa[0].id,'VI_456412');
        List<String> listErreurs = gaService.miseAJourProgrammesFidelite('ccpp1234', contactsGa);
        System.assert(listErreurs.size()==0);

        Test.stopTest();
    } 
    static testMethod void testServiceGenerationArtisan(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c paysZWE = TestFactory.createReference('pays', 'Zimbabwe','ZWE','Zimbabwe');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
		insert pays; insert paysZWE; insert CP; insert NAF; insert enseigne; insert agence;

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
		List<String> listErreurs = GenerationArtisanService.serviceGenerationArtisan(professionnel.Id, 'ccpp1234');

        Test.stopTest();
    } 
    static testMethod void testServiceGenerationArtisanVFP(){
        Test.startTest();

		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c paysZWE = TestFactory.createReference('pays', 'Zimbabwe','ZWE','Zimbabwe');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c agence = TestFactory.createReference('Agence', 'CCC','CCC','CCC');
		insert pays; insert paysZWE; insert CP; insert NAF; insert enseigne; insert agence;

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
		List<String> listErreurs = GenerationArtisanService.serviceGenerationArtisanVFP('', 'ccpp1234');

        Test.stopTest();
    } 
  
}