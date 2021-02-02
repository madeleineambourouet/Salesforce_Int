@isTest 
private class Test_DQE 
{
     private static testMethod void test_DQE_AddressController()
    {
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','75017');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert pays; insert CP; insert NAF; insert enseigne; insert TV;
        
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Adresse_mail__c = 'test@gmail.com';
        professionnel.Phone = '0612345678';
        insert professionnel;
        Contact ctc  = TestFactory.createContact(professionnel);
        insert ctc;
        Lead ld = TestFactory.createLead(NAF);
        insert ld;
        
        Test.startTest();
        
        DQE_AddressController ctrl = new DQE_AddressController();
        ctrl.controller = ctrl;
        ctrl.objectType = 'Account';
        ctrl.fieldPays = 'Pays';
        ctrl.fieldCP = 'CP';
        ctrl.recordAccount = professionnel;
        ctrl.fieldStreet = 'Name';
        ctrl.fieldNumber = 'Name';
        String label1 = ctrl.fieldStreetLabel;
        label1 = ctrl.fieldNumberLabel;
        ctrl.recordAccount = null;
        ctrl.recordContact = ctc;
        ctrl.fieldStreet = 'Name';
        ctrl.fieldNumber = 'Name';
        label1 = ctrl.fieldStreetLabel;
        label1 = ctrl.fieldNumberLabel;
        ctrl.recordContact = null;
        ctrl.recordLead = ld;
        ctrl.fieldStreet = 'Name';
        ctrl.fieldNumber = 'Name';
        label1 = ctrl.fieldStreetLabel;
        label1 = ctrl.fieldNumberLabel;
        
        ctrl.getPageCont();
        
        Test.stoptest();
    }

    private static testMethod void test_DQE_AutoCompleteController()
    {
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','75017');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert pays; insert CP; insert NAF; insert enseigne; insert TV;
        
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Adresse_mail__c = 'test@gmail.com';
        professionnel.Phone = '0612345678';
        insert professionnel;
        Contact ctc  = TestFactory.createContact(professionnel);
        insert ctc;
        Lead ld = TestFactory.createLead(NAF);
        insert ld;
        
        Test.startTest();
        
        DQE_AutoCompleteController ctrl = new DQE_AutoCompleteController();
        
        ctrl.cacheField  = 'cacheField';
        ctrl.searchType = 'City';
        ctrl.controller = ctrl;
        ctrl.objectType = 'Account';
    
        List<String> lCities = DQE_AutoCompleteController.getDQECities('FRA', '44860', 'City', 'St');
        system.assert(lCities != null && lCities.size() > 0);
        
        List<DQE_CityResult.DQE_City> lCitiesDQE = DQE_AutoCompleteController.getDQECities1('FRA', '44860', 'City', 'St');
        system.assert(lCitiesDQE != null && lCitiesDQE.size() > 0);
        
        
        List<DQE_StreetResult.DQE_Street> LStreet = DQE_AutoCompleteController.getDQEStreets('Street', cp.Id, 'FRA', 'pin');
        system.assert(LStreet != null && LStreet.size() > 0);
        
        List<String> lNumber = DQE_AutoCompleteController.getDQEStreetNumber('Number', cp.Id, '8876', '44860', 'FRA', '1');
        system.assert(lNumber != null && lNumber.size() > 0);
        
        Test.stopTest();
    }


	private static testMethod void test_VFC_Account_Edit() {
	    
	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert pays; insert CP; insert NAF; insert enseigne; insert TV;
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Adresse_mail__c = 'test@gmail.com';
        professionnel.Phone = '0612345678';
        insert professionnel;
        Contact ctc  = TestFactory.createContact(professionnel);
        insert ctc;
        Lead ld = TestFactory.createLead(NAF);
        insert ld;
        Layout_Configuration__c layout = new Layout_Configuration__c(Name = 'Account', Email_to_validate__c = 'Adresse_mail__c', Champs_telephone_a_valider__c = 'Phone;PersonHomePhone;PersonMobilePhone;T_l_phone_ATC__c', 
		                                                Champs_SIRET_a_valider__c = 'SIRET_texte__c');
		layout.Champs_addresse_valider_1__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		layout.Champs_addresse_valider_2__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		layout.Champs_addresse_valider_3__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Account.fieldSets.getMap();
		for (Schema.FieldSet key : FsMap.values())
		{
		    layout.Fieldset_to_display__c += key.getName() + ';';
		}
        insert layout;
        system.debug('>>>> TEST: ' + layout);
        Test.startTest();
        //Test.setMock(HTTPCalloutMock.class, new MockHTTP());
        VFC_Account_Edit accPage = new VFC_Account_Edit(new ApexPages.StandardController(professionnel));
        //VFC_Contact_Edit ctcPage = new VFC_Contact_Edit(new ApexPages.StandardController(ctc));
        //VFC_Lead_Edit ldPage = new VFC_Lead_Edit(new ApexPages.StandardController(ld));
        
        accPage.getPageCont();
        accPage.save();
        accPage.cancel();
        
        DQE_EmailController dqe_email = new DQE_EmailController();
        dqe_email.controller = accPage;
        dqe_email.emailToCheck = professionnel.Adresse_mail__c;
        dqe_email.objectType = 'Account';
        dqe_email.emailAPIName = 'Adresse_mail__c';
        String labelEmail = dqe_email.fieldEmailLabel;
        dqe_email.checkEmailField();
        
        DQE_PhoneController dqe_phone = new DQE_PhoneController();
        dqe_phone.controller = accPage;
        dqe_phone.phoneToCheck = professionnel.Phone;
        dqe_phone.objectType = 'Account';
        dqe_phone.phoneAPIName = 'Phone';
        String labelPhone = dqe_phone.fieldPhoneLabel;
        dqe_phone.checkPhoneField();
        
        DQE_SIRETController dqe_SIRET = new DQE_SIRETController();
        dqe_SIRET.controller = accPage;
        dqe_SIRET.SIRETToCheck = professionnel.SIRET_texte__c;
        dqe_SIRET.objectType = 'Account';
        dqe_SIRET.SIRETAPIName = 'SIRET_texte__c';
        String labelSIRET = dqe_SIRET.fieldSIRETLabel;
        dqe_SIRET.checkSIRETField();
        dqe_SIRET.SIRETToCheck = '0123';
        dqe_SIRET.checkSIRETField();
        
        //accPage.emailField = 'Adresse_mail__c';
        //accPage.checkEmailField();
        Test.stopTest();
	}

    	private static testMethod void test_VFC_Contact_Edit() {
	    
	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert pays; insert CP; insert NAF; insert enseigne; insert TV;
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Adresse_mail__c = 'test@gmail.com';
        professionnel.Phone = '0612345678';
        insert professionnel;
        Contact ctc  = TestFactory.createContact(professionnel);
        insert ctc;
        Lead ld = TestFactory.createLead(NAF);
        insert ld;
        Layout_Configuration__c layout = new Layout_Configuration__c(Name = 'Contact', Email_to_validate__c = 'Adresse_mail__c', Champs_telephone_a_valider__c = 'Phone;PersonHomePhone;PersonMobilePhone;T_l_phone_ATC__c', 
		                                                Champs_SIRET_a_valider__c = 'SIRET_texte__c');
		layout.Champs_addresse_valider_1__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		layout.Champs_addresse_valider_2__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		layout.Champs_addresse_valider_3__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Contact.fieldSets.getMap();
		for (Schema.FieldSet key : FsMap.values())
		{
		    layout.Fieldset_to_display__c += key.getName() + ';';
		}
        insert layout;
        system.debug('>>>> TEST: ' + layout);
        Test.startTest();
        //Test.setMock(HTTPCalloutMock.class, new MockHTTP());
        VFC_Contact_Edit ctcPage = new VFC_Contact_Edit(new ApexPages.StandardController(ctc));
        //VFC_Contact_Edit ctcPage = new VFC_Contact_Edit(new ApexPages.StandardController(ctc));
        //VFC_Lead_Edit ldPage = new VFC_Lead_Edit(new ApexPages.StandardController(ld));
        
        ctcPage.getPageCont();
        ctcPage.save();
        ctcPage.cancel();
        
        DQE_EmailController dqe_email = new DQE_EmailController();
        dqe_email.controller = ctcPage;
        dqe_email.emailToCheck = ctc.Email;
        dqe_email.objectType = 'Contact';
        dqe_email.emailAPIName = 'Email';
        String labelEmail = dqe_email.fieldEmailLabel;
        dqe_email.checkEmailField();
        
        DQE_PhoneController dqe_phone = new DQE_PhoneController();
        dqe_phone.controller = ctcPage;
        dqe_phone.phoneToCheck = ctc.Phone;
        dqe_phone.objectType = 'Contact';
        dqe_phone.phoneAPIName = 'Phone';
        String labelPhone = dqe_phone.fieldPhoneLabel;
        dqe_phone.checkPhoneField();
        
        Test.stopTest();
	}

    private static testMethod void test_VFC_Lead_Edit() {
	    
	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert pays; insert CP; insert NAF; insert enseigne; insert TV;
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Adresse_mail__c = 'test@gmail.com';
        professionnel.Phone = '0612345678';
        insert professionnel;
        Contact ctc  = TestFactory.createContact(professionnel);
        insert ctc;
        Lead ld = TestFactory.createLead(NAF);
        insert ld;
        Layout_Configuration__c layout = new Layout_Configuration__c(Name = 'Lead', Email_to_validate__c = 'Adresse_mail__c', Champs_telephone_a_valider__c = 'Phone;PersonHomePhone;PersonMobilePhone;T_l_phone_ATC__c', 
		                                                Champs_SIRET_a_valider__c = 'SIRET_texte__c');
		layout.Champs_addresse_valider_1__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		layout.Champs_addresse_valider_2__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		layout.Champs_addresse_valider_3__c = 'P:Pays;CP=CP__c;R=Rue__c;N=Number__c';
		Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Lead.fieldSets.getMap();
		for (Schema.FieldSet key : FsMap.values())
		{
		    layout.Fieldset_to_display__c += key.getName() + ';';
		}
        insert layout;
        system.debug('>>>> TEST: ' + layout);
        Test.startTest();
        //Test.setMock(HTTPCalloutMock.class, new MockHTTP());
        VFC_Lead_Edit ldPage = new VFC_Lead_Edit(new ApexPages.StandardController(ld));
        //VFC_Contact_Edit ctcPage = new VFC_Contact_Edit(new ApexPages.StandardController(ctc));
        //VFC_Lead_Edit ldPage = new VFC_Lead_Edit(new ApexPages.StandardController(ld));
        
        ldPage.getPageCont();
        ldPage.save();
        ldPage.cancel();
        
        DQE_EmailController dqe_email = new DQE_EmailController();
        dqe_email.controller = ldPage;
        dqe_email.emailToCheck = ld.Email;
        dqe_email.objectType = 'Lead';
        dqe_email.emailAPIName = 'Email';
        String labelEmail = dqe_email.fieldEmailLabel;
        dqe_email.checkEmailField();
        
        DQE_PhoneController dqe_phone = new DQE_PhoneController();
        dqe_phone.controller = ldPage;
        dqe_phone.phoneToCheck = ld.Phone;
        dqe_phone.objectType = 'Lead';
        dqe_phone.phoneAPIName = 'Phone';
        String labelPhone = dqe_phone.fieldPhoneLabel;
        dqe_phone.checkPhoneField();
        
        DQE_SIRETController dqe_SIRET = new DQE_SIRETController();
        dqe_SIRET.controller = ldPage;
        dqe_SIRET.SIRETToCheck = ld.SIRET__c;
        dqe_SIRET.objectType = 'Lead';
        dqe_SIRET.SIRETAPIName = 'SIRET__c';
        String labelSIRET = dqe_SIRET.fieldSIRETLabel;
        dqe_SIRET.checkSIRETField();
        dqe_SIRET.SIRETToCheck = '0123';
        dqe_SIRET.checkSIRETField();
        
        Test.stopTest();
	}

}