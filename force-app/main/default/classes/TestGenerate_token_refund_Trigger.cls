@isTest (seealldata = true)
private class TestGenerate_token_refund_Trigger {

    private static testMethod void test(){
  
    
{   
  // Create Compte pro...
        
                    
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
                           
        // Create token...
		
     Token__c token = new Token__c(Name = 'test', Compte__c = compte.id, Type_de_token__c = 'Annulation');
      insert token;
	  
	  // Create Billing account...
	  Zuora__CustomerAccount__c BA = new Zuora__CustomerAccount__c ( Name='TEST', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Balance__c = decimal.valueof('20'), Zuora__Account__c=compte.id);
                                                       
      insert BA;
    
     // Create Payment...
	  Zuora__Payment__c P = new Zuora__Payment__c (Name='P-00000099', Zuora__Amount__c  = decimal.valueof('100'), Zuora__Account__c=compte.id, Zuora__BillingAccount__c= BA.id, 
      Zuora__EffectiveDate__c = Date.newInstance(2017,01,15));
                                                       
      insert P;
        
       // Create refund...       
     
     Zuora__Refund__c T = new Zuora__Refund__c (Name='R-00000050', Token__c  = '64a66d7d9777e9d73e4c92fac78665d2', Zuora__Account__c=compte.id, Zuora__BillingAccount__c= BA.id, Zuora__Amount__c  = decimal.valueof('500'));
                                                       
      insert T;
       
       T.Declenchement_Token__c = true;
       
        T.Token__c  = token.id;
        update T;
     
        
 system.debug('----->>> END UPSERT T: ' + T.Token__c + 'Token été inséré avec succès.');
 
          
 
       
}
}
}