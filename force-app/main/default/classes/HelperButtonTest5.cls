@isTest
public with sharing class HelperButtonTest5 {
	
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
		insert acc;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = acc.Id;
        quote.Name = 'Quote Name';
        quote.zqu__Status__c = 'Sent to Z-Billing';
        insert quote;

		Attachment pj = new Attachment(ParentId = quote.Id, Name = 'PJ', Body = Blob.valueof('body des body'));
		insert pj;

		Test.startTest();
		helperButton.validerProposition(quote.Id);

		helperButton.callAbandonnerProposition(quote.Id);
		Test.stopTest();

	}
}