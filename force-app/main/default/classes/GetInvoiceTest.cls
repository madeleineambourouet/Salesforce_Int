@isTest
global without sharing class GetInvoiceTest {

	@isTest
	public static void invoicesTest() {
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
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208');
        insert compte;
        
        Contact ctc = new Contact(AccountId = compte.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'pierrot.carpe@businessdecision.com');
        ctc.Contact_Principal_O_N__c = true;
        insert ctc;

        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id; 
                    update a;

		Zuora__ZInvoice__c facture = new Zuora__ZInvoice__c();
		facture.Name = 'TEST';
		facture.Zuora__Account__c = compte.Id;

		insert facture;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
		ApexPages.StandardController factureCTRL1 = new ApexPages.StandardController(facture);
        GetInvoice getI = new GetInvoice(factureCTRL1);

        getI.saveInv();
        getI.saveInv();

        getI.code = 404;
        getI.saveInv();

        getI.code = 987;
        getI.saveInv();

        List<Attachment> inv = [SELECT Id FROM Attachment WHERE ParentId = :getI.currentInvoice.Id];
        delete inv;
        getI.code = 200;
        getI.emailToContact();
        getI.emailToContact();

        ctc.Contact_Principal_O_N__c = false;
        update ctc;
        getI.contactMail = null;
        getI.emailToContact();
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