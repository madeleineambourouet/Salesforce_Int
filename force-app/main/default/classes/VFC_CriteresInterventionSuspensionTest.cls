/**
* @author Musabimana Clement
* @date 14/08/2018
* @description Test class for VFC_CriteresInterventionSuspension
**/
@isTest
public class VFC_CriteresInterventionSuspensionTest {
    @testSetup 
    static void setup() {

	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
	    Reference__c CP1 = TestFactory.createReference('CP', '75017','75017','Paris');
	    Reference__c CP2 = TestFactory.createReference('CP', '75018','75018','Paris');
	    Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');		

		Account professionnel = TestFactory.createAccount(true, pays, CP1, enseigne, NAF);
		insert professionnel;
		Contact contactPro = TestFactory.createContact(professionnel);
		insert contactPro;
      	GeoCat__c geocat1 = TestFactory.createGeocat(contactPro, CP1);
      	geocat1.Zone_d_intervention__c = 1;
      	GeoCat__c geocat2 = TestFactory.createGeocat(contactPro, CP2);
      	geocat2.Zone_d_intervention__c = 2;
      	insert geocat1;
      	insert geocat2;

    }

    static testMethod void testSetDateSuspensionEmptyDates(){
        Test.startTest();

        Contact contactpro = [SELECT Id,Name FROM Contact LIMIT 1];
		PageReference pageRef = Page.VF_CriteresInterventionSuspension;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', contactpro.Id);
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contactpro);
		VFC_CriteresInterventionSuspension ciSuspension = new VFC_CriteresInterventionSuspension(stdContact);
		ciSuspension.setDateSuspension();
        Test.stopTest();
    } 

    static testMethod void testSetDateSuspensionInvalidesDates(){
        Test.startTest();

        Contact contactpro = [SELECT Id,Name FROM Contact LIMIT 1];
		PageReference pageRef = Page.VF_CriteresInterventionSuspension;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', contactpro.Id);
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contactpro);
		VFC_CriteresInterventionSuspension ciSuspension = new VFC_CriteresInterventionSuspension(stdContact);
		ciSuspension.critereInterventionGenerique.Date_de_debut__c = Date.newInstance(2018, 08, 17);
		ciSuspension.setDateSuspension();
        Test.stopTest();
    }  

    static testMethod void testSetDateSuspensionDateDebutSupDateFin(){
        Test.startTest();

        Contact contactpro = [SELECT Id,Name FROM Contact LIMIT 1];
		PageReference pageRef = Page.VF_CriteresInterventionSuspension;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', contactpro.Id);
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contactpro);
		VFC_CriteresInterventionSuspension ciSuspension = new VFC_CriteresInterventionSuspension(stdContact);
		ciSuspension.critereInterventionGenerique.Date_de_debut__c = Date.newInstance(2018, 08, 17);
		ciSuspension.critereInterventionGenerique.Date_de_fin__c = Date.newInstance(2018, 08, 01);
        ciSuspension.critereInterventionGenerique.Motifs_de_suspension__c = 'Assurance';
		ciSuspension.setDateSuspension();
        Test.stopTest();
    }   

    static testMethod void testSetDateSuspensionDatesNotEmptyAndOk(){
        Test.startTest();

        Contact contactpro = [SELECT Id,Name FROM Contact LIMIT 1];
        List<GeoCat__c> lGeoCat = [SELECT id, Date_de_debut__c, Date_de_fin__c FROM GeoCat__c WHERE Contact__c =: contactpro.Id];
        System.assertEquals(lGeoCat[0].Date_de_debut__c,null);
        System.assertEquals(lGeoCat[0].Date_de_fin__c,null);
		PageReference pageRef = Page.VF_CriteresInterventionSuspension;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', contactpro.Id);
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contactpro);
		VFC_CriteresInterventionSuspension ciSuspension = new VFC_CriteresInterventionSuspension(stdContact);
		ciSuspension.critereInterventionGenerique.Date_de_debut__c = Date.newInstance(2018, 08, 01);
		ciSuspension.critereInterventionGenerique.Date_de_fin__c = Date.newInstance(2018, 08, 17);
        ciSuspension.critereInterventionGenerique.Motifs_de_suspension__c = 'Assurance';
		ciSuspension.setDateSuspension();
        lGeoCat = [SELECT id, Date_de_debut__c, Date_de_fin__c FROM GeoCat__c WHERE Contact__c =: contactpro.Id];
        System.assertEquals(lGeoCat[0].Date_de_debut__c,Date.newInstance(2018, 08, 01));
        System.assertEquals(lGeoCat[0].Date_de_fin__c,Date.newInstance(2018, 08, 17));
        Test.stopTest();
    }

    static testMethod void testCancelModification(){
        Test.startTest();

        Contact contactpro = [SELECT Id,Name FROM Contact LIMIT 1];
		PageReference pageRef = Page.VF_CriteresInterventionSuspension;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', contactpro.Id);
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contactpro);
		VFC_CriteresInterventionSuspension ciSuspension = new VFC_CriteresInterventionSuspension(stdContact);
		ciSuspension.cancelModification();
        Test.stopTest();
    } 
}