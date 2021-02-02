@isTest(SeeAllData=true)
private class Test_Usages {

    private static testMethod void test() {
        
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null LIMIT 1];
        
        Reference__c pays = TestFactory.createReference('pays','France','FRA','FRA');
        Reference__c CP = TestFactory.createReference('CP', '75000', '75000', '75000');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'AAA','AAA','AAA');
        Reference__c NAF = TestFactory.createReference('NAF','BBB','BBB','BBB');
        insert pays; insert CP; insert enseigne; insert NAF;
        system.debug('>>>>> After reference creation');
        
        Account PRO = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        insert PRO;
        Account PART = TestFactory.createAccount(false, pays, CP, null, null);
        insert PART;
        system.debug('>>>>> After createPart');
        
        Contact ctc = TestFactory.createContact(PRO);
        insert ctc;
        system.debug('>>>>> After createContact');
        Reference__c competence = TestFactory.createReference('competence','CCC','CCC','CCC');
        insert competence;
        system.debug('>>>>> After create competence');
        Projet__c projet = TestFactory.createProject(PART, CP, pays, us);
        insert projet;
        system.debug('>>>>> After create projet');
        Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(ctc, competence, projet);
        insert miseEnRelation;
        system.debug('>>>>> After create miseenrelation');
        
        system.debug('>>>>> Before test.startTest');
        Test.startTest();
        system.debug('>>>>> After test.startTest');
        
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(Name = 'test billing account', Zuora__Account__c = PRO.id, Zuora__AccountNumber__c = '123456');
        insert billingaccount;
        
        
        
        miseEnRelation.Date_de_s_lection__c = Date.today();
        miseEnRelation.IsModified__c = true;
        update miseEnRelation;
        Odigo_SMS.generateTokenSMS(miseEnRelation.id, '+33611111111', 'M. PRO', 'M. PART', '+33622222222', 'part@mail.fr', 'projet', 'categorie', 'description', 'lieu', PRO.Login__c, 'M');
        
        VFC_Export_Expansion_Lead expansion = new VFC_Export_Expansion_Lead();
        expansion.VFC_Export_Expansion_Lead();
        
        Test.stopTest();

    }

}