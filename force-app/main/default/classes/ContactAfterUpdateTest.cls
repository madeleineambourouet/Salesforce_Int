@isTest
private class ContactAfterUpdateTest 
{
    // Unit test => No active subscription
    private static testMethod void testWS_NoActiveSubscription() 
    {
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA', Libelle__c = 'France');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, MobilePhone = '+33677887766', Phone = '+33111111111', Email='test@test.fr', Adresse1__c = '2 rue des tests',
                                        Pays_lkp__c = FR.Id, Code_postal_lkp__c = CP.Id);
        insert ctc;
        
        // After insert : update contact principal on account        
        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id;       
                    update a;
        
        ctc.Firstname = 'Contact200';
        update ctc;
    }
    
    // Unit test => OK
    private static testMethod void testWS_OK() 
    {
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA', Libelle__c = 'France');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Zuora__Subscription__c subActive = new Zuora__Subscription__c(Name = 'Subscription', Zuora__Account__c=compte.Id, Zuora__Status__c = 'Active');
        insert subActive;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, MobilePhone = '+33677887766', Phone = '+33111111111', Email='test@test.fr', Adresse1__c = '2 rue des tests',
                                        Pays_lkp__c = FR.Id, Code_postal_lkp__c = CP.Id);
        insert ctc;
        
        ctc.Firstname = 'Contact200';
        update ctc;
        
        // After insert : update contact principal on account        
        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id;       
                    update a;
    }
    
    // Unit test => KO
    private static testMethod void testWS_KO() 
    {
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA', Libelle__c = 'France');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Zuora__Subscription__c subActive = new Zuora__Subscription__c(Name = 'Subscription', Zuora__Account__c=compte.Id, Zuora__Status__c = 'Active');
        insert subActive;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, MobilePhone = '+33677887766', Phone = '+33111111111', Email='test@test.fr', Adresse1__c = '2 rue des tests',
                                        Pays_lkp__c = FR.Id, Code_postal_lkp__c = CP.Id);
        insert ctc;
        
        ctc.Firstname = 'Contact500';
        update ctc;
        
        // After insert : update contact principal on account        
        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id;       
                    update a;
    }
    
    // Unit test => Exception
    private static testMethod void testWS_Exception() 
    {
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA', Libelle__c = 'France');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        Zuora__Subscription__c subActive = new Zuora__Subscription__c(Name = 'Subscription', Zuora__Account__c=compte.Id, Zuora__Status__c = 'Active');
        insert subActive;
        
        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, MobilePhone = '+33677887766', Phone = '+33111111111', Email='test@test.fr', Adresse1__c = '2 rue des tests',
                                        Pays_lkp__c = FR.Id, Code_postal_lkp__c = CP.Id);
        insert ctc;
        
        ctc.Firstname = 'ContactException';
        update ctc;
        // After insert : update contact principal on account        
        Account a = new Account();
        
                    a.Contact_principal__c = ctc.id;
                    a.id = compte.id;       
                    update a;
    }

    // Bulk test
    private static testMethod void testWS_Bulk() 
    {
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA', Libelle__c = 'France');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;
        
        Zuora__Subscription__c subActive = new Zuora__Subscription__c(Name = 'Subscription', Zuora__Account__c=compte.Id, Zuora__Status__c = 'Active');
        insert subActive;
        
        Test.startTest();
        
        List<Contact> lContact = new List<Contact>();
        for (integer i = 0 ; i < 101 ; i++)
        {
            Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test' + i, Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, MobilePhone = '+33677887766', Phone = '+33111111111', Email='test' + i + '@test.fr', Adresse1__c = '2 rue des tests',
                                        Pays_lkp__c = FR.Id, Code_postal_lkp__c = CP.Id );
            lContact.add(ctc);
        }
        insert lContact;
        
        // AJOUT LEILA
        // After insert : update contact principal on account        
              
         Account a = new Account();
         Contact con = new Contact();
         for(Contact c : lContact)
         {
             con = c;
             break;
         }
         
          a.Contact_principal__c = con.id;
          a.id = compte.id;       
          update a;
        
        for (Contact c : lContact)
        {
            c.Firstname = 'Contact200';
        }
        update lContact;
        
        
    }

}