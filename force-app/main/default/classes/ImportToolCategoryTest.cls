@isTest
public without sharing class ImportToolCategoryTest {
	@isTest
	public static void ImportTest() {
        	RecordType idCat = [SELECT Id FROM RecordType WHERE DeveloperName = 'Categorie' LIMIT 1];
        	RecordType RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1];
        	RecordType RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1];
                ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;
                ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
                ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;

                Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
                insert NAF;

        	Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        	insert pays;

        	Reference__c refA = new Reference__c(Key__c = '1002', Libelle__c = 'Construction de maison en maçonnerie', Name = 'Construction de maison en maçonnerie', RecordTypeId = idCat.Id);
        	insert refA;

        	Reference__c refB = new Reference__c(Key__c = '1003', Libelle__c = 'Construction de maison en maçonnerie', Name = 'Construction de maison en maçonnerie', RecordTypeId = idCat.Id);
        	insert refB;

        	Reference__c refC = new Reference__c(Key__c = '1004', Libelle__c = 'Construction de maison en maçonnerie', Name = 'Construction de maison en maçonnerie', RecordTypeId = idCat.Id);
        	insert refC;

        	Reference__c refD = new Reference__c(Key__c = '1005', Libelle__c = 'Construction de maison en maçonnerie', Name = 'Construction de maison en maçonnerie', RecordTypeId = idCat.Id);
        	insert refD;

        	Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal.Id, Code__c = '75001', Name = 'Paris');
                insert CP;

                Reference__c compFirst = new Reference__c(RecordTypeId = RTCompetence, Key__c = '1', Name = 'First Competence', Parent__c = '0', Libelle_3__c = 'CAT_1', Obsolete__c = false);
                insert compFirst;

                Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
                insert enseigne;

                Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
                insert particulier;

                Account pro = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
                insert pro;

                Contact con = TestFactory.createContact(pro);
                insert con;


                Projet__c projet = new Projet__c(Particulier__c=particulier.Id, Pays_lkp__c=pays.Id, Code_postal__c=CP.Id, Categorie_lkp__c=refA.id);
                insert projet;

                Intermediation__c inte = TestFactory.createMiseEnRelation(con, compFirst, projet );
                insert inte;

                String s = 'entete1;entete2\n';
                s += '1002;1003\n';
                s += '1004;1005\n';
                Blob doc = Blob.valueOf(s);
                ImportToolCategory impor = new ImportToolCategory();
                impor.nameFile = 'test.csv';
                impor.contentFile = doc;
                impor.date_debut = Date.newInstance(2000, 1, 1);
                Test.startTest();

                impor.UpsertCategorie();
                impor.nameFile = 'test.xlsx';
                impor.UpsertCategorie();
                s = 'entete1;entete2';
                doc = Blob.valueOf(s);
                impor.contentFile = doc;
                impor.UpsertCategorie();

                Test.stopTest();
	}
}