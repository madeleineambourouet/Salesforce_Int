@isTest (seealldata = true)
private class Test_EventTrigger {
 private static testMethod void test() {
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
     
     	Reference__c AG = new Reference__c(RecordTypeId = RTAgence, Name = 'Point P');
        insert AG;
     
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Account1', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                         Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
        
        Event event = new Event(Subject='RDV client',StartDateTime=system.today(),EndDateTime=system.today(),Description= 'test',Agence__c=AG.Id, Compte_rendu_du_RDV_client__c= 'test',OwnerId=UserInfo.getUserId() ,ActivityDate=system.today(),WhoId=ctc.id,WhatId = compte.Id);
       	insert event;

    }    
}