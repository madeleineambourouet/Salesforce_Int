@isTest(seealldata = false)
private class Test_VFC_Geocat_NewEditBis
{

    private static testMethod void test() 
    {
        system.debug('>>>>>>>> TEST : Start preping data');
        // Creation of test data
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1', Obsolete__c = true );
        insert compFirst;
        Reference__c compSecond = new Reference__c(RecordTypeId = RTCompetence, Key__c = '2', Name = 'Second Competence', Parent__c = '1', Libelle_3__c = 'CAT_2', Obsolete__c = true);
        insert compSecond;
        
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', AccountId = compte.Id, Phone = '+33111111111');
        insert ctc;
        
        system.debug('>>>>>>>> TEST : End preping data');
        
        
        
        // Launch the visualforce page
        system.debug('>>>>>>>> TEST : Start Init ctrl');
        //PageReference pageRef = Page.VF_Geocat_NewEditBis;
        //Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id', zQuote.Id);

        // Launch the controller
        Geocat__c geocat = new Geocat__c();
        ApexPages.StandardController geocatCtrl = new ApexPages.StandardController(geocat);
        VFC_Geocat_NewEditBis controller = new VFC_Geocat_NewEditBis(geocatCtrl);
        system.debug('>>>>>>>> TEST : End Init ctrl');
        
        // Save geocat
        system.debug('>>>>>>>> TEST : Start Save');
        controller.thisGeocat.Contact__c = ctc.Id;
        controller.thisGeocat.Adresse__c = CP.Id;
        controller.thisGeocat.Zone_d_intervention__c = 12;
        controller.thisGeocat.DDP__c = 12;
        controller.thisGeocat.Exclusion__c = '75015, 75017';
        controller.thisGeocat.Date_de_debut__c = Date.Today();
        controller.thisGeocat.Date_de_fin__c = Date.Today() + 30;
        controller.thisGeocat.FaminePoids__c = 10;
        /**
        for (Reference__c ref : controller.mapRecord.varNiveau.keySet())
        {
            List<Reference__c> niveau2 = controller.mapRecord.varNiveau.get(ref);
            // go through the list of second item
            for (Reference__c ref2 : niveau2)
               ref2.Selected__c = true;
        }
        **/
        for (GeocatMapWrapperBis.GeocatMapItem item : controller.mapRecord.lReference)
        {
            for (Reference__c ref2 : item.refNiveau2)
            {
                ref2.Selected__c = true;
            }
        }
        //controller.saveGeocat();
        PageReference pr = controller.saveGeocat();
        if (pr == null) {
        	controller.thisGeocat.Exclusion__c = '75015.75017';
        	pr = controller.saveGeocat();
        	if (pr == null) {
        		controller.thisGeocat.Exclusion__c = '7;75017';
        		pr = controller.saveGeocat();
        		if (pr == null) {
	        		controller.thisGeocat.Exclusion__c = '75015;75017';
	        		pr = controller.saveGeocat();
	        	}
        	}
        }
        System.debug('pr  : ' + pr);
        Id geocatId = (Id)(pr.getUrl().replace('/', ''));
        System.debug('geocatId ' + geocatId);
        system.debug('>>>>>>>> TEST : End Save');


        Test.startTest();

        // Edit geoat
        system.debug('>>>>>>>> TEST : Start Edit');
        //Geocat__c geocatEdit = [SELECT Id FROM Geocat__c ORDER BY CreatedDate DESC LIMIT 1];
        Geocat__c geocatEdit = [SELECT Id FROM Geocat__c WHERE Id = :geocatId];
        ApexPages.StandardController geocatCtrl1 = new ApexPages.StandardController(geocatEdit);
        VFC_Geocat_NewEditBis controllerEdit = new VFC_Geocat_NewEditBis(geocatCtrl1);
        controller.saveGeocat();
        system.debug('>>>>>>>> TEST : End Edit');        
        
        // Back geocat
        system.debug('>>>>>>>> TEST : Start Back');
        controller.backsaveGeocat();
        system.debug('>>>>>>>> TEST : End Back');
        
        Test.stopTest();
    }

}