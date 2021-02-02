@isTest
public class Batch_Famine_Satisfaction_TEST {
    @testSetup 
    static void setup() {
        
        List<Reference__c> listReferences = new List<Reference__c>();
        List<Account> listAccounts = new List<Account>();
        List<Competence__c> listCompetences = new List<Competence__c>();
        List<Zuora__Subscription__c> listZuora_Subscriptions = new List<Zuora__Subscription__c>();
        List<Zuora__SubscriptionProductCharge__c> listZuoraSubscriptionProductCharges = new List<Zuora__SubscriptionProductCharge__c>();

        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        //insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;

        listReferences.add(CP);
        listReferences.add(competence);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        insert listReferences;
        
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        //insert particulier;
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        professionnel.Statut_de_la_souscription__c = 'Active';
        professionnel.offre_intermediation_active__c = true;
        professionnel.aucun_ci_actif__c=false;
        professionnel.Desactivation_des_ODC_impaye_recurrent__c = false;
        //insert professionnel;

        listAccounts.add(professionnel);
        listAccounts.add(particulier);
        insert listAccounts;

        List<Contact> contactList = new List<Contact>();
        Contact contactPro = TestFactory.createContact(professionnel);
        contactList.add(contactPro);
        Contact contactPro2 = TestFactory.createContact(professionnel);
        contactList.add(contactPro2);
        insert contactList;


        Projet__c projet = TestFactory.createProject(particulier, CP, pays, us);
        projet.Statut_Projet__c = 'Qualifié';
        projet.Etat__c = 'ODC ouverte';
        projet.Source__c = 'VANN';
        projet.Demande_du_Part__c = 'Artisans qualifiés';  
        insert projet;

        List<Geocat__c> geocatList = new List<Geocat__c>();
        Geocat__c geocat = new Geocat__c();
        geocat.Contact__c = contactPro.Id;
        geocat.Account__c = professionnel.Id;
        geocat.Adresse__c = CP.Id;
        geocat.Zone_d_intervention__c = 12;
        geocat.DDP__c = 2;
        geocat.Exclusion__c = '75015, 75017';
        geocat.Date_de_fin__c = Date.Today() - 1;
        geocat.FaminePoids__c = 20;
        geocatList.add(geocat);
        Geocat__c geocat2 = new Geocat__c();
        geocat2.Contact__c = contactPro.Id;
        geocat2.Account__c = professionnel.Id;
        geocat2.Adresse__c = CP.Id; 
        geocat2.Zone_d_intervention__c = 12;
        geocat2.DDP__c = 3;
        geocat2.Exclusion__c = '75015, 75018';
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
        geocat3.Date_de_fin__c = Date.Today() + 30;
        geocat3.FaminePoids__c = 20;
        geocatList.add(geocat3);
        Geocat__c geocat4 = new Geocat__c();
        geocat4.Contact__c = contactPro.Id;
        geocat4.Account__c = professionnel.Id;
        geocat4.Adresse__c = CP.Id; 
        geocat4.Zone_d_intervention__c = 12;
        geocat4.DDP__c = 3;
        geocat4.Exclusion__c = '75015, 75017';
        geocat4.Date_de_debut__c = Date.Today();
        geocat4.Date_de_fin__c = Date.Today() + 30;
        geocat4.FaminePoids__c = 100;
        geocatList.add(geocat4);
        Geocat__c geocat5 = new Geocat__c();
        geocat5.Contact__c = contactPro.Id;
        geocat5.Account__c = professionnel.Id;
        geocat5.Adresse__c = CP.Id; 
        geocat5.Zone_d_intervention__c = 12;
        geocat5.DDP__c = 3;
        geocat5.Exclusion__c = '75015, 75017';
        geocat5.Date_de_debut__c = Date.Today();
        geocat5.Date_de_fin__c = Date.Today() + 30;
        geocat5.FaminePoids__c = 130;
        geocatList.add(geocat5);
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

        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfLastMonth = firstDayOfMonth.addDays(-1);
        Date dateToday = Date.today();

        List<Intermediation__c> interList = new List<Intermediation__c>();
        Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, projet);
        miseEnRelation.Statut_Selection__c = 'Demandee';
        miseEnRelation.Professionnel__c =  professionnel.Id;  
        miseEnRelation.Critere_d_intervention__c =  geocat.Id; 
        miseEnRelation.Date_de_s_lection__c =  dateToday - 1;
        interList.add(miseEnRelation);
        Intermediation__c miseEnRelation2 = TestFactory.createMiseEnRelation(contactPro, competence, projet);
        miseEnRelation2.Statut_Selection__c = 'Demandee';
        miseEnRelation2.Professionnel__c =  professionnel.Id;  
        miseEnRelation2.Critere_d_intervention__c =  geocat.Id;   
        miseEnRelation2.Date_de_s_lection__c =  dateToday - 20;
        interList.add(miseEnRelation2);
        Intermediation__c miseEnRelation3 = TestFactory.createMiseEnRelation(contactPro, competence, projet);
        miseEnRelation3.Statut_Selection__c = 'Demandee';
        miseEnRelation3.Professionnel__c =  professionnel.Id;  
        miseEnRelation3.Critere_d_intervention__c =  geocat.Id;   
        miseEnRelation3.Date_de_s_lection__c = dateToday - 15;
        interList.add(miseEnRelation3);
        Intermediation__c miseEnRelation4 = TestFactory.createMiseEnRelation(contactPro, competence, projet);
        miseEnRelation4.Statut_Selection__c = 'Demandee';
        miseEnRelation4.Professionnel__c =  professionnel.Id;    
        miseEnRelation4.Date_de_s_lection__c = dateToday - 18;
        interList.add(miseEnRelation4);
        Intermediation__c miseEnRelation5 = TestFactory.createMiseEnRelation(contactPro, competence, projet);
        miseEnRelation5.Statut_Selection__c = 'Demandee';
        miseEnRelation5.Professionnel__c =  professionnel.Id;    
        miseEnRelation5.Date_de_s_lection__c = dateToday - 18;
        interList.add(miseEnRelation5);

        insert interList;  

    }
    static testmethod void test() {        
        Test.startTest();
        Batch_Famine_Satisfaction fam = new Batch_Famine_Satisfaction();
        Database.executeBatch(fam);
     //   Account acc = [SELECT Id,FaminePourcentage__c,FamineIndicateurChiffres__c FROM Account where Pro_ou_Part__c='pro' LIMIT 1 ];
        //System.assertEquals(acc.FamineIndicateurChiffres__c,'1/14');
        Test.stopTest();
    }
    static testmethod void testSchedulable() {        
        Test.startTest();
        Batch_Famine_Satisfaction fam = new Batch_Famine_Satisfaction();
        String cronexp = '0 0 0 ? * * *';
        system.schedule('test', cronexp, fam);
        Test.stopTest();
    }

}