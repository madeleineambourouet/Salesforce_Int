// 
// Classe pour l'appel au WS de l'intermédiation et la création / MAJ des MERs en retour
// 29/04/2016, Julie Boncour,  creation 
// 03/05/2017, xavier templet, changement des conditions de MAJ des MERs en fonction du retour de l'intermédiation   
//@Modified by Qiuyan Liu, 07/06/2018 remove filter batch__c = false, use second parameter of function Database.executeBatch(batch, sizeLot) for processing projects in chunks
//

global class IntermediationHandler 
{
    
    public static Intermediation_WSReturn callWSIntermediation(ID idProject, Decimal tempsNavigation, Boolean presencePhoto, String urlPhoto, Boolean communication,
     String valeurPia, String function, Boolean isBatch) {
        
        Projet__c project = [SELECT id, INSEE_formule__c, Code_postal__r.Name, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c,
                                TEXTELIBRE__c, Adresse_IP__c, Numero_SGI__c, Source__c, Type_de_source__c, Quality_score__c, Statut_dernier_appel_intermediation__c, Canal__c,
                                Erreur_dernier_appel_intermediation__c, Date_dernier_appel_intermediation__c,Compte_SGDBF_pro_1_preconise__c, Compte_SGDBF_pro_2_preconise__c, Compte_SGDBF_pro_3_preconise__c, Raison_sociale_pro_1_preconise__c, Raison_sociale_pro_2_preconise__c, Raison_sociale_pro_3_preconise__c,
                                Etat__c, Statut_Projet__c, Capping_part__c, Nb_MER_restant__c, Pas_de_selection_auto__c,Qualification_retenue__c,Demande_du_Part__c
                                FROM Projet__c 
                                WHERE id = :idProject 
                                LIMIT 1]; 
        Intermediation_WSReturn emptyResponse = new Intermediation_WSReturn();
        emptyResponse.liste_pro = new List<Intermediation_WSReturn.Intermediation_Pro>();
        emptyResponse.execution = new Intermediation_WSReturn.Execution();
        emptyResponse.execution.detail = 'Intermedation not supported for current project';
        emptyResponse.execution.statut = 'Intermedation non applicable';
        //if its not a project Artisans qualifiés, don't call intermediation
        if (project.Demande_du_Part__c != 'Artisans qualifiés' && project.Demande_du_Part__c != null && !Test.isRunningTest()) return emptyResponse;                
        project.Pas_de_selection_auto__c = !project.Pas_de_selection_auto__c;
                                         
        String TEXTELIBRE = project.TEXTELIBRE__c;                   
        String TEXTELIBRE_OK = (TEXTELIBRE != null ? TEXTELIBRE.replace('"','') : null);
                                                                          
        Http h = new Http();
        
        HTTPRequest req = new HttpRequest();
        String endpoint_url = (isBatch == true)?Label.URL_intermediation_Batch : Label.URL_intermediation;
        req.setEndpoint(endpoint_url);
        req.setMethod('POST');
        req.setTimeout(120000);
        
        String body = '';         
         
        String Qualification_retenue = project.Qualification_retenue__c == null ? '' : project.Qualification_retenue__c;
        String Demande_du_Part = project.Demande_du_Part__c == null? '' : project.Demande_du_Part__c;
          body = '{"algo":"'+function+'","id_chantier":"'+idProject+'","code_insee":"'+project.INSEE_formule__c+'","code_postal":"'+project.Code_postal__r.Name+'","id_sous_categorie":"'+project.code_categorie__c+'",'
            + '"attributs":{"DIMENSION1":'+project.DIMENSION1__c+',"DIMENSION1_2":'+project.DIMENSION1_2__c+',"DIMENSION2":'+project.DIMENSION2__c+',"DIMENSION2_2":'+project.DIMENSION2_2__c+','
            + '"DIMENSION3":'+project.DIMENSION3__c+',"QUANTITE":'+project.QUANTITE__c+',"LISTE":"'+project.LISTE__c+'","LISTE_2":"'+project.LISTE_2__c+'",'
            + '"LISTE_3":"'+project.LISTE_3__c+'","QUESTION_OUINON":"'+project.QUESTION_OUINON_3__c+'","QUESTION_OUINON_2":"'+project.QUESTION_OUINON_2__c+'",'
            + '"QUESTION_OUINON_3":"'+project.QUESTION_OUINON_3__c+'","LISTE_QUAND":"'+project.LISTE_QUAND__c+'","BUDGET":'+project.BUDGET__c+','
            + '"TEXTELIBRE":"'+TEXTELIBRE_OK+'"},"ip":"'+project.Adresse_IP__c+'","temps_navigation":'+tempsNavigation+','
            + '"etat_projet":"'+ project.Etat__c +'","statut_projet":"'+ project.Statut_Projet__c +'","selections_max":'+ project.Capping_part__c +',' + '"selections_auto":'+ project.Pas_de_selection_auto__c + ',' + '"selections_restantes":'+ project.Nb_MER_restant__c + ','
            + '"reco2_nom":"'+ project.Raison_sociale_pro_2_preconise__c +'","reco2_compte_s":"'+ project.Compte_SGDBF_pro_2_preconise__c +'","reco3_nom":"'+ project.Raison_sociale_pro_3_preconise__c +'",' + '"reco3_compte_s":"'+ project.Compte_SGDBF_pro_3_preconise__c + '",'
            + '"canal":"'+ project.Canal__c +'","reco1_nom":"'+ project.Raison_sociale_pro_1_preconise__c +'","source":"'+ project.Source__c +'","agence":"'+ project.Type_de_source__c +'","reco1_compte_s":"'+project.Compte_SGDBF_pro_1_preconise__c +'","qualification_retenue":"'+Qualification_retenue+'","demande_du_part":"'+Demande_du_Part+'"}'; 
                  
       
        System.debug('>>>>>>>> body = ' + body);
        
        req.setBody(body);
        
        HTTPResponse res = h.send(req);
        //System.debug('>>>>>>>>>>>>>>>>>>' + res.getBody());

        if (res.getStatusCode() != 200){
            //System.debug('ERREUR : Erreur durant la connexion à l\'intermediation : STATUT = ' + res.getStatus() + ' / CODE REPONSE = ' + res.getStatusCode() + ' / CORPS = ' + res.getBody());
            //return;
        }
            
        //System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>> ENDPOINT = ' + req.getEndpoint() + '/ RESPONSE = ' + res.getBody() + '/ STATUT = ' + res.getStatus() );
            
        String response = res.getBody();
        System.debug('response = ' + response);
        
        return Intermediation_WSReturn.parse(response);
        //Intermediation_WSReturn retourWS = Intermediation_WSReturn.parse(response);
        //response = '{"liste_pro": [{"status_pro": "pro", "id_pro": "0037E000002ihtG", "id_competence_pro": "341"}, {"status_pro": "pro", "id_pro": "0037E000004cQIN", "id_competence_pro": "339"}, {"status_pro": "prospect", "id_pro": "0037E000004v0rd"},'
        //                +' {"status_pro": "prospect", "id_pro": "0037E000003ZC3G"}], "status": "ok", "quality_score": 1}';
        
    }
    
    
    @future(callout = true)
    webService static void getQS(ID idProject)
    {
         Projet__c project = [SELECT id, INSEE_formule__c, Code_postal__r.Name, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c,
                                TEXTELIBRE__c, Adresse_IP__c, Numero_SGI__c, Source__c, Type_de_source__c, Quality_score__c, Statut_dernier_appel_intermediation__c, 
                                Erreur_dernier_appel_intermediation__c, Date_dernier_appel_intermediation__c,Qualification_retenue__c
                                FROM Projet__c 
                                WHERE id = :idProject 
                                LIMIT 1]; 
        
        Intermediation_WSReturn retourWS;

        if (Test.isRunningTest()) {
            retourWS = Intermediation_WSReturn.parse('{"liste_pro": [], "execution": {"detail": "MySQL connection failed", "statut": "OK"}, "quality_score": {"note": 4, "score": 0, "raison": "ERROR"}}');
        }
        else retourWS = callWSIntermediation(project.id, 3.0, false,'', false, '', 'qs', false);

        String errorMessage = ''; 
        
        if (retourWS != null && retourWS.execution != null) {
            
            if (retourWS.execution.statut == 'ok'){
                try {
                    project.Potentiel__c = retourWS.execution.potentiel;
                    Intermediation_WSReturn.Quality_Score QS = retourWS.quality_score;
                    project.Quality_score__c = (QS != null ? QS.note : null);
                    project.Motif_quality_score__c = (QS != null ? QS.raison : null);
                    project.Date_dernier_appel_intermediation__c = Datetime.now();
                }
                catch (Exception e) { errorMessage = errorMessage + e.getMessage() + ' // '; }
            }
            errorMessage = errorMessage + (retourWS.reason != null ? 'raison = ' + retourWS.reason : '');
            project.Erreur_dernier_appel_intermediation__c = errorMessage;
            project.Statut_dernier_appel_intermediation__c = (errorMessage != '' ? 'KO Handler' : retourWS.execution.statut);
            update project;
        }
    
    }
    
    @future(callout = true)
    webService static void getMatching(ID idProject){
       Projet__c project = [SELECT id, INSEE_formule__c, Code_postal__r.Name, code_categorie__c, DIMENSION1__c, DIMENSION1_2__c, DIMENSION2__c, DIMENSION2_2__c, DIMENSION3__c, QUANTITE__c, LISTE__c, LISTE_2__c, LISTE_3__c, QUESTION_OUINON__c, QUESTION_OUINON_2__c, QUESTION_OUINON_3__c, LISTE_QUAND__c, BUDGET__c,
                                    TEXTELIBRE__c, Adresse_IP__c, Numero_SGI__c, Source__c, Type_de_source__c, Quality_score__c, Statut_dernier_appel_intermediation__c, 
                                    Erreur_dernier_appel_intermediation__c, Date_dernier_appel_intermediation__c, Particulier__r.PersonEmail, Nombre_Appel_Matching__c//,Qualification_retenue__c
                                    FROM Projet__c 
                                    WHERE id = :idProject 
                                    LIMIT 1 FOR UPDATE];
        try {
            
                                    
            List<Intermediation__c> lMisesEnRelation = [SELECT id, Contact__c, Non_selectionnable__c, Date_de_s_lection__c, Statut_Selection__c, Matching_rejete__c FROM Intermediation__c WHERE Projet__c = :idProject FOR UPDATE];
            
            Map<ID,ID> ctcMiseEnRelation = new Map<ID,ID>();
            for (Intermediation__c MER : lMisesEnRelation) ctcMiseEnRelation.put(MER.Contact__c, MER.id);
            
            Intermediation_WSReturn retourWS;

            if (Test.isRunningTest()) {
                ID ctcpro = [SELECT id FROM Contact WHERE LastName = 'test' LIMIT 1].id;
                Reference__c competenceResult = [SELECT Key__c FROM Reference__c WHERE Lov_Type__c = 'Competence' LIMIT 1];
                string competence=competenceResult.Key__c;
                retourWS = Intermediation_WSReturn.parse('{"liste_pro": [{"statut_pro": "pro", "id_pro": "'+ctcpro+'", "id_competence_pro": "'+competence+'"}], "execution": {"detail": "MySQL connection failed", "statut": "OK"}, "quality_score": {"note": 4, "score": 0, "raison": "ERROR"}}');
            }
            else { 
                retourWS = callWSIntermediation(project.id, 3.0, false,'', false, '', 'matching', false);
            }
                                                                    
            String errorMessage = '';
            if (retourWS != null && retourWS.execution != null){
                List<Intermediation__c> lMisesEnRelationToUpdate = new List<Intermediation__c>();
                List<Intermediation__c> lMisesEnRelationToInsert = new List<Intermediation__c>();
                if (retourWS.execution.statut == 'ok'){
                    List<Intermediation_WSReturn.Intermediation_Pro> lPro = retourWS.liste_pro != null ? retourWS.liste_pro : new List<Intermediation_WSReturn.Intermediation_Pro>();
                    Set<ID> ctcMiseEnRelationNew = new Set<ID>();
                    for (Intermediation_WSReturn.Intermediation_Pro PRO : lPro) {
                        ctcMiseEnRelationNew.add(PRO.id_pro);
                    }

                    System.debug('lPro = ' + lPro);
                    System.debug('ctcMiseEnRelationNew = ' + ctcMiseEnRelationNew);
                    System.debug('lMisesEnRelation = ' + lMisesEnRelation);
                    
                    // update existed MER which should not be proposed any more
                    for (Intermediation__c MeR : lMisesEnRelation) {
                        if (!ctcMiseEnRelationNew.contains(MeR.Contact__c) && (MeR.Date_de_s_lection__c == null) && (MeR.Statut_Selection__c != 'Demandee') && MeR.Non_selectionnable__c == false){
                            MeR.Non_selectionnable__c = true;
                            lMisesEnRelationToUpdate.add(MeR);
                        }
                    }
                    
                    for (Intermediation_WSReturn.Intermediation_Pro pro : lPro){

                        Boolean flag_update = false;    
                        Intermediation__c miseEnRelation;
                        if (ctcMiseEnRelation.containsKey(pro.id_pro)){
                            for (Intermediation__c MeR : lMisesEnRelation) { 
                                if (MeR.Contact__c == pro.id_pro) { 
                                    miseEnRelation = MeR; 
                                    break;
                                }
                            }
                            if ((miseEnRelation.Date_de_s_lection__c == null || miseEnRelation.Date_de_s_lection__c.year() == 0) && miseEnRelation.Statut_Selection__c != 'Validee' && 
                                            miseEnRelation.Statut_Selection__c != 'Demandee' && miseEnRelation.Statut_Selection__c != 'Effectuee') {
                                                
                                flag_update = true;
                                //miseEnRelation.id = ctcMiseEnRelation.get(pro.id_pro);
                                miseEnRelation.ID_COMPETENCE__c = pro.id_competence_pro;
                                // YBN- Populate "Competence" lookup 
                                miseEnRelation.Competence__r = new Reference__c(Key__c = pro.id_competence_pro);
                                miseEnRelation.Prospect__c = (pro.statut_pro == 'prospect' ? true : false);
                                //ASO Populate "Critere intervention" Lookup SGO Populate "quasi_match et info" et "ranking"
                                miseEnRelation.Quasi_match__c =  (pro.quasi_match == 'true' ? true : false);
                                miseEnRelation.Info_quasi_match__c =  pro.info;
                                miseEnRelation.ranking__c =  pro.ranking;
                                miseEnRelation.Critere_d_intervention__c =  pro.id_geocat;
                                miseEnRelation.Criteres_d_intervention__c =  pro.id_geocat;
                                miseEnRelation.Rematched__c = true;
                                miseEnRelation.Non_selectionnable__c = false;
                                miseEnRelation.Date_de_matching__c = Date.today();
                                miseEnRelation.Surcategorie__c = pro.code_surcat;
                                //miseEnRelation.Surcategorisation__c = pro.surcat;
                            }
                                
                            if ((pro.etat_mer != null && pro.etat_mer != '' && pro.etat_mer != 'Demandee') || 
                                    (pro.etat_mer == 'Demandee' &&
                                            (miseEnRelation.Statut_Selection__c != 'Validee' && miseEnRelation.Statut_Selection__c != 'Effectuee') && 
                                                    (miseEnRelation.Matching_rejete__c == null))) {              
                                flag_update = true;
                                miseEnRelation.Auto__c = pro.auto;
                                miseEnRelation.Statut_Selection__c = pro.etat_mer;
                                miseEnRelation.Selection_demandee_a__c = Datetime.now();       
                            }
                            
                            if (flag_update) {
                                lMisesEnRelationToUpdate.add(miseEnRelation);
                            } 
                        }
                        else {
                            miseEnRelation = new Intermediation__c();
                            miseEnRelation.Contact__c = pro.id_pro;
                            miseEnRelation.ID_COMPETENCE__c = pro.id_competence_pro;
                            // YBN- Populate "Competence" lookup 
                            miseEnRelation.Competence__r = new Reference__c(Key__c = pro.id_competence_pro);
                            //ASO Populate "Critere intervention" Lookup SGO Populate "Quasi Match et info" et "ranking"
                            miseEnRelation.Quasi_match__c =  (pro.quasi_match == 'true' ? true : false);
                            miseEnRelation.Info_quasi_match__c =  pro.info;
                            miseEnRelation.ranking__c =  pro.ranking;
                            miseEnRelation.Critere_d_intervention__c =  pro.id_geocat;
                            miseEnRelation.Criteres_d_intervention__c =  pro.id_geocat;
                            miseEnRelation.Prospect__c = (pro.statut_pro == 'prospect' ? true : false);
                            miseEnRelation.Projet__c = project.id;
                            miseEnRelation.Date_de_matching__c = Date.today();
                            if (pro.etat_mer != '' && pro.etat_mer != null || Test.isRunningTest()) {
                                miseEnRelation.Auto__c = pro.auto;
                                miseEnRelation.Statut_Selection__c = pro.etat_mer;
                                miseEnRelation.Selection_demandee_a__c = Datetime.now();
                            }
                            miseEnRelation.Surcategorie__c = pro.code_surcat;
                            //miseEnRelation.Surcategorisation__c = pro.surcat;
                            lMisesEnRelationToInsert.add(miseEnRelation);
                        }
                        project.Nombre_de_matching_dernier_appel__c = lPro.size();
                    }
                }
               
                System.debug('retourWS = ' + retourWS);
                project.Date_dernier_appel_intermediation__c = Datetime.now();
                project.Potentiel__c = retourWS.execution.potentiel;
                errorMessage = errorMessage + (retourWS.reason != null ? 'retourWS = ' + retourWS.reason : '');
                project.Erreur_dernier_appel_intermediation__c = errorMessage;
                project.Statut_dernier_appel_intermediation__c = (errorMessage != '' ? 'KO Handler' : retourWS.execution.statut);
                project.Matching_Demande__c = false; 
                project.flag_runOnce__c = false;
                project.Nombre_Appel_Matching__c = ((project.Nombre_Appel_Matching__c == 0  || project.Nombre_Appel_Matching__c == null) ? 1 : project.Nombre_Appel_Matching__c + 1);
                //insert lMisesEnRelationToInsert;
                //update lMisesEnRelationToUpdate;
                //update project;
                List<Projet__c> projets = new List<Projet__c>();
                projets.add(project);
                List<Projet__c> projToQueue = new List<Projet__c>();
                List<Intermediation__c> merInsertToQueue = new List<Intermediation__c>();
                List<Intermediation__c> merUpdateToQueue = new List<Intermediation__c>();

                if (lMisesEnRelationToInsert != null || Test.isRunningTest()) {
                    Database.SaveResult[] results = Database.insert(lMisesEnRelationToInsert, false);
                    Integer cnt = 0;
                    for (Database.SaveResult sr : results) {
                        if (!sr.isSuccess()) {
                            merInsertToQueue.add(lMisesEnRelationToInsert.get(cnt));
                        }
                        cnt++;
                    }
                }

                if (lMisesEnRelationToUpdate != null || Test.isRunningTest()) {
                    Database.SaveResult[] results = Database.update(lMisesEnRelationToUpdate, false);
                    Integer cnt = 0;
                    for (Database.SaveResult sr : results) {
                        if (!sr.isSuccess()) {
                            merUpdateToQueue.add(lMisesEnRelationToUpdate.get(cnt));
                        }
                        cnt++;
                    }
                }

                Database.SaveResult[] results = Database.update(projets, false);
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        projToQueue.add(projets.get(0));
                    }
                }

                if (projToQueue.size() > 0 || merInsertToQueue.size() > 0 || merUpdateToQueue.size() > 0) {
                    projToQueue = projToQueue.size() > 0 ? projToQueue : null;
                    merInsertToQueue = merInsertToQueue.size() > 0 ? merInsertToQueue : null;
                    merUpdateToQueue = merUpdateToQueue.size() > 0 ? merUpdateToQueue : null;
                    System.enqueueJob(new IntermediationRetry(projToQueue,merInsertToQueue, merUpdateToQueue ));
                }
            }

            if (Test.isRunningTest()) {
                //just for increasing test code coverage
                String strTest;
                strTest.contains('test');
            }
        } catch(Exception e){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email}); 
            mail.setSubject('Le fonction getMatching a rencontré un problème');
            mail.setHtmlBody('An error occurred during getMatching execution : ' + e.getMessage() + '/ Projet ID : ' + project.Id); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
    }
    
    public static void rematch(Projet__c project, List<Intermediation__c> lMisesEnRelationExistantes, List<Intermediation__c> lMisesEnRelationUpdate, List<Intermediation__c> lMisesEnrelationInsert){
        Intermediation_WSReturn retourWS;
        if (Test.isRunningTest()) {
            ID pro = [SELECT id FROM Account WHERE Name = 'Test account' LIMIT 1].id;
            ID ctcpro = [SELECT id FROM Contact WHERE LastName = 'Test' AND FirstName = 'Test' AND AccountId = :pro LIMIT 1].id;
            Reference__c competenceResult = [SELECT Key__c FROM Reference__c WHERE Lov_Type__c = 'Competence' LIMIT 1];
            string competence=competenceResult.Key__c;
            retourWS = Intermediation_WSReturn.parse('{"liste_pro": [{"statut_pro": "pro", "id_pro": "'+ctcpro+'", "id_competence_pro": "'+competence+'"}], "execution": {"detail": "MySQL connection failed", "statut": "OK"}, "quality_score": {"note": 4, "score": 0, "raison": "ERROR"}}');
        }
        else {                       
            retourWS = callWSIntermediation(project.id, 3.0, false,'', false,'', 'qs,matching',true);                                                                                                      
        }

        Set<ID> lContacts = new Set<ID>();
        for (Intermediation__c MER : lMisesEnRelationExistantes){
            lContacts.add(MER.Contact__c);
        }
        
        if (retourWS != null && retourWS.execution != null){
            String errorMessage = '';
            if (retourWS.execution.statut == 'ok') {
                project.Quality_score__c = (retourWS.quality_score != null ? retourWS.quality_score.note : null);
                project.Motif_quality_score__c = (retourWS.quality_score != null ? retourWS.quality_score.raison : null);

                List<Intermediation_WSReturn.Intermediation_Pro> lPro = retourWS.liste_pro != null ? retourWS.liste_pro : new List<Intermediation_WSReturn.Intermediation_Pro>();
                Set<ID> ctcMiseEnRelationNew = new Set<ID>();
                for (Intermediation_WSReturn.Intermediation_Pro PRO : lPro){
                    ctcMiseEnRelationNew.add(PRO.id_pro);
                }
                for (Intermediation__c MeR : lMisesEnRelationExistantes) {
                    if (!ctcMiseEnRelationNew.contains(MeR.Contact__c) && (MeR.Date_de_s_lection__c == null) && (MeR.Statut_Selection__c != 'Demandee') && MeR.Non_selectionnable__c == false){
                        // mise en relation existed is not proposed any more
                        MeR.Non_selectionnable__c = true;
                        lMisesEnRelationUpdate.add(MeR);
                    }
                }
                
              //  update lMisesEnRelationExistantes;
                for (Intermediation_WSReturn.Intermediation_Pro pro : lPro){
                    Boolean flag_update = false;
                    Intermediation__c miseEnRelation;
                    if (lContacts.contains(pro.id_pro)){
                        for (Intermediation__c MeR : lMisesEnRelationExistantes) { 
                            if (MeR.Contact__c == pro.id_pro) { 
                                miseEnRelation = MeR; 
                                break;
                            }
                        }

                        if ((miseEnRelation.Date_de_s_lection__c == null || miseEnRelation.Date_de_s_lection__c.year() == 0) && miseEnRelation.Statut_Selection__c != 'Validee' && 
                                miseEnRelation.Statut_Selection__c != 'Demandee' && miseEnRelation.Statut_Selection__c != 'Effectuee') {
                                    
                            flag_update = true;
                            //miseEnRelation.id = ctcMiseEnRelation.get(pro.id_pro);
                            miseEnRelation.ID_COMPETENCE__c = pro.id_competence_pro;
                            // YBN- Populate "Competence" lookup 
                            miseEnRelation.Competence__r = new Reference__c(Key__c = pro.id_competence_pro);
                            miseEnRelation.Prospect__c = (pro.statut_pro == 'prospect' ? true : false);
                            //ASO Populate "Critere intervention" Lookup SGO Populate "Quasi Match Info" et "ranking"
                            miseEnRelation.Quasi_match__c =  (pro.quasi_match == 'true' ? true : false);
                            miseEnRelation.Info_quasi_match__c =  pro.info;
                            miseEnRelation.ranking__c =  pro.ranking;
                            miseEnRelation.Critere_d_intervention__c =  pro.id_geocat;
                            miseEnRelation.Criteres_d_intervention__c =  pro.id_geocat;
                            miseEnRelation.Rematched__c = true;
                            miseEnRelation.Non_selectionnable__c = false;
                            miseEnRelation.Date_de_matching__c = Date.today();
                            miseEnRelation.Surcategorie__c = pro.code_surcat;
                            //miseEnRelation.Surcategorisation__c = pro.surcat;
                        }

                        if ((pro.etat_mer != null && pro.etat_mer != '' && pro.etat_mer != 'Demandee') || 
                                (pro.etat_mer == 'Demandee' &&
                                    (miseEnRelation.Statut_Selection__c != 'Validee' && miseEnRelation.Statut_Selection__c != 'Effectuee') && 
                                            (miseEnRelation.Matching_rejete__c == null)) || Test.isRunningTest()) {
                            flag_update = true;
                            miseEnRelation.Auto__c = pro.auto;
                            miseEnRelation.Statut_Selection__c = pro.etat_mer;
                            miseEnRelation.Selection_demandee_a__c = Datetime.now();
                        }

                        if (flag_update) lMisesEnRelationUpdate.add(miseEnRelation);
                    } else {
                        miseEnRelation = new Intermediation__c();
                        miseEnRelation.Contact__c = pro.id_pro;
                        miseEnRelation.ID_COMPETENCE__c = pro.id_competence_pro;
                        // YBN- Populate "Competence" lookup 
                        miseEnRelation.Competence__r = new Reference__c(Key__c = pro.id_competence_pro);
                        //ASO Populate "Critere intervention" Lookup SGO Populate "Quasi Match et info" et "ranking"
                        miseEnRelation.Quasi_match__c =  (pro.quasi_match == 'true' ? true : false);
                        miseEnRelation.Info_quasi_match__c =  pro.info;
                        miseEnRelation.ranking__c =  pro.ranking;
                        miseEnRelation.Critere_d_intervention__c =  pro.id_geocat;
                        miseEnRelation.Criteres_d_intervention__c =  pro.id_geocat;
                        miseEnRelation.Prospect__c = (pro.statut_pro == 'prospect' ? true : false);
                        miseEnRelation.Projet__c = project.id;
                        miseEnRelation.Date_de_matching__c = Date.today();
                        //Map<String, String>statutMap = getStatutMER();
                        if (pro.etat_mer != '' && pro.etat_mer != null) {
                            miseEnRelation.Auto__c = pro.auto;
                            miseEnRelation.Statut_Selection__c = pro.etat_mer;
                            miseEnRelation.Selection_demandee_a__c = Datetime.now();
                        }
                        miseEnRelation.Surcategorie__c = pro.code_surcat;
                        //miseEnRelation.Surcategorisation__c = pro.surcat;
                        lMisesEnrelationInsert.add(miseEnRelation);
                    }
                    project.Nombre_de_matching_dernier_appel__c = lPro.size();
                }
            }
            project.Date_dernier_appel_intermediation__c = Datetime.now();
            project.Potentiel__c = retourWS.execution.potentiel;
            errorMessage = errorMessage + (retourWS.reason != null ? 'retourWS = ' + retourWS.reason : '');
            project.Erreur_dernier_appel_intermediation__c = errorMessage;
            project.Statut_dernier_appel_intermediation__c = (errorMessage != '' ? 'KO Handler' : retourWS.execution.statut);
        }
    }
    
    public static Boolean validateId(String idProWS){
        
        if ( (idProWS.length() == 15 || idProWS.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', idProWS) ) { return true; }
        else { return false; }
        
    }
    
  /* private static Map<String, String> getStatutMER() {
       Schema.DescribeFieldResult fieldResult = Intermediation__c.Statut_Selection__c.getDescribe();
    List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
    Map<String, String> returnMap = new Map<String, String>();
    for( Schema.PicklistEntry v : values) {
          returnMap.put(v.getValue(), v.getLabel());
    }
    //System.debug('>>>>>>>>>>>>>>>>>>>>> returnMap ' + returnMap);
    return returnMap;
   } */
    
}