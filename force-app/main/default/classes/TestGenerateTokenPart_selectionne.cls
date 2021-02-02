@isTest (seealldata = true)
private class TestGenerateTokenPart_selectionne {

    private static testMethod void test(){
  
    
{   
  // READ INTERMEDIATION ...
        
         
        
       
    
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
         ID RTComptePro = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' and id != NULL LIMIT 1].Id; 
         ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
          ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
       
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        
        
                
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;
           
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        // Créer un compte particulier et l'insert
        Account compte_test = new Account(LastName= 'Test2',
                                          FirstName= 'Compte2',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33210768765',
                                          PersonEmail='leila@gmail.com');
        System.debug('Leila Le compte particulier ' + compte_test.FirstName + ' ' + compte_test.LastName  + ' a été crée avec succès.');
        
        insert compte_test;
        
       
            
       
        // Créer un compte pro et l'insert
        Account compte = new Account(Name = 'Test account',
                                           RecordTypeId = TestFactory.RTComptePro,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          Phone = '+33635136116',
                                          SIRET_texte__c = '32212091600208',
                                          Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest',
                                          Flux_code_Enseigne__c = 'Etest',                                          
                                          Code_NAF_APE_societe_declarante__c = NAF.id);
                                          
        System.debug('Leila Le compte pro ' + compte.Name + ' a été crée avec succès.');
        
        insert compte;
       
        
        
        //Créer un projet affilié à compte_test et l'insert
        Projet__c projet_test = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= compte_test.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                              Description__c='description test youhou');
        System.debug('Le projet ' + projet_test.Titre__c + ' a été crée avec succès.');
        
        insert projet_test;

      
                                  
    
      Token__c token = new Token__c(Name = 'test', Compte__c = compte_test.id, Type_de_token__c = 'Part Sélectionné');
      insert token;
       
     
     
     Intermediation__c MEL = new Intermediation__c (  Projet__c = projet_test.id, Professionnel__c  = compte.id, Date_de_matching__c =date.today(), Token_Part_Selectionne__c ='adb57bc8194936ca44d09fb70f364bb0');
                                                       
      insert MEL;
       
       MEL.Is_selectionne__c = true;
       
        MEL.Token_Part_Selectionne__c  = token.id;
        update MEL;
        
      system.debug('----->>> END UPSERT MEL: ' + MEL.Token_Part_Selectionne__c + 'Token été inséré avec succès.');  
                 
     
        
 
 
         
}
}
}