// 
// Test du Batch pour créer les faits de vente
// 24/01/2018, xavier templet, version initiale   
//

//@isTest
@isTest(seeAllData=true)
private class Batch_Daily_SalesFact_Test {

	public static String CRON_EXP = '0 26 18 29 3 ? 2022'; // from the 29/3/2022 runs monthly the 29th at 18h26

    public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
    public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);
    public static final String DEFAULT_CURRENCY = 'EUR';
		
	static testmethod void testScheduledJob_Daily_SalesFact() {
    //@testSetup 
    //static void setup() {
    
            ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte;

        Contact ctc = new Contact(Salutation = 'M', FirstName = 'Contact', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, 
                                        AccountId = compte.Id, DoNotCall = true, Phone = '+33111111111');
        insert ctc;
        
      	List<Zuora__CustomerAccount__c> BAList =new List<Zuora__CustomerAccount__c>();      
   
      	Zuora__CustomerAccount__c billacnt = new Zuora__CustomerAccount__c (Name='SIMPLY MARKET', Zuora__Zuora_Id__c  = '2c92c0f954e742b50154e755ff561c73', Zuora__Account__c=compte.id, Zuora__Balance__c = decimal.valueof('30'), Token__c = 'c221ab6562d72be959691ae6275186f9', EchecsPaiementConsecutifs__c ='1', Email_de_relance_impayes__c = '1er email de facture impayée', Email_du_contact_principal__c = 'test1@test.fr', Zuora__LastInvoiceDate__c = Date.today().addDays(0-Integer.valueOf(System.Label.Date_d_envoi_impaye)), Exclu_relance_impaye__c = false);
      	insert billacnt;
      	//BAList.Add(billacnt); INSERT BAList;
     

		Zuora__Subscription__c Subscription7 = new Zuora__Subscription__c(Name='A-S00006129', Type_de_geste__c='Création de souscription', Zuora__MRR__c = 26.25, Zuora__Status__c = 'Cancelled',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(), Zuora__SubscriptionEndDate__c = Date.today().addDays(-1), Zuora__Account__c = compte.Id);
        insert Subscription7;
  
        Test.startTest();
        Batch_Daily_SalesFact b = new Batch_Daily_SalesFact(); 
        database.executebatch(b);
        // Schedule the test job
        //String jobId = System.schedule('Scheduled Batch_Monthly_SalesFact ApexTest', CRON_EXP, new Batch_Monthly_SalesFact());
        Zuora__Payment__c pay = new Zuora__Payment__c(Name='test', Zuora__Account__c=compte.Id, Zuora__Amount__c = 50, Zuora__BillingAccount__c = billacnt.Id, Zuora__EffectiveDate__c = Date.today());
        Zuora__Refund__c refu = new Zuora__Refund__c(Name='test', Zuora__Account__c=compte.Id, Zuora__Amount__c = 50, Zuora__BillingAccount__c = billacnt.Id, Zuora__RefundDate__c = Date.today());
        insert pay;
        insert refu;
        
        Test.stopTest();

        List<Sales_Facts__c> sfactLst = [select Id, Name from Sales_Facts__c where Subscription__c = :Subscription7.Id];
        system.assertEquals(sfactLst.size()>0, true);


    	
    }
}