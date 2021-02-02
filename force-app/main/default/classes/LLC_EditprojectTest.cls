@isTest (SeeAllData=false)
private class LLC_EditprojectTest {

    @testSetup
    static void setup() {
      
      ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
      
      List<Reference__c> listReferences = new List<Reference__c>();
      List<Account> listAccounts = new List<Account>(); 
      Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
      Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
      Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
      Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
      Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
      Reference__c categorie = TestFactory.createReference('categorie', 'ACS', 'AC', 'ACS'); 
      categorie.Duree_selection_auto__c = 3;  
      Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
      User us = TestFactory.createUser('0123456789', sysAdm);
      Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
      //insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;insert categorie; 
      insert TV;
      listReferences.add(CP);
      listReferences.add(competence);
      listReferences.add(NAF);
      listReferences.add(enseigne);
      listReferences.add(categorie);
      listReferences.add(pays);
      insert listReferences;
      Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
      //insert particulier;
      Account professionnel = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
      //insert professionnel;
      listAccounts.add(particulier);
      listAccounts.add(professionnel);
      insert listAccounts;
      Contact contactPro = TestFactory.createContact(professionnel);
      insert contactPro;
      Projet__c project = TestFactory.createProject(particulier, CP, pays, us);  
      Projet__c project2 = TestFactory.createProject(particulier, CP, pays, us);      
      project2.Statut_Projet__c ='Part NRP';
      project2.Sous_statut__c ='2ème appel';
      project2.Etat__c='Contact part clos'; 
      Projet__c project3 = TestFactory.createProject(particulier, CP, pays, us);
      project3.Etat__c='ODC close';
        
      Projet__c project4 = TestFactory.createProject(particulier, CP, pays, us);
      project4.Statut_Projet__c ='Qualifié';
      project4.Categorie_lkp__c = categorie.id;
        
      Projet__c project5 = TestFactory.createProject(particulier, CP, pays, us);  
      project5.Statut_Projet__c = 'Projet partenaire';
        
      Projet__c project6 = TestFactory.createProject(particulier, CP, pays, us);  
      project6.Etat__c='Contact part ouvert';

      Projet__c project7 = TestFactory.createProject(particulier, CP, pays, us);  
      project7.Etat__c='Contact part ouvert';
      project7.Statut_Projet__c ='Part NRP';
      project7.Sous_statut__c ='2ème appel';
        
      List<Projet__c> listProjets = new List<Projet__c>();
      listProjets.add(project); 
      listProjets.add(project2);
      listProjets.add(project3);
      listProjets.add(project4);
      listProjets.add(project5);
      listProjets.add(project6); 
      listProjets.add(project7); 
      insert listProjets;
      
      List<StatusCycleProject__c> scpList = new List<StatusCycleProject__c>();
      
      List<String> cvList = new String[]{'En attente de suivi', 'Faux numéro', 'Faux numéro', 'Nouveau', 'Nouveau', 'Part NRP', 'Part NRP', 'Pas de pros à suivre', 'Projet partenaire', 'Qualifié'};
      List<String> nvList = new String[]{'Suivi effectué', 'Projet Partenaire', 'Qualifié', 'Part NRP', 'Projet différé', 'Qualifié', 'Projet partenaire', 'Pas de pros clos', 'Projet partenaire transmis', 'Pas de pros à suivre'};
      List<String> etatList = new String[]{'ODC close', '', 'ODC ouverte', '', 'Contact part clos', 'ODC ouverte', '', 'ODC close', 'Contact part clos', ''};
      for (Integer i = 0; i < 10; i++) {
        StatusCycleProject__c scp1 = new StatusCycleProject__c(Name=String.valueOf(i), Current_Value__c=cvList[i], Next_Value__c=nvList[i], Order__c=i, Etat__c=etatList[i]);
        scpList.add(scp1);
      }
      insert scpList;
    }

    static testMethod void test() {
        
        Projet__c pro = [SELECT Id FROM Projet__c LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.curProject.Sous_statut__c = '1er appel'; 
            //controller.ownerLockClick();
            projetVariables = LLC_Editproject.CallStatusChange(JSON.serializePretty(projetVariables));
            projetVariables.statusSelected = 'Part NRP';
            projetVariables.subStatusSelected = '3ème appel';
            projetVariables = LLC_Editproject.callSaveProject(JSON.serializePretty(projetVariables));
            system.assertEquals(projetVariables.issaveOK,true);
            Test.stopTest();

        }
    }

    static testMethod void test2() {
        
        Projet__c pro = [SELECT Id FROM Projet__c WHERE Etat__c='Contact part ouvert' and Sous_statut__c ='2ème appel' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.statusSelected = 'Part NRP';
            projetVariables.subStatusSelected = '1er appel';
            projetVariables.curProject.Etat__c='Contact part ouvert';
            projetVariables = LLC_Editproject.callCloseProject(JSON.serializePretty(projetVariables));
            projetVariables = LLC_Editproject.CallSaveProjectMotif(JSON.serializePretty(projetVariables));
            system.assertEquals(projetVariables.curProject.Etat__c,'Contact part clos');
            Test.stopTest();

        }
    } 
    
	static testMethod void test3() {
        
        Projet__c pro = [SELECT Id FROM Projet__c WHERE Etat__c='Contact part clos' and Sous_statut__c ='2ème appel' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.statusSelected = 'Part NRP';
            projetVariables.subStatusSelected = '2eme appel';
            projetVariables.curProject.Etat__c='Contact part clos';
            projetVariables = LLC_Editproject.callOpenProject(JSON.serializePretty(projetVariables));
            system.assertEquals(projetVariables.curProject.Etat__c,'Contact part ouvert');
            Test.stopTest();

        }
    }
    
	static testMethod void test4() {
        
        Projet__c pro = [SELECT Id FROM Projet__c WHERE Etat__c='ODC close' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.statusSelected = 'Part NRP';
            projetVariables.subStatusSelected = '3eme appel';
            projetVariables.curProject.Etat__c='ODC close';
            projetVariables = LLC_Editproject.callOpenProject(JSON.serializePretty(projetVariables));
            system.assertEquals(projetVariables.curProject.Etat__c,'ODC ouverte');
            Test.stopTest();

        }
    }
    static testMethod void test5() {
        
        Projet__c pro = [SELECT Id FROM Projet__c WHERE Statut_Projet__c='Qualifié' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.statusSelected = 'Qualifié';
            projetVariables.subStatusSelected = '';
            projetVariables.curProject.Date_de_Qualification__c=null;
            projetVariables = LLC_Editproject.callSaveProject(JSON.serializePretty(projetVariables));
            Test.stopTest();

        }
    }
    static testMethod void test6() {
        
        Projet__c pro = [SELECT Id FROM Projet__c LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.statusSelected = 'Pas de pros à suivre';
            projetVariables.subStatusSelected = 'Demande précoce';
            projetVariables.curProject.Etat__c='Contact part ouvert';
            projetVariables = LLC_Editproject.callSaveProject(JSON.serializePretty(projetVariables));
            Test.stopTest();

        }
    } 
    static testMethod void test7() {
        
        Projet__c pro = [SELECT Id FROM Projet__c LIMIT 1]; 
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            LLC_Editproject llc_Editproject_test = new LLC_Editproject();
            LLC_Editproject.ProjetVariables projetVariables = LLC_Editproject.CallLoadprojetData(pro.Id);
            projetVariables.statusSelected = 'Qualifié';
            projetVariables.subStatusSelected = '';
            projetVariables.curProject.Etat__c='ODC ouverte';
            projetVariables = LLC_Editproject.CallSaveProject(JSON.serializePretty(projetVariables));            
            projetVariables = LLC_Editproject.CallChangePojectQualifDate(JSON.serializePretty(projetVariables));
            Test.stopTest();

        }
    } 
}