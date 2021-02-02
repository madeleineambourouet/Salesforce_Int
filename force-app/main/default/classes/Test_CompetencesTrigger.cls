@isTest(seealldata = true)
private class Test_CompetencesTrigger {

    private static testMethod void test() {
        
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
                                        
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', AccountId = compte.Id, Phone = '+33111111111');
        insert ctc;
        
        
        
        GeoCat__c GC = new GeoCat__c(Adresse__c = CP.id, Contact__c = ctc.Id, Zone_d_intervention__c = 20, Categorie_niveau__c = '',FaminePoids__c=10);
        insert GC; 
        
        Test.StartTest();
        
        Competence__c competence = new Competence__c(Name = 'cuisine', GeoCat__c = GC.id);
        Competence__c competence2 = new Competence__c(Name = 'cuisine2', GeoCat__c = GC.id);
        insert competence;
        update competence;
        insert competence2;
        delete competence;
        
        Test.stopTest();
    }

}