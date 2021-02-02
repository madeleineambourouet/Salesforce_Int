/**
* @author Leila BOUAIFEL
* @date 20/07/2017
*
* @description Test class for Class Batch_CertifUpdateAccount_TEST
*/
@isTest(SeeAllData=false)
private class Batch_CertifUpdateAccount_TEST {
    
    @testSetup
    static void setup() {
        
        // Create Compte pro 
        
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;        
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        ID RTCertification = [SELECT id FROM RecordType WHERE DeveloperName = 'Document_Certification' LIMIT 1].id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'Zimbabwe', key__c = 'ZWE');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
        
        
        Reference__c certification = new Reference__c(RecordTypeId = RTCertification, Name = 'certif', key__c = 'Ctest');
        insert certification;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                     Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                     Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Statut_de_la_souscription__c = '');
        
        insert compte;
        
        // Create contact 
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                  AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
        
        // create document certification
        Document_Certification__c Certif = new Document_Certification__c(Compte__c = compte.id,  Nom__c = certification.id , Statut__c = 'Validée', Name='test', Date_d_expiration__c =system.today());
        insert Certif;
        
    }
    
    static testMethod void test() {
        Test.startTest();
        Batch_CertifUpdateAccount b = new Batch_CertifUpdateAccount(); 
        database.executebatch(b);
        String cronexp = '0 0 0 ? * * *';
        system.schedule('test', cronexp, b);
        Test.stopTest();
        
    }    
}