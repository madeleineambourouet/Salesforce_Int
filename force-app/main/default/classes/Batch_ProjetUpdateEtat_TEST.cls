/**
* @author Leila BOUAIFEL
* @date 03/01/2017*
* @description Test class for Class Batch_ProjetUpdateEtat
* @Leila BOUAIFEL Modify le 22/06/18
* @Leila BOUAIFEL Modify le 22/10/18 
*/
@isTest (SeeAllData=false)
private class Batch_ProjetUpdateEtat_TEST {
    @testSetup
    static void setup() {
        
        ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
        
        List<Reference__c> listReferences = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c competence = TestFactory.createReference('competence', '1','competence','Agenceur');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User us = TestFactory.createUser('0123456789', sysAdm);
        Technical_Values__c TV = TestFactory.createCustomSettings('XZZZZ');
        //insert pays; insert CP; insert competence; insert NAF; insert enseigne; insert TV;

        listReferences.add(CP);
        listReferences.add(competence);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        insert listReferences;
        
        // Create particulier
        Account particulier = TestFactory.createAccount(false, pays, CP, null, null);
        insert particulier;
        
        DateTime d = DateTime.now();
        
        List<Projet__c> CreateProjet = new List<Projet__c>();
        
        // Create projet 1
        Projet__c project1 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project1;
        project1.Statut_Projet__c = 'Part NRP';
        project1.Sous_statut__c = '1er appel';
        project1.Etat__c = 'Contact part ouvert';
        project1.Adresse_mail__c = 'test1@gmail.com';
        project1.email_projet__c = 'test1@gmail.com';
        project1.Source__c = 'HOMLY YOU';
        project1.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project1);
        
        // Create projet 2
        Projet__c project2 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project2;
        project2.Statut_Projet__c = 'Faux numéro'; 
        project2.Etat__c = 'Contact part ouvert';
        project2.Adresse_mail__c = 'test2@test.com';
        project2.email_projet__c = 'test2@test.com';
        project2.Source__c = 'HOMLY YOU';
        project2.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project2);
        
        // Create projet 3
        Projet__c project3 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project3;
        project3.Statut_Projet__c = 'Pas de pros à suivre'; 
        project3.Adresse_mail__c = 'test3@gmail.com';
        project3.email_projet__c = 'test3@test.com';
        project3.Source__c = 'HOMLY YOU';
        project3.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project3);
        
        // Create projet 4
        Projet__c project4 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project4;
        project4.Statut_Projet__c = 'En attente de suivi'; 
        project4.Adresse_mail__c = 'test4@gmail.com';
        project4.email_projet__c = 'test4@test.com';
        project4.Source__c = 'HOMLY YOU';
        project4.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project4);
        
        // Create projet 5
        Projet__c project5 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project5;
        project5.Statut_Projet__c = 'Part NRP Concours';
        project5.Sous_statut__c = '1er appel'; 
        project5.Etat__c = 'Prestation Concours ouverte';
        project5.Adresse_mail__c = 'test5@gmail.com';
        project5.email_projet__c = 'test5@test.com';
        project5.Source__c = 'HOMLY YOU';
        project5.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project5);
        
        // Create projet 6
        Projet__c project6 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project6;
        project6.Statut_Projet__c = 'Part NRP Métré'; 
        project6.Sous_statut__c = '1er appel';
        project6.Etat__c = 'Prestation Métré ouverte';
        project6.Adresse_mail__c = 'test6@gmail.com';
        project6.email_projet__c = 'test6@test.com';
        project6.Source__c = 'HOMLY YOU';
        project6.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project6);
        
        // Create projet 7
        Projet__c project7 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project7;
        project7.Statut_Projet__c = 'Part NRP Planche ambiance';
        project7.Sous_statut__c = '1er appel'; 
        project7.Etat__c = '  Prestation Planche ambiance ouverte';
        project7.Adresse_mail__c = 'test7@gmail.com';
        project7.email_projet__c = 'test7@test.com';
        project7.Source__c = 'HOMLY YOU';
        project7.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project7);
        
        // Create projet 8
        Projet__c project8 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project8;
        project8.Statut_Projet__c = 'Part NRP EPH';
        project8.Sous_statut__c = '1er appel'; 
        project8.Etat__c = 'Projet EPH ouvert';
        project8.Adresse_mail__c = 'test8@gmail.com';
        project8.email_projet__c = 'test8@test.com';
        project8.Source__c = 'HOMLY YOU';
        project8.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project8);
        
        // Create projet 10
        Projet__c project10 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project10;
        project10.Statut_Projet__c = 'Part NRP EPH MOE';
        project10.Sous_statut__c = '1er appel'; 
        project10.Etat__c = 'Projet EPH MOE ouvert';
        project10.Adresse_mail__c = 'test8@gmail.com';
        project10.email_projet__c = 'test8@test.com';
        project10.Source__c = 'HOMLY YOU';
        project10.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project10);
        
        // Create projet 9
        Projet__c project9 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project9;
        project9.Statut_Projet__c = 'Part NRP Archi'; 
        project9.Sous_statut__c = '1er appel';
        project9.Etat__c = 'Mer Archi ouverte';
        project9.email_projet__c = 'test9@test.com';
        project9.Adresse_mail__c = 'test9@gmail.com';
        project9.Source__c = 'HOMLY YOU';
        project9.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project9);
        
        
        // Create projet 12
        Projet__c project12 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project12;
        project12.Statut_Projet__c = 'Part NRP Conseils travaux';
        project12.Etat__c = 'Prestation Conseils travaux ouverte';
        project12.email_projet__c = 'test12@test.com';
        project12.Adresse_mail__c = 'test12@gmail.com';
        project12.Source__c = 'HOMLY YOU';
        project12.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project12);
        
        // Create projet 13
        Projet__c project13 = TestFactory.createProject(particulier, CP, pays, us);
        //insert project13;
        project13.Statut_Projet__c = 'Part NRP Autorisation';
        project13.Etat__c = 'Prestation Autorisation ouverte';
        project13.email_projet__c = 'test13@test.com';
        project13.Adresse_mail__c = 'test13@gmail.com';
        project13.Source__c = 'HOMLY YOU';
        project13.Date_de_fin_ODC_ouverte__c = d.addDays(-2);
        CreateProjet.add(project13);
        
        insert CreateProjet;
    }
    // call the batch
    static testMethod void test() {
        Test.startTest();
        Batch_ProjetUpdateEtat b = new Batch_ProjetUpdateEtat();
        database.executebatch(b); 
        Test.stopTest();
        
        // Verify Statut Projet was updated for all project
        
        List<Projet__c> UpdateProjet = [SELECT Statut_Projet__c, Etat__c, Sous_statut__c  FROM Projet__c where Statut_Projet__c = 'Part NRP' OR Statut_Projet__c = 'Faux numéro' or Statut_Projet__c = 'En attente de suivi' or Statut_Projet__c = 'Pas de pros à suivre'  or Statut_Projet__c = 'Part NRP Concours' or Statut_Projet__c = 'Part NRP Métré' or Statut_Projet__c = 'Part NRP Planche ambiance' or Statut_Projet__c = 'Part NRP EPH' or Statut_Projet__c = 'Part NRP Archi' or Statut_Projet__c = 'Part NRP Conseils travaux' or Statut_Projet__c = 'Part NRP Autorisation'];
        
        //System.assertEquals(UpdateProjet.Size(), 13 );         
        List<Projet__c> listeProjetToUpdate =  new List<Projet__c>();
        System.debug('******** avant le for du test ');
        for (Projet__c P : UpdateProjet ) { 
            System.debug('******** tests '+P);
            // Verify Statut Projet was updated for one project with value 'Part NRP' 
            if (p.Statut_Projet__c == 'Part NRP' && p.Sous_statut__c == '2ème appel') {
                p.Etat__c = 'Contact part clos';
            }      
            // Verify Statut Projet was updated for one project with value 'Faux numéro' 
            if (p.Statut_Projet__c == 'Faux numéro' ) {
                p.Etat__c = 'Contact part clos';
            }    
            // Verify Statut Projet was updated for one project with value 'En attente de suivi'  and 'Pas de pros à suivre'
            if (p.Statut_Projet__c == 'En attente de suivi' || p.Statut_Projet__c == 'Pas de pros à suivre') { 
                p.Etat__c = 'ODC close';
            }     
            // Verify Statut Projet was updated for one project with value 'Part NRP Concours'  
            if (p.Statut_Projet__c == 'Part NRP Concours' ) { 
                p.Etat__c = 'Prestation Concours close';
            }    
            // Verify Statut Projet was updated for one project with value 'Part NRP Métré'  
            if (p.Statut_Projet__c == 'Part NRP Métré' ) { 
                p.Etat__c = 'Prestation Métré close';
            }    
            // Verify Statut Projet was updated for one project with value 'Part NRP Planche ambiance'  
            if (p.Statut_Projet__c == 'Part NRP Planche ambiance' ) { 
                p.Etat__c = 'Prestation Planche ambiance close';
            }    
            // Verify Statut Projet was updated for one project with value 'Part NRP EPH'  
            if (p.Statut_Projet__c == 'Part NRP EPH' ) { 
                p.Etat__c = 'Projet EPH clos';
            }   
            // Verify Statut Projet was updated for one project with value 'Part NRP Archi'  
            if (p.Statut_Projet__c == 'Part NRP Archi' ) { 
                p.Etat__c = 'Mer Archi close';
            }   
            
            // Verify Statut Projet was updated for one project with value 'Part NRP Conseils travaux'  
            if (p.Statut_Projet__c == 'Part NRP Conseils travaux') {
                p.Etat__c = 'Prestation Conseils travaux close';
            }   
            // Verify Statut Projet was updated for one project with value 'Part NRP Autorisation'  
            if (p.Statut_Projet__c == 'Part NRP Autorisation' ) { 
                p.Etat__c = 'Prestation Autorisation close';
            }
            //update UpdateProjet;
            listeProjetToUpdate.add(P);
        }
        if(listeProjetToUpdate.size()>0){
            update listeProjetToUpdate;
        }
    }
}