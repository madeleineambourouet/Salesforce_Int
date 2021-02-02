@isTest
public without sharing class ParrainageTriggerTest {
	@isTest
	public static void testfilleul() {

		ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;

        Reference__c NAF1 = new Reference__c(RecordTypeId = RTNAF, Code__c = 'BBB', Name = 'Activiteb');
        insert NAF1;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;

		Account parrain = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', Statut_global__c = 'CLIENT',
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id,
                                        Code_NAF_APE_societe_declarante__c = NAF.Id);
        insert parrain;
        system.debug('TEST parrain contenu  =' + parrain);
        Account filleul = new Account(RecordTypeId = RTComptePro, Name = 'T', SIRET_texte__c = '02212091600207', Phone = '+33635136117', Statut_global__c = 'CLIENT',
                                        Pays_LKP__c = FR.id, Code_postal__c = CP.Id,
                                        Code_NAF_APE_societe_declarante__c = NAF1.Id, code_client__c='B0000');
        system.debug('TEST filleul contenu  =' + filleul);
        insert filleul;
        system.debug('TEST filleul contenu  =' + filleul);

        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = parrain.Id, DoNotCall = true, Phone = '+33111111111', Email='a@b.c');
        insert ctc;

        parrain.contact_principal__c=ctc.id;
        filleul.contact_principal__c=ctc.id;

        update parrain;

        update filleul;

        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00006123',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = parrain.Id);
       
        insert Subscription;

        

        Zuora__Subscription__c Subscriptionf = new Zuora__Subscription__c(Name='A-S00009456',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today() ,Zuora__Account__c = filleul.Id);
        
        

        test.startTest();

        filleul.Parrain__c = parrain.Id;


        try {
                checkRecursiveSFDC.runGODSON = true;
        	update filleul;
                insert Subscriptionf;

                
        } catch (Exception e) {

        }

        Subscriptionf.Zuora__Status__c = 'Cancelled';
        Subscriptionf.Zuora__SubscriptionEndDate__c = Date.today();
        update Subscriptionf;


        try {
                
        	update filleul;
        } catch (Exception e) {
        	system.debug(e.getMessage());
        }

        Subscriptionf.Zuora__SubscriptionEndDate__c = Date.today().addMonths(-4);
        update Subscriptionf;

        system.debug('TEST : passage ligne 80');

        filleul.Statut_de_la_souscription__c = 'Cancelled';
        filleul.Premiere_souscription__c = null;
        update filleul;

        Subscriptionf.Zuora__Status__c = 'Active';
        Subscriptionf.Zuora__SubscriptionEndDate__c = Date.today();
        update Subscriptionf;

        Subscriptionf.Zuora__Status__c = 'Cancelled';
        Subscriptionf.Zuora__SubscriptionEndDate__c = Date.today().addDays(3);
        update Subscriptionf;
        test.stopTest();
	}
}