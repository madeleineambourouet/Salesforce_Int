@isTest
public without sharing class ModifyActivateDateTest {

	@isTest
	public static void activateDateTest() {
		ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        //ID templateID = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Proposition_validee' LIMIT 1];
        
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert TV;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        //EmailTemplate templateNew = new EmailTemplate(DeveloperName = template.DeveloperName, FolderId = template.FolderId, TemplateType= template.TemplateType, Name = template.Name);
        //insert templateNew;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208');
        insert compte;
        
        Contact ctc = new Contact(AccountId = compte.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'pierrot.carpe@businessdecision.com');
        insert ctc;
        
        // AJOUT LEILA
        // After insert : update contact principal on account        
        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id; 
                    update a;
        
        GeoCat__c geocat = TestFactory.createGeocat(ctc, CP);
        
        zqu__Quote__c zQuote = new zqu__Quote__c(RecordTypeId = RTCreationQuote, zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id, Produit__c = 'Offre Homly Travaux', OwnerId = UserInfo.getUserId(), zqu__StartDate__c = Date.newInstance(2100, 1, 1));
        insert zQuote;

        Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
		ApexPages.StandardController quoteCTRL1 = new ApexPages.StandardController(zQuote);
		ModifyActivateDate mad = new ModifyActivateDate(quoteCTRL1);
		
        mad.dateChanged = '10/10/21041';
        mad.changeDate();

        mad.dateChanged = '10/10/6000';
        mad.changeDate();

        mad.dateChanged = '10/10/2000';
        mad.changeDate();

        mad.dateChanged = '10/10/2104';
        mad.changeDate();
        mad.goBack();

		//mad.code = 404;
		//mad.changeDate();
		
		//mad.code = 999;
		//mad.changeDate();
		Test.stopTest();
	}

	public class MockHttpResponse200 implements HttpCalloutMock {
    // Implement this interface method
   		public HTTPResponse respond(HttpRequest req) {
        
	        // Create a fake response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/pdf;charset=UTF-8');
	        res.setBody('ok');
	        res.setStatusCode(200);
	        return res;
    	}
	}
		
}