/**
* @author Clement Musabimana
* @date 23/01/2020
* @description point d'entrée des méthodes appelés par le triiger du compte
**/

public class AccountTriggerDispatcher {

	/**
	* @author Clement Musabimana
	* @date 23/01/2020
	* @description point d'entrée des méthodes appelés par le trigger after update du compte
	**/
    public static void accountTriggerAfterUpdate(Map<Id, Account> oldMap, Map<Id, Account>  newMap, List<Account> newList){
    /*
    @Future
    public static void accountTriggerAfterUpdate(String oldMapJsonstring, String newMapJsonstring, String newListJsonstring){

        Map<Id,account> oldMap = (Map<Id, account>) JSON.deserialize(oldMapJsonstring, Map<Id, account>.class);
        Map<Id,account> newMap = (Map<Id, account>) JSON.deserialize(newMapJsonstring, Map<Id, account>.class);
        List<Account> newList = (List<Account>) JSON.deserialize(newListJsonstring, List<Account>.class);*/
    	////[1]TRAITEMENT si le Name du compte change
    	//after update trigger added 16/12/2016 by Qiuyan Liu
		// for sychronisation with Bus when Account Name(Raison Sociale) changed
		List<Id> accIdList = new List<Id>();

    	////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateAccountRelatedObjects
    	List<String> listIdAccount = new List<String>();
        //Map des nouveaux owners par compte
    	Map<Id,Id> mapAccountIdNewOwnerId = new Map<Id,Id>();
        //Map des anciens owners par compte
    	Map<Id,Id> mapAccountIdOldOwnerId = new Map<Id,Id>();
        //Map des nouveaux Tc referents par compte
    	Map<Id,Id> mapAccountIdNewTcReferentId = new Map<Id,Id>();
        //Map des anciens Tc referents par compte
    	Map<Id,Id> mapAccountIdOldTcReferentId = new Map<Id,Id>();
    	Integer ii = 0;
    	Integer jj = 0;

    	////[3]TRAITEMENT POUR  la methode onboardingTraitements.createOnboardingTasksNouvelleOffre
        List<String> listAllEvenements = new List<String>();
        //Map qui stocke la derniere le contact principal sur une souscription
        Map<String,String> mapAccountContactPrincipalId = new Map<String,String>();
        Map<String,Date> mapAccountDateEffet = new Map<String,Date>();
        Map<String,String> mapAccountOwnerId = new Map<String,String>();
        //Map qui stocke la liste des operations effectuées dans la derniere quote sur un compte
        Map<String,List<String>> mapAccountListEvenement = new Map<String,List<String>>();
        //Map contenant le numero de priorité de l'evenement a traiter par compte: voir dans la table custom méta data (Onbording actions)
        Map<String,Decimal> mapAccountEvenementPrioriteATraiter = new Map<String,Decimal>();
        //On definit la liste des taches a creer par compte
        Map<String,List<Task>> mapAccountListeTasksToInsert = new Map<String,List<Task>>();
        String compteOnbordingStepValue = Label.Compte_Onbording_Step_Value;
        String compteOnbordingEventValue = Label.Compte_Onbording_Event_Value;

        ////[4]TRAITEMENT MailAccountTrigger
        Set<Id> Ids = new Set<Id>();
        Map<String,Account> mapAccountParticulier = new Map<String,Account>();
        Map<String,Boolean> mapAccountHasSouscription = new Map<String,Boolean>();
        Map<String,Boolean> mapAccountHasSouscriptionActive = new Map<String,Boolean>();
        Map<String,Boolean> mapAccountHasSouscriptionPack = new Map<String,Boolean>();


        ////[5]TRAITEMENT Pour setter l'etat du compte avant le passage au nouvelles offres
        Set<Id> IdsOldSatate = new Set<Id>();

        Integer size = newList.size(); 
    	//for (Account acc : newList) {
        for(Integer i = 0; i < size; ++i){ 
            Account acc = newList[i];
            Account oldP = oldMap != null ? oldMap.get(acc.Id) : null;
            Account newP = newMap != null ? newMap.get(acc.Id) : null;
            //System.debug('accountTriggerAfterUpdate* oldP '+oldP);
            //System.debug('accountTriggerAfterUpdate* newP '+ newP);

	    	////[1]TRAITEMENT si le Name du compte change
	    	//after update trigger added 16/12/2016 by Qiuyan Liu
			// for sychronisation with Bus when Account Name(Raison Sociale) changed
			if (oldP.Name != newP.Name) {
				accIdList.add(acc.Id);
			}
            ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateAccountRelatedObjects
            if(acc != null && oldP !=null && acc.OwnerId != null && acc.OwnerId != oldP.OwnerId){
            	mapAccountIdNewOwnerId.put(acc.Id,acc.OwnerId);
            	mapAccountIdOldOwnerId.put(acc.Id,oldP.OwnerId);
            	ii = ii +1;
            	if(!listIdAccount.contains(acc.Id)){
            		listIdAccount.add(acc.Id);
            	}
            }
            if(acc != null && oldP !=null && acc.TC_Referent__c != null && acc.TC_Referent__c != oldP.TC_Referent__c){
            	mapAccountIdNewTcReferentId.put(acc.Id,acc.TC_Referent__c);
            	mapAccountIdOldTcReferentId.put(acc.Id,oldP.TC_Referent__c);
            	jj = jj +1;
            	if(!listIdAccount.contains(acc.Id)){
            		listIdAccount.add(acc.Id);
            	}
            }

            ////[3]TRAITEMENT POUR  la methode onboardingTraitements.createOnboardingTasksNouvelleOffre
            if((oldP != null  && acc.Statut_activation__c != oldP.Statut_activation__c && compteOnbordingStepValue == acc.Statut_activation__c && acc.IsPersonAccount == false) 
               || (oldP == null  && compteOnbordingStepValue == acc.Statut_activation__c && acc.IsPersonAccount == false)){
                mapAccountContactPrincipalId.put(acc.Id, acc.Contact_Principal__c);
                //Dans le cas d'un déclenchement en massage sur le trigger, on stocke la liste des données à traiter par compte dans une map
                mapAccountEvenementPrioriteATraiter.put(acc.Id, 0);
                List<Task> listeTasksToInsertTemp = new List<Task>();
                mapAccountListeTasksToInsert.put(acc.Id, listeTasksToInsertTemp);
                Date dateEffet = null;
                if(acc.Date_nouveau_client__c != null){ 
                    dateEffet = acc.Date_nouveau_client__c.Date();
                }
                else{
                   dateEffet = Date.today();
                }
                mapAccountDateEffet.put(acc.Id,dateEffet);

                List<String> listEvent = new List<String>();
                if(!listEvent.contains(compteOnbordingEventValue)){
                    listEvent.add(compteOnbordingEventValue);
                    mapAccountListEvenement.put(acc.Id,listEvent);
                    listAllEvenements.add(compteOnbordingEventValue);
                }
                
                //Utiliser plus tard pour affecter l'owner ou le TC referent par compte suivant les conditions
                if(mapAccountOwnerId.get(acc.Id) == null){
                    mapAccountOwnerId.put(acc.Id, acc.OwnerId);
                }

                ////[5]TRAITEMENT Pour setter l'etat du compte avant le passage au nouvelles offres
                /*IdsOldSatate.add(acc.Id);
                mapAccountHasSouscription.put(acc.Id,false);
                mapAccountHasSouscriptionActive.put(acc.Id,false);
                mapAccountHasSouscriptionPack.put(acc.Id,false);*/

            }
            //fonction permettant de recuprer un token d'activation de mail pour les nouvelles offres
            if( (Label.UtiliserPartnerShipPourLesProPilote == 'PartnerShip'  || (acc.Pro_Pilote__c == false && acc.Nat_To_Sync__c == false) )
                && ( (oldP != null  && acc.Statut_activation__c != oldP.Statut_activation__c && acc.Statut_activation__c == compteOnbordingStepValue && acc.Login__c != null && acc.Compte_Nouvelles_Offres__c == true) 
                     || (oldP == null  && compteOnbordingStepValue == acc.Statut_activation__c && acc.Login__c != null && acc.Compte_Nouvelles_Offres__c == true) 
                     || (oldP != null && oldP.Login__c == null && acc.Login__c != null  && compteOnbordingStepValue == acc.Statut_activation__c && acc.Compte_Nouvelles_Offres__c == true)
                ) ) {
                AccountMethods.callProjectPlaceActivationToken(acc.Login__c,acc.Id);
            }

            ////[4]TRAITEMENT MailAccountTrigger
            Account oldAcc = oldP;
            mapAccountParticulier.put(acc.Id,acc);
            
            if (oldAcc.PersonEmail != acc.PersonEmail)
                Ids.add(acc.Id); 
            
            if (oldAcc.PersonMobilePhone != acc.PersonMobilePhone)
                Ids.add(acc.Id); 
            
            if (oldAcc.Login__c != acc.Login__c)
                Ids.add(acc.Id);  

        }
        ////[1]TRAITEMENT si le Name du compte change
    	//after update trigger added 16/12/2016 by Qiuyan Liu
		// for sychronisation with Bus when Account Name(Raison Sociale) changed
       	//System.debug('accIdList.size() ' + accIdList.size());
		//System.debug('accIdList ' + accIdList);
		if (accIdList.size() > 0) {
			Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE (Contact_Principal_O_N__c = true OR Contact_de_facturation__c = true) AND  AccountId in:accIdList]);
			//System.debug('conMap.keyset() ' + conMap.keyset());
			BUSWSHandler.wsContactUpdateHandler(new List<Id>(conMap.keyset()));
		}
		////[3]TRAITEMENT POUR  la methode onboardingTraitements.createOnboardingTasksNouvelleOffre
        if(!listAllEvenements.isEmpty()){

            String listAllEvenementsJsonstring = JSON.serialize(listAllEvenements); 
            String mapAccountListEvenementJsonstring = JSON.serialize(mapAccountListEvenement); 
            String mapAccountContactPrincipalIdJsonstring = JSON.serialize(mapAccountContactPrincipalId); 
            String mapAccountDateEffetJsonstring = JSON.serialize(mapAccountDateEffet); 
            String mapAccountOwnerIdJsonstring = JSON.serialize(mapAccountOwnerId); 
            String mapAccountEvenementPrioriteATraiterJsonstring = JSON.serialize(mapAccountEvenementPrioriteATraiter); 
            String mapAccountListeTasksToInsertJsonstring = JSON.serialize(mapAccountListeTasksToInsert);
            //AccountTriggerDispatcher.accountTriggerAfterUpdate(oldMapJsonstring, newMapJsonstring, newListJsonstring);
        	onboardingTraitements.createOnboardingTasksNouvelleOffre(listAllEvenementsJsonstring,mapAccountListEvenementJsonstring,mapAccountContactPrincipalIdJsonstring,mapAccountDateEffetJsonstring,mapAccountOwnerIdJsonstring,mapAccountEvenementPrioriteATraiterJsonstring,mapAccountListeTasksToInsertJsonstring);
            //onboardingTraitements.createOnboardingTasksNouvelleOffre(listAllEvenements,mapAccountListEvenement,mapAccountContactPrincipalId,mapAccountDateEffet,mapAccountOwnerId,mapAccountEvenementPrioriteATraiter,mapAccountListeTasksToInsert);

        }
        ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateAccountRelatedObjects
        if(!listIdAccount.isEmpty()){
        	onboardingTraitements.updateAccountRelatedObjects(listIdAccount,mapAccountIdNewOwnerId,mapAccountIdOldOwnerId,mapAccountIdNewTcReferentId,mapAccountIdOldTcReferentId);
        }
        if(Ids.size()>0){
    
            List<Projet__c> child = (Ids.size()>0 ? [SELECT Id, Particulier__c, email_projet__c,Telephone_Mobile__c from projet__c where Particulier__c in :Ids] : new List<Projet__c>());
            List<Projet__c> newchild = new List<Projet__c>();
            Boolean add = false;

            for (Projet__c projet: child)
            {
                Account acc2 = mapAccountParticulier.get(projet.Particulier__c);  
                add=false;
                if (acc2 != null && projet.Particulier__c == acc2.Id && projet.email_projet__c != acc2.PersonEmail)  { 
                    projet.email_projet__c = acc2.PersonEmail;    
                    add=true;
                }  
                if (acc2 != null && projet.Particulier__c == acc2.Id && projet.Telephone_Mobile__c != acc2.PersonMobilePhone) { 
                    projet.Telephone_Mobile__c = acc2.PersonMobilePhone;   
                    add = true;
                }
                if(add) {
                    newchild.add(projet);
                }
            }
            
            if (newchild.isEmpty() == false) {
                update newchild;
                
            }
            
            
            List<Zuora__Refund__c> childR = (Ids.size()>0 ? [SELECT Id, Zuora__Account__c, Login_du_contact_principal__c from Zuora__Refund__c where Zuora__Account__c in :Ids] : new List<Zuora__Refund__c>());
            
            List<Zuora__Refund__c> newchildR = new List<Zuora__Refund__c>();
            
            for (Zuora__Refund__c refund: childR)
            {
                Account acc3 = mapAccountParticulier.get(refund.Zuora__Account__c); 
                if (acc3 != null && refund.Zuora__Account__c == acc3.Id && refund.Login_du_contact_principal__c != acc3.Login__c)
                {
                    refund.Login_du_contact_principal__c = acc3.Login__c;
                    newchildR.add(refund);
                }
            }
            
            if (newchildR.isEmpty() == false)
                update newchildR;
            
            List<Zuora__PaymentMethod__c> childPayment = (Ids.size()>0 ? [SELECT Id, Zuora__BillingAccount__r.Zuora__Account__c, Email_du_contact_principal__c from Zuora__PaymentMethod__c where Zuora__BillingAccount__r.Zuora__Account__c in :Ids] : new List<Zuora__PaymentMethod__c>());
            
            List<Zuora__PaymentMethod__c> newchildPayment = new List<Zuora__PaymentMethod__c>();
            
            for (Zuora__PaymentMethod__c payment: childPayment)
            {
                Account acc4 = mapAccountParticulier.get(payment.Zuora__BillingAccount__r.Zuora__Account__c); 
                if (acc4 != null && payment.Zuora__BillingAccount__r.Zuora__Account__c == acc4.Id && payment.Email_du_contact_principal__c != acc4.Login__c)
                {
                    payment.Email_du_contact_principal__c = acc4.Login__c;
                    newchildPayment.add(payment);
                }
            }
            
            if (newchildPayment.isEmpty() == false)
                update newchildPayment;
            
            List<Zuora__CustomerAccount__c> childBA = (Ids.size()>0 ? [SELECT Id, Zuora__Account__c, Email_du_contact_principal__c from Zuora__CustomerAccount__c where Zuora__Account__c in :Ids] : new List<Zuora__CustomerAccount__c>());
            
            List<Zuora__CustomerAccount__c> newchildBA = new List<Zuora__CustomerAccount__c>();
            
            for (Zuora__CustomerAccount__c BA: childBA)
            {
                Account acc5 = mapAccountParticulier.get(BA.Zuora__Account__c); 
                if (acc5 != null && BA.Zuora__Account__c == acc5.Id && BA.Email_du_contact_principal__c != acc5.Login__c)
                {
                    BA.Email_du_contact_principal__c = acc5.Login__c;
                    newchildBA.add(BA);
                }
            }
            
            if (newchildBA.isEmpty() == false)
                update newchildBA;
       
        }

    }
    /**
    * @author Clement Musabimana
    * @date 23/01/2020
    * @description point d'entrée des méthodes appelés par le trigger before insert du compte
    **/
    public static void accountTriggerBeforeInsert(Map<Id, Account> oldMap, Map<Id, Account>  newMap, List<Account> newList){
		ID PaysFR = Label.ID_France;
	    ID serviceWeb = Label.ID_Service_Web;

    	////[1]TRAITEMENT 
	    List<Account> creaManuelle = new List<Account>();
	    List<Account> creaNonManuelle = new List<Account>();
	    List<Account> createCodeClient = new List<Account>();
	    List<Account> updateNomEnseignes = new List<Account>();
	    List<Account> updateCodeEnseignes = new List<Account>();
	    List<Account> updateMailAssurances = new List<Account>();

        ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateChargeClientele
        List<String> listIdOwnerChanged = new List<String>();
        Map<Id,List<Account>> mapIdOwnerChangedAccount = new Map<Id,List<Account>>();


        Integer size = newList.size(); 
        //for (Account acc : newList) {
        for(Integer i = 0; i < size; ++i){ 
            Account acc = newList[i];
            Account oldP = oldMap != null ? oldMap.get(acc.Id) : null;
            Account newP = newMap != null ? newMap.get(acc.Id) : null;
            //System.debug('accountTriggerBeforeInsert* oldP '+oldP);
            //System.debug('accountTriggerBeforeInsert* newP '+ newP);


            ////[1]TRAITEMENT 
			if (acc.IsPersonAccount || acc.RecordType.IsPersonType) {
				acc.Login__c = acc.PersonEmail;
			}
            if (!acc.isPersonAccount && acc.Pays_LKP__c == PaysFR && acc.SIRET_texte__c != null && AccountMethods.checkSIRET(acc.SIRET_texte__c) == false) 
                acc.addError('Le SIRET n\'est pas valide.');
            else
            {
                /*
                for (Reference__c ref : lRef)
                {
                    if (acc.Code_NAF_texte__c != null && acc.Code_NAF_texte__c.equals(ref.Name))
                        acc.Code_NAF_APE_societe_declarante__c = ref.Id;
                    if (acc.Code_postal_texte__c != null && acc.Code_postal_texte__c.equals(ref.Name))
                        acc.Code_postal__c = ref.Id;
                }
                */
            }
            if (acc.IsConvertedLead__c || acc.CreatedById == serviceWeb) { creaNonManuelle.add(acc); }
            else { creaManuelle.add(acc); }
            if (acc.Liste_des_enseignes_de_gestion_o_il_est__c != null) { updateNomEnseignes.add(acc); }
            if (!acc.isPersonAccount) {createCodeClient.add(acc);}




            ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateChargeClientele
            //Si owner est modifié et si le tc referent n'est pas modifié
            if(acc != null && oldP !=null && acc.OwnerId != null && acc.OwnerId != oldP.OwnerId && acc.TC_Referent__c == oldP.TC_Referent__c ){
                //System.debug('updateChargeClientele* TC_Referent__c OKK ');
                if(!listIdOwnerChanged.contains(acc.OwnerId)){
                    listIdOwnerChanged.add(acc.OwnerId);
                }
                if(mapIdOwnerChangedAccount.get(acc.OwnerId) == null){
                    List<Account> listAccount = new List<Account>();
                    listAccount.add(acc);
                    mapIdOwnerChangedAccount.put(acc.OwnerId,listAccount);
                }
                else{
                    List<Account> listAccount = mapIdOwnerChangedAccount.get(acc.OwnerId);
                    listAccount.add(acc);
                    mapIdOwnerChangedAccount.put(acc.OwnerId,listAccount);
                }
                //par défaut on met le CC égale au owner: cas ou le binome n'existerait pas. sinon le champ sera modifié par le binome par la suite
                acc.TC_Referent__c = acc.OwnerId;
            }
        }
        ////[1]TRAITEMENT 
        if (createCodeClient.size()>0){
            if (!Test.isRunningTest()){
            Technical_Values__c TV = [SELECT Name, Code_client__c FROM Technical_Values__c WHERE Name = 'Technical values' LIMIT 1];
            //if (Test.isRunningTest()){TV.Code_client__c = 'XZZZZ'; update TV;}
            TV.Code_client__c = AccountMethods.generateCodeClient(createCodeClient, TV.Code_client__c);
            update TV;
            }
            else{ AccountMethods.generateCodeClient(createCodeClient, 'TZZZZ'); }
        }
        ////[1]TRAITEMENT 
        if (updateNomEnseignes.size()>0){
        	//@CMU:23/08/2019: lEnseignes: pour eviter les DML EXception (execution a chaque trigger) on fait la requete dans cette condition
        	List<Reference__c> lEnseignes = [SELECT id, Name, key__c FROM Reference__c WHERE RecordType.DeveloperName = 'Enseigne'];
        	AccountMethods.setListeEnseignes(updateNomEnseignes, true, lEnseignes);
        }
        ////[1]TRAITEMENT 
        if (creaManuelle.size()>0){
        	//@CMU:23/08/2019: lEnseignes: pour eviter les DML EXception (execution a chaque trigger) on fait la requete dans cette condition
        	User currentUser = [SELECT id, Name, Title, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        	AccountMethods.setUserInfoBySGI(creaManuelle, null, true, currentUser);
        }
        ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateChargeClientele
        if(!listIdOwnerChanged.isEmpty()){
            onboardingTraitements.updateChargeClientele(listIdOwnerChanged,mapIdOwnerChangedAccount);
        }

    }
    /**
    * @author Clement Musabimana
    * @date 23/01/2020
    * @description point d'entrée des méthodes appelés par le trigger before insert du compte
    **/
    public static void accountTriggerAfterInsert(Map<Id, Account> oldMap, Map<Id, Account>  newMap, List<Account> newList){
		
        //@CMU:23/08/2019: lEnseignes: pour eviter les DML EXception (execution a chaque trigger) on fait la requete dans cette condition
        User creatorUser = [SELECT id, Name, Title, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];

        ////[1]TRAITEMENT Create the default member
        List<AccountTeamMember> laccTeamMember = new List<AccountTeamMember>();

    	////[2]TRAITEMENT POUR  la methode onboardingTraitements.createOnboardingTasksNouvelleOffre
        List<String> listAllEvenements = new List<String>();
        //Map qui stocke la derniere le contact principal sur une souscription
        Map<String,String> mapAccountContactPrincipalId = new Map<String,String>();
        Map<String,Date> mapAccountDateEffet = new Map<String,Date>();
        Map<String,String> mapAccountOwnerId = new Map<String,String>();
        //Map qui stocke la liste des operations effectuées dans la derniere quote sur un compte
        Map<String,List<String>> mapAccountListEvenement = new Map<String,List<String>>();
        //Map contenant le numero de priorité de l'evenement a traiter par compte: voir dans la table custom méta data (Onbording actions)
        Map<String,Decimal> mapAccountEvenementPrioriteATraiter = new Map<String,Decimal>();
        //On definit la liste des taches a creer par compte
        Map<String,List<Task>> mapAccountListeTasksToInsert = new Map<String,List<Task>>();
        String compteOnbordingStepValue = Label.Compte_Onbording_Step_Value;
        String compteOnbordingEventValue = Label.Compte_Onbording_Event_Value;

        
        Integer size = newList.size(); 
        //for (Account acc : newList) {
        for(Integer i = 0; i < size; ++i){ 
            Account acc = newList[i];
            Account oldP = oldMap != null ? oldMap.get(acc.Id) : null;
            Account newP = newMap != null ? newMap.get(acc.Id) : null;
            //System.debug('accountTriggerAfterUpdate* oldP '+oldP);
            //System.debug('accountTriggerAfterUpdate* newP '+ newP);

            if (creatorUser != null)
            {
                AccountTeamMember member = new AccountTeamMember();
                member.UserId = creatorUser.Id;
                member.AccountId = acc.Id;
                member.TeamMemberRole = creatorUser.Title;
                laccTeamMember.add(member);
            }
	    	
            ////[2]TRAITEMENT POUR  la methode onboardingTraitements.createOnboardingTasksNouvelleOffre
            if((oldP != null  && acc.Statut_activation__c != oldP.Statut_activation__c && compteOnbordingStepValue == acc.Statut_activation__c) || (oldP == null  && compteOnbordingStepValue == acc.Statut_activation__c)){
                mapAccountContactPrincipalId.put(acc.Id, acc.Contact_Principal__c);
                //Dans le cas d'un déclenchement en massage sur le trigger, on stocke la liste des données à traiter par compte dans une map
                mapAccountEvenementPrioriteATraiter.put(acc.Id, 0);
                List<Task> listeTasksToInsertTemp = new List<Task>();
                mapAccountListeTasksToInsert.put(acc.Id, listeTasksToInsertTemp);
                mapAccountDateEffet.put(acc.Id,acc.CreatedDate.date());

                List<String> listEvent = new List<String>();
                if(!listEvent.contains(compteOnbordingEventValue)){
                    listEvent.add(compteOnbordingEventValue);
                    mapAccountListEvenement.put(acc.Id,listEvent);
                    listAllEvenements.add(compteOnbordingEventValue);
                }
                
                //Utiliser plus tard pour affecter l'owner ou le TC referent par compte suivant les conditions
                if(mapAccountOwnerId.get(acc.Id) == null){
                    mapAccountOwnerId.put(acc.Id, acc.OwnerId);
                }

            }
            ////[2]TRAITEMENT POUR  la methode onboardingTraitements.createOnboardingTasksNouvelleOffre
            //fonction permettant de recuprer un token d'activation de mail pour les nouvelles offres
            if( (Label.UtiliserPartnerShipPourLesProPilote == 'PartnerShip'  || (acc.Pro_Pilote__c == false && acc.Nat_To_Sync__c == false) )
                && ( (oldP != null  && acc.Statut_activation__c != oldP.Statut_activation__c && acc.Statut_activation__c == compteOnbordingStepValue && acc.Login__c != null && acc.Compte_Nouvelles_Offres__c == true)
                     || (oldP == null  && compteOnbordingStepValue == acc.Statut_activation__c && acc.Login__c != null && acc.Compte_Nouvelles_Offres__c == true)
                     || (oldP != null && oldP.Login__c == null && acc.Login__c != null  && compteOnbordingStepValue == acc.Statut_activation__c && acc.Compte_Nouvelles_Offres__c == true)
                ) ) {
                AccountMethods.callProjectPlaceActivationToken(acc.Login__c,acc.Id);
            }
        }
	}
    /**
    * @author Clement Musabimana
    * @date 23/01/2020
    * @description point d'entrée des méthodes appelés par le trigger before insert du compte
    **/
    public static void accountTriggerBeforeUpdate(Map<Id, Account> oldMap, Map<Id, Account>  newMap, List<Account> newList){
        ID PaysFR = Label.ID_France;

        ////[1]TRAITEMENT POUR  la methode onboardingTraitements.updateChargeClientele
        List<String> listIdOwnerChanged = new List<String>();
        Map<Id,List<Account>> mapIdOwnerChangedAccount = new Map<Id,List<Account>>();



        ////[2]TRAITEMENT 
        List<Account> creaManuelle = new List<Account>();
        List<Account> creaNonManuelle = new List<Account>();
        
        List<Account> createCodeClient = new List<Account>();
        
        List<Account> updateNomEnseignes = new List<Account>();
        List<Account> updateCodeEnseignes = new List<Account>();
        List<Account> updateMailAssurances = new List<Account>();


        
        Integer size = newList.size(); 
        //for (Account acc : newList) {
        for(Integer i = 0; i < size; ++i){ 
            Account acc = newList[i];
            Account oldP = oldMap != null ? oldMap.get(acc.Id) : null;
            Account newP = newMap != null ? newMap.get(acc.Id) : null;
            //System.debug('accountTriggerBeforeInsert* oldP '+oldP);
            //System.debug('accountTriggerBeforeInsert* newP '+ newP);


            ////[1]TRAITEMENT 
            if (acc.IsPersonAccount || acc.RecordType.IsPersonType) {
                acc.Login__c = acc.PersonEmail;
            }
            if (!acc.isPersonAccount && acc.Pays_LKP__c == PaysFR && acc.SIRET_texte__c != null && AccountMethods.checkSIRET(acc.SIRET_texte__c) == false) 
                acc.addError('Le SIRET n\'est pas valide.');
            else 
            {
                String redirect = '';
                if (acc.Reinitialisation_mdp__c == true && acc.Reinitialisation_mdp__c != oldP.Reinitialisation_mdp__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'E-mail');
                    //else {redirect = AccountMethods.generateToken(acc.PersonEmail,31,5,'E-mail');}
                    acc.Reinitialisation_mdp__c = false;
                    //acc.Last_URL_redirection__c = redirect;
                }
                //System.debug('acc.Login_as__c '+acc.Login_as__c);
                //System.debug('oldP.Login_as__c '+oldP.Login_as__c);
                if (acc.Login_as__c == true && acc.Login_as__c != oldP.Login_as__c)
                {
                    //System.debug('acc.Login_as__c ' + acc.Login_as__c);
                    redirect = AccountMethods.generateToken(acc.login__c, 1,1,'');
                    //System.debug('redirect ' + redirect);
                    acc.Login_as__c = false;
                    acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                } 
                
               if (acc.Alerte_expiration__c == 'JM7' && acc.Alerte_expiration__c != oldP.Alerte_expiration__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'assuranceJM7');
                    acc.Alerte_expiration__c = '';
                    //acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                }
             
               if (acc.Alerte_expiration__c == 'JM30' && acc.Alerte_expiration__c != oldP.Alerte_expiration__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'assuranceJM30');
                    acc.Alerte_expiration__c = '';
                    //acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                }

               if (acc.Alerte_expiration__c == 'JP60' && acc.Alerte_expiration__c != oldP.Alerte_expiration__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'assuranceJP60');
                    acc.Alerte_expiration__c = '';
                    //acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                }
   
             
                if (acc.Alerte_exp_certification__c == 'JM7' && acc.Alerte_exp_certification__c != oldP.Alerte_exp_certification__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'certifJM7');
                    acc.Alerte_exp_certification__c = '';
                    //acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                }
             
                if (acc.Alerte_exp_certification__c == 'JM30' && acc.Alerte_exp_certification__c != oldP.Alerte_exp_certification__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'certifJM30');
                    acc.Alerte_exp_certification__c = '';
                    //acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                }

                if (acc.Alerte_exp_certification__c == 'JM0' && acc.Alerte_exp_certification__c != oldP.Alerte_exp_certification__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'certifJM0');
                    acc.Alerte_exp_certification__c = '';
                    //acc.Last_URL_redirection__c = redirect;
                    //System.debug('>>>>>>>>>>>>>>> URL FIN = ' + acc.Last_URL_redirection__c);
                }
                          
                if (acc.Oubli_mdp_web__c == true && acc.Oubli_mdp_web__c != oldP.Oubli_mdp_web__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'E-mail');
                    acc.Oubli_mdp_web__c = false;
                    acc.Last_URL_redirection__c = redirect;
                }
                
                if (acc.Creation_compte__c == true && acc.Creation_compte__c != oldP.Creation_compte__c)
                {
                    redirect = AccountMethods.generateToken(acc.login__c, 31,5,'E-mail création');
                    acc.Creation_compte__c = false;
                    acc.Last_URL_redirection__c = redirect;
                }
            }
            
            if (newP.Vendeur_source_pr_inscription_SGI__c != oldP.Vendeur_source_pr_inscription_SGI__c) { 
                creaNonManuelle.add(acc); 
            }
            if (newP.Liste_des_enseignes_de_gestion_o_il_est__c != oldP.Liste_des_enseignes_de_gestion_o_il_est__c) {
                updateNomEnseignes.add(acc);
            }
            if (newP.Flux_code_Enseigne__c != oldP.Flux_code_Enseigne__c) {
                updateCodeEnseignes.add(acc);
            }
            if (newP.Login__c != oldP.Login__c && acc.Login__c != '' && acc.Login__c != null) {
                updateMailAssurances.add(acc);
            }

            ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateChargeClientele
            //Si owner est modifié et si le tc referent n'est pas modifié
            if(acc != null && oldP !=null && acc.OwnerId != null && acc.OwnerId != oldP.OwnerId && acc.TC_Referent__c == oldP.TC_Referent__c ){
                //System.debug('updateChargeClientele* TC_Referent__c OKK ');
                if(!listIdOwnerChanged.contains(acc.OwnerId)){
                    listIdOwnerChanged.add(acc.OwnerId);
                }
                if(mapIdOwnerChangedAccount.get(acc.OwnerId) == null){
                    List<Account> listAccount = new List<Account>();
                    listAccount.add(acc);
                    mapIdOwnerChangedAccount.put(acc.OwnerId,listAccount);
                }
                else{
                    List<Account> listAccount = mapIdOwnerChangedAccount.get(acc.OwnerId);
                    listAccount.add(acc);
                    mapIdOwnerChangedAccount.put(acc.OwnerId,listAccount);
                }
                //par défaut on met le CC égale au owner: cas ou le binome n'existerait pas. sinon le champ sera modifié par le binome par la suite
                acc.TC_Referent__c = acc.OwnerId;
            }
        }
        ////[1]TRAITEMENT 
        List<Reference__c> lEnseignes = null;
        if(updateNomEnseignes.size()>0 ||updateCodeEnseignes.size()>0){
            //@CMU:23/08/2019: lEnseignes: pour eviter les DML EXception (execution a chaque trigger) on fait la requete dans cette condition
            lEnseignes = [SELECT id, Name, key__c FROM Reference__c WHERE RecordType.DeveloperName = 'Enseigne'];               
        }
        if (updateNomEnseignes.size()>0){
            //AccountMethods.setListeEnseignes(updateNomEnseignes, true, lEnseignes);
        }
        if (updateCodeEnseignes.size()>0){
            //AccountMethods.setListeEnseignes(updateCodeEnseignes, false, lEnseignes);
        }
        ////[2]TRAITEMENT POUR  la methode onboardingTraitements.updateChargeClientele
        if(!listIdOwnerChanged.isEmpty()){
            onboardingTraitements.updateChargeClientele(listIdOwnerChanged,mapIdOwnerChangedAccount);
        }
    }
}