trigger LeadManagementTrigger on Lead (before insert, before update, after update) {
    
	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        SearchDuplicates.search(Trigger.new);
        for (Lead ldebug : Trigger.new)
            System.debug('Orange Doublon = ' + ldebug.Doublon__c);
    }
        
    if (Trigger.isUpdate && Trigger.isAfter){
        
        for (Lead piste : Trigger.new){
            
            if (piste.isConverted == false && piste.Status == 'Qualifiée' && piste.Status != Trigger.oldMap.get(piste.Id).Status){
            //if (piste.isConverted == false && piste.Piste_qualifiee__c && piste.Piste_qualifiee__c != Trigger.oldMap.get(piste.Id).Piste_qualifiee__c){
            
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(piste.Id);
                
                
                //try { ALGO VERIFICATION SIRET 
                //SI LE SIRET EST OK : LE PROCESS DE CONVERSION DEMARRE
                //SINON, ON DECOCHE LA CASE ET ON THROW UNE POPUP D'ERREUR
                //}
                
            
                // Check si le compte existe dans le système
                Id accId = null;
                if (piste.SIRET__c != null && piste.SIRET__c != '') { 
                    List<Account> lAcc = [SELECT Id, Name, Canal_pr_inscription__c FROM Account WHERE SIRET_texte__c = :piste.SIRET__c];
                    if (lAcc.size() > 0){
                        lc.setAccountId(lAcc[0].Id);
                        accId = lAcc[0].Id;
                        
                        
                        lAcc[0].Name = piste.Company;
                        lAcc[0].Effectif_entreprise_TEFET__c = piste.Effectif_entreprise_TEFET__c;
                        lAcc[0].Code_NAF_APE_societe_declarante__c = piste.Code_NAF__c;
                        lAcc[0].Code_postal__c = piste.Cod_postal__c;
                        
                        //Canal_pr_inscription__c est une création du compte manuelle ?
                        if (lAcc[0].Canal_pr_inscription__c != 'ITCS') {
                            lAcc[0].Canal_pr_inscription__c = piste.Canal_pr_inscription__c;
                            lAcc[0].Type_de_source_pr_inscription__c = piste.Type_de_source_pr_inscription__c;
                            lAcc[0].Source_pr_inscription__c = piste.Source_pr_inscription__c;
                            lAcc[0].Emetteur_pr_inscription__c = piste.Emetteur_pr_inscription__c;
                            //lAcc[0].Vendeur_source_pr_inscription_SGI__c = piste.Numero_SGI__c;
                        }
                        
                        //lAcc[0].Nom_de_l_assurance__c = piste.Nom_de_l_assurance__c;
                        lAcc[0].Adresse1__c = piste.Adresse1__c;
                        lAcc[0].IsConvertedLead__c = true;
                        
                        if (piste.Numero_SGI__c != null && piste.Numero_SGI__c != '') {
                        	lAcc[0].Vendeur_source_pr_inscription_SGI__c = piste.Numero_SGI__c;
                        	lAcc[0].Adresse_mail__c = piste.Adresse_mail__c;
                        	lAcc[0].Nom_pr_nom_vendeur_source_pr_inscript__c = piste.Identite__c;
                        	lAcc[0].Tel_vendeur_source_pr_inscription__c = piste.Tel_vendeur_source_pre_inscription__c;
                        }
                        
                        update lAcc[0];
                    }
                }
            
                // Check si le contact existe dans le système
                List<Contact> lContact = [SELECT Id FROM Contact WHERE AccountId = :accId AND FirstName = :piste.FirstName AND LastName = :piste.LastName ];
                if (lContact.size() > 0){
                    lc.SetContactID(lContact[0].Id);
                    lContact[0].MobilePhone = piste.MobilePhone;
                    lContact[0].Email = piste.Email;
                    update lContact[0];
                    //system.debug('>>>>>>>>>>>>>>>>> LEAD TO CONVERT: Account:' + lc.getAccountId() + ' / Contact: ' + lc.getContactId()); 
                }
                
                // set la création d'une opportunité
                lc.setDoNotCreateOpportunity(true);
                //lc.setOpportunityName('OPP - ' + piste.Company);
                
                // Converti le lead
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                //system.debug('>>>>>>>>>>>>>> after convertion: ' +l.Id);
                
                //convertedAccountID = lc.getAccountId();
                
            }
        }
        
        //redirectAfterLeadCreation(convertedAccountID);

    }
}
    /*
    static PageReference redirectAfterLeadCreation(ID accountID){
        //Account acc = [SELECT id FROM Account WHERE id = :accountID];
        PageReference PR = new PageReference('/'+accountID);
        PR.setRedirect(true);
        System.debug('>>>>>>>>>>>>>>>>>>>>> LA REDIRECTION VA AVOIR LIEU VERS LA PAGE ' + PR.getURL());
        return PR;
    }
    /* 

 e) redirige le user sur la page du compte
 
        }
   }
*/