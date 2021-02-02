@isTest //(seealldata = true)
private class Test_IntermediationWS {
    
    private static testMethod void Test_IntermediationWS() {
        
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTCategorie = [SELECT Id FROM RecordType WHERE DeveloperName = 'Categorie' LIMIT 1].Id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null LIMIT 1];
 
        Technical_Values__c TV = new Technical_Values__c(Name = 'Technical values', Code_client__c = 'XZZZZ');
        //Technical_Values__c TV = TestFactory.createCustomSettings('00000');
        insert TV;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris', Libelle_2__c = '92014');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
        
        Reference__c categorie = new Reference__c(RecordTypeId = RTCategorie, Name = '1022', key__c = '1022');
        insert categorie;

        Reference__c competence = TestFactory.createReference('competence', 'competence', 'competence', 'competence');
        insert competence;

        Account compte = new Account(RecordTypeId = RTComptePart, LastName = 'Test', FirstName = 'test', PersonMobilePhone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id);
        insert compte;
        
        Account comptePRO = TestFactory.createAccount(true,  FR,  CP,  enseigne,  NAF);
        insert comptePRO;
        
        Contact pro = TestFactory.createContact(comptePRO);
        insert pro;
        
        Projet__c projet = new Projet__c(Particulier__c = compte.Id, Categorie_lkp__c = categorie.id, DIMENSION3__c = 10.0, LISTE_QUAND__c = 'asap', BUDGET__c = 30000.0, 
                                            TEXTELIBRE__c = 'tout va bien', Adresse_IP__c = '193.234.1.9', Sous_Activite__c = 'Isolation', Code_postal__c = CP.id, 
                                            Pays_LKP__c = FR.id, Description__c = '', Numero_SGI__c = '0');
        insert projet;
        
        Test.setMock(HTTPCalloutMock.class, new MockHTTP());
        Test.startTest();

        system.debug('>>>> TESTING callWSIntermediation');
        IntermediationHandler.callWSIntermediation(projet.id, 3.0, false,'', false, '', 'qs', false);
        
        system.debug('>>>> TESTING GetQS');
        IntermediationHandler.getQS(projet.id);

        system.debug('>>>> TESTING GetMatching');
        IntermediationHandler.getMatching(projet.id);
        
        List<Projet__c> projToQueue = new List<Projet__c>();
        projToQueue.add(projet);
        List<Intermediation__c> merInsertToQueue = new List<Intermediation__c>();
        List<Intermediation__c> merUpdateToQueue = new List<Intermediation__c>();
        
        System.enqueueJob(new IntermediationRetry(projToQueue,merInsertToQueue, merUpdateToQueue ));
        // rematch is tested by class Test_BatchIntermediation

        Test.stopTest();

  }
  

}