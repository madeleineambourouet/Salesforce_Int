@isTest
public without sharing class CompteProSectionTest {

    @isTest
    public static void RecapTest() {
        Test.startTest();
        User u = [SELECT Id, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()];
        RecordType rtm = [SELECT Id, DeveloperName
                            FROM RecordType
                            WHERE DeveloperName = 'Matching_rejet' LIMIT 1];
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;

        List<Reference__c> listReferences = new List<Reference__c>();
        List<Account> listAccounts = new List<Account>();
        List<Zuora__Product__c> listZuoraProducts = new List<Zuora__Product__c>();
        List<Zuora__SubscriptionProductCharge__c> listZuoraSubscriptionProductCharges = new List<Zuora__SubscriptionProductCharge__c>();
        List<Intermediation__c> listIntermediations = new List<Intermediation__c>();

        Reference__c RECRED = new Reference__c(RecordTypeId = rtm.Id, Name='Recrédit test', key__c = 'TEST');
        //insert RECRED;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        //insert NAF;

        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        //insert FR;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        //insert CP;

        Reference__c ENS = new Reference__c(RecordTypeId = RTEnseigne,  Name = 'enseigne', key__c = 'ENS');
        //insert ENS;


        Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1', Obsolete__c = true );
        //insert compFirst;
        listReferences.add(RECRED);
        listReferences.add(NAF);
        listReferences.add(FR);
        listReferences.add(CP);
        listReferences.add(ENS);
        listReferences.add(compFirst);
        insert listReferences; 


        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        //insert compte;

        Account part = TestFactory.createAccount(false, FR, CP, ENS, NAF);
        //insert part;
        listAccounts.add(compte);
        listAccounts.add(part);
        insert listAccounts; 

        Contact con = TestFactory.createContact(compte);
        insert con;

        Zuora__Product__c z1 = new Zuora__Product__c(Name='test z', Zuora__SKU__c='SKU-00000001');
        //insert z1;

        Zuora__Product__c z4 = new Zuora__Product__c(Name='test z', Zuora__SKU__c='SKU-00000004');
        //insert z4;
        listZuoraProducts.add(z1);
        listZuoraProducts.add(z4);
        insert listZuoraProducts;

        Zuora__SubscriptionProductCharge__c zcap = new Zuora__SubscriptionProductCharge__c(Name='Abonnement CapRenov+', Zuora__Account__c=compte.Id, Zuora__EffectiveEndDate__c = Date.today(), Zuora__EffectiveStartDate__c = Date.today(), Zuora__Product__c=z1.Id);
        //insert zcap;

        Zuora__SubscriptionProductCharge__c zoff = new Zuora__SubscriptionProductCharge__c(Name='Abonnement Offre Homly Travaux', Zuora__Account__c=compte.Id, Zuora__EffectiveEndDate__c = Date.today(), Zuora__EffectiveStartDate__c = Date.today(), Zuora__Product__c=z4.Id);
        //insert zoff;
        listZuoraSubscriptionProductCharges.add(zcap);
        listZuoraSubscriptionProductCharges.add(zoff);
        insert listZuoraSubscriptionProductCharges;

        Event e = new Event(Subject='visite client', WhatId=compte.Id, DurationInMinutes=15, ActivityDateTime=Date.Today());
        insert e;

        Task t = new Task(Subject='appel', WhatId=compte.Id);
        insert t;

        GeoCat__c geo = TestFactory.createGeoCat(con, CP);
        geo.Account__c = compte.Id;
        geo.DDP__c = 10;
        insert geo;

        Projet__c p = TestFactory.createProject(part,CP, FR, u);
        insert p;

        Intermediation__c intRejet = TestFactory.createMiseEnRelation(con,compFirst,p);
        intRejet.Professionnel__c = compte.Id;
        intRejet.Matching_rejete__c = RECRED.Id;
        //insert intRejet;

        Intermediation__c int1 = TestFactory.createMiseEnRelation(con,compFirst,p);
        int1.Professionnel__c = compte.Id;
        int1.Is_selectionne__c = true;
        int1.Date_de_s_lection__c = Date.Today();
        int1.Criteres_d_intervention__c = geo.Id;
        //insert int1;

        Intermediation__c int2 = TestFactory.createMiseEnRelation(con,compFirst,p);
        int2.Professionnel__c = compte.Id;
        int2.Is_selectionne__c = true;
        int2.Date_de_s_lection__c = Date.Today();
        int2.Criteres_d_intervention__c = geo.Id;
        //insert int2;
        listIntermediations.add(intRejet);
        listIntermediations.add(int1);
        listIntermediations.add(int2);
        ApexPages.StandardController compteProCTRL = new ApexPages.StandardController(compte);

        CompteProSection comptePro = new CompteProSection(compteProCTRL);
        Test.stopTest();
    }
}