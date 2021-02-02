/**
 * @File Name          : AccountTrigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 01-14-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/20/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger AccountTrigger on Account (before insert, after insert, before update, after update) 
{

	// before insert, after insert, before update
	//Original code, from BD
	ID PaysFR = Label.ID_France; //[SELECT id FROM Reference__c WHERE key__c = 'FRA' LIMIT 1].id;
    ID serviceWeb = Label.ID_Service_Web;//[SELECT id FROM User WHERE Est_Service_Web__c = true LIMIT 1].id;

    //@CMU:23/08/2019: lEnseignes: pour eviter les DML EXception (execution a chaque trigger) ces deux requetes sont executées dans des conditions spécifiques et pas tout le temps
    //User currentUser = [SELECT id, Name, Title, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
    //List<Reference__c> lEnseignes = [SELECT id, Name, key__c FROM Reference__c WHERE RecordType.DeveloperName = 'Enseigne'];
    
    List<Account> creaManuelle = new List<Account>();
    List<Account> creaNonManuelle = new List<Account>();
    
    List<Account> createCodeClient = new List<Account>();
    
    List<Account> updateNomEnseignes = new List<Account>();
    List<Account> updateCodeEnseignes = new List<Account>();
    List<Account> updateMailAssurances = new List<Account>();

	// AFTER UPDATE
	if (Trigger.isAfter && Trigger.isUpdate) {

		//AccountTriggerDispatcher.accountTriggerAfterUpdate(Trigger.oldMap, Trigger.newMap, Trigger.new);
        /*String oldMapJsonstring = JSON.serialize(Trigger.oldMap); 
        String newMapJsonstring = JSON.serialize(Trigger.newMap); 
        String newListJsonstring = JSON.serialize(Trigger.new); */
        //AccountTriggerDispatcher.accountTriggerAfterUpdate(oldMapJsonstring, newMapJsonstring, newListJsonstring);
        AccountTriggerDispatcher.accountTriggerAfterUpdate(Trigger.oldMap, Trigger.newMap,Trigger.New);         
        //System.debug('Account Trigger after update ends ...');
        
        // after passage du compte aux nouvelles offres
        AccountMethods.triggerPushTopicOnProObjects(Trigger.newMap, Trigger.oldMap);
        // After update phone to LMSG projects 
        AccountMethods.updatePhoneOnProjetLMSG(Trigger.newMap, Trigger.oldMap);
	}

    
    // BEFORE INSERT
    if (Trigger.isInsert && Trigger.isBefore)
    {
        // set flag if user is HK :
        AccountMethods.setIsUpdatedBySF(Trigger.new, null, true);

        AccountTriggerDispatcher.accountTriggerBeforeInsert(Trigger.oldMap, Trigger.newMap, Trigger.new); 
        
        // Before insert of a Part compte nouvelles offres
        Indicateur_LMSG.account_LMSG(Trigger.new, null);
    }

    // AFTER INSERT
    if (Trigger.isInsert && Trigger.isAfter)
    {
        system.debug('>>> TRIGGER AFTER INSERT');
    	//@CMU:23/08/2019: lEnseignes: pour eviter les DML EXception (execution a chaque trigger) on fait la requete dans cette condition
    	User currentUser = [SELECT id, Name, Title, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        AccountMethods.setDefaultAccountTeam(Trigger.new, currentUser);
        AccountTriggerDispatcher.accountTriggerAfterInsert(Trigger.oldMap, Trigger.newMap, Trigger.new);
    }


    // BEFORE UPDATE
    if (Trigger.isUpdate && Trigger.isBefore)
    {  
        // set flag if user is HK :
        AccountMethods.setIsUpdatedBySF(Trigger.new, Trigger.oldMap, false);
        // if called by partnership on Pro_Pilote and Nouvelle_Offre so do not affect the status
        AccountMethods.proResilieActivated(Trigger.new, Trigger.oldMap);

        //if (creaNonManuelle.size()>0){AccountMethods.setUserInfoBySGI(creaNonManuelle, null, false, currentUser);}
        // if (updateMailAssurances.size()>0){AccountMethods.setMailAssurances(updateMailAssurances);}
        AccountTriggerDispatcher.accountTriggerBeforeUpdate(Trigger.oldMap, Trigger.newMap, Trigger.new); 
 
        // Compte pro passe en pro-Actif : alors verifier si ses prestations sont toutes positionnables et le passer en pro positionnable si necessaire
        MandatoryDocs_StatusSetter.setAccToPos_NoCommit(Trigger.oldMap, Trigger.newMap);

        // Extract UBOs if needed
        UBOMethods.extractUBOs(Trigger.new, Trigger.oldMap);

        // Before update compte nouvelles offres
        Indicateur_LMSG.account_LMSG(Trigger.new, Trigger.oldMap);

        // Before update of the new email from the Project Place
        ProjectPlaceWS.emailChangeCompletedPart(Trigger.new, Trigger.oldMap);

        // Before update, check if we have to send UBOs to HiPay
        UBOMethods.EnvoyerUboDuPro(Trigger.newMap, Trigger.oldMap);
    }
    
    /*ID PaysFR = Label.ID_France; //[SELECT id FROM Reference__c WHERE key__c = 'FRA' LIMIT 1].id;
    ID serviceWeb = Label.ID_Service_Web;//[SELECT id FROM User WHERE Est_Service_Web__c = true LIMIT 1].id;
    
    User currentUser = [SELECT id, Name, Title, FederationIdentifier, Phone, Email, UserRole.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
    
    List<Reference__c> lEnseignes = [SELECT id, Name, key__c FROM Reference__c WHERE RecordType.DeveloperName = 'Enseigne'];
    
    List<Account> creaManuelle = new List<Account>();
    List<Account> creaNonManuelle = new List<Account>();
    
    List<Account> createCodeClient = new List<Account>();
    
    List<Account> updateNomEnseignes = new List<Account>();
    List<Account> updateCodeEnseignes = new List<Account>();
    List<Account> updateMailAssurances = new List<Account>();
    
    //String code_client_final = '';

    
    // BEFORE INSERT
    if (Trigger.isInsert && Trigger.isBefore)
    {
        for (Account compte : Trigger.new)
        {
            if (!compte.isPersonAccount && compte.Pays_LKP__c == PaysFR && compte.SIRET_texte__c != null && AccountMethods.checkSIRET(compte.SIRET_texte__c) == false) 
                compte.addError('Le SIRET n\'est pas valide.');
            else
            {
                // this loop was commented
                for (Reference__c ref : lRef)
                {
                    if (compte.Code_NAF_texte__c != null && compte.Code_NAF_texte__c.equals(ref.Name))
                        compte.Code_NAF_APE_societe_declarante__c = ref.Id;
                    if (compte.Code_postal_texte__c != null && compte.Code_postal_texte__c.equals(ref.Name))
                        compte.Code_postal__c = ref.Id;
                }
                // this loop was commented
            }
            if (compte.IsConvertedLead__c || compte.CreatedById == serviceWeb) { creaNonManuelle.add(compte); }
            else { creaManuelle.add(compte); }
            if (compte.Liste_des_enseignes_de_gestion_o_il_est__c != null) { updateNomEnseignes.add(compte); }
            if (!compte.isPersonAccount) {createCodeClient.add(compte);}
        
            
        }
        
        if (createCodeClient.size()>0){
            if (!Test.isRunningTest()){
            Technical_Values__c TV = [SELECT Name, Code_client__c FROM Technical_Values__c WHERE Name = 'Technical values' LIMIT 1];
            //if (Test.isRunningTest()){TV.Code_client__c = 'XZZZZ'; update TV;}
            TV.Code_client__c = AccountMethods.generateCodeClient(createCodeClient, TV.Code_client__c);
            update TV;
            }
            else{ AccountMethods.generateCodeClient(createCodeClient, 'TZZZZ'); }
        }
        //System.debug('>>>>>>>>>>>> code client = ' + code_client_final);
        //update TV;
        
        if (updateNomEnseignes.size()>0){AccountMethods.setListeEnseignes(updateNomEnseignes, true, lEnseignes);}
        if (creaManuelle.size()>0){AccountMethods.setUserInfoBySGI(creaManuelle, null, true, currentUser);}
        if (creaNonManuelle.size()>0){AccountMethods.setUserInfoBySGI(creaNonManuelle, null, false, currentUser);}
        
       
    }

    // AFTER INSERT
    if (Trigger.isInsert && Trigger.isAfter)
    {
        system.debug('>>> TRIGGER AFTER INSERT');
        AccountMethods.setDefaultAccountTeam(Trigger.new, currentUser);
        
    }

    // BEFORE UPDATE
    if (Trigger.isUpdate && Trigger.isBefore)
    {
        for (Account compte : Trigger.new)
        {
            if (!compte.isPersonAccount && compte.Pays_LKP__c == PaysFR && compte.SIRET_texte__c != null && AccountMethods.checkSIRET(compte.SIRET_texte__c) == false) 
                compte.addError('Le SIRET n\'est pas valide.');
            else 
            {
                String redirect = '';
                if (compte.Reinitialisation_mdp__c == true && compte.Reinitialisation_mdp__c != Trigger.oldMap.get(compte.id).Reinitialisation_mdp__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'E-mail');
                    //else {redirect = AccountMethods.generateToken(compte.PersonEmail,31,5,'E-mail');}
                    compte.Reinitialisation_mdp__c = false;
                    //compte.Last_URL_redirection__c = redirect;
                }
                System.debug('compte.Login_as__c '+compte.Login_as__c);
                System.debug('Trigger.oldMap.get(compte.id).Login_as__c '+Trigger.oldMap.get(compte.id).Login_as__c);
                if (compte.Login_as__c == true && compte.Login_as__c != Trigger.oldMap.get(compte.id).Login_as__c)
                {
                    System.debug('compte.Login_as__c ' + compte.Login_as__c);
                    redirect = AccountMethods.generateToken(compte.login__c, 1,1,'');
                    System.debug('redirect ' + redirect);
                    compte.Login_as__c = false;
                    compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }
                
               if (compte.Alerte_expiration__c == 'JM7' && compte.Alerte_expiration__c != Trigger.oldMap.get(compte.id). Alerte_expiration__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'assuranceJM7');
                    compte.Alerte_expiration__c = '';
                    //compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }
             
               if (compte.Alerte_expiration__c == 'JM30' && compte.Alerte_expiration__c != Trigger.oldMap.get(compte.id). Alerte_expiration__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'assuranceJM30');
                    compte.Alerte_expiration__c = '';
                    //compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }

               if (compte.Alerte_expiration__c == 'JP60' && compte.Alerte_expiration__c != Trigger.oldMap.get(compte.id). Alerte_expiration__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'assuranceJP60');
                    compte.Alerte_expiration__c = '';
                    //compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }
   
             
                if (compte.Alerte_exp_certification__c == 'JM7' && compte.Alerte_exp_certification__c != Trigger.oldMap.get(compte.id). Alerte_exp_certification__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'certifJM7');
                    compte.Alerte_exp_certification__c = '';
                    //compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }
             
                if (compte.Alerte_exp_certification__c == 'JM30' && compte.Alerte_exp_certification__c != Trigger.oldMap.get(compte.id). Alerte_exp_certification__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'certifJM30');
                    compte.Alerte_exp_certification__c = '';
                    //compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }

                if (compte.Alerte_exp_certification__c == 'JM0' && compte.Alerte_exp_certification__c != Trigger.oldMap.get(compte.id). Alerte_exp_certification__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'certifJM0');
                    compte.Alerte_exp_certification__c = '';
                    //compte.Last_URL_redirection__c = redirect;
                    System.debug('>>>>>>>>>>>>>>> URL FIN = ' + compte.Last_URL_redirection__c);
                }
                          
                if (compte.Oubli_mdp_web__c == true && compte.Oubli_mdp_web__c != Trigger.oldMap.get(compte.id).Oubli_mdp_web__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'E-mail');
                    compte.Oubli_mdp_web__c = false;
                    compte.Last_URL_redirection__c = redirect;
                }
                
                if (compte.Creation_compte__c == true && compte.Creation_compte__c != Trigger.oldMap.get(compte.id).Creation_compte__c)
                {
                    redirect = AccountMethods.generateToken(compte.login__c, 31,5,'E-mail création');
                    compte.Creation_compte__c = false;
                    compte.Last_URL_redirection__c = redirect;
                }
            }
            
            if (Trigger.newMap.get(compte.id).Vendeur_source_pr_inscription_SGI__c != Trigger.oldMap.get(compte.id).Vendeur_source_pr_inscription_SGI__c) { 
                creaNonManuelle.add(compte); 
            }
            if (Trigger.newMap.get(compte.id).Liste_des_enseignes_de_gestion_o_il_est__c != Trigger.oldMap.get(compte.id).Liste_des_enseignes_de_gestion_o_il_est__c) {
                updateNomEnseignes.add(compte);
            }
            if (Trigger.newMap.get(compte.id).Flux_code_Enseigne__c != Trigger.oldMap.get(compte.id).Flux_code_Enseigne__c) {
                updateCodeEnseignes.add(compte);
            }
            if (Trigger.newMap.get(compte.id).Login__c != Trigger.oldMap.get(compte.id).Login__c && compte.Login__c != '' && compte.Login__c != null) {
                updateMailAssurances.add(compte);
            }
        }
        if (updateNomEnseignes.size()>0){AccountMethods.setListeEnseignes(updateNomEnseignes, true, lEnseignes);}
        if (updateCodeEnseignes.size()>0){AccountMethods.setListeEnseignes(updateCodeEnseignes, false, lEnseignes);}
        if (creaNonManuelle.size()>0){AccountMethods.setUserInfoBySGI(creaNonManuelle, null, false, currentUser);}
        // if (updateMailAssurances.size()>0){AccountMethods.setMailAssurances(updateMailAssurances);}
    }*/
    
    
}