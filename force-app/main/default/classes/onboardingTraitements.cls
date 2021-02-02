/**
* @author Clement Musabimana
* @date 08/08/2019
* @description Traitements liés au processus onboarding
**/
public class onboardingTraitements {
    /**
    * @author Clement Musabimana
    * @date 08/08/2019
    * @description Permet de modifier  le champs « chargé de clientèle » automatiquement avec le binôme du nouveau BD propriétaire 
    **/
    public static void updateChargeClientele(List<String> listIdOwnerChanged,Map<Id,List<Account>> mapIdOwnerChangedAccount){
        //Le binome BD/TC referent est stocké dans la table User
        if(Test.isRunningTest() || listIdOwnerChanged.isEmpty())
            return;
        for(User usr : [Select Id, TC_ITC_Referent_Binome__c from User where Id in: listIdOwnerChanged]){
            if(mapIdOwnerChangedAccount.get(usr.Id) != null){
                for (Account acc : mapIdOwnerChangedAccount.get(usr.Id)){
                    if(usr.TC_ITC_Referent_Binome__c != null){
                        acc.TC_Referent__c = usr.TC_ITC_Referent_Binome__c;
                    }
                }
            }
        }
    }

    /**
    * @author Clement Musabimana
    * @date 08/08/2019
    * @description Permet de modifier  le champs « ownerId » automatiquement avec l'Id du TC ou du BD suite 
    **/
    public static void updateAccountRelatedObjects(List<String> listIdAccount,Map<Id,Id> mapAccountIdNewOwnerId,Map<Id,Id> mapAccountIdOldOwnerId,Map<Id,Id> mapAccountIdNewTcReferentId,Map<Id,Id> mapAccountIdOldTcReferentId){
        
        List<Task> listTaskToUpdate = new List<Task>();
        List<Case> listTCaseToUpdate = new List<Case>();
        if(!Test.isRunningTest() && !listIdAccount.isEmpty()) {

            //System.debug('updateAccountRelatedObjects* map mapAccountIdNewOwnerId '+ mapAccountIdNewOwnerId);
            //System.debug('updateAccountRelatedObjects* map mapAccountIdOldOwnerId '+ mapAccountIdOldOwnerId);
            //System.debug('updateAccountRelatedObjects* map mapAccountIdNewTcReferentId '+ mapAccountIdNewTcReferentId);
            //System.debug('updateAccountRelatedObjects* map mapAccountIdOldTcReferentId '+ mapAccountIdOldTcReferentId);
            //System.debug('updateAccountRelatedObjects* list listIdAccount '+ listIdAccount);
            //System.debug('updateAccountRelatedObjects* sizemap mapAccountIdNewOwnerId '+ mapAccountIdNewOwnerId.size());
            //System.debug('updateAccountRelatedObjects* sizemap mapAccountIdOldOwnerId '+ mapAccountIdOldOwnerId.size());

            //Recuparation des noms des taches onboarding
            String labelListeOnboardingTaches = Label.Onboarding_taches;
            Set<string> listeOnboardingTaches = new Set<string>();
            listeOnboardingTaches.addAll(labelListeOnboardingTaches.split(';'));
            //System.debug('listeOnboardingTaches ='+listeOnboardingTaches); 
            //Recuparation des noms des taches onboarding specifique au BD
            String labelListeOnboardingTachesBd = Label.onbording_taches_bd;
            Set<string> listeOnboardingTachesBd = new Set<string>();
            listeOnboardingTachesBd.addAll(labelListeOnboardingTachesBd.split(';'));
            //System.debug('listeOnboardingTachesBd ='+listeOnboardingTachesBd); 
            //Recuparation des noms des taches onboarding specifique au CC
            String labelListeOnboardingTachesCc = Label.onbording_taches_cc;
            Set<string> listeOnboardingTachesCc = new Set<string>();
            listeOnboardingTachesCc.addAll(labelListeOnboardingTachesCc.split(';'));
            //System.debug('listeOnboardingTachesCc ='+listeOnboardingTachesCc);


            //Modification des owners des activités: Dans le cas ou le proprietaire change ou le TC referent change
            //On modifie les taches en se referant au noms des taches onboarding et en se referant aux taches des BD ou des CC
            
                
            for(Task tsk : [select id,AccountId,OwnerId,Subject from Task where IsClosed = false and Subject in: listeOnboardingTaches and AccountId in: listIdAccount]){
                //System.debug('updateAccountRelatedObjects* tsk.id  '+ tsk.id);
                //System.debug('updateAccountRelatedObjects* tsk.OwnerId  '+ tsk.OwnerId);
                //System.debug('updateAccountRelatedObjects* mapAccountIdOldOwnerId.get('+tsk.AccountId+')  '+ mapAccountIdOldOwnerId.get(tsk.AccountId));
                //System.debug('updateAccountRelatedObjects* mapAccountIdNewOwnerId.get('+tsk.AccountId+')  '+ mapAccountIdNewOwnerId.get(tsk.AccountId));
                //System.debug('updateAccountRelatedObjects* mapAccountIdOldTcReferentId.get('+tsk.AccountId+')  '+ mapAccountIdOldTcReferentId.get(tsk.AccountId));
                //System.debug('updateAccountRelatedObjects* mapAccountIdNewTcReferentId.get('+tsk.AccountId+')  '+ mapAccountIdNewTcReferentId.get(tsk.AccountId));
                //System.debug('updateAccountRelatedObjects* tsk.AccountId  '+ tsk.AccountId);
                //Salesforce changement automatiquement le owner des taches correspondants à l'owner du compte si celui-ci est modifié
                //Le traiement si après est faussé donc. On a défini la liste des taches du BD et la liste des taches du CC en etiquette pour contourner le probleme
                //if(mapAccountIdOldOwnerId.get(tsk.AccountId) != null && mapAccountIdOldOwnerId.get(tsk.AccountId) == tsk.OwnerId && mapAccountIdNewOwnerId.get(tsk.AccountId) != null ){
                if(listeOnboardingTachesBd.contains(tsk.Subject) && mapAccountIdNewOwnerId.get(tsk.AccountId) != null){
                    tsk.OwnerId = mapAccountIdNewOwnerId.get(tsk.AccountId);
                    if(mapAccountIdNewOwnerId.get(tsk.AccountId) == null){
                        //System.debug('mapAccountIdNewOwnerId*  null tsk.AccountId '+ tsk.AccountId);
                    }
                    if(!listTaskToUpdate.contains(tsk)){
                        listTaskToUpdate.add(tsk);
                    }
                    //System.debug('updateAccountRelatedObjects* tsk OwnerId update '+ tsk);
                }
                //else if(mapAccountIdOldTcReferentId.get(tsk.AccountId) != null && mapAccountIdOldTcReferentId.get(tsk.AccountId) == tsk.OwnerId && mapAccountIdNewTcReferentId.get(tsk.AccountId) != null ){
                else if(listeOnboardingTachesCc.contains(tsk.Subject) && mapAccountIdNewTcReferentId.get(tsk.AccountId) != null){
                    tsk.OwnerId = mapAccountIdNewTcReferentId.get(tsk.AccountId);
                    if(mapAccountIdNewTcReferentId.get(tsk.AccountId) == null){
                        //System.debug('mapAccountIdNewTcReferentId*  null tsk.AccountId '+ tsk.AccountId);
                    }
                    if(!listTaskToUpdate.contains(tsk)){
                        listTaskToUpdate.add(tsk); 
                    }
                    //System.debug('updateAccountRelatedObjects* tsk TcReferentId update '+ tsk);
                }
            }
            
            //Modification owner requetes: Dans le cas ou le proprietaire change ou le TC referent change
            //On modifie les requetes en affectant ceux de l'ancien owner du compte au nouveau owner du compte 
            //et ceux de l'ancien TC referent au nouveau TC referent
            for(Case requete : [select id,AccountId,OwnerId from Case  where IsClosed = false and AccountId in: listIdAccount]){
                //System.debug('updateAccountRelatedObjects* requete.id  '+ requete.id);
                //System.debug('updateAccountRelatedObjects* requete.OwnerId  '+ requete.OwnerId);
                //System.debug('updateAccountRelatedObjects* mapAccountIdOldOwnerId.get(requete.AccountId)  '+ mapAccountIdOldOwnerId.get(requete.AccountId));
                //System.debug('updateAccountRelatedObjects* mapAccountIdNewOwnerId.get(requete.AccountId)  '+ mapAccountIdNewOwnerId.get(requete.AccountId));
                //System.debug('updateAccountRelatedObjects* mapAccountIdOldTcReferentId.get(requete.AccountId)  '+ mapAccountIdOldTcReferentId.get(requete.AccountId));
                //System.debug('updateAccountRelatedObjects* mapAccountIdNewTcReferentId.get(requete.AccountId)  '+ mapAccountIdNewTcReferentId.get(requete.AccountId));
                //System.debug('updateAccountRelatedObjects* requete.AccountId  '+ requete.AccountId);
                if(mapAccountIdOldOwnerId.get(requete.AccountId) != null && mapAccountIdOldOwnerId.get(requete.AccountId) == requete.OwnerId && mapAccountIdNewOwnerId.get(requete.AccountId) != null ){
                    requete.OwnerId = mapAccountIdNewOwnerId.get(requete.AccountId);
                    if(!listTCaseToUpdate.contains(requete)){
                        listTCaseToUpdate.add(requete);
                    }
                    //System.debug('updateAccountRelatedObjects* requete update '+ requete);
                }
                else if(mapAccountIdOldTcReferentId.get(requete.AccountId) != null && mapAccountIdOldTcReferentId.get(requete.AccountId) == requete.OwnerId && mapAccountIdNewTcReferentId.get(requete.AccountId) != null ){
                    requete.OwnerId = mapAccountIdNewTcReferentId.get(requete.AccountId);
                    if(!listTCaseToUpdate.contains(requete)){
                        listTCaseToUpdate.add(requete);
                    }
                    //System.debug('updateAccountRelatedObjects* requete update '+ requete);
                }
            }
        }
        if(!listTaskToUpdate.isEmpty()){
            update listTaskToUpdate;        
        }
        if(!listTCaseToUpdate.isEmpty()){
            update listTCaseToUpdate;
        }
    }

    /**
    * @author Clement Musabimana
    * @date 27/08/2019
    * @description Permet de creer les taches onboarding en fonction du type de souscription et de fermer les taches existantes de types onboarding sur le compte
    **/
    public static void createOnboardingTasks(Map<Id, Zuora__Subscription__c> oldMap, Map<Id, Zuora__Subscription__c>  newMap, List<Zuora__Subscription__c> newList){
        List<String> listIdAccount = new List<String>();
        List<Account> listAccount = new List<Account>();
        List<Account> listAccountToUpdate = new List<Account>();
        List<String> listAllEvenements = new List<String>();
        //Map qui stocke la derniere quote active ayant donné à la modification de la souscription
        Map<String,String> mapAccountLastquoteIdActive = new Map<String,String>();
        //Map qui stocke la derniere le contact principal sur une souscription
        Map<String,String> mapAccountContactPrincipalId = new Map<String,String>();
        Map<String,Date> mapAccountDateEffet = new Map<String,Date>();
        Map<String,String> mapAccountOwnerId = new Map<String,String>();
        Map<String,String> mapAccountTcReferentId = new Map<String,String>();
        //Map qui stocke la liste des operations effectuées dans la derniere quote sur un compte
        Map<String,List<String>> mapAccountListEvenement = new Map<String,List<String>>();
        List<Task> listeTasksToInsert = new List<Task>();        
        List<Task> listeTasksToClose = new List<Task>();
        //Map contenant le numero de priorité de l'evenement a traiter par compte: voir dans la table custom méta data (Onbording actions)
        Map<String,Decimal> mapAccountEvenementPrioriteATraiter = new Map<String,Decimal>();
        //On definit la liste des taches a creer par compte
        Map<String,List<Task>> mapAccountListeTasksToInsert = new Map<String,List<Task>>();
        List<String> listIdAccountAddedTask = new List<String>();
        
        //Récupération des comptes sur lesquels on doit créer les taches
        //On est en création ou modification de souscription
        for (Zuora__Subscription__c sub : newList) {
            Zuora__Subscription__c oldP = oldMap != null ? oldMap.get(sub.Id) : null;
            Zuora__Subscription__c newP = newMap != null ? newMap.get(sub.Id) : null;
            //System.debug('createOnboardingTasks* oldP '+oldP);
            //System.debug('createOnboardingTasks* newP '+ newP);
            //System.debug('createOnboardingTasks* sub.Zuora__Account__c '+ sub.Zuora__Account__c);
            //System.debug('createOnboardingTasks* sub.Zuora__CustomerAccount__c '+ sub.Zuora__CustomerAccount__c);
            if((sub.Zuora__Status__c == 'Active' && (oldP == null || sub.Zuora__Version__c != oldP.Zuora__Version__c || sub.Zuora__Status__c != oldP.Zuora__Status__c)) && (sub.Type_de_geste__c == 'Création de souscription' || sub.Type_de_geste__c == 'Modification de souscription')){
                if(!listIdAccount.contains(sub.Zuora__Account__c)){
                    listIdAccount.add(sub.Zuora__Account__c);
                    //on reinitialise l'etape de la frise onboarding: traitement fait anciennement dans  le processus Taches_ITC
                    if(Label.Tache_Stage_Onboarding_Value != null && (Label.Tache_Stage_Onboarding_Value).trim() != ''){
                        Account acc = new Account();
                        acc.Id = sub.Zuora__Account__c;
                        acc.Stage_Onboarding_Value__c = Decimal.valueOf(Label.Tache_Stage_Onboarding_Value);
                        listAccount.add(acc);
                    }
                    mapAccountContactPrincipalId.put(sub.Zuora__Account__c, sub.Contact_Principal__c);
                    //Dans le cas d'un déclenchement en massage sur le trigger, on stocke la liste des données à traiter par compte dans une map
                    mapAccountEvenementPrioriteATraiter.put(sub.Zuora__Account__c, 0);
                    List<Task> listeTasksToInsertTemp = new List<Task>();
                    mapAccountListeTasksToInsert.put(sub.Zuora__Account__c, listeTasksToInsertTemp);
                }
            }
        }
        //On recupere les types de modifications sur la quote et on  concatene (zqu__AmendmentType__c + zqu__ProductRatePlan__r.Typedeproduit__c ) comme evenement
        for (zqu__QuoteRatePlan__c zquQuoteRatePlan : [select id,zqu__Quote__r.zqu__Account__c,zqu__Quote__r.zqu__Account__r.OwnerId,zqu__Quote__r.zqu__Account__r.TC_Referent__c,zqu__Quote__c,zqu__Quote__r.CreatedDate, zqu__Quote__r.Date_de_validation__c ,Name,zqu__AmendmentType__c,zqu__ProductRatePlan__r.Typedeproduit__c,zqu__Quote__r.Effective_Amendment_Start_Date__c,zqu__QuoteProductName__c,zqu__ProductRatePlan__r.Name from zqu__QuoteRatePlan__c  where zqu__Quote__c in (select Id from zqu__Quote__c where zqu__Account__c =: listIdAccount and zqu__Status__c='Sent to Z-Billing' ) order by zqu__Quote__r.Date_de_validation__c desc,zqu__Quote__r.CreatedDate desc]) {
            if(mapAccountLastquoteIdActive.get(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c) == null){
                mapAccountLastquoteIdActive.put(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c,zquQuoteRatePlan.zqu__Quote__c);
                mapAccountDateEffet.put(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c,zquQuoteRatePlan.zqu__Quote__r.Effective_Amendment_Start_Date__c);
                List<String> listEvent = new List<String>();
                if(!listEvent.contains(zquQuoteRatePlan.zqu__AmendmentType__c+'_'+zquQuoteRatePlan.zqu__ProductRatePlan__r.Typedeproduit__c)){
                    listEvent.add(zquQuoteRatePlan.zqu__AmendmentType__c+'_'+zquQuoteRatePlan.zqu__ProductRatePlan__r.Typedeproduit__c);
                }
                mapAccountListEvenement.put(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c,listEvent);
                
                //Utiliser plus tard pour affecter l'owner ou le TC referent par compte suivant les conditions
                if(mapAccountOwnerId.get(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c) == null){
                    mapAccountOwnerId.put(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c, zquQuoteRatePlan.zqu__Quote__r.zqu__Account__r.OwnerId);
                }
                //Utiliser plus tard pour affecter l'owner ou le TC referent par compte suivant les conditions
                if(mapAccountTcReferentId.get(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c) == null){
                    mapAccountTcReferentId.put(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c, zquQuoteRatePlan.zqu__Quote__r.zqu__Account__r.TC_Referent__c);
                }
            }
            else if (mapAccountLastquoteIdActive.get(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c) == zquQuoteRatePlan.zqu__Quote__c){
                List<String> listEvent = mapAccountListEvenement.get(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c);
                if(!listEvent.contains(zquQuoteRatePlan.zqu__AmendmentType__c+'_'+zquQuoteRatePlan.zqu__ProductRatePlan__r.Typedeproduit__c)){
                    listEvent.add(zquQuoteRatePlan.zqu__AmendmentType__c+'_'+zquQuoteRatePlan.zqu__ProductRatePlan__r.Typedeproduit__c);
                }
                mapAccountListEvenement.put(zquQuoteRatePlan.zqu__Quote__r.zqu__Account__c,listEvent);
            }
        }
        //System.debug('createOnboardingTasks* mapAccountListEvenement '+ mapAccountListEvenement);
        //On reformate les evenements recupérés en creant des combinaisons d'evenement pour chaque compte: even1_event 2, event2_event1: cela permet de couvrir tout type de déclaration dans la table "Custom Méta data type":OnbordingActions__mdt pour trouver les bonnes taches a creer
        for (String key : mapAccountListEvenement.keySet()) {
            List<String> listEventFinale = new List<String>(); 
            List<String> listEvent = mapAccountListEvenement.get(key);
            for (String index1 : listEvent) {
                for (String index2 : listEvent) {
                    if(index1 != index2 && !listEventFinale.contains(index1+'_'+index2)){
                        listEventFinale.add(index1+'_'+index2);
                        if(!listAllEvenements.contains(index1+'_'+index2)){
                            listAllEvenements.add(index1+'_'+index2);
                        }
                    }
                    else if(index1 == index2 && !listEventFinale.contains(index1+'_'+index2)){
                        listEventFinale.add(index1);
                        if(!listAllEvenements.contains(index1)){
                            listAllEvenements.add(index1);
                        }
                    }
                }
            }
            if(!listEventFinale.isEmpty()){
                mapAccountListEvenement.put(key,listEventFinale);
            }
        }
        //System.debug('createOnboardingTasks* mapAccountListEvenement finale '+ mapAccountListEvenement);
        //System.debug('createOnboardingTasks* listAllEvenements finale '+ listAllEvenements);

        //TACHES A CREER
        for (OnbordingActions__mdt oba : [SELECT DeveloperName, AttributionId__c, DateDebutAppel__c, EcheanceUniquement__c, Evenement__c,Priorite__c, QualifiedApiName, Statut__c, Type__c,Objet__c,EvenementPriorite__c,Exception__c  FROM OnbordingActions__mdt  where Evenement__c in:listAllEvenements order by EvenementPriorite__c desc]) {
            for (String key : mapAccountListEvenement.keySet()) {
                //Permet de gerer un seul evement par compte si une priorite est renseigné
                // exemple New_Product_Pack avec priorité 30 vs New_Product_Standalone avec priorité 0: le New_product_Standalone sera ignoré
                if(oba.EvenementPriorite__c != null && (mapAccountListEvenement.get(key)).contains(oba.Evenement__c) && mapAccountEvenementPrioriteATraiter.get(key) != null && oba.EvenementPriorite__c > mapAccountEvenementPrioriteATraiter.get(key) ){
                    mapAccountEvenementPrioriteATraiter.put(key,oba.EvenementPriorite__c);
                    //System.debug('createOnboardingTasks* evenementPrioriteATraiter modif key '+key+' priorite '+ oba.EvenementPriorite__c);
                    List<Task> listeTasksToInsertTemp = mapAccountListeTasksToInsert.get(key);
                    listeTasksToInsertTemp.clear();
                    mapAccountListeTasksToInsert.put(key,listeTasksToInsertTemp);
                }
                //System.debug('createOnboardingTasks* oba.EvenementPriorite__c modif key '+key +' event '+ oba.EvenementPriorite__c);
                //System.debug('createOnboardingTasks* oba.Exception__c modif key '+key +' event '+ oba.Exception__c);
                //System.debug('createOnboardingTasks* mapAccountEvenementPrioriteATraiter modif key '+key+' priorite '+ mapAccountEvenementPrioriteATraiter.get(key));
                if(oba.EvenementPriorite__c == null || (mapAccountEvenementPrioriteATraiter.get(key) != null && oba.EvenementPriorite__c == mapAccountEvenementPrioriteATraiter.get(key) && oba.Exception__c != 'NOT_EXECUTE')){
                    if(mapAccountListEvenement.get(key) != null && (mapAccountListEvenement.get(key)).contains(oba.Evenement__c)){
                        //System.debug('createOnboardingTasks oba: '+oba);
                        Task tsk = new Task();
                        tsk.ActivityDate = mapAccountDateEffet.get(key)+Integer.valueof(oba.EcheanceUniquement__c);
                        if(mapAccountOwnerId.get(key) != null){
                            tsk.OwnerId = mapAccountOwnerId.get(key);
                        }
                        if(oba.AttributionId__c == 'tc'){
                        //    tsk.OdigoCti__Call_start_time__c = mapAccountDateEffet.get(key)+Integer.valueof(oba.DateDebutAppel__c);
                            if(mapAccountTcReferentId.get(key) != null){
                                tsk.OwnerId = mapAccountTcReferentId.get(key);
                            }
                        }
                        tsk.Priority = oba.Priorite__c; 
                        tsk.Status = oba.Statut__c;
                        tsk.Subject = oba.Objet__c;
                        tsk.Type = oba.Type__c;
                        tsk.WhatId = key;
                        tsk.WhoId = mapAccountContactPrincipalId.get(key);
                        //Si pas de priorite indiqué sur l'evenement on la sauvegardera
                        if(oba.EvenementPriorite__c == null){
                            listeTasksToInsert.add(tsk);
                            listIdAccountAddedTask.add(key);
                            //System.debug('createOnboardingTasks oba.EvenementPriorite__c == null '+key+' listIdAccountAddedTask: '+listIdAccountAddedTask);
                        }
                        //Si priorité indiqué, on met la tache dans une liste temporaire qui sera vidée si on tombe sur un evement avec une priorité plus grande
                        //Cela permet de ne garder que les taches de l'evenement avec la priorité plus grande
                        else {
                            if(mapAccountListeTasksToInsert.get(key) != null){
                                List<Task> listeTasksToInsertTemp = mapAccountListeTasksToInsert.get(key);
                                listeTasksToInsertTemp.add(tsk);
                                mapAccountListeTasksToInsert.put(key,listeTasksToInsertTemp);
                                //System.debug('createOnboardingTasks oba.EvenementPriorite__c == null '+key+' listeTasksToInsertTemp: '+listeTasksToInsertTemp);
                            }
                        }
                        //System.debug('createOnboardingTasks listeTasksToInsert: '+listeTasksToInsert);
                    }
                }
            }
        }
        //System.debug('createOnboardingTasks mapAccountListeTasksToInsert: '+mapAccountListeTasksToInsert);
        for (String key : mapAccountListeTasksToInsert.keySet()) {
            if(!(mapAccountListeTasksToInsert.get(key)).isEmpty()){
                listeTasksToInsert.addAll(mapAccountListeTasksToInsert.get(key));
                listIdAccountAddedTask.add(key);
                //System.debug('createOnboardingTasks oba.EvenementPriorite__c key '+key+' listIdAccountAddedTask: '+listIdAccountAddedTask);
            }
        }

        

        //TACHES A FERMER
        String labelListeOnboardingTaches = Label.Onboarding_taches;
        Set<string> listeOnboardingTaches = new Set<string>();
        listeOnboardingTaches.addAll(labelListeOnboardingTaches.split(';'));
        //System.debug('createOnboardingTasks listeOnboardingTaches ='+listeOnboardingTaches); 

        //On ne cherche les taches a fermer que si on a des taches à inserer
        if(!listeTasksToInsert.isEmpty()){
            //Modification owner activités: Dans le cas ou le proprietaire change ou le TC referent change
            for(Task tsk : [select id,AccountId,OwnerId,Subject from Task where IsClosed = false and Subject in: listeOnboardingTaches and AccountId in: listIdAccountAddedTask]){
                //System.debug('createOnboardingTasks* tsk.id  '+ tsk.id);
                //System.debug('createOnboardingTasks* tsk.AccountId  '+ tsk.AccountId);
                if(!listeTasksToClose.contains(tsk)){
                    tsk.Status = Label.Tache_statut_ferme;
                    listeTasksToClose.add(tsk); 
                }
            }           
        }

        for(Account acc: listAccount){
            if(listIdAccountAddedTask.contains(String.valueof(acc.Id))){
                if(mapAccountEvenementPrioriteATraiter.get(acc.Id) != null){
                    acc.Perimetre_Onboarding_Value__c = mapAccountEvenementPrioriteATraiter.get(acc.Id);
                }
                listAccountToUpdate.add(acc);
            }
        }

        //System.debug('listeTasksToClose: '+listeTasksToClose);
        if(!listeTasksToClose.isEmpty()){
            update listeTasksToClose;
        }

        //System.debug('listeTasksToInsert: '+listeTasksToInsert);
        if(!listeTasksToInsert.isEmpty()){
            insert listeTasksToInsert;
        }
        if(!listAccountToUpdate.isEmpty()){
            update listAccountToUpdate;
        }
    }

    /**
    * @author Clement Musabimana
    * @date 09/12/2019
    * @description Permet de creer les taches onboarding en fonction du statut du compte pour les nouvelles offres
    **/
    //public static void createOnboardingTasksNouvelleOffre(List<String> listAllEvenements,Map<String,List<String>> mapAccountListEvenement,Map<String,String> mapAccountContactPrincipalId,Map<String,Date> mapAccountDateEffet,Map<String,String> mapAccountOwnerId,Map<String,Decimal> mapAccountEvenementPrioriteATraiter,Map<String,List<Task>> mapAccountListeTasksToInsert){
    @Future
    public static void createOnboardingTasksNouvelleOffre(String listAllEvenementsJsonstring,String mapAccountListEvenementJsonstring,String mapAccountContactPrincipalIdJsonstring,String mapAccountDateEffetJsonstring,String mapAccountOwnerIdJsonstring,String mapAccountEvenementPrioriteATraiterJsonstring,String mapAccountListeTasksToInsertJsonstring){
        
        List<String> listAllEvenements = (List<String> ) JSON.deserialize(listAllEvenementsJsonstring, List<String>.class);
        Map<String,List<String>> mapAccountListEvenement = (Map<String,List<String>>) JSON.deserialize(mapAccountListEvenementJsonstring, Map<String,List<String>>.class);
        Map<String,String> mapAccountContactPrincipalId = (Map<String,String>) JSON.deserialize(mapAccountContactPrincipalIdJsonstring, Map<String,String>.class);
        Map<String,Date> mapAccountDateEffet = (Map<String,Date>) JSON.deserialize(mapAccountDateEffetJsonstring, Map<String,Date>.class);
        Map<String,String> mapAccountOwnerId = (Map<String,String>) JSON.deserialize(mapAccountOwnerIdJsonstring, Map<String,String>.class);
        Map<String,Decimal> mapAccountEvenementPrioriteATraiter = (Map<String,Decimal>) JSON.deserialize(mapAccountEvenementPrioriteATraiterJsonstring, Map<String,Decimal>.class);
        Map<String,List<Task>> mapAccountListeTasksToInsert = (Map<String,List<Task>>) JSON.deserialize(mapAccountListeTasksToInsertJsonstring, Map<String,List<Task>>.class);

        //Map qui stocke la derniere quote active ayant donné à la modification de la souscription
        Map<String,String> mapAccountLastquoteIdActive = new Map<String,String>();
        Map<String,String> mapAccountTcReferentId = new Map<String,String>();
        List<Task> listeTasksToInsert = new List<Task>();        
        List<Task> listeTasksToClose = new List<Task>();
        List<String> listIdAccountAddedTask = new List<String>();
        Set<string> listeOnboardingTaches = new Set<string>();

        //System.debug('createOnboardingTasks* mapAccountListEvenement finale '+ mapAccountListEvenement);
        //System.debug('createOnboardingTasks* listAllEvenements finale '+ listAllEvenements);

        //TACHES A CREER
        for (OnbordingActions__mdt oba : [SELECT DeveloperName, AttributionId__c, DateDebutAppel__c, EcheanceUniquement__c, Evenement__c,Priorite__c, QualifiedApiName, Statut__c, Type__c,Objet__c,EvenementPriorite__c,Exception__c  FROM OnbordingActions__mdt  where Evenement__c in:listAllEvenements order by EvenementPriorite__c desc]) {
            if(!listeOnboardingTaches.contains(oba.Objet__c)){
                for (String key : mapAccountListEvenement.keySet()) {
                    //Permet de gerer un seul evement par compte si une priorite est renseigné
                    // exemple New_Product_Pack avec priorité 30 vs New_Product_Standalone avec priorité 0: le New_product_Standalone sera ignoré
                    if(oba.EvenementPriorite__c != null && (mapAccountListEvenement.get(key)).contains(oba.Evenement__c) && mapAccountEvenementPrioriteATraiter.get(key) != null && oba.EvenementPriorite__c > mapAccountEvenementPrioriteATraiter.get(key) ){
                        mapAccountEvenementPrioriteATraiter.put(key,oba.EvenementPriorite__c);
                        //System.debug('createOnboardingTasks* evenementPrioriteATraiter modif key '+key+' priorite '+ oba.EvenementPriorite__c);
                        List<Task> listeTasksToInsertTemp = mapAccountListeTasksToInsert.get(key);
                        listeTasksToInsertTemp.clear();
                        mapAccountListeTasksToInsert.put(key,listeTasksToInsertTemp);
                    }
                    //System.debug('createOnboardingTasks* oba.EvenementPriorite__c modif key '+key +' event '+ oba.EvenementPriorite__c);
                    //System.debug('createOnboardingTasks* oba.Exception__c modif key '+key +' event '+ oba.Exception__c);
                    //System.debug('createOnboardingTasks* mapAccountEvenementPrioriteATraiter modif key '+key+' priorite '+ mapAccountEvenementPrioriteATraiter.get(key));
                    if(oba.EvenementPriorite__c == null || (mapAccountEvenementPrioriteATraiter.get(key) != null && oba.EvenementPriorite__c == mapAccountEvenementPrioriteATraiter.get(key) && oba.Exception__c != 'NOT_EXECUTE')){
                        if(mapAccountListEvenement.get(key) != null && (mapAccountListEvenement.get(key)).contains(oba.Evenement__c)){
                            //System.debug('createOnboardingTasks oba: '+oba);
                            Task tsk = new Task();
                            tsk.ActivityDate = mapAccountDateEffet.get(key)+Integer.valueof(oba.EcheanceUniquement__c);
                            if(mapAccountOwnerId.get(key) != null){
                                tsk.OwnerId = mapAccountOwnerId.get(key);
                            }
                            if(oba.AttributionId__c == 'tc'){
                                //tsk.OdigoCti__Call_start_time__c = mapAccountDateEffet.get(key)+Integer.valueof(oba.DateDebutAppel__c);
                                if(mapAccountTcReferentId.get(key) != null){
                                    tsk.OwnerId = mapAccountTcReferentId.get(key);
                                }
                            }
                            tsk.Priority = oba.Priorite__c; 
                            tsk.Status = oba.Statut__c;
                            tsk.Subject = oba.Objet__c;
                            tsk.Type = oba.Type__c;
                            tsk.WhatId = key;
                            tsk.WhoId = mapAccountContactPrincipalId.get(key);
                            //Si pas de priorite indiqué sur l'evenement on la sauvegardera
                            if(oba.EvenementPriorite__c == null){
                                listeTasksToInsert.add(tsk);
                                listIdAccountAddedTask.add(key);
                                //System.debug('createOnboardingTasks oba.EvenementPriorite__c == null '+key+' listIdAccountAddedTask: '+listIdAccountAddedTask);
                            }
                            //Si priorité indiqué, on met la tache dans une liste temporaire qui sera vidée si on tombe sur un evement avec une priorité plus grande
                            //Cela permet de ne garder que les taches de l'evenement avec la priorité plus grande
                            else {
                                if(mapAccountListeTasksToInsert.get(key) != null){
                                    List<Task> listeTasksToInsertTemp = mapAccountListeTasksToInsert.get(key);
                                    listeTasksToInsertTemp.add(tsk);
                                    mapAccountListeTasksToInsert.put(key,listeTasksToInsertTemp);
                                    //System.debug('createOnboardingTasks oba.EvenementPriorite__c == null '+key+' listeTasksToInsertTemp: '+listeTasksToInsertTemp);
                                }
                            }
                            listeOnboardingTaches.add(oba.Objet__c);
                            //System.debug('createOnboardingTasks listeTasksToInsert: '+listeTasksToInsert);
                        }
                    }
                }
            }
        }
        //System.debug('createOnboardingTasks mapAccountListeTasksToInsert: '+mapAccountListeTasksToInsert);
        for (String key : mapAccountListeTasksToInsert.keySet()) {
            if(!(mapAccountListeTasksToInsert.get(key)).isEmpty()){
                listeTasksToInsert.addAll(mapAccountListeTasksToInsert.get(key));
                listIdAccountAddedTask.add(key);
                //System.debug('createOnboardingTasks oba.EvenementPriorite__c key '+key+' listIdAccountAddedTask: '+listIdAccountAddedTask);
            }
        }

        

        //TACHES A FERMER
        //System.debug('createOnboardingTasks listeOnboardingTaches ='+listeOnboardingTaches); 

        //On ne cherche les taches a fermer que si on a des taches à inserer
        if(!listeTasksToInsert.isEmpty()){
            //Modification owner activités: Dans le cas ou le proprietaire change ou le TC referent change
            for(Task tsk : [select id,AccountId,OwnerId,Subject from Task where IsClosed = false and Subject in: listeOnboardingTaches and AccountId in: listIdAccountAddedTask FOR UPDATE]){
                //System.debug('createOnboardingTasks* tsk.id  '+ tsk.id);
                //System.debug('createOnboardingTasks* tsk.AccountId  '+ tsk.AccountId);
                if(!listeTasksToClose.contains(tsk)){
                    tsk.Status = Label.Tache_statut_ferme;
                    listeTasksToClose.add(tsk); 
                }
            }           
        }

        System.debug('###Failed  listeTasksToClose: '+listeTasksToClose);
        if(!listeTasksToClose.isEmpty()){
            //update listeTasksToClose;
            DataBase.SaveResult[] updateResults = DataBase.update(listeTasksToClose, false);
            System.debug('###Failed  updateResults: '+updateResults);
            for(DataBase.SaveResult res : updateResults) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {            
                        System.debug('###Failed '+err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('###Failed ' + err.getFields());
                    }
                }
            }
        }
        System.debug('###Failed  listeTasksToInsert: '+listeTasksToInsert);
        //System.debug('listeTasksToInsert: '+listeTasksToInsert);
        if(!listeTasksToInsert.isEmpty()){
            //insert listeTasksToInsert;
            DataBase.SaveResult[] insertResults = DataBase.insert(listeTasksToInsert, false);
            System.debug('###Failed  insertResults: '+insertResults);
            for(DataBase.SaveResult res : insertResults) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {            
                        System.debug('###Failed '+err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('###Failed ' + err.getFields());
                    }
                }
            }
        }
    }
     
}