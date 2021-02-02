@isTest
public class Batch_compte_indicateurs_TEST {
    @testSetup 
    static void setup() {
      
	    List<Reference__c> listReferences = new List<Reference__c>();
	    List<Account> listAccounts = new List<Account>();
	    List<Competence__c> listCompetences = new List<Competence__c>();
	    List<Zuora__Subscription__c> listZuora_Subscriptions = new List<Zuora__Subscription__c>();
	    List<Zuora__SubscriptionProductCharge__c> listZuoraSubscriptionProductCharges = new List<Zuora__SubscriptionProductCharge__c>();

        ID RTAssurance = [SELECT id FROM RecordType WHERE DeveloperName = 'Document_Assurance' LIMIT 1].id;
		Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
		Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
		Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
		Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
		Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c assurance = new Reference__c(RecordTypeId = RTAssurance, Name = 'Assurance', key__c = 'Ctest');
		//Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
		//User us = TestFactory.createUser('0123456789', sysAdm);
		//insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;

		listReferences.add(CP);
		listReferences.add(competence);
		listReferences.add(NAF);
		listReferences.add(enseigne);
		listReferences.add(pays);
        listReferences.add(assurance);
		insert listReferences;
		Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		//insert professionnel;
		Account professionnel2 = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel2.Statut_de_la_souscription__c = 'Active';
		professionnel2.Name = 'Test account2';
        professionnel2.Phone = '+3363513617';
        professionnel2.SIRET_texte__c = '32212091600300';
		Account professionnel3 = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
		professionnel3.Statut_de_la_souscription__c = 'Active';
		professionnel3.Name = 'Test account3';
        professionnel3.Phone = '+3363513618';
        professionnel3.SIRET_texte__c = '32212091600400';
		professionnel3.Statut_de_la_souscription__c = 'Active';
		//insert professionnel;

		listAccounts.add(professionnel);
		listAccounts.add(professionnel2);
		listAccounts.add(professionnel3);
		insert listAccounts;

        List<Contact> contactList = new List<Contact>();
		Contact contactPro = TestFactory.createContact(professionnel);
        contactList.add(contactPro);
        Contact contactPro2 = TestFactory.createContact(professionnel2);
        contactList.add(contactPro2);
        insert contactList;

		List<Geocat__c> geocatList = new List<Geocat__c>();
        Geocat__c geocat = new Geocat__c();
        geocat.Contact__c = contactPro.Id;
        geocat.Account__c = professionnel.Id;
        geocat.Adresse__c = CP.Id;
        geocat.Zone_d_intervention__c = 12;
        geocat.DDP__c = 2;
        geocat.Exclusion__c = '75015, 75017';
        geocat.Date_de_debut__c = null;
        geocat.Date_de_fin__c = null;
        geocat.FaminePoids__c = 20;
        geocatList.add(geocat);
        Geocat__c geocat2 = new Geocat__c();
        geocat2.Contact__c = contactPro.Id;
        geocat2.Account__c = professionnel.Id;
        geocat2.Adresse__c = CP.Id; 
        geocat2.Zone_d_intervention__c = 12;
        geocat2.DDP__c = 3;
        geocat2.Exclusion__c = '75015, 75017';
        geocat2.Date_de_debut__c = null;
        geocat2.Date_de_fin__c = Date.Today() + 30;
        geocat2.FaminePoids__c = 20;
        geocatList.add(geocat2);
        Geocat__c geocat3 = new Geocat__c();
        geocat3.Contact__c = contactPro.Id;
        geocat3.Account__c = professionnel.Id;
        geocat3.Adresse__c = CP.Id; 
        geocat3.Zone_d_intervention__c = 12;
        geocat3.DDP__c = 3;
        geocat3.Exclusion__c = '75015, 75017';
        geocat3.Date_de_debut__c = Date.Today();
        geocat3.Date_de_fin__c = null;
        geocat3.FaminePoids__c = 20;
        geocatList.add(geocat3);
        Geocat__c geocat4 = new Geocat__c();
        geocat4.Contact__c = contactPro2.Id;
        geocat4.Account__c = professionnel2.Id;
        geocat4.Adresse__c = CP.Id; 
        geocat4.Zone_d_intervention__c = 12;
        geocat4.DDP__c = 0;
        geocat4.Exclusion__c = '75015, 75017';
        geocat4.Date_de_debut__c = Date.Today();
        geocat4.Date_de_fin__c = Date.Today() + 30;
        geocat4.FaminePoids__c = 100;
        geocatList.add(geocat4);
        Geocat__c geocat5 = new Geocat__c();
        geocat5.Contact__c = contactPro2.Id;
        geocat5.Account__c = professionnel2.Id;
        geocat5.Adresse__c = CP.Id; 
        geocat5.Zone_d_intervention__c = 0;
        geocat5.DDP__c = 10;
        geocat5.Exclusion__c = '75015, 75017';
        geocat5.Date_de_debut__c = Date.Today();
        geocat5.Date_de_fin__c = Date.Today() + 30;
        geocat5.FaminePoids__c = 130;
        geocatList.add(geocat5);
        Geocat__c geocat6 = new Geocat__c();
        geocat6.Contact__c = contactPro.Id;
        geocat6.Account__c = professionnel.Id;
        geocat6.Adresse__c = CP.Id; 
        geocat6.Zone_d_intervention__c = 0;
        geocat6.DDP__c = 10;
        geocat6.Exclusion__c = '75015, 75017';
        geocat6.FaminePoids__c = 130;
        geocatList.add(geocat6);
        insert geocatList;

        Competence__c competenceGeocat = new Competence__c(Name = 'TEST_Competence', GeoCat__c = geocat.id);
        listCompetences.add(competenceGeocat);
        Competence__c competenceGeocat2 = new Competence__c(Name = 'TEST_Competence2', GeoCat__c = geocat2.id);
        listCompetences.add(competenceGeocat2);
        Competence__c competenceGeocat3 = new Competence__c(Name = 'TEST_Competence3', GeoCat__c = geocat3.id);
        listCompetences.add(competenceGeocat3); 
        Competence__c competenceGeocat4 = new Competence__c(Name = 'TEST_Competence4', GeoCat__c = geocat4.id);
        listCompetences.add(competenceGeocat4); 
        Competence__c competenceGeocat5 = new Competence__c(Name = 'TEST_Competence5', GeoCat__c = geocat5.id);
        listCompetences.add(competenceGeocat5); 
        insert listCompetences;

        Zuora__Subscription__c Subscription = new Zuora__Subscription__c(Name='A-S00008888',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(), Type_de_geste__c = 'Création de souscription' ,Zuora__Account__c = professionnel.Id);
       	Zuora__Subscription__c Subscription2 = new Zuora__Subscription__c(Name='A-S00009999',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(), Type_de_geste__c = 'Création de souscription' ,Zuora__Account__c = professionnel2.Id);
       	Zuora__Subscription__c Subscription3 = new Zuora__Subscription__c(Name='A-S00007777',Zuora__MRR__c = 26.25, Zuora__Status__c = 'Active',Zuora__Version__c=1,Zuora__TermStartDate__c=system.today(),Zuora__SubscriptionStartDate__c=system.today(),Zuora__ContractEffectiveDate__c=system.today(), Type_de_geste__c = 'Création de souscription' ,Zuora__Account__c = professionnel3.Id);
       	listZuora_Subscriptions.add(Subscription);
        listZuora_Subscriptions.add(Subscription2);
        listZuora_Subscriptions.add(Subscription3);
        insert listZuora_Subscriptions;

        Zuora__Product__c z1 = new Zuora__Product__c(Name='test z', Zuora__SKU__c='SKU-00000001');
        insert z1;

        Zuora__SubscriptionProductCharge__c zc = new Zuora__SubscriptionProductCharge__c(Name='Offre "Intégral"', Zuora__Account__c=professionnel.Id, Zuora__EffectiveStartDate__c = Date.today(),Zuora__EffectiveEndDate__c = null, Zuora__Product__c=z1.Id,Zuora__Subscription__c=Subscription.Id);
        Zuora__SubscriptionProductCharge__c zc2 = new Zuora__SubscriptionProductCharge__c(Name='Offre "Intégral"', Zuora__Account__c=professionnel2.Id, Zuora__EffectiveStartDate__c = Date.today(),Zuora__EffectiveEndDate__c = null, Zuora__Product__c=z1.Id,Zuora__Subscription__c=Subscription2.Id);
        Zuora__SubscriptionProductCharge__c zc3 = new Zuora__SubscriptionProductCharge__c(Name='Offre "Intégral"', Zuora__Account__c=professionnel2.Id, Zuora__EffectiveStartDate__c = Date.today()-61,Zuora__EffectiveEndDate__c = null, Zuora__Product__c=z1.Id,Zuora__Subscription__c=Subscription3.Id);
        listZuoraSubscriptionProductCharges.add(zc);
        listZuoraSubscriptionProductCharges.add(zc2);
        listZuoraSubscriptionProductCharges.add(zc3);
        insert listZuoraSubscriptionProductCharges;

        Document_Assurance__c Assur1 = new Document_Assurance__c(Compte__c = professionnel.id,  Nom__c = assurance.id , Statut__c = 'Validée', Name='test', Date_d_expiration__c =system.today());
        Document_Assurance__c Assur2 = new Document_Assurance__c(Compte__c = professionnel2.id,  Nom__c = assurance.id , Statut__c = 'Expirée', Name='test', Date_d_expiration__c =system.today()-5);
        List<Document_Assurance__c> listAssurs = new List<Document_Assurance__c>(); 
        listAssurs.add(Assur1);
        listAssurs.add(Assur2);
        insert listAssurs;

        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfLastMonth = firstDayOfMonth.addDays(-1);
  
    }
    static testmethod void test() {        
        Test.startTest();
		Batch_compte_indicateurs ind = new Batch_compte_indicateurs();
		Database.executeBatch(ind);
		/*
		for (Account acc :[select id,SIRET_texte__c,offre_intermediation_active__c,aucun_ci_actif__c from Account]) {
			if(acc.SIRET_texte__c == '32212091600208'){
				system.assertEquals(acc.offre_intermediation_active__c,true);
			}
			if(acc.SIRET_texte__c == '32212091600300'){
				system.assertEquals(acc.aucun_ci_actif__c,true);
			}
		}*/
        Test.stopTest();
        //System.assertEquals(acc.FamineIndicateurChiffres__c,'1/14');
    }
    static testmethod void testSchedulable() {        
        Test.startTest();
        Batch_compte_indicateurs ind = new Batch_compte_indicateurs();
        String cronexp = '0 0 0 ? * * *';
        system.schedule('test', cronexp, ind);
        Test.stopTest();
    }

}