@isTest (seealldata = true)
private class TestGenerateTokenOffresdTrigger {

    private static testMethod void test(){
  
    
{   
  // READ OFFRES FLAG TOKEN...
        
                    
       ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
       
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
        User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
        
               
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');
        insert enseigne;

        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest', Login__c = 'a@a.a');
       
        insert compte;
                           
             
     Token__c token = new Token__c(Name = 'test', Compte__c = compte.id, Type_de_token__c = 'Assurance manquante');
      insert token;
        
              
     
     Zuora__SubscriptionProductCharge__c T = new Zuora__SubscriptionProductCharge__c (  Name='Abonnement Offre Homly Travaux', Token_Offre_et_frais_de_souscription__c  = '1dce462686ff92129156454df078dc98', Zuora__Account__c=compte.id);
                                                       
      insert T;
       
       T.Declenchement_Token_Assurance_manquante__c= true;
       
        T.Token_Offre_et_frais_de_souscription__c  = token.id;
        update T;
     
        
 system.debug('----->>> END UPSERT T: ' + T.Token_Offre_et_frais_de_souscription__c + 'Token été inséré avec succès.');
 
          
 
       
}
}
}