@isTest (seealldata = true)
private class TestQuoteUpdateAccountTrigger {

    private static testMethod void test(){
  
 // GET USER FROM USER TABLE...

      /* User u = [select LastName  FROM user WHERE LastName= 'BOUAIFEL' limit 1];

  // RUN AS USER...

        system.runAs(u)

        {*/
         ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
       
        ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
      
        
       /* Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        insert TV; */
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        insert NAF;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;



       Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208');
        insert compte;
       
         Contact ctc = new Contact(AccountId = compte.id, FirstName = 'test', Salutation = 'M.', LastName = 'Test', Phone = '+33111111111', Email = 'leila.bouaifel+classetest@gmail.com');
        insert ctc;
        
       zqu__Quote__c zQuote = new zqu__Quote__c(RecordTypeId = RTCreationQuote, zqu__Account__c = compte.id, zqu__BillToContact__c = ctc.id, zqu__SoldToContact__c = ctc.id);
        insert zQuote;
        
        zQuote.Envoi_mail_generate_PDF__c = true;
        zQuote.Modification_offres__c = true;
        zQuote.Resiliation_offres__c = true;
        zQuote.Produit__c = 'Offre Homly Travaux';
        update zQuote;
        
        //compte.Update_Owner_Quote__c = u.id;
        //compte.Update_Owner_Quote__c = UserInfo.getUserId();
        //update compte;
          
       
//}

}
}