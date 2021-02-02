/**
 * @File Name          : IntermediationTriggerUtils.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/11/2020, 10:32:11 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
**/
// 
// Class support pour le trigger sur les MERs
// 27/01/2017,  Qiuyan Liu, creation du batch à lancer suite à validation des MERs 
// 03/05/2017, xavier templet, nouvelle fonction future pour appel odigo sms suite à validation des MERs à la place du batch
// 16/08/2017, Qiuyan Liu, EB119, Projet Affiliation
// 18/09/2017, xavier templet, nouveau WS suppression depuis le bouton d'un amendement

global class IntermediationTriggerUtils {


    public Static Integer VALIDITY = 31;
    public Static Integer N_USAGES = 5;
    public Static String EMAIL = '';
    public Static String EMAIL_PART ='Part Sélectionné';
    public Static Integer LOT_SIZE = 40;
    
    // Appel par le bouton "Annuler le rejet du matching"
	webservice static void CancelAmendmentWS(Id Mer, Id Quo) {

		if (Mer != null && Quo != null) {
	   		List<Intermediation__c> CanceledRejects = [SELECT Id, Name, Matching_rejete__c, Matching_rejete_date__c, Matching_rejete_par__c, recredit_quote__c  
	   			FROM Intermediation__c WHERE Id = :Mer];
			if (CanceledRejects !=null && CanceledRejects.size()>0) {
			System.debug('IntermediationTriggerUtils >>>>> CanceledRejects :' + CanceledRejects);

	   		List<zqu__Quote__c> quoListDetails = [SELECT Id, Name, zqu__Status__c, Detail_de_modification__c, Motif_d_abandon__c FROM zqu__Quote__c WHERE Id = :Quo];
			 if (quoListDetails !=null && quoListDetails.size()>0) {
			System.debug('IntermediationTriggerUtils >>>>> quoListDetails :' + quoListDetails);
			 	
	   		List<zqu__QuoteAmendment__c> quoAmendmentList = [SELECT Id, Name FROM zqu__QuoteAmendment__c WHERE zqu__Quote__c in :quoListDetails];
			if (quoAmendmentList.size()>0) {
			//System.debug('IntermediationTriggerUtils >>>>> quoAmendmentList :' + quoAmendmentList);

   			List<zqu__QuoteAmendment__c> quoAmendmentList2 = new List<zqu__QuoteAmendment__c>();
    		for (Intermediation__c m : CanceledRejects) {
					for (zqu__QuoteAmendment__c qA : quoAmendmentList) 
						if (qA.Name.containsIgnoreCase(m.Name)) {
							quoAmendmentList2.add(qA);
							m.Matching_rejete__c = null;
			                m.Matching_rejete_date__c = null;
		                	m.Matching_rejete_par__c = null;
			                //m.Requete_Recredit__c = null;
		                	m.recredit_quote__c = null;
							break;
		    			}
    		}
    		update CanceledRejects;

			delete quoAmendmentList2;
 			QuoteMethods.AmendmentDetails(quoListDetails);
			if (quoAmendmentList.size() == 1) 
				for (zqu__Quote__c zq : quoListDetails)  
					if (zq.Id == Quo) {
						zq.zqu__Status__c = 'Abandonnée';
						zq.Detail_de_modification__c = '';
						zq.Motif_d_abandon__c = 'Proposition non valide';
					}
			update quoListDetails;
			}}}//if (quoListDetails !=null && quoListDetails.size()>0)
 		}
 		  		
		
	}

    public static void SelectionMER(Map<Id,Intermediation__c> NewMer, Map<Id,Intermediation__c> OldMer) {

        Map<Id, Projet__c> projetUpdateMap = new Map<Id,Projet__c>();
        Map<Id, Intermediation__c> validMERMap = new Map<Id, Intermediation__c>();
        List<String> MER2selectId = new List<String>();

        integer n = 0, i = 0;

        
        for (Id merId : OldMer.keyset()) {
            Intermediation__c merOld = OldMer.get(merId);
            Intermediation__c merNew = NewMer.get(merId);
            if (merNew.Statut_Selection__c == 'Validee' && merOld.Statut_Selection__c != merNew.Statut_Selection__c) {
                Intermediation__c merUpdate = new Intermediation__c();
                merUpdate.Id = merNew.Id;
                merUpdate.Date_de_s_lection__c = Date.today();
                DateTime myDT = DateTime.now(); 
                merUpdate.DateTime_Selection__c = myDT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                merUpdate.Is_selectionne__c  = true;
                merUpdate.Statut_Selection__c = 'Effectuee';
                validMERMap.put(merNew.Id, merUpdate);
                MER2selectId.add(merNew.Id);

            }

               n++;
               if (n>=LOT_SIZE) {

                if (!validMERMap.isEmpty() && MER2selectId.size()>0) {
                    System.debug('SelectionMER MER2selectId LOT ' + ' No: '+ i +' size: '+ MER2selectId.size());
                    update validMERMap.values();
                    SelectionMERasync(MER2selectId);
                    MER2selectId.clear();
                    validMERMap.clear();
                }
                i++; n = 0;
               }
            
        }
       
        if (!validMERMap.isEmpty() && MER2selectId.size()>0) {
            update validMERMap.values();
            SelectionMERasync(MER2selectId);
        }
        
    }
    
    @future(callout=true)
    //public static void SelectionMERasync(List<String> serializedMER) {
    public static void SelectionMERasync(List<String> MER2selectId) {
        
        List<Token__c> tokenList = new List<Token__c>();
        Map<Id, Projet__c> projetUpdateMap = new Map<Id,Projet__c>();

        List<Intermediation__c> merList = [SELECT Id, Contact__c, Contact__r.AccountId, Contact__r.Account.Login__c, Contact__r.Account.Mail_de_facturation__c, Contact__r.Name, Contact__r.MobilePhone, 
                                            Projet__c, Projet__r.Particulier__r.PersonMobilePhone, Projet__r.Particulier__r.Phone, Projet__r.Particulier__r.PersonOtherPhone, 
                                            Projet__r.Particulier__r.PersonEmail, Projet__r.Particulier__r.Name, Projet__r.Titre__c, Projet__r.Description__c, Projet__r.Code_postal__r.Name, 
                                            Projet__r.Ville_formule__c, Projet__r.Flux_Categorie__c, Projet__r.Particulier__r.Salutation, Projet__r.Statut_Projet__c, Projet__r.Etat__c, 
                                            Projet__r.Mises_en_relation_selectionnees__c, Projet__r.Particulier__c, Projet__r.Particulier__r.Login__c
                                            FROM Intermediation__c WHERE Id in: MER2selectId FOR UPDATE];

        //Avoid the execution of trigger Generate_token_Part_selectionne on Intermediation__c
        checkRecursiveSFDC.runOnce();
        try {
            for (Intermediation__c mer : merList) {
            //for (MERhelper mer : merList) {
                
                if (!projetUpdateMap.containsKey(mer.Projet__c) && 
                    (mer.Projet__r.Mises_en_relation_selectionnees__c != null && mer.Projet__r.Mises_en_relation_selectionnees__c > 0)  &&
                    (mer.Projet__r.Statut_Projet__c == 'Pas de pros à suivre' || mer.Projet__r.Statut_Projet__c =='Qualifié') && 
                    (mer.Projet__r.Etat__c == 'ODC ouverte' || mer.Projet__r.Etat__c == 'ODC réouverte')) {
                    projetUpdateMap.put(mer.Projet__c, new Projet__c(Id=mer.Projet__c, Statut_Projet__c = 'En attente de suivi'));
                }
              
                Blob targetBlob = Blob.valueOf(mer.Contact__r.Account.Login__c + Datetime.now().getTime());
                Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
                String hash = EncodingUtil.convertToHex(hashBlob);
                //System.debug('>>>>>>>>>>>>>>>>>> hash = ' + hash);
                
                /*//token part, same function as Apex trigger : Generate_token_Part_selectionne
                Blob targetBlobPart = Blob.valueOf(mer.Projet__r.Particulier__r.Login__c + Datetime.now().getTime());
                Blob hashBlobPart = Crypto.generateDigest('MD5', targetBlob);
                String hashPart = EncodingUtil.convertToHex(hashBlob);*/
                
                //token pro
                Token__c token = new Token__c(Name = hash, Compte__c = mer.Contact__r.AccountId, Validite__c = VALIDITY,Nombre_d_usage_token_restant__c = N_USAGES,
                                              Type_de_token__c = EMAIL, URL_redirection__c = Label.URL_web_pour_email + hash, 
                                              Email_du_compte__c = (EMAIL == 'Quote' ? mer.Contact__r.Account.Mail_de_facturation__c : mer.Contact__r.Account.login__c));
                tokenList.add(token);
                
                /*//token part, same function as Apex trigger : Generate_token_Part_selectionne
                Token__c tokenPart = new Token__c(Name = hashPart, Compte__c = mer.Projet__r.Particulier__c, Validite__c = VALIDITY,Nombre_d_usage_token_restant__c = N_USAGES,
                                              Type_de_token__c = EMAIL_PART, URL_redirection__c = Label.URL_web_pour_email + hashPart, 
                                              Email_du_compte__c = mer.Projet__r.Particulier__r.Login__c);
                tokenList.add(tokenPart); */
                
               
                String urlToken = Label.URL_web_pour_email + 'pro/mon-espace#/project/' + mer.Id + '/' + hash;
               
                //System.debug('mer token' + token.URL_redirection__c);
               
                String projetPartPhone = mer.Projet__r.Particulier__r.PersonMobilePhone != null ? mer.Projet__r.Particulier__r.PersonMobilePhone : 
                                                                                                  (mer.Projet__r.Particulier__r.Phone != null ? mer.Projet__r.Particulier__r.Phone : 
                                                                                                                                                mer.Projet__r.Particulier__r.PersonOtherPhone); 
                
                String body = 'HOMLY YOU. ' + mer.Projet__r.Particulier__r.Salutation + ' ' + mer.Projet__r.Particulier__r.Name.toUpperCase() + ' souhaite faire appel à vos services pour son projet à ' 
                            + mer.Projet__r.Ville_formule__c + '(' + mer.Projet__r.Code_postal__r.Name + ')' + '.\n \n' 
                            + 'Descriptif du projet : ' + mer.Projet__r.Flux_Categorie__c + '\n \n'
                            + 'Coordonnées du particulier : \n' 
                            + mer.Projet__r.Particulier__r.Name.toUpperCase() + '\n'
                            + projetPartPhone + '\n'
                            + mer.Projet__r.Particulier__r.PersonEmail + '\n \n'
                            + 'Prenez contact dès maintenant pour mettre toutes les chances de votre côté et gagner ce chantier ! \n \n'
                            + 'Plus de détails sur ' + urlToken + '\n \n'
                            + 'À très vite sur Homly You !';
                //System.debug('>>>>>>>>>>>>>>>>> SMS body ' + body);

                //OdigoSms.WS01_OdigoSms.Result result = OdigoSms.WS01_OdigoSms.sendTextMessage(mer.Contact__r.MobilePhone, body);
                //System.debug('>>>>>> RESULTAT = ' + (result.isSuccess() ? 'OK' : 'Error' + result.message));

                //mer.Resultat_envoi_SMS__c = (result.isSuccess() ? 'OK' : 'Erreur lors de l\'envoi du SMS : ' + result.message);
               // mer.SMS_envoye__c = (result.isSuccess() ? body : 'Erreur lors de l\'envoi du SMS');
                mer.url_token__c = urlToken;
                //mer.Token_Part_Selectionne__c = hashPart;
                
                System.debug('mer.Projet__r.Mises_en_relation_selectionnees__c ' + mer.Projet__r.Mises_en_relation_selectionnees__c);
                System.debug('mer.Projet__r ' + mer.Projet__r); 
               
                
            }
            update merList;
            
            if (!projetUpdateMap.isEmpty()) {
                update projetUpdateMap.values();

                //Modified by Qiuyan Liu, EB-129, call bus to notify the changement of Projet__c's Statut_Projet__c, Sous_statut__c and Etat__c
                //List<Projet__c> proList = [select id from Projet__c where id in : projetUpdateMap.keySet() FOR UPDATE];
                ProjetAffiliationWS updateJob = new ProjetAffiliationWS(new List<Id>(projetUpdateMap.keyset()));
                ID jobID = System.enqueueJob(updateJob);
            }

            if (tokenList.size() > 0) {
                insert tokenList;
            }

            
        
        } catch (Exception e) {
            System.debug('Apex Class : Batch_ValideIntermediation, An error occurred during the batch execution: ' + e.getMessage());
        }
    }



    public static void contactMer(List<Intermediation__c> triggerNew) {
        List<ID> lContactID = new List<ID>();
        for (Intermediation__c miseEnRelation : triggerNew){
            lContactID.add(miseEnRelation.Contact__c);
        }
        
        List<Contact> lContact = [SELECT id, AccountId FROM Contact WHERE id IN :lContactID];
        
        for (Intermediation__c miseEnRelation : triggerNew){
            for (Contact ctc : lContact) {
                if (miseEnRelation.Contact__c == ctc.id){ miseEnRelation.Professionnel__c = ctc.AccountId; }
            }
        }
    }
    
    public static void Generate_token_Part_selectionne(List<Intermediation__c> newlist, Map<Id,Intermediation__c> inte, Map<Id,Intermediation__c> oldInt) {
        Map<Id, Intermediation__c> merMap = new Map<Id, Intermediation__c>([SELECT Id, Projet__c, Projet__r.Particulier__c, Projet__r.Particulier__r.Login__c, Projet__r.Particulier__r.Mail_de_facturation__c FROM Intermediation__c WHERE Id IN :newlist]);                       
            List<Token__c> tokenList = new List<Token__c>();
            for(Id merId : merMap.keyset()) {
                Intermediation__c oldMER = oldInt.get(merId);
                 system.debug('>>>>>>>> oldMER '+ oldMER);
                Intermediation__c newMER = inte.get(merId);
                 system.debug('>>>>>>>> newMER '+ newMER);
                Intermediation__c curMER = merMap.get(merId);
                system.debug('>>>>>>>> curMER '+ curMER);
                system.debug('>>>>>>>> Generate_token_Part_selectionne 3 '+ newMER.Is_selectionne__c);

                if(oldMER.Is_selectionne__c != newMER.Is_selectionne__c && newMER.Is_selectionne__c == true) { 
                    Blob targetBlob = Blob.valueOf(curMER.Projet__r.Particulier__r.Login__c + Datetime.now().getTime());
                    Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
                    String hash = EncodingUtil.convertToHex(hashBlob);
                    Token__c token = new Token__c(Name = hash, Compte__c = curMER.Projet__r.Particulier__c, Validite__c = 31, Nombre_d_usage_token_restant__c = 5, 
                                    Type_de_token__c = 'Part Sélectionné', URL_redirection__c = Label.URL_web_pour_email + hash,Email_du_compte__c = curMER.Projet__r.Particulier__r.Login__c);
                    tokenList.add(token);
                    curMER.Token_Part_Selectionne__c = hash;  
                 }
            }
            if (tokenList.size() > 0) {
                insert tokenList;
                update merMap.values();  
            }
    }
    
    public static void UsageCreation(Map<Id,Intermediation__c> NewMer, Map<Id,Intermediation__c> OldMer) {
        List<String> intermediationIdsList = new List<String>();
       
        integer n = 0, i = 0;
        
        for (Id merId : NewMer.keyset()) {
            Intermediation__c record1 = NewMer.get(merId);
            Intermediation__c oldIntermed = OldMer.get(merId);
            if ((record1.IsModified__c == true) && (record1.Date_de_s_lection__c !=NULL) && (record1.IsModified__c != oldIntermed.IsModified__c)) {     
               intermediationIdsList.add(record1.Id);
               n++;
               if (n>=50) {
                if (intermediationIdsList.size()>0){
                    System.debug('UsageCreationIntermediationTrigger intermediationIdsList LOT ' + ' No: '+ i +' size: '+ intermediationIdsList.size());
                    UsageCreationClass.AppelZuora(intermediationIdsList);
                    intermediationIdsList.clear();
                }
                i++; n = 0;
              }
            }
        }

        if (intermediationIdsList.size()>0){
            System.debug('UsageCreationIntermediationTrigger intermediationIdsList LOT ' + ' No: '+ i +' size: '+ intermediationIdsList.size());
            UsageCreationClass.AppelZuora(intermediationIdsList);
        }    
        
    }

    public static void FirstMatch(List<Intermediation__c> NewMer) {
        List<Id> idsProj = new List<Id>();
        List<Intermediation__c> intermediationMapProjet = new List<Intermediation__c>();
        if (NewMer != null) {
            for (Intermediation__c i : NewMer ){
                idsProj.add(i.Projet__c);
                //intermediationMapProjet.put(i, i.Projet__c);
            }

            Map<Id, Projet__c> pMap = new Map<Id, Projet__c>([SELECT Id, Name, Nombre_Appel_Matching__c, CreatedDate, (SELECT Id FROM Professionels_propos_s__r ) FROM Projet__c WHERE Id In :idsProj]);


            for (Intermediation__c i : NewMer) {
                //System.debug('pMap.get(i.Projet__c).Professionels_propos_s__r = ' + pMap.get(i.Projet__c).Professionels_propos_s__r);
                //System.debug('pMap.get(i.Projet__c).Nombre_Appel_Matching__c = ' + pMap.get(i.Projet__c).Nombre_Appel_Matching__c);

                if (pMap.containsKey(i.Projet__c) && pMap.get(i.Projet__c).Professionels_propos_s__r == null && pMap.get(i.Projet__c).Nombre_Appel_Matching__c == 0) {
                    i.Date_Premier_Match__c = pMap.get(i.Projet__c).CreatedDate;
                    i.QuasiMatch_Premier_Match__c = (i.Quasi_match__c == true ? true : false);
                } else if (pMap.containsKey(i.Projet__c) && (pMap.get(i.Projet__c).Nombre_Appel_Matching__c > 0 || pMap.get(i.Projet__c).Professionels_propos_s__r != null )) {
                    i.Date_Premier_Match__c = Datetime.now();
                    i.QuasiMatch_Premier_Match__c = (i.Quasi_match__c == true ? true : false);
                }
            }
        }
    }
}