/**
* @author Qiuyan Liu
* @date 10/01/2017
*@date 07/08/2018 modify by Leila
*
* @description test class for  VFC_EditProject
*/
@isTest (SeeAllData=false)
private class VFC_EditProjectTest {

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
            ApexPages.currentPage().getParameters().put('Id', pro.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(pro);
            VFC_EditProject controller = new VFC_EditProject(stdProject);
            pro.Sous_statut__c = '1er appel'; 
            //controller.ownerLockClick();
            controller.statusChange();
            controller.statusSelected = 'Part NRP';
            controller.subStatusSelected = '3ème appel';
            controller.saveProject();
            controller.cancelProject();
            controller.OpenProject();
            controller.saveProjectMotif();
            Test.stopTest();

        }
    }
     static testMethod void test2() {
        
        Projet__c pro = [SELECT Id FROM Projet__c where Etat__c='Contact part clos' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', pro.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(pro);
            VFC_EditProject controller = new VFC_EditProject(stdProject);
            controller.OpenProject();
            Test.stopTest();
        }
    }
    
    static testMethod void test3() {
        
        Projet__c pro = [SELECT Id FROM Projet__c where Statut_Projet__c ='Qualifié' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', pro.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(pro);
            VFC_EditProject controller = new VFC_EditProject(stdProject);
            controller.ChangePojectQualifDate();
            controller.curProject.Etat__c= 'ODC ouverte';
            controller.ChangePojectODCDate();
            Test.stopTest();
        }
    }
    
    static testMethod void test4() {
        
        Projet__c pro = [SELECT Id FROM Projet__c where Etat__c='ODC close' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', pro.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(pro);
            VFC_EditProject controller = new VFC_EditProject(stdProject);
            controller.OpenProject();
            Test.stopTest();
        }
    }
    
     static testMethod void test5() {
        
        Projet__c pro = [SELECT Id FROM Projet__c where Statut_Projet__c ='Projet partenaire' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', pro.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(pro);
            VFC_EditProject controller = new VFC_EditProject(stdProject);
            controller.initDefautPicklistValue();
            Test.stopTest();
        }
    }
    
    static testMethod void test6() {
        
        Projet__c pro = [SELECT Id, Motif_de_cloture__c FROM Projet__c where Statut_Projet__c ='Part NRP' and Etat__c='Contact Part ouvert' LIMIT 1];
        Profile scProfile = TestFactory.getProfilByName('Service Client');
        User us = new User(IsActive =true ,Alias='user', Email='usersgdbf@cdvp.com', EmailEncodingKey='UTF-8', LastName='my test user', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId = scProfile.Id, TimeZoneSidKey='Europe/Paris', UserName='usersgdbf@cdvp.com');
        insert us;
        
        System.runAs(us) {
            Test.startTest();
            ApexPages.currentPage().getParameters().put('Id', pro.Id);
            ApexPages.StandardController stdProject = new ApexPages.StandardController(pro);
            VFC_EditProject controller = new VFC_EditProject(stdProject);
            controller.curProject.Etat__c= 'Contact Part ouvert';
            controller.curProject.Statut_Projet__c = 'Part NRP';            
            controller.saveProjectMotif();
            controller.saveProject();
            controller.cancelProject();
            controller.CloseProject();
            Test.stopTest();
        }
        
            PageReference pr = Page.VF_Motif_de_cloture_Projet;
			Test.setCurrentPage(pr);
			
			pr.getParameters().put('id',pro.Id);
			ApexPages.StandardController sc = new ApexPages.standardController(pro);
        
        
    }
    
}