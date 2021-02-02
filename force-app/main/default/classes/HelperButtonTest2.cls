@isTest
public with sharing class HelperButtonTest2 {
	
	@isTest
	public static void HelperTest() {
		// initialisation
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
		insert acc;

		Contact contactPro = TestFactory.createContact(acc);
    	insert contactPro;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = acc.Id;
        quote.Name = 'Quote Name';
        quote.PM_SecondTokenId__c = '12344563768';
        quote.PM_TokenId__c = '1343434';
        quote.PM_CreditCardType__c = 'Visa';
        quote.PM_CardNumber__c = '1234567876545676';
        quote.PM_CardHolderName__c = 'Test Test';
        quote.PM_ExpirationYear__c = '2017';
        quote.PM_ExpirationMonth__c = '10';
        quote.PM_Email__c = 'a@a.a';
        quote.PM_BillingCountry__c = 'us';
        quote.zqu__Status__c = 'New';
        insert quote;

        Zuora__ZInvoice__c facture = new Zuora__ZInvoice__c();
		facture.Name = 'TEST';
		facture.Zuora__Account__c = acc.Id;
		insert facture;

		Attachment pj = new Attachment(ParentId = quote.Id, Name = 'PJ', Body = Blob.valueof('body des body'));
		insert pj;

		Test.startTest();
		HelperButton.getInvoiceNumber(facture.Id);

        HelperButton.validerProposition(quote.Id);

        HelperButton.validerModification(quote.Id, 'modif');
        Test.stopTest();
	}
}