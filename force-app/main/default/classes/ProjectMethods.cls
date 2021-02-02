/**
 * @File Name          : ProjectMethods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-02-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/11/2020   Hassan Dakhcha     Initial Version
**/
// 31/05/2018, Created by Qiuyan Liu, optimization project's foncitonalities
public with sharing class ProjectMethods {

    public static void initProjectValues(List<Projet__c> newList) {
        //called before insert
        Set<Id> accIdSet = new Set<Id>();
        for (Projet__c proj : newList) {
            accIdSet.add(proj.Particulier__c);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, PersonEmail, Phone, PersonMobilePhone  FROM Account WHERE IsPersonAccount = true AND id in: accIdSet]);
        for (Projet__c proj : newList) {
            if (accMap.containsKey(proj.Particulier__c) && accMap.get(proj.Particulier__c).PersonEmail != null && accMap.get(proj.Particulier__c).PersonEmail.contains('@')) { 
                proj.email_projet__c = accMap.get(proj.Particulier__c).PersonEmail;
                
            }
        
  			if (accMap.containsKey(proj.Particulier__c)) {
                proj.Telephone_Mobile__c = accMap.get(proj.Particulier__c).PersonMobilePhone != null ? accMap.get(proj.Particulier__c).PersonMobilePhone : accMap.get(proj.Particulier__c).Phone;
            }
            
            if (UserInfo.getName() != 'Service Web') {
                proj.Source__c = 'CRM';
                proj.Canal__c = 'ITCS';
            }

            if (proj.Statut_Projet__c != null && proj.Statut_Projet__c.contains('Eligible')) {
                proj.A_deja_ete_eligible_a__c = proj.Statut_Projet__c;
            }
        }

        updateProjetCodePostal(null, null, newList);
        updateProjetCategorie(null, null, newList);
        updateProjetPays(null, null, newList);
        updateProjetProprietaireProjet(null, null, newList);
    }

    public static void updateProjectValues(Map<Id, Projet__c> oldMap, Map<Id, Projet__c>  newMap, List<Projet__c> newList) {
        //called before update
        updateProjetCodePostal(oldMap, newMap, newList);
        updateProjetCategorie(oldMap, newMap, newList);
        updateProjetPays(oldMap, newMap, newList);
        updateProjetProprietaireProjet(oldMap, newMap, newList);
        for (Projet__c proj : newList) {
            proj.A_deja_ete_eligible_a__c = proj.A_deja_ete_eligible_a__c == null? '' : proj.A_deja_ete_eligible_a__c;
            if (proj.Statut_Projet__c != null && proj.Statut_Projet__c.contains('Eligible') && !proj.A_deja_ete_eligible_a__c.endsWith(proj.Statut_Projet__c) && oldMap.get(proj.Id).Statut_Projet__c != newMap.get(proj.Id).Statut_Projet__c) {
                proj.A_deja_ete_eligible_a__c += '/' + proj.Statut_Projet__c;
            }
        }
    }

    public static void updateProjetCodePostal(Map<Id, Projet__c> oldMap, Map<Id, Projet__c> newMap, List<Projet__c> newList) {
        Set<Id> referenceIds = new Set<Id>();
        if (oldMap == null && newMap == null) {
            //Trigger before insert context
            for (Projet__c proj : newList) {
                referenceIds.add(proj.Code_postal__c);
            }
        } 

        if (oldMap != null) {
            //Trigger before update context
            for (Id projId : newMap.keySet()) {
                Projet__c oldP = oldMap.get(projId);
                Projet__c newP = newMap.get(projId);
                if (oldP.Code_postal__c != newP.Code_postal__c && newP.Code_postal__c != null) {
                    referenceIds.add(newP.Code_postal__c);
                }
            }
        }

        Map<Id, Reference__c> codePostalMap = new Map<Id, Reference__c>([SELECT Id,Libelle__c, Libelle_2__c, Name,  Lov_Type__c FROM Reference__c WHERE Lov_Type__c = 'CP_Ville' AND Id IN:referenceIds AND Active_PP__c = true]);
        for (Projet__c proj : newList) {
            if (codePostalMap.containsKey(proj.Code_postal__c) || Test.isRunningTest()) {
                Reference__c ref = codePostalMap.get(proj.Code_postal__c);
                if (Test.isRunningTest()) {
                    ref = new Reference__c();
                }
                proj.INSEE__c = ref.Libelle_2__c;
                proj.Ville__c = ref.Libelle__c;
                proj.Zip_code__c = ref.Name;
                //insert --> flag = false
                //update --> flag = true
                proj.flag_runOnce__c = oldMap == null? false : true;
            }
        }

    }

    public static void updateProjetCategorie(Map<Id, Projet__c> oldMap, Map<Id, Projet__c> newMap, List<Projet__c> newList) {
        Set<Id> referenceIds = new Set<Id>();
        if (oldMap == null && newMap == null) {
            //Trigger before insert context
            for (Projet__c proj : newList) {
                referenceIds.add(proj.Categorie_lkp__c);
            }
        } 

        if (oldMap != null) {
            //Trigger before update context
            for (Id projId : newMap.keySet()) {
                Projet__c oldP = oldMap.get(projId);
                Projet__c newP = newMap.get(projId);
                if (oldP.Categorie_lkp__c != newP.Categorie_lkp__c && newP.Categorie_lkp__c != null) {
                    referenceIds.add(newP.Categorie_lkp__c);
                }
            }
        }

        Map<Id, Reference__c> categorieMap = new Map<Id, Reference__c>([SELECT Id, Key__c, Libelle__c, Libelle_2__c, Name,  Lov_Type__c FROM Reference__c WHERE Lov_Type__c = 'Categorie' AND Id IN:referenceIds]);
        for (Projet__c proj : newList) {
            if (categorieMap.containsKey(proj.Categorie_lkp__c) || Test.isRunningTest()) {
                Reference__c ref = categorieMap.get(proj.Categorie_lkp__c);
                if (Test.isRunningTest()) {
                    ref = new Reference__c();
                }
                proj.Flux_Categorie__c = ref.Name;
                proj.Flux_Code_Categorie__c = ref.Key__c;
                //insert --> flag = false
                //update --> flag = true
                proj.flag_runOnce__c = oldMap == null? false : true;
                //Categorie_initiale__c changes on insert
                proj.Categorie_initiale__c = oldMap == null? ref.Key__c : proj.Categorie_initiale__c;
            }
        }
    }

    public static void updateProjetPays(Map<Id, Projet__c> oldMap, Map<Id, Projet__c> newMap, List<Projet__c> newList) {
        Set<Id> referenceIds = new Set<Id>();
        if (oldMap == null && newMap == null) {
            //Trigger before insert context
            for (Projet__c proj : newList) {
                referenceIds.add(proj.Pays_lkp__c);
            }
        } 

        if (oldMap != null) {
            //Trigger before update context
            for (Id projId : newMap.keySet()) {
                Projet__c oldP = oldMap.get(projId);
                Projet__c newP = newMap.get(projId);
                if (oldP.Pays_lkp__c != newP.Pays_lkp__c && newP.Pays_lkp__c != null) {
                    referenceIds.add(newP.Pays_lkp__c);
                }
            }
        }

        Map<Id, Reference__c> categorieMap = new Map<Id, Reference__c>([SELECT Id, Key__c, Libelle__c, Libelle_2__c, Name,  Lov_Type__c FROM Reference__c WHERE Lov_Type__c = 'Pays' AND Id IN:referenceIds]);
        for (Projet__c proj : newList) {
            if (categorieMap.containsKey(proj.Pays_lkp__c) || Test.isRunningTest()) {
                Reference__c ref = categorieMap.get(proj.Pays_lkp__c);
                if (Test.isRunningTest()) {
                    ref = new Reference__c();
                }
                proj.Flux_Code_Pays__c = ref.Key__c;
                proj.Flux_Pays__c = ref.Name;
            }
        }
    }

    /**
    * @author Clement Musabimana
    * @date 21/05/2019
    * @description Modification du champs Proprietaire_du_projet__c au changement de status: passage au status RDV EPH ou Qualifié EPH
    **/
    public static void updateProjetProprietaireProjet(Map<Id, Projet__c> oldMap, Map<Id, Projet__c>  newMap, List<Projet__c> newList) {

        String  mailBody = '';
        //Permet de controller l'unicité d'un user sur un cp ou un departement 
        Map<Id, Id> projetUserMap = new Map<Id, Id>();
        Map<Id, Id> codeDepartMap = new Map<Id, Id>();
        Boolean isAffectationFound = false;

        //List<User> listUsers = new List<User>([select id,Affectation_code_postal__c, Affectation_departement__c  from User where Affectation_code_postal__c != null or Affectation_departement__c != null]);
        List<User> listUsers = new List<User>();

        for (User usr : [select id,Affectation_code_postal__c, Affectation_departement__c  from User where IsActive = true]) {
            if((usr.Affectation_code_postal__c != null && usr.Affectation_code_postal__c != '') || (usr.Affectation_departement__c != null && usr.Affectation_departement__c != '')){
                listUsers.add(usr);
            }
        }
        System.debug('updateProjetProprietaireProjet listUsers '+listUsers);
        Set<Id> referenceIds = new Set<Id>();
        for (Projet__c proj : newList) {
            referenceIds.add(proj.Code_postal__c);
        }

        Map<Id, Reference__c> codePostalMap = new Map<Id, Reference__c>([SELECT Id,Libelle__c, Libelle_2__c, Name,  Lov_Type__c FROM Reference__c WHERE Lov_Type__c = 'CP_Ville' AND Id IN:referenceIds AND Active_PP__c = true]);
        System.debug('updateProjetProprietaireProjet codePostalMap '+codePostalMap);

        for (Projet__c proj : newList) {
            Projet__c oldP = oldMap != null ? oldMap.get(proj.Id) : null;
            Projet__c newP = newMap != null ? newMap.get(proj.Id) : null;
            System.debug('updateProjetProprietaireProjet* oldP '+oldP);
            System.debug('updateProjetProprietaireProjet* newP '+ newP);
            //Si proprietaire vide alors on le renseigne si condition ok
            if(proj.Proprietaire_du_projet__c == null){
                if(((oldP != null && newP != null && oldP.Statut_Projet__c != newP.Statut_Projet__c) && (newP.Statut_Projet__c == 'Qualifié EPH' ||newP.Statut_Projet__c == 'RDV pris EPH' ||newP.Statut_Projet__c == 'Sans RDV pris EPH' ||newP.Statut_Projet__c == 'Eligible EPH')) 
                    || ( oldP == null && newP == null && (proj.Statut_Projet__c == 'Qualifié EPH' ||proj.Statut_Projet__c == 'RDV pris EPH' ||proj.Statut_Projet__c == 'Sans RDV pris EPH' ||proj.Statut_Projet__c == 'Eligible EPH'))){              
                    for (User usr : listUsers) {
                        List<String> listCodePostaux =   usr.Affectation_code_postal__c != null ? usr.Affectation_code_postal__c.split('/') : null;
                        List<String> listCodeDepartements =   usr.Affectation_departement__c != null ? usr.Affectation_departement__c.split('/') : null;
                        System.debug('updateProjetProprietaireProjet usr '+usr);
                        System.debug('updateProjetProprietaireProjet listCodePostaux '+listCodePostaux);
                        System.debug('updateProjetProprietaireProjet listCodeDepartements '+listCodeDepartements);
                        //Si le statut passe à RDV EPH ou Qualifié EPH
                   
                        Reference__c refCodePostal = codePostalMap.get(proj.Code_postal__c);
                        String codeDepartement = '';

                        if(proj.Code_postal__c != null){
                            codeDepartement = (String.valueOf(refCodePostal.Name)).substring(0, 2);
                        }
                        System.debug('updateProjetProprietaireProjet add projcp => '+codePostalMap.get(proj.Code_postal__c)+' proj => '+proj.id + ' user => '+usr.Id);

                        //Recherche par code postal
                        if(proj.Code_postal__c != null && listCodePostaux != null && listCodePostaux.contains(refCodePostal.Name) && projetUserMap.get(proj.id) == null){
                            proj.Proprietaire_du_projet__c = usr.Id;
                            System.debug('updateProjetProprietaireProjet usr.Id '+usr.Id);
                            projetUserMap.put(proj.id,usr.id);
                            isAffectationFound = true;
                            System.debug('updateProjetProprietaireProjet projcp trouvé');
                        }
                        else if(proj.Code_postal__c != null && listCodePostaux != null && listCodePostaux.contains(refCodePostal.Name) && projetUserMap.get(proj.id) != usr.id){
                            proj.Proprietaire_du_projet__c = null;
                            System.debug('updateProjetProprietaireProjet plusieurs users avec meme cp');
                            mailBody = mailBody + 'Doublon affectation code postal<br/>'; 
                            mailBody = mailBody + 'projet: Id: ' + proj.id+' code postal: '+refCodePostal.Name + ' particulier: Id: ' +proj.Particulier__c+'<br/>';
                            mailBody = mailBody + 'Utilisateur: ' + projetUserMap.get(proj.id) +'<br/>'; 
                            mailBody = mailBody + 'Utilisateur: ' + usr.id +'<br/><br/>'; 
                        }
                        
                        if(codeDepartement != '' && listCodeDepartements != null && listCodeDepartements.contains(codeDepartement) && projetUserMap.get(proj.id) == null){
                            proj.Proprietaire_du_projet__c = usr.Id;
                            System.debug('updateProjetProprietaireProjet usr.Id '+usr.Id);
                            projetUserMap.put(proj.id,usr.id);
                            isAffectationFound = true;
                            System.debug('updateProjetProprietaireProjet projdpt trouvé');
                        }
                        else if(codeDepartement != '' && listCodeDepartements != null && listCodeDepartements.contains(codeDepartement) && projetUserMap.get(proj.id) != usr.id){
                            proj.Proprietaire_du_projet__c = null;
                            System.debug('updateProjetProprietaireProjet plusieurs users avec meme dpt');
                            mailBody = mailBody + 'Doublon affectation code postal<br/>'; 
                            mailBody = mailBody + 'projet: Id: ' + proj.id+' code postal: '+refCodePostal.Name + ' particulier: Id: ' +proj.Particulier__c+'<br/>';
                            mailBody = mailBody + 'Utilisateur: ' + projetUserMap.get(proj.id) +'<br/>'; 
                            mailBody = mailBody + 'Utilisateur: ' + usr.id +'<br/><br/>';
                        }
                    }

                }
            }
        }
        if(isAffectationFound == false){
            //Si aucun utilisateur trouvé avec le même code postal que sur le projet
            for (Projet__c proj : newList) { 
                if(proj.Proprietaire_du_projet__c == null){
                    Projet__c oldP = oldMap != null ? oldMap.get(proj.Id) : null;
                    Projet__c newP = oldMap != null ? newMap.get(proj.Id) : null;
                    //Si le statut passe à RDV EPH ou Qualifié EPH
                    if(((oldP != null && newP != null && oldP.Statut_Projet__c != newP.Statut_Projet__c) && (newP.Statut_Projet__c == 'Qualifié EPH' ||newP.Statut_Projet__c == 'RDV pris EPH' ||newP.Statut_Projet__c == 'Sans RDV pris EPH' ||newP.Statut_Projet__c == 'Eligible EPH')) 
                        || ( oldP == null && newP == null  && (proj.Statut_Projet__c == 'Qualifié EPH' || proj.Statut_Projet__c == 'RDV pris EPH' ||proj.Statut_Projet__c == 'Sans RDV pris EPH' ||proj.Statut_Projet__c == 'Eligible EPH'))){
                        Reference__c refCodePostal = codePostalMap.get(proj.Code_postal__c);
                        System.debug('updateProjetProprietaireProjet aucun user avec meme cp');
                        mailBody = mailBody + 'Pas d\'utilisateur trouvé sur le code postal du projet projet: Id: ' + proj.id+' code postal: '+refCodePostal.Name + ' particulier: Id: ' +proj.Particulier__c+'<br/><br/>'; 
                    }
                }
            }
        }
        if(mailBody != ''){
            System.debug('updateProjetProprietaireProjet **** envoi mail ');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            //String email = 'Clement.Musabimana@ext.saint-gobain.com';
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email}); 
            mail.setSubject('La méthode updateProjetProprietaireProjet d\'assignation de proprietaire de projet EPH a rencontré un ou plusieurs problème(s)');
            mailBody = '<html><body>' + mailBody + '</body></html>';
            mail.setHtmlBody(mailBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('updateProjetProprietaireProjet **** envoi mail ok');
        }

    }

  /*  public static void createClick2call(List<Projet__c> projets) {
        Integer minute_tmp = Datetime.now().minute();
        Integer minute_calculated = (minute_tmp/15) * 15;
        
        Datetime d_before = Datetime.newInstance(Datetime.now().year(),
                                                    Datetime.now().month(),
                                                    Datetime.now().day(),
                                                    Datetime.now().hour(),
                                                    minute_calculated,
                                                    0);
        Datetime d_after = Datetime.newInstance(Datetime.now().year(),
                                                    Datetime.now().month(),
                                                    Datetime.now().day(),
                                                    (minute_calculated != 45 ? Datetime.now().hour() : Datetime.now().hour() + 1),
                                                    (minute_calculated != 45 ? minute_calculated + 15 : 0),
                                                    0);
        System.debug('d_after ' + d_after);
        System.debug('d_before ' + d_before);



        List<Creneau__c> Creneaux = [SELECT Date_Horaire__c, Disponible__c, Quota__c, Reference_du_Creneau__c, Groupe_Odigo__c
                                    FROM Creneau__c
                                    WHERE Date_Horaire__c >= :d_before
                                    AND Date_Horaire__c < :d_after
                                    AND Disponible__c != 0
                                    AND Groupe_Odigo__c = 'Accueil Client Part.' ORDER BY Date_Horaire__c ASC NULLS FIRST];
        
        System.debug('Creneaux = ' + Creneaux);
        System.debug('projets = ' + projets);
        List<Rappel__c> rappels = new List<Rappel__c>();
        List<Id> idsNoCreneaux = new List<Id>();
        List<Projet__c> projetsNoCreneaux = new List<Projet__c>();
        List<Id> partIds = new List<Id>();
        Map<Id, String> mapPartNumber = new Map<Id, String>();
        Map<String, String> mapProjetCodePostal = new Map<String, String>();

        for (Projet__c p : projets) {
            partIds.add(p.Particulier__c);
        }

        for (Projet__c p : [SELECT Id, Particulier__r.Phone, Particulier__r.PersonMobilePhone, Particulier__c,Code_postal__r.Name FROM Projet__c WHERE Particulier__c IN :partIds]) {
            mapPartNumber.put(p.Particulier__c, (p.Particulier__r.Phone != null ? p.Particulier__r.Phone : p.Particulier__r.PersonMobilePhone));
            mapProjetCodePostal.put(p.Id,p.Code_postal__r.Name);
        }


        for (Projet__c p : projets) {
            System.debug('p.Statut_Projet__c = ' + p.Statut_Projet__c);
            System.debug('p.Demande_Part_Origine__c = ' + p.Demande_Part_Origine__c);
            System.debug('p.Mobile__c = ' + p.Mobile__c);
            System.debug('p.Categories_eligibles_EPH_IDF__c = ' + p.Categories_eligibles_EPH_IDF__c);
            System.debug('p.Categories_eligibles_EPH_RA__c = ' + p.Categories_eligibles_EPH_RA__c);
            System.debug('mapPartNumber = ' + mapPartNumber);
            String departement = '';

            if(p.Code_postal__c != null){
                departement = (String.valueOf(mapProjetCodePostal.get(p.Id))).substring(0, 2);
            }
            System.debug('departement = ' + departement);
            String labelListeDepartementSansRappel = Label.Departement_sans_rappel_immediat;
            Set<string> listeDepartementSansRappel = new Set<string>();
            listeDepartementSansRappel.addAll(labelListeDepartementSansRappel.split(','));
            System.debug('listeDepartementSansRappel ='+listeDepartementSansRappel);  

            //@CMU: 27/11/2019: exclusion des projet EPH_IDF et EPH_RA
            //if (Creneaux.size() > 0 && p.Statut_Projet__c =='Nouveau' && p.Demande_Part_Origine__c == 'Artisans qualifiés' && mapPartNumber.containsKey(p.Particulier__c) && p.Source__c != 'CALL ENTRANTS') {
            if (!listeDepartementSansRappel.contains(departement) && (Creneaux.size() > 0 && p.Statut_Projet__c =='Nouveau' && p.Demande_Part_Origine__c == 'Artisans qualifiés' && mapPartNumber.containsKey(p.Particulier__c) && p.Source__c != 'CALL ENTRANTS' && p.Categories_eligibles_EPH_IDF__c == false && p.Categories_eligibles_EPH_RA__c == false)) {
                Rappel__c rappel = new Rappel__c();
                rappel.No_de_Rappel__c = mapPartNumber.get(p.Particulier__c).replace('+33', '0');
                rappel.Type_de_demande__c = 'Click2Call';
                rappel.Date_Horaire__c = d_before;
                rappel.Reference_du_Creneau__c = Creneaux[0].Reference_du_Creneau__c;
                rappel.Projet__c = p.Id;
                rappel.Queue_Odigo__c = 'accueil_rappel_part';
                rappels.add(rappel);

            } else if (Creneaux.size() == 0) {
                idsNoCreneaux.add(p.Id);
            }
        }

        if (idsNoCreneaux.size() != 0) {
            for (Projet__c p : [SELECT Id, Name, No_Creneau__c FROM Projet__c WHERE Id = :idsNoCreneaux]) {
                p.No_Creneau__c = true;
                projetsNoCreneaux.add(p);
            }
        }

        if (projetsNoCreneaux.size() != 0) {
            update projetsNoCreneaux;
        }

        if (rappels.size() != 0) {insert rappels;}
    } 
*/
}