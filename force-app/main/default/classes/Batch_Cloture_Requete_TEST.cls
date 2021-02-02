@isTest
public class  Batch_Cloture_Requete_TEST {
    @testSetup 
    static void setup() {

	    Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
	    Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
	    Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
	    Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
	    Reference__c motif = TestFactory.createReference('Motif', 'Demande de Pro','Motif_R_45','Demande de Pro');
      	insert pays; insert CP; insert NAF; insert enseigne; insert motif;

		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		insert professionnel;


		Case requete = TestFactory.createRequete(professionnel, Batch_Cloture_Requete.STATUT_EN_COURS, motif.Id);
		insert requete;
    }
    static testmethod void test() {        
        Test.startTest();
        Batch_Cloture_Requete bcr = new Batch_Cloture_Requete();
		Database.executeBatch(bcr);
        Test.stopTest();
       	Case requete = [SELECT Id, Status FROM Case LIMIT 1];
        System.assertEquals(requete.Status,Batch_Cloture_Requete.STATUT_FERMEE);
    }

}