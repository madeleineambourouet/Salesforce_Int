@isTest (SeeAllData=false)
private class Test_AccountTrigger 
{

    private static testMethod void test() 
    {
        Test.startTest();
        List<Reference__c> listReferences = new List<Reference__c>();
        List<User> listUsers = new List<User>();
        List<Account> listAccounts = new List<Account>();
        
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
       // User us = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier != null AND isActive = true LIMIT 1];
       	Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		User us = new User(Alias='myAlias', Email='usersgdbf@testclasssgdbf.com',
							   EmailEncodingKey='UTF-8', LastName='Test',LanguageLocaleKey='fr',
							   LocaleSidKey='fr_FR_EURO', TimeZoneSidKey='Europe/Paris',
							   UserName='usersgdbf@testclasssgdbf.com',ProfileId=sysAdm.Id,
							   FederationIdentifier='1234567890');
        
        listUsers.add(us);
        insert listUsers;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        Reference__c enseigne = new Reference__c(RecordTypeId = RTEnseigne, Name = 'Etest', key__c = 'Etest');

        listReferences.add(NAF);
        listReferences.add(CP);
        listReferences.add(FR);
        listReferences.add(enseigne);
        insert listReferences;

        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', Phone = '+33635136116', /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, 
                                        Code_postal__c = CP.id, Code_NAF_APE_societe_declarante__c = NAF.id, SIRET_texte__c = '32212091600208', 
                                        Liste_des_enseignes_de_gestion_o_il_est__c = 'Etest', Flux_code_Enseigne__c = 'Etest');
        System.debug('>>>>>>>>>>>>>>>> create compte ' + compte);
        Account part = new Account(Salutation = 'M.', FirstName = 'Test', LastName = 'Part', RecordTypeId = RTComptePart, PersonEmail = 'test@gmail.com', Phone = '+33635136116',PersonMobilePhone = '+33617512148', Pays_LKP__c = FR.id);
        
        listAccounts.add(compte);
        listAccounts.add(part);
        insert listAccounts; 

        AccountMethods.checkSIRET(compte.SIRET_texte__c);
                                        
        AccountTeamMember teamMember = new AccountTeamMember(AccountId = compte.Id, UserId = us.Id, TeamMemberRole = 'ATC SERVICE');
        insert teamMember;
        
        Token__c token = new Token__c(Name = part.PersonEmail, Compte__c = part.id, Type_de_token__c = 'E-mail création');
        insert token;
        
        Projet__c projet = new Projet__c(Particulier__c = part.Id, Sous_Activite__c = 'Isolation', Code_postal__c = CP.id, Pays_LKP__c = FR.id, Description__c = '',Telephone_Mobile__c = part.PersonMobilePhone,email_projet__c = part.PersonEmail, Numero_SGI__c = us.FederationIdentifier);
        insert projet;

        projet.Numero_SGI__c = '';
        update projet;
        
        part.PersonMobilePhone = '+33611111111';
        //part.PersonEmail = 'l@l.fr';
        update part;
        
        compte.Reinitialisation_mdp__c = true;
        compte.Login_as__c = true;
        compte.Alerte_expiration__c = 'JM7';
        compte.Alerte_expiration__c = 'JM30';
        compte.Alerte_expiration__c = 'JP60';
        compte.Alerte_exp_certification__c = 'JM7';
        compte.Alerte_exp_certification__c = 'JM30';
        compte.Alerte_exp_certification__c = 'JM0';
        compte.Oubli_mdp_web__c = true;
        compte.Creation_compte__c = true;
        compte.Vendeur_source_pr_inscription_SGI__c = us.FederationIdentifier;
        update compte;
        
        AccountTeamMember atm = new AccountTeamMember(AccountId = compte.id, UserId = us.id, TeamMemberRole = 'ITCS');
        insert atm;
        
        ApexPages.currentPage().getParameters().put('AccountId', compte.id);
        ApexPages.currentPage().getParameters().put('typeClient', 'Pro');
        
        AccountTeam_Utils utils = new AccountTeam_Utils();
        utils.calculateTCReference();
        
        Account_Redirect red = new Account_Redirect(new ApexPages.StandardController(compte));
        PageReference pf = red.redirect();
        
        LeadMethods lMet = new LeadMethods();
        
        VFC_Export_Expansion_Account expansion = new VFC_Export_Expansion_Account();
        expansion.VFC_Export_Expansion_Account();
        
        VFC_Extension_Account extAccount = new VFC_Extension_Account(new ApexPages.StandardController(compte));
        extAccount.fillCountry();
        
        VFC_Extension_Projet extProjet = new VFC_Extension_Projet(new ApexPages.StandardController(projet));
        extProjet.fillCountry();

        Test.stopTest();
        
    }

}