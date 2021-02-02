// 
// Classe de test pour la sélection des MERs suite déclenchement du trigger
// 14/04/2017, xavier templet, création   
//

@isTest
public with sharing class IntermediationTrigger_TEST {
    
    @testSetup
    static void setup() {   
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        List<Reference__c> referenceList = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Reference__c rejetMatching = TestFactory.createReference('Matching_rejet', 'Recrédit - Geste co', 'GCO_REC', 'Recrédit - Geste co');
        //Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        referenceList.add(pays);
        referenceList.add(CP);
        referenceList.add(competence);
        referenceList.add(NAF);
        referenceList.add(enseigne); 
        referenceList.add(rejetMatching);
        insert referenceList;
        //insert TV;

        List<Account> accList = new List<Account>();
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        accList.add(particulier);
        Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        accList.add(professionnel);
        insert accList;
        Contact contactPro = TestFactory.createContact(professionnel);
        insert contactPro;
        
        List<Projet__c> projList = new List<Projet__c>();
        Projet__c project = TestFactory.createProject(particulier, CP, pays, us);
        projList.add(project);
        Projet__c projectMM2 = TestFactory.createProject(particulier, CP, pays, us);
        projList.add(projectMM2);
        //insert projList;

        project.Statut_Projet__c = 'Qualifié';
        project.Etat__c = 'ODC ouverte';
        project.Adresse_mail__c = 'test@gmail.com';
        project.Demande_du_Part__c = 'Architectes';   

        projectMM2.Adresse_mail__c = 'test@gmail.com';
        projectMM2.Demande_du_Part__c = 'Architectes';    
        //update projList;
        insert projList;

        List<Intermediation__c> interList = new List<Intermediation__c>();
        Intermediation__c miseEnRelation = TestFactory.createMiseEnRelation(contactPro, competence, project);
        miseEnRelation.Statut_Selection__c = 'Demandee';
        miseEnRelation.Professionnel__c =  professionnel.Id;    
        interList.add(miseEnRelation);
          
        Intermediation__c MerMM2 = TestFactory.createMiseEnRelation(contactPro,competence, projectMM2);
        MerMM2.Date_MER_Architecte__c = date.today();  
        interList.add(MerMM2);
        //insert interList;
            
        Intermediation__c MERvalid = new Intermediation__c();
        MERvalid.Id = miseEnRelation.Id;        
        MERvalid.Professionnel__c =  professionnel.Id;
        MERvalid.Projet__c = project.Id;  
        checkRecursiveSFDC.runSMS = true;
        checkRecursiveSFDC.run = true;
        MERvalid.Statut_Selection__c = 'Validee';
        //update MERvalid;
        interList.add(MERvalid);
        insert interList;             
        System.assert(miseEnRelation.url_token__c != '');

        //Après récup du projet et de la Mer (ToDo)
        //System.assertEquals(miseEnRelation.Statut_Selection__c, 'Effectuee');
        //System.assertEquals(project.Statut_Projet__c, 'En attente de suivi');
        //check IsModified__c = true et Date_de_s_lection__c = date.today();

        // On simule le rejet de la MER et la création de l'amendement par Batch_Recredit
        miseEnRelation.Matching_rejete__c = rejetMatching.Id;
        zqu__Quote__c quote = new zqu__Quote__c();  
        quote.zqu__Amendment_Name__c = 'Recrédit';
        quote.zqu__account__c = professionnel.Id;
        quote.zqu__SoldToContact__c = contactPro.Id;
        quote.zqu__BillToContact__c = contactPro.Id; 
        quote.zqu__Status__c = 'New';
        quote.zqu__SubscriptionType__c = 'Amend Subscription';
        quote.zqu__Subscription_Term_Type__c = 'Evergreen';
        quote.zqu__InvoiceProcessingOption__c = 'Subscription';
        quote.zqu__ApplyCreditBalance__c = true;
        quote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';
        quote.zqu__SubscriptionVersion__c = 1.0;            
        insert quote;      
    }
    
    @isTest
    public static void Test_IntermediationTrigger() {
 
        // Début des tests
        Test.startTest();           
        ID rejetMatchingId = [SELECT Id FROM Reference__c WHERE Name = 'Recrédit - Geste co' LIMIT 1].Id;    
        ID quoteId = [SELECT Id FROM zqu__Quote__c LIMIT 1].Id; 
        Intermediation__c miseEnRelation = [SELECT Id,Matching_rejete__c,recredit_quote__c FROM Intermediation__c WHERE Statut_Selection__c = 'Demandee' LIMIT 1];      
        miseEnRelation.Matching_rejete__c = rejetMatchingId;
        miseEnRelation.recredit_quote__c = quoteId;
        update miseEnRelation;
        Test.stopTest();
      }
    
}