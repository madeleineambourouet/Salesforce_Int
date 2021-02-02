@isTest (seealldata = true)
private class TestGenerateTokenContactTrigger {

    private static testMethod void test(){
  
    
{   
        // READ Comptes and contacts ...
        
           
    
        ID RTComptePro = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' and id != NULL LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        ID RTAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1].Id;
       
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        
                     
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
           
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c Agence = new Reference__c(RecordTypeId = RTAgence , Name = 'AGDE POINT P', key__c = '3307');
        insert Agence;
        
         
         
       
        // Créer un compte pro et l'insert
        Account compte = new Account(Name = 'Test account',
                                          RecordTypeId = RTComptePro,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          Phone = '+33635136116',
                                          SIRET_texte__c = '32212091600208',
                                          Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest',
                                          Flux_code_Enseigne__c = 'Etest',                                          
                                          Code_NAF_APE_societe_declarante__c = NAF.id,
                                          Enseignes_de_gestion_Client__c = 'ACS') ;
                                          
                                          
               
        insert compte;
       
        
             
                                  
    
      Token__c token = new Token__c(Name = 'test', Compte__c = compte.id, Type_de_token__c = 'Campagne Oneshot');
      insert token;
       
     
     
     Contact CON = new Contact ( AccountId  = compte.id, Check_Token_Oneshot__c = true,Contact_Principal_O_N__c= true, LastName='TEST',FirstName = 'Leila', Salutation ='Mme', Token_campagne_oneshot__c ='9d525b22324cd24e848aafe6569c2c53',   Email='leila@test.fr', MobilePhone='+33617512148');
                                                       
      insert CON;
       
       CON.Check_Token_Oneshot__c = true;
       
        CON.Token_campagne_oneshot__c  = token.id;
        update CON;
        
      system.debug('----->>> END UPSERT CON: ' + CON.Token_campagne_oneshot__c + 'Token été inséré avec succès.');  
                 
     
        
 
 
         
}
}
}