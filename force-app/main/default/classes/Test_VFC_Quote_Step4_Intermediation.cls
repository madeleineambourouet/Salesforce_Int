@isTest (seeAllData=false)
private class Test_VFC_Quote_Step4_Intermediation
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
        

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Key__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Key__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1');
        insert compFirst;
        Reference__c compSecond = new Reference__c(RecordTypeId = RTCompetence, Key__c = '2', Name = 'Second Competence', Parent__c = '1', Libelle_3__c = 'CAT_2');
        insert compSecond;
        
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', AccountId = compte.Id, Phone = '+33111111111');
        insert ctc;
        
        zqu__Quote__c zQuote = new zqu__Quote__c(zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id);
        insert zQuote;

        GeoCat__c geo = TestFactory.createGeoCat(ctc, CP);
        insert geo;

        

        system.debug('>>>>>>>> TEST : End preping data');
        
        Test.startTest();
        
        // Launch the visualforce page
        system.debug('>>>>>>>> TEST : Start Init ctrl');
        PageReference pageRef = Page.VF_Quote_Step4_Intermediation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', zQuote.Id);

        // Launch the controller
        ApexPages.StandardController quoteCtrl = new ApexPages.StandardController(zQuote);
        VFC_Quote_Step4_Intermediation controller = new VFC_Quote_Step4_Intermediation(quoteCtrl);
        system.debug('>>>>>>>> TEST : End Init ctrl');
        
        // List geocat
        system.debug('>>>>>>>> TEST : Start Init ctrl');
        controller.vf_contactIdSelected = ctc.Id;
        controller.vf_contactLastname = ctc.Lastname;
        controller.vf_contactFirstname = ctc.Firstname;
        controller.listGeocat();
        controller.backlistGeocat();
        controller.refreshContact();
        system.debug('>>>>>>>> TEST : End Init ctrl');
        
        // Add geocat
        system.debug('>>>>>>>> TEST : Start Add');
        controller.addGeocat();
        controller.newGeocat.Adresse__c = CP.Id;
        controller.newGeocat.Zone_d_intervention__c = 12;
        controller.newGeocat.DDP__c = 12;
        controller.newGeocat.Exclusion__c = '75015, 75017';
        controller.newGeocat.Date_de_debut__c = Date.Today();
        controller.newGeocat.Date_de_fin__c = Date.Today() + 30;
        controller.newGeocat.FaminePoids__c = 10;

        /*for (Reference__c ref : controller.mapRecord.varNiveau.keySet())
        {
            List<Reference__c> niveau2 = controller.mapRecord.varNiveau.get(ref);
            // go through the list of second item
            for (Reference__c ref2 : niveau2)
               ref2.Selected__c = true;
        }
        */
        for (GeocatMapWrapper.GeocatMapItem item : controller.mapRecord.lReference)
        {
            for (GeocatMapWrapper.CompetenceMapItem ref2 : item.refNiveau2)
            {
                ref2.selected = true;
            }
        }
        
        system.debug('>>>>>>>> TEST : End Add');
        
        // save geocat
        system.debug('>>>>>>>> TEST : Start Save');
        controller.saveGeocat();
        controller.saveGeocatBis();
        system.debug('>>>>>>>> TEST : End Save');
        
        // edit geocat
        system.debug('>>>>>>>> TEST : Start Edit');
        Geocat__c geocat = [SELECT Id FROM Geocat__c ORDER BY CreatedDate DESC LIMIT 1];
        controller.vf_geocatId = geocat.Id;
        controller.editGeocat();
        system.debug('>>>>>>>> TEST : End Edit');
        
        // delete geocat
        system.debug('>>>>>>>> TEST : Start Delete');
        controller.deleteGeocat();
        system.debug('>>>>>>>> TEST : End Delete');
        
        // back
        system.debug('>>>>>>>> TEST : Start Back');
        controller.backsaveGeocat();
        system.debug('>>>>>>>> TEST : End Back');
        
        // navigation
        system.debug('>>>>>>>> TEST : Start Navigation');
        string backtext = controller.BackButtonText;
        string nexttext = controller.NextButtonText;
        controller.navigateNext();
        controller.navigateBack();
        controller.cancel();
        system.debug('>>>>>>>> TEST : End Navigation');
        
        Test.stopTest();
    }
}