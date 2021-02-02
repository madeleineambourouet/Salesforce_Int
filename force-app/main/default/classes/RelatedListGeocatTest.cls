@isTest
public without sharing class RelatedListGeocatTest {
        
        @isTest
        public static void getTested() {
                system.debug('>>>>>>>> TEST : Start preping data');
        // Creation of test data
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;
        ID RTCategorie = [SELECT Id FROM RecordType WHERE DeveloperName = 'Categorie' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;

        
        Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1', Obsolete__c = false);
        insert compFirst;
        Reference__c compSecond = new Reference__c(RecordTypeId = RTCompetence, Key__c = '2', Name = 'Second Competence', Parent__c = '1', Libelle_3__c = 'CAT_2', Obsolete__c = false);
        insert compSecond;

        Reference__c compThird = new Reference__c(RecordTypeId = RTCompetence, Key__c = '3', Name = 'Third Competence', Parent__c = '1', Libelle_3__c = 'CAT_2', Obsolete__c = true);
        insert compThird;

        Reference__c catFirst = new Reference__c(RecordTypeId = RTCategorie, Key__c = '3', Name = 'First Categorie', Libelle__c = 'First Categorie');
        insert catFirst;
        
        Reference__c catSecond = new Reference__c(RecordTypeId = RTCategorie, Key__c = '4', Name = 'Second Categorie', Libelle__c = 'Second Categorie');
        insert catSecond;

        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', AccountId = compte.Id, Phone = '+33111111111');
        insert ctc;
        
        system.debug('>>>>>>>> TEST : End preping data');

        Geocat__c geocat = new Geocat__c();
        geocat.Contact__c = ctc.Id;
        geocat.Adresse__c = CP.Id;
        geocat.Zone_d_intervention__c = 12;
        geocat.DDP__c = 12;
        geocat.Exclusion__c = '75015, 75017';
        geocat.Date_de_debut__c = Date.Today();
        geocat.Date_de_fin__c = Date.Today() + 30;
        geocat.FaminePoids__c=10;

        insert geocat;

        Competence__c  c1 = new Competence__c(GeoCat__c = geocat.Id, Niveau_1__c = compFirst.Id, Niveau_2__c = compSecond.Id);
        insert c1;

        Competence__c  c2 = new Competence__c(GeoCat__c = geocat.Id, Niveau_1__c = compFirst.Id, Niveau_2__c = compThird.Id);
        insert c2;

        ApexPages.StandardController std = new ApexPages.StandardController(geocat);
        RelatedListGeocat rController = new RelatedListGeocat(std);

        }
}