@IsTest
public without sharing class TryAndBuyMethodsTest {
	


	@IsTest
	private static void test() {
		ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
		Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris', key__c = '75001_75001');
        insert CP;

        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'ZWE');
        insert FR;

		TryAndBuyMethods.TryObject obj = new TryAndBuyMethods.TryObject();
		obj.subscriptionMode = 'try';
		
		obj.products = new TryAndBuyMethods.productsObject();
		obj.products.billingPeriod = 'yearly';
		obj.products.productList = new List<TryAndBuyMethods.productListObjet>();
		TryAndBuyMethods.productListObjet prod = new TryAndBuyMethods.productListObjet();
		prod.name = 'Tolteck';
		prod.startDate = '2030-01-01';
		prod.endDate = '2030-02-01';
		obj.products.productList.add(prod);

		obj.company = new TryAndBuyMethods.companyObject();
		obj.company.companyName = 'testo fredo';

		obj.companyIdentifiersFR = new TryAndBuyMethods.companyIdentifiersFRObject();
		obj.companyIdentifiersFR.siret = '41515263600015';

		obj.companyAddress = new TryAndBuyMethods.companyAddressObject();
		obj.companyAddress.address = 'ok des ok';
		obj.companyAddress.InseeCode = '75001';
		obj.companyAddress.country = 'fra';
		obj.companyAddress.zipCode = '75001';

		obj.contacts = new List<TryAndBuyMethods.contactsObject>();

		TryAndBuyMethods.contactsObject con = new TryAndBuyMethods.contactsObject();
		con.title = 'mr';
		con.firstName = 'mr';
		con.lastName = 'mr';
		con.phone1 = '+33111111111';
		con.email = 'aaaaa@aaaaaa.com';

		con.contactAddress = new TryAndBuyMethods.contactAddressObject();
		con.contactAddress.inseeCode = '75001';
		con.contactAddress.zipCode = '75001';
		con.contactAddress.country = 'ZWE';
		obj.contacts = new List<TryAndBuyMethods.contactsObject>();
		obj.contacts.add(con);

		TryWS.traitement_try(obj);
		TryWS.traitement_try(obj);

		

		

	}
}