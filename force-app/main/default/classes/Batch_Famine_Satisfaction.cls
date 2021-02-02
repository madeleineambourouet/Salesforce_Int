/**
* @author Clement Musabimana
* @date 26/09/2018
* @description Batch permettant de calculer la satisfaction d'un client Pro
**/
public class Batch_Famine_Satisfaction implements Database.Batchable<sObject>, Schedulable  {
  //public static final String QUERY = 'Select Id,Statut_de_la_souscription__c from account where Statut_de_la_souscription__c = \'Active\' and id=\'0013E00000tezP4\'';
  //public static final String QUERY = 'select id,offre_intermediation_active__c,au_moins_un_ci_suspendu__c,aucun_ci_actif__c,Desactivation_des_ODC_impaye_recurrent__c  from Account where offre_intermediation_active__c = true and aucun_ci_actif__c=false and Desactivation_des_ODC_impaye_recurrent__c = false and Id=\'0013E00000ptzvD\'';
  public static final String QUERY = 'select id,offre_intermediation_active__c,au_moins_un_ci_suspendu__c,aucun_ci_actif__c,Desactivation_des_ODC_impaye_recurrent__c  from Account where (offre_intermediation_active__c = true and aucun_ci_actif__c=false and Desactivation_des_ODC_impaye_recurrent__c = false) or (FamineIndicateur__c !=null or FamineIndicateurChiffres__c != null or FaminePourcentage__c != null)';

    public Database.QUERYLocator start(Database.BatchableContext BC){
      return Database.getQUERYLocator(QUERY);
    }


    public void execute(Database.BatchableContext BC, List<sObject> scope){
      List<Id> listAccId = new List<Id> ();
      List<Account> listAccountsToUpdate = new List<Account> ();
      //Map pour stocker les poids de chaque critère d'intervention d'un compte pro
      Map<Id,Map<Id,Decimal>> mapAccountCiPoids = new Map<Id,Map<Id,Decimal>>();
      //Map pour stocker la somme poids d'un compte pro
      Map<Id,Decimal> mapAccountCiTotalPoids = new Map<Id,Decimal>();
      //Map pour stocker le nombre d'ODC attendus pour chaque critère d'intervention d'un compte pro
      Map<Id,Map<Id,Decimal>> mapAccountCiNbOdcAttendus = new Map<Id,Map<Id,Decimal>>();
      //Map pour stocker le nombre d'ODC apportés pour chaque critère d'intervention d'un compte pro
      Map<Id,Map<Id,Decimal>> mapAccountCiOdcApportes = new Map<Id,Map<Id,Decimal>>();
      Map<Id,Account> mapAccounts = new Map<Id,Account>();
      //Map pour stocker les CI avec au moins une comptence active
      Map<Id,Boolean> mapCiWithCompetenceActive = new Map<Id,Boolean>();
      //Map pour stocker le Nb de MeR reçues sur la période non rattachées à un CI 
      Map<Id,Integer> mapAccountsNbMerSansCi = new Map<Id,Integer>();
      for (Account acc : (list<Account>)scope) {
          //On remet tous les indicateurs à null
          acc.FaminePourcentage__c = null;
          acc.FamineIndicateurChiffres__c = null;
          listAccountsToUpdate.add(acc);
          //on ne calcule la famine que pour les comptes actives avec une offre intermediation
          if(acc.offre_intermediation_active__c == true && acc.aucun_ci_actif__c == false && acc.Desactivation_des_ODC_impaye_recurrent__c == false){
            listAccId.add(acc.Id);
            mapAccounts.put(acc.Id, acc);
          }

      }
      system.debug('Batch_Famine_Satisfaction *** mapAccounts '+mapAccounts);

      /*
      for (AggregateResult  aggregate_Result : [SELECT GeoCat__c FROM Competence__c where Active__c = true group by GeoCat__c]) {
        //system.debug('Batch_Famine_Satisfaction *** aggregate_Result '+aggregate_Result);
        //system.debug('Batch_Famine_Satisfaction *** GeoCat__c '+aggregate_Result.get('GeoCat__c'));
        String geocatId_string = String.valueof(aggregate_Result.get('GeoCat__c'));
        Id geocatId = Id.valueOf(geocatId_string);
        mapCiWithCompetenceActive.put(geocatId, true);
      }*/

      for (Competence__c c : [SELECT GeoCat__c FROM Competence__c where Active__c = true  AND GeoCat__c IN (SELECT Id FROM GeoCat__c WHERE Account__c IN :listAccId) ORDER BY GeoCat__c]) {
        if(mapCiWithCompetenceActive.get(c.GeoCat__c) == null){
          mapCiWithCompetenceActive.put(c.GeoCat__c, true);
        }
      }

      system.debug('Batch_Famine_Satisfaction listAccId '+listAccId);
      Date dateToday = Date.today();
      Date dateTodayMoinsUnMois = dateToday.addMonths(-1);
      system.debug('Batch_Famine_Satisfaction dateToday '+dateToday);
      system.debug('Batch_Famine_Satisfaction dateTodayMoinsUnMois '+dateTodayMoinsUnMois);

      //On stocke la liste des poids des CI par comptes: une map de compte contenant une map de CI
      //On stocke la liste du nombre d'ODC des CI par comptes: une map de compte contenant une map de CI
      for (GeoCat__c  geocat : [Select Id,Account__r.Id,DDP__c,FaminePoids__c,Account__c,Zone_d_intervention__c,Date_de_debut__c,Date_de_fin__c from GeoCat__c where Account__c in: listAccId]) {
        system.debug('Batch_Famine_Satisfaction geocat '+geocat);
        //Le critere d'intervention a au moins une competence active
        system.debug('Batch_Famine_Satisfaction mapCiWithCompetenceActive.get(geocat.Id) '+mapCiWithCompetenceActive.get(geocat.Id));
        if(mapCiWithCompetenceActive.get(geocat.Id) != null){
          //Le critere d'intervention n'est pas desactivé
          if((((geocat.Date_de_debut__c == null && geocat.Date_de_fin__c == null) || 
            (geocat.Date_de_debut__c != null  && dateToday<geocat.Date_de_debut__c) || 
            (geocat.Date_de_fin__c != null  && dateToday>geocat.Date_de_fin__c))) &&
            (geocat.DDP__c != null && geocat.DDP__c > 0 && geocat.Zone_d_intervention__c != null && geocat.Zone_d_intervention__c > 0)){
            system.debug('Batch_Famine_Satisfaction geocat cond 2');
            //SI le CI est bien lié a un compte en cours de traitement
            if(geocat.Account__r.Id != null && mapAccounts.get(geocat.Account__r.Id) != null){
              system.debug('Batch_Famine_Satisfaction *** geocat '+geocat);
              if(mapAccountCiPoids.get(geocat.Account__c) != null){
                if(mapAccountCiPoids.get(geocat.Account__c).get(geocat.Id) == null){
                  mapAccountCiPoids.get(geocat.Account__c).put(geocat.Id,geocat.FaminePoids__c);
                  mapAccountCiNbOdcAttendus.get(geocat.Account__c).put(geocat.Id,geocat.DDP__c);
                }               
              }
              else{
                Map<Id,Decimal> mapAccountCiPoidsTemp = new Map<Id,Decimal>();
                Map<Id,Decimal> mapAccountCiNbOdcTemp = new Map<Id,Decimal>();
                mapAccountCiPoidsTemp.put(geocat.Id,geocat.FaminePoids__c);
                mapAccountCiNbOdcTemp.put(geocat.Id,geocat.DDP__c);
                mapAccountCiPoids.put(geocat.Account__c, mapAccountCiPoidsTemp);
                mapAccountCiNbOdcAttendus.put(geocat.Account__c, mapAccountCiNbOdcTemp);
              }
              // somme des poids d'un compte
              if(mapAccountCiTotalPoids.get(geocat.Account__c) != null){
                Decimal totaltemp =  mapAccountCiTotalPoids.get(geocat.Account__c);  
                system.debug('Batch_Famine_Satisfaction *** totaltemp '+totaltemp); 
                system.debug('Batch_Famine_Satisfaction *** geocat.FaminePoids__c '+geocat.FaminePoids__c); 
                Decimal famine = geocat.FaminePoids__c != null ? geocat.FaminePoids__c : 0;
                totaltemp = totaltemp +  famine; 
                mapAccountCiTotalPoids.put(geocat.Account__c,totaltemp);        
              }
              else{
                mapAccountCiTotalPoids.put(geocat.Account__c,geocat.FaminePoids__c);   
              }
            } 
          }
        }
      }

      
      //Recuperation du nombre d'ODC (par type de critere d'intervention) recu par compte pro
      //for (Intermediation__c  intermediation : [select id, Critere_d_intervention__c, Professionnel__c, CreatedDate from Intermediation__c where Date_de_s_lection__c != null and Critere_d_intervention__c != null and  Professionnel__c in: listAccId and Date_de_s_lection__c = LAST_MONTH]) {
      for (Intermediation__c  intermediation : [select id, Critere_d_intervention__c, Criteres_d_intervention__c, Professionnel__c, CreatedDate from Intermediation__c where Date_de_s_lection__c != null and  Professionnel__c in: listAccId and Date_de_s_lection__c >=: dateTodayMoinsUnMois  and Date_de_s_lection__c <=: dateToday]) {
          system.debug('Batch_Famine_Satisfaction *** intermediation '+intermediation);
          system.debug('Batch_Famine_Satisfaction *** intermediation '+intermediation);
          String ciString = intermediation.Critere_d_intervention__c;
          //On reduit la taille de l'Id a 15 au lieu de 18, pour avoir la même taille que dans la map mapAccountCiOdcApportes
          String keyCiString = ciString  != null && ciString != '' ? ciString.substring(0, 15) : '';
          if(keyCiString != ''){
            if(mapAccountCiOdcApportes.get(intermediation.Professionnel__c) != null){
              if(mapAccountCiOdcApportes.get(intermediation.Professionnel__c).get(keyCiString) == null){
                mapAccountCiOdcApportes.get(intermediation.Professionnel__c).put(keyCiString,1);
              }
              else {
                Decimal nbOdc = mapAccountCiOdcApportes.get(intermediation.Professionnel__c).get(keyCiString);
                nbOdc = nbOdc + 1;
                mapAccountCiOdcApportes.get(intermediation.Professionnel__c).put(keyCiString,nbOdc);
              }
            }
            else{
              system.debug('Batch_Famine_Satisfaction *** OKKK ');
              Map<Id,Decimal> mapAccountMerCiTemp = new Map<Id,Decimal>();
              mapAccountMerCiTemp.put(keyCiString,1);
              mapAccountCiOdcApportes.put(intermediation.Professionnel__c, mapAccountMerCiTemp);
            }
            //Verification si la MER n'est pas rattachée a un critere d'intervention
            if(mapAccountCiNbOdcAttendus.get(intermediation.Professionnel__c) != null){
              if(mapAccountCiNbOdcAttendus.get(intermediation.Professionnel__c).get(keyCiString) == null){
                if(mapAccountsNbMerSansCi.get(intermediation.Professionnel__c) == null){
                  mapAccountsNbMerSansCi.put(intermediation.Professionnel__c,1);
                }
                else{
                  Integer nbMerSansCi =  mapAccountsNbMerSansCi.get(intermediation.Professionnel__c);
                  nbMerSansCi = nbMerSansCi + 1;
                  mapAccountsNbMerSansCi.put(intermediation.Professionnel__c, nbMerSansCi);
                }
              }
            }
          }
      }
      //Calcul du taux de satisfaction
      // SOMME pour tous les criteres d'interventios d'un même compte (odcApportes/odcAttendus)*poids
      system.debug('Batch_Famine_Satisfaction *** mapAccountCiNbOdcAttendus '+mapAccountCiNbOdcAttendus);
      system.debug('Batch_Famine_Satisfaction *** mapAccountCiOdcApportes '+mapAccountCiOdcApportes);
      system.debug('Batch_Famine_Satisfaction *** mapAccountCiPoids '+mapAccountCiPoids);
      String  mailBody = '';
      for (Id keyAccount : mapAccountCiNbOdcAttendus.keySet()) {
        Decimal faminePourcentage = 0;
        Decimal odcAttendus = 0;
        Decimal odcApportes = 0;
        Decimal sumPoidsAccount = mapAccountCiTotalPoids.get(keyAccount) != null ? mapAccountCiTotalPoids.get(keyAccount) : 0;
        Boolean hasPoidsNull =  false;
        Decimal nbMerSansCi = mapAccountsNbMerSansCi.get(keyAccount) != null ? mapAccountsNbMerSansCi.get(keyAccount) : 0;
        Integer nbCi = mapAccountCiNbOdcAttendus.get(keyAccount) != null ? mapAccountCiNbOdcAttendus.get(keyAccount).size() : 0;
        system.debug('Batch_Famine_Satisfaction *** nbMerSansCi '+nbMerSansCi);


        //Calcul du taux de satisfaction d'un compte
        for (Id keyCi : mapAccountCiNbOdcAttendus.get(keyAccount).keySet()) {
          Decimal odcCiAttendus = mapAccountCiNbOdcAttendus.get(keyAccount).get(keyCi);
          Decimal odcCiApportes = mapAccountCiOdcApportes.get(keyAccount) != null ? mapAccountCiOdcApportes.get(keyAccount).get(keyCi) : null;
          Decimal poids = mapAccountCiPoids.get(keyAccount) != null ? mapAccountCiPoids.get(keyAccount).get(keyCi) : null;
          if(odcCiApportes != null && odcCiAttendus != null && poids != null && odcCiAttendus != 0 && sumPoidsAccount != 0){
            //FORMULE DU TAUX DE SATISFACTION
            faminePourcentage = faminePourcentage + (((odcCiApportes+(nbMerSansCi/nbCi))/odcCiAttendus)*(poids/sumPoidsAccount));
            system.debug('Batch_Famine_Satisfaction *** (((odcCiApportes+(nbMerSansCi/nbCi))/odcCiAttendus)*poids) '+(((odcCiApportes+(nbMerSansCi/nbCi))/odcCiAttendus)*(poids/sumPoidsAccount)));
          }
          if(odcCiApportes != null){
            odcApportes = odcApportes + odcCiApportes ;
          }
          if(odcCiAttendus != null){
            odcAttendus = odcAttendus + odcCiAttendus ;
          }
          system.debug('Batch_Famine_Satisfaction *** keyAccount = '+keyAccount +' keyCi = '+keyCi+ ' odcCiAttendus '+odcCiAttendus);
          system.debug('Batch_Famine_Satisfaction *** keyAccount = '+keyAccount +' keyCi = '+keyCi+ ' odcCiApportes '+odcCiApportes);
          system.debug('Batch_Famine_Satisfaction *** keyAccount = '+keyAccount +' keyCi = '+keyCi+ ' poids '+poids);
          system.debug('Batch_Famine_Satisfaction *** keyCi '+keyCi);
        }
        odcApportes = odcApportes + nbMerSansCi ;
        system.debug('Batch_Famine_Satisfaction *** odcApportes '+odcApportes);
        system.debug('Batch_Famine_Satisfaction *** faminePourcentage '+faminePourcentage);
        faminePourcentage = faminePourcentage * 100;
        system.debug('Batch_Famine_Satisfaction *** faminePourcentage *100 '+faminePourcentage);
        faminePourcentage = 100 - faminePourcentage;
        system.debug('Batch_Famine_Satisfaction *** faminePourcentage 100 - '+faminePourcentage);

        if(faminePourcentage > 100){
          faminePourcentage = 100;
        }
        else if(faminePourcentage < 0){
          faminePourcentage = 0;
        }

        Account accountToUpdate = mapAccounts.get(keyAccount);     
        accountToUpdate.FaminePourcentage__c = faminePourcentage;
        accountToUpdate.FamineIndicateurChiffres__c = odcApportes + '/'+odcAttendus;
         
        // Ajout deja fait au dessus 
        //listAccountsToUpdate.add(accountToUpdate);
      }
     
      system.debug('Batch_Famine_Satisfaction *** listAccountsToUpdate '+listAccountsToUpdate);
      if(listAccountsToUpdate.size() > 0){
        update listAccountsToUpdate;

      }

    }
    public void finish(Database.BatchableContext BC){

    }

    public void execute(SchedulableContext context) { 
        Batch_Famine_Satisfaction  b = new  Batch_Famine_Satisfaction (); 
        database.executebatch(b);
    }
}