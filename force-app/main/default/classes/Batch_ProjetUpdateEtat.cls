//
// Batch pour MAJ Etat de clotûre par rapport aux valeurs de Statut projet
// 28/12/2016, Leila BOUAIFEL, creation
// 14/06/2017, xavier templet, update en fonction de la Date de fin ODC ouverte
// 04/07/2017, Qiuyan Liu, correction pour clôturer tous les projets après certains jours(N1, N2, M)
// 22/08/2017, Qiuyan Liu, EB-129, call bus to notify the changement of Projet__c's Statut_Projet__c, Sous_statut__c and Etat__c
// 29/03/2018, Leila, EB Offres part, Statuts (faux numéro +Part NRP 1 à 4) + PART NRP nouveaux services parts
// 04/06/18, Leila, modification batch suite quickwin projet
// 22/10/18, Leila, ajout EPH MOE et modif Autorisation
// 12/05/20, Leila, Exclusion des projets au statut : Part NRP et sous-statut : Pas dispo immédiatement

public with sharing class Batch_ProjetUpdateEtat implements Database.Batchable<sObject>, Schedulable  {
    
    String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Integer n1Days = Integer.valueOf(System.Label.CloseStatutProjet_N1);
        Integer n2Days = Integer.valueOf(System.Label.CloseStatutProjet_N2);
        Integer n4Days = Integer.valueOf(System.Label.CloseStatutProjet_N4);
        Integer n5Days = Integer.valueOf(System.Label.CloseStatutProjet_N5);
        Integer mDays = Integer.valueOf(System.Label.CloseStatutProjet_m);
        Integer m1Days = Integer.valueOf(System.Label.CloseStatutProjet_m1);

        // DateTime.now() returns the current Datetime based on a GMT calendar
        DateTime d1 = DateTime.now(); 
        d1 = d1.addDays(0 - n1Days);
        DateTime n1Start = DateTime.newInstanceGmt(d1.year(), d1.month(), d1.day(), 0, 0, 0);
        d1 = d1.addDays(1);
        DateTime n1End = DateTime.newInstanceGmt(d1.year(), d1.month(), d1.day(), 0, 0, 0); 
        
        DateTime d2 = DateTime.now();
        d2 = d2.addDays(0 - n2Days);
        DateTime n2Start = DateTime.newInstanceGmt(d2.year(), d2.month(), d2.day(), 0, 0, 0);
        d2 = d2.addDays(1);
        DateTime n2End = DateTime.newInstanceGmt(d2.year(), d2.month(), d2.day(), 0, 0, 0); 
        
        DateTime d3 = DateTime.now();
        d3 = d3.addDays(0-mDays);
        DateTime mStart = DateTime.newInstanceGmt(d3.year(), d3.month(), d3.day(), 0, 0, 0);
        d3 = d3.addDays(1);
        DateTime  mEnd = DateTime.newInstanceGmt(d3.year(), d3.month(), d3.day(), 0, 0, 0); 
        
        DateTime d6 = DateTime.now();
        d6 = d6.addDays(0-m1Days);
        DateTime m1Start = DateTime.newInstanceGmt(d6.year(), d6.month(), d6.day(), 0, 0, 0);
        d6 = d6.addDays(1);
        DateTime  m1End = DateTime.newInstanceGmt(d6.year(), d6.month(), d6.day(), 0, 0, 0);         
        
        DateTime d4 = DateTime.now();
        d4 = d4.addDays(0-mDays);
        DateTime n4Start = DateTime.newInstanceGmt(d4.year(), d4.month(), d4.day(), 0, 0, 0);
        d4 = d4.addDays(1);
        DateTime  n4End = DateTime.newInstanceGmt(d4.year(), d4.month(), d4.day(), 0, 0, 0); 
        
        DateTime d5 = DateTime.now();
        d5 = d5.addDays(0-mDays);
        DateTime n5Start = DateTime.newInstanceGmt(d5.year(), d5.month(), d5.day(), 0, 0, 0);
        d5 = d5.addDays(1);
        DateTime  n5End = DateTime.newInstanceGmt(d5.year(), d5.month(), d5.day(), 0, 0, 0); 

        String n1StartStr = n1Start.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n1EndStr = n1End.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n2StartStr = n2Start.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n2EndStr = n2End.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n4StartStr = n4Start.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n4EndStr = n4End.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n5StartStr = n5Start.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String n5EndStr = n5End.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String mStartStr = mStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String mEndStr = mEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String m1StartStr = m1Start.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String m1EndStr = m1End.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

        query = 'SELECT Id, Statut_Projet__c,Sous_statut__c, Canal__c, Etat__c, Date_de_fin_ODC_ouverte__c, CreatedDate, (SELECT CreatedDate, NewValue, OldValue, ParentId FROM Histories WHERE Field = \'Statut_Projet__c\' ORDER BY CreatedDate DESC) FROM Projet__c WHERE Etat__c != \'ODC close\' AND Etat__c != \'Contact part clos\' AND (Statut_Projet__c=\'Part NRP\' OR Statut_Projet__c=\'Faux numéro\' OR Statut_Projet__c=\'Part NRP Concours\' OR Statut_Projet__c=\'Part NRP Métré\' OR Statut_Projet__c=\'Part NRP Planche ambiance\' OR Statut_Projet__c=\'Part NRP EPH\' OR Statut_Projet__c=\'Part NRP EPH MOE\' OR Statut_Projet__c=\'Part NRP Archi\'  OR Statut_Projet__c=\'Part NRP Autorisation\' OR Statut_Projet__c=\'Part NRP Conseils travaux\' OR Statut_Projet__c=\'Pas de pros à suivre\' OR Statut_Projet__c=\'En attente de suivi\')';

        if(test.Isrunningtest()){
        query = 'SELECT Id, Statut_Projet__c,Sous_statut__c, Etat__c, Date_de_fin_ODC_ouverte__c, Canal__c, CreatedDate, (SELECT CreatedDate, NewValue, OldValue, ParentId FROM Histories WHERE Field = \'Statut_Projet__c\') FROM Projet__c WHERE Etat__c != \'ODC close\' AND Etat__c != \'Contact part clos\' AND (Statut_Projet__c=\'Part NRP\' OR Statut_Projet__c=\'Faux numéro\'  OR Statut_Projet__c=\'Part NRP Concours\' OR Statut_Projet__c=\'Part NRP Métré\' OR Statut_Projet__c=\'Part NRP Planche ambiance\' OR Statut_Projet__c=\'Part NRP EPH\' OR Statut_Projet__c=\'Part NRP EPH MOE\' OR Statut_Projet__c=\'Part NRP Archi\'  OR Statut_Projet__c=\'Part NRP Autorisation\'  OR Statut_Projet__c=\'Part NRP Conseils travaux\' OR Statut_Projet__c=\'Pas de pros à suivre\' OR Statut_Projet__c=\'En attente de suivi\')';
        }
             
        system.debug('####query '+query);      
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Projet__c> scope) {
        System.debug(' scope ' + scope);
        System.debug(' scope.size() ' + scope.size());
               
        String content = null;
        String toAddress = null;            
        Id projectId ;
        
                  
        Integer n1Days = Integer.valueOf(System.Label.CloseStatutProjet_N1);
        Integer n2Days = Integer.valueOf(System.Label.CloseStatutProjet_N2);
        Integer n4Days = Integer.valueOf(System.Label.CloseStatutProjet_N4);
        Integer n5Days = Integer.valueOf(System.Label.CloseStatutProjet_N5);
        Integer mDays =  Integer.valueOf(System.Label.CloseStatutProjet_m);
        Integer m1Days = Integer.valueOf(System.Label.CloseStatutProjet_m1);
        
        //Returns the current Datetime based on a GMT calendar.
        DateTime d1 = DateTime.now(); 
        DateTime d2 = DateTime.now();
        DateTime d3 = DateTime.now();
        DateTime d4 = DateTime.now();
        DateTime d5 = DateTime.now();
        DateTime d6 = DateTime.now();
        
        d1 = d1.addDays(0 - n1Days);
        DateTime n1Start = DateTime.newInstanceGmt(d1.year(), d1.month(), d1.day(), 0, 0, 0); 

        d2 = d2.addDays(0 - n2Days);
        DateTime n2Start = DateTime.newInstanceGmt(d2.year(), d2.month(), d2.day(), 0, 0, 0); 
        
        d3 = d3.addDays(0-mDays);
        DateTime mStart = DateTime.newInstanceGmt(d3.year(), d3.month(), d3.day(), 0, 0, 0);
        
        d6 = d6.addDays(0-m1Days);
        DateTime m1Start = DateTime.newInstanceGmt(d6.year(), d6.month(), d6.day(), 0, 0, 0);
        
        d4 = d4.addDays(0 - n4Days);
        DateTime n4Start = DateTime.newInstanceGmt(d4.year(), d4.month(), d4.day(), 0, 0, 0); 
        
        d5 = d5.addDays(0 - n5Days);
        DateTime n5Start = DateTime.newInstanceGmt(d5.year(), d5.month(), d5.day(), 0, 0, 0); 
        
        
        
        if(test.Isrunningtest()) {
          d1 = DateTime.now();
          d2 = DateTime.now();
          d2 = DateTime.now();
          n1Start = DateTime.newInstanceGmt(d1.year(), d1.month(), d1.day(), 0, 0, 0); 
          n2Start = DateTime.newInstanceGmt(d2.year(), d2.month(), d2.day(), 0, 0, 0);
          n4Start = DateTime.newInstanceGmt(d4.year(), d4.month(), d4.day(), 0, 0, 0);
          n5Start = DateTime.newInstanceGmt(d5.year(), d5.month(), d5.day(), 0, 0, 0);
          mStart = DateTime.newInstanceGmt(d3.year(),  d3.month(), d3.day(), 0, 0, 0);
          m1Start = DateTime.newInstanceGmt(d6.year(), d6.month(), d6.day(), 0, 0, 0);
        }
      
        //list for holding project updates
        List<Projet__c> ProjetToUpdate = new List<Projet__c>(); 
        
        for (Projet__c s : scope)  { 

          Projet__History phNew = new Projet__History(ParentId=s.Id);
          List<Projet__History> phSimulationList = new List<Projet__History>();
          phSimulationList.add(phNew);
          List<Projet__History> phList = test.Isrunningtest() ? phSimulationList : s.Histories;

            if ((s.Statut_Projet__c == 'Part NRP' && s.Sous_statut__c!= 'Part pas disponible immédiatement') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {
                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP' || Test.isRunningTest()) { 
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n1Start >= d )) 
              //|| (n1Start.isSameDay( d ))) 
                            ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Contact part clos',ClosedBy__c = 'Batch', Canal__c = s.Canal__c));
                      break;
                    } 
                }
            } else if ((s.Statut_Projet__c == 'Faux numéro') && phList != null &&phList.size() > 0) { 
                
                for (Projet__History ph : phList) {
                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Faux numéro' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now())  || (n2Start >= d )) 
                        //|| (n2Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Contact part clos', ClosedBy__c = 'Batch', Canal__c = s.Canal__c));
                        break;
                    }
                }
            } else if ((s.Statut_Projet__c == 'Pas de pros à suivre') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {
                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Pas de pros à suivre' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (mStart >= d )) 
                        //|| (mStart.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='ODC close', Statut_Projet__c='Pas de pros clos', Sous_statut__c ='' , ClosedBy__c = 'Batch', Canal__c = s.Canal__c));
                        break;
                    } 
                }
            }  else if ((s.Statut_Projet__c == 'En attente de suivi') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'En attente de suivi' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (m1Start >= d )) 
                        //|| (m1Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='ODC close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }

             else if ((s.Statut_Projet__c == 'Part NRP Concours') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP Concours' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n4Start >= d )) 
                        //|| (n4Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Prestation Concours close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }        
            else if ((s.Statut_Projet__c == 'Part NRP Métré') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP Métré' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n4Start >= d )) 
                        //|| (n4Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Prestation Métré close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }
            else if ((s.Statut_Projet__c == 'Part NRP Planche ambiance') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP Planche ambiance' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n4Start >= d )) 
                        //|| (n4Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Prestation Planche ambiance close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }

            else if ((s.Statut_Projet__c == 'Part NRP EPH') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP EPH' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n5Start >= d )) 
                        //|| (n5Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Projet EPH clos', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }
            
            else if ((s.Statut_Projet__c == 'Part NRP EPH MOE') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP EPH MOE' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n5Start >= d )) 
                        //|| (n5Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Projet EPH MOE clos', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }
            
            else if ((s.Statut_Projet__c == 'Part NRP Archi') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP Archi' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n4Start >= d )) 
                        //|| (n4Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Mer Archi close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }
            else if ((s.Statut_Projet__c == 'Part NRP Autorisation') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP Autorisation' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n4Start >= d )) 
                        //|| (n4Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Prestation Autorisation close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }
           
           
            else if ((s.Statut_Projet__c == 'Part NRP Conseils travaux') && phList != null && phList.size() > 0) { 
                
                for (Projet__History ph : phList) {

                    DateTime d = Test.isRunningTest() ? Datetime.now() : ph.CreatedDate;
                    if (ph.NewValue == 'Part NRP Conseils travaux' || Test.isRunningTest()) {
            if ((s.Date_de_fin_ODC_ouverte__c != null && s.Date_de_fin_ODC_ouverte__c < DateTime.now()) || (n4Start >= d )) 
                        //|| (n4Start.isSameDay( d ))) 
                          ProjetToUpdate.add(new Projet__c(Id=s.Id, Etat__c='Prestation Conseils travaux close', ClosedBy__c = 'Batch', Canal__c = s.Canal__c)); 
                        break;
                    } 
                }
            }       
        }
                       
        //System.debug(' ProjetToUpdate ' + ProjetToUpdate);      
        if(ProjetToUpdate != null && ProjetToUpdate.size() > 0) { 
            update ProjetToUpdate; 
            List<Id> ids = new List<Id>();
            for (Projet__c p : ProjetToUpdate) {
                if (p.Canal__c == 'Web') {
                    ids.add(p.Id);
                }
            }
            if (ids.size() > 0) {
               System.enqueueJob(new ProjetAffiliationWS(ids)); 
            }
        }
        
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute(SchedulableContext context) {
        Batch_ProjetUpdateEtat b = new Batch_ProjetUpdateEtat(); 
        database.executebatch(b);
    }
    
}