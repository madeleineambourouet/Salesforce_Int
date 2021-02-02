/**
 * @File Name          : MatchMethods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 01-16-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/24/2020   Hassan Dakhcha     Initial Version
**/
public class MatchMethods {
  
    public static HttpResponse res ;
    /**
    * @description 
    * @author Hassan Dakhcha | 3/30/2020 
    * @param accountId 
    * @return List<MatchObjectClass> 
    **/
    @AuraEnabled
    public static List<MatchObjectClass> getMatchForSObject(id objectId) {
        String idStr = (String)objectId;
        List<String> prjIds = null;
        List<String> proIds = null;
        if(idStr.startsWith('001')) {
            Account  acc = [SELECT id, Contact_principal__r.External_Contact_id__c FROM Account WHERE id=:objectId];
            if(acc.Contact_principal__r.External_Contact_Id__c == null || acc.Contact_principal__r.External_Contact_Id__c =='')
                return null;
                
            proIds = new List<String>();
            proIds.add(acc.Contact_principal__r.External_Contact_Id__c);
        } else {
            PROJET_LMSG__C projet = [SELECT id, Identifiant_PP__c FROM Projet_LMSG__C WHERE id = :objectId];
            if(projet.Identifiant_PP__c==null || projet.Identifiant_PP__c=='')
                return null;
            prjIds = new List<String>();
            prjIds.add(projet.Identifiant_PP__c);
        }

        List<MatchObjectClass> mList = handleCallout(proIds, prjIds, true);

        //for(MatchObjectClass mat : mList)
            //System.debug('#### HDAK handleCaloutForAccount : Match ' + mat);

        if(mList == null) {
            throw new AuraHandledException(res.getStatus());
        }
        return mList;
    }

    @AuraEnabled
    public static string getMatchNumber(String objectId) {
        String objectName = objectId.startsWith('001') ? 'ACCOUNT' : 'Projet_LMSG__C';
        String query = 'SELECT id, Nombre_de_Match_visibles__c, Nombre_total_de_Match__c FROM ' + objectName + '  WHERE id=\'' + objectId+ '\'';
        SObject obj =  Database.query(query);

        Decimal numAccMatch = 0;
        Decimal numPrjMatch = 0;
        if(Label.ActivateMatchFix == 'TRUE') {
            numAccMatch = objectName == 'ACCOUNT' ? (((Account)obj).Nombre_total_de_Match__c==null? 0 : ((Account)obj).Nombre_total_de_Match__c) : 0;
            numPrjMatch = objectName != 'ACCOUNT' ? (((Projet_LMSG__C)obj).Nombre_total_de_Match__c==null? 0 : ((Projet_LMSG__C)obj).Nombre_total_de_Match__c) : 0;
            //System.debug('##### HDAK match Fix Activated getMatchNumber  : ' +  numAccMatch + numPrjMatch);
        } else {
            numAccMatch = objectName == 'ACCOUNT' ? (((Account)obj).Nombre_de_Match_visibles__c==null? 0 : ((Account)obj).Nombre_de_Match_visibles__c) : 0;
            numPrjMatch = objectName != 'ACCOUNT' ? (((Projet_LMSG__C)obj).Nombre_de_Match_visibles__c==null? 0 : ((Projet_LMSG__C)obj).Nombre_de_Match_visibles__c) : 0;
        }

        return '  Nombre total de matchs : ' + String.valueOf(numAccMatch+numPrjMatch);
    }

    /**
    * @description 
    * @author Hassan Dakhcha | 3/24/2020 
    * @return  Map<String, Integer> 
    **/
    public static Map<id, Map<String, Integer>> CountMatchsForObjects(List<String> proIds, List<String> projectIds, Boolean filterArchived) {
        Map< id, Map<String, Integer>> counterMap = new Map<id, Map<String, Integer>>();
        if(proIds==null && projectIds==null)
           return null;
                    
        List<MatchObjectClass> lMatch = null;		
        try {		
            lMatch = handleCallout(proIds, projectIds, filterArchived);
        } catch(Exception exp) {		
            //System.debug('### HDAK match exception =  '+ exp.getMessage());		
            return counterMap;		
        }		
        
        if(lMatch == null)
            return counterMap;

        String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' ;
        for(MatchObjectClass match : lMatch) {
            String idAccFromMatch = match.AccountURL.substringBetween(baseURL, '/view?0.source=alohaHeader');
            if(idAccFromMatch!=null && idAccFromMatch !='') {
                Map<String, Integer> indicateur = counterMap.get(idAccFromMatch);
                if(indicateur==null) {
                    indicateur = new Map<String, Integer> {'numVis' => 0, 'NumPos' => 0};
                    counterMap.put(idAccFromMatch, indicateur);
                }

                if(Label.ActivateMatchFix == 'TRUE') {
                    if(match.viewable == true) {
                        indicateur.put('numVis', indicateur.get('numVis')+1);
                    }
                    if(match.positionable == true) {
                        indicateur.put('NumPos' , indicateur.get('NumPos')+1);
                    }
                } else {
                    // update nombre de match:
                    if(match.viewable == true) {
                        indicateur.put('numVis', indicateur.get('numVis')+1);
                        //update nombre de positionnable:
                        if(match.positionable == true) {
                            //System.debug('##### HDAK positionable ' + idAccFromMatch );
                            indicateur.put('NumPos' , indicateur.get('NumPos')+1);
                        }
                    }
                }
            }

            String idPrjFromMatch = match.ProjectURL.substringBetween(baseURL, '/view?0.source=alohaHeader');
            if(idPrjFromMatch!=null && idPrjFromMatch!='') {
                Map<String, Integer> indicateur = counterMap.get(idPrjFromMatch);
                if(indicateur==null) {
                    indicateur = new Map<String, Integer>{'numVis' => 0, 'NumPos' => 0};
                    counterMap.put(idPrjFromMatch, indicateur);
                }

                if(Label.ActivateMatchFix == 'TRUE') {
                    if(match.viewable == true) {
                        indicateur.put('numVis' , indicateur.get('numVis')+1);
                    }
                    if(match.positionable == true) {
                        indicateur.put('NumPos' , indicateur.get('NumPos')+1);
                    }
                } else {
                    if(match.viewable == true) {
                        indicateur.put('numVis' , indicateur.get('numVis')+1);
                        if(match.positionable == true) {
                            indicateur.put('NumPos' , indicateur.get('NumPos')+1);
                        }
                    }
                }
            }   
        }
        return counterMap;
    }


    public static List<Map<String, String>> getMatchList(List<String> proIds, List<String> projectIds, Boolean filterArchived) {
        List<Map<String, String>> matchList = null;
        try {
            res = getMatchs(proIds, projectIds, filterArchived);
            //System.debug('#### HDAK response  ' + res);
        } catch(Exception e) {    
            System.debug('#### HDAK Exception lors de l\'appel a WBE: ' + e.getMessage());
            /*
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email});
            mail.setSubject('Erreur lors de l\'appel a WBE pour recuperer les matchs');
            String body='Une erreur lors de l\'appel a WBE pour recuperer les matchs, si c\'est le batch ce lots ne va pas etre mis a jours, mais les autres lots de 50 le seront. </BR>';
            body += 'l\'erreur est la suivante : ' + e.getMessage() + '</BR>';
            body += '# STACK TRACE : </BR>';
            body += e.getStackTraceString();
            body += ' ------------------- </BR>';
            if(proIds!=null) {
                 body += ' Liste des pros : </BR>';
                body += ' ------------------- </BR>';
                for(String str : proIds)
                    body += str + ' ';
            }
            if(projectIds!=null) {
                body += ' ------------------- </BR>';
                body += ' Liste des projets : </BR>';
                body += ' ------------------- </BR>';
                for(String str : projectIds)
                    body += str + ' ';
            }
            
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            */
            return null;
        }

     /*   if(res != null || res.getStatusCode() == 401 ) {
            // may have glitch on expire date of the token
            res = getMatchs(proIds, projectIds);
            System.debug('#### HDAK response  ' + res);

        } */
       
        if (res != null && res.getStatusCode() == 200) {
            String resJson = res.getBody();
            //System.debug('#### HDAK json  ' + resJson);
            matchList = new List<Map<String, String>>();

            List<Object> objList = (List<Object>)JSON.deserializeUntyped(resJson);
            for(Object obj : objList) {
                Map<String, Object> matchBody = (Map<String, Object>)obj;
                matchList.add(new Map<String, String> { 'projectWbeId' => (String)matchBody.get('projectId') ,
                                                        'proWbeId' => (String)matchBody.get('userId') ,
                                                        'status' => (String)matchBody.get('status'),
                                                        'createdDate' =>  (String)matchBody.get('createdAt'),
                                                        'positionable' => matchBody.get('positionable')==true? 'true':'false',
                                                        'positionedCount' => String.valueOf(matchBody.get('positionedCount')) });
            }
        } else {
            System.debug('#### HDAK batch : Token   ' + res);
            System.debug('#### HDAK batch : Token   ' + res.getBody());
        }
        return matchList;
    }

    /**
    * @description 
    * @author Hassan Dakhcha | 3/24/2020 
    * @return String 
    **/
    private static List<MatchObjectClass> handleCallout(List<String> proIds, List<String> projectIds, Boolean filterArchived) {
            List<MatchObjectClass> sfMatchList = new List<MatchObjectClass>();
            List<Map<String, String>> matchList= getMatchList(proIds, projectIds, filterArchived);
            if(matchList == null) {
                return sfMatchList;
            }
            Set<String> projectWBEIdSet = new Set<String>();
            if(projectIds!=null) {
                projectWBEIdSet.addAll(projectIds);
            }

            Set<String> proWBEIdSet = new Set<String>();
            if(proIds!=null) {
                proWBEIdSet.addAll(proIds);
            }

            for(Map<String, String> mapElem : matchList) {
                projectWBEIdSet.add(mapElem.get('projectWbeId'));
                proWBEIdSet.add(mapElem.get('proWbeId'));
            }

           // bind the PRO/Project wbe to the PRO/Project SF
            List<Account> accList = new List<Account>();
            if(!proWBEIdSet.isEmpty()) {
                accList = [ SELECT id, Contact_principal__r.External_Contact_Id__c,  Name, Nombre_de_Match_visibles__c ,Nombre_de_matchs_Pros_positionnables__c
                            FROM Account WHERE Contact_principal__r.External_Contact_Id__c IN : proWBEIdSet];
            }
            List<Projet_LMSG__C> prjList = new List<Projet_LMSG__c>();
            if(!proWBEIdSet.isEmpty()) {
                prjList = [ SELECT id, Identifiant_PP__c, Name, Nombre_de_Match_visibles__c, Particulier__c, Particulier__r.Name, Besoin_Travaux__c, Besoin_Travaux__r.Name, Nombre_de_matchs_Pros_positionnables__c
                            FROM Projet_LMSG__C WHERE Identifiant_PP__c IN : projectWBEIdSet];
            }

            Map<String, Account> accIdMap = new Map<String, Account>();
            for(Account acc : accList) {
                accIdMap.put(acc.Contact_principal__r.External_Contact_Id__c , acc);	
            }
            Map<String, Projet_LMSG__c> prjIdMap = new Map<String, Projet_LMSG__c>();
            for(Projet_LMSG__c prj : prjList) {
                prjIdMap.put(prj.Identifiant_PP__c, prj);
            }

            // status map :
            Map<String, String> statusMap = new Map<String, String>{ 'CREATED' => 'Nouveau' , 'READ' => 'Lu' ,
                                                                    'REFUSED' => 'Refusé' , 'ACCEPTED' => 'Positionné' ,
                                                                    'ARCHIVED' => 'Archivé', 'VIEWED' => 'Lu'};
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' ;
            String endURL = '/view?0.source=alohaHeader';
            Integer numProPos = 0;
            Integer numProVisibles = 0;
            for(Map<String, String> mapObj : matchList) {
                List<String> dateStr = mapObj.get('createdDate').split('T');
                List<String> calendar = dateStr[0].split('-');
                List<String> hours = dateStr[1].split(':');
                hours[2] = hours[2].substringBefore('.');
                if(!hours[2].isNumeric()) {		
                    hours[2]='00';		
                }

                Account acc = accIdMap.get(mapObj.get('proWbeId'));
                Projet_LMSG__c prj = prjIdMap.get(mapObj.get('projectWbeId'));
                MatchObjectClass newMatch = new MatchObjectClass(   acc==null? 'Compte introuvable' : acc.Name,
                                                                    acc==null? 'Compte introuvable' : baseURL+acc.Id+endURL,
                                                                    prj==null? 'Projet introuvable' : prj.Name,
                                                                    prj==null? 'Projet introuvable' : baseURL+prj.Id+endURL,
                                                                    prj==null? 'Part introuvable'   : prj.Particulier__r.Name,
                                                                    prj==null? 'Part introuvable'   : baseURL+prj.Particulier__c+endURL,
                                                                    statusMap.get(mapObj.get('status')),
                                                                    Datetime.newInstance(Integer.valueOf(calendar[0]),
                                                                                         Integer.valueOf(calendar[1]),
                                                                                         Integer.valueOf(calendar[2]),
                                                                                         Integer.valueOf(hours[0]), 
                                                                                         Integer.valueOf(hours[1]), 
                                                                                         Integer.valueOf(hours[2])),
                                                                    mapObj.get('positionable')=='true' ? true : false,
                                                                    Integer.valueOf(mapObj.get('positionedCount')) < 3 ? true : false,
                                                                    mapObj.get('positionedCount'),
                                                                    prj==null? 'Besoin introuvable'  : prj.Besoin_Travaux__r.Name,
                                                                    prj==null? 'Besoin introuvable'  : baseURL+prj.Besoin_Travaux__c+endURL);
                sfMatchList.add(newMatch);
                //System.debug('##### HDAK match object : ' + newMatch);
                //System.debug('##### HDAK match positionable : ' +  mapObj.get('positionable'));
                //System.debug('##### HDAK match visible : ' + mapObj.get('positionedCount'));
  
                if(Label.ActivateMatchFix == 'TRUE') {
                    //System.debug('##### HDAK match Fix Activated  : ' + newMatch);
                    if(newMatch.viewable == true) {
                        numProVisibles++;
                    }
                    if(newMatch.positionable==true) {
                        numProPos++;
                    }

                } else {
                    if(newMatch.viewable == true) {
                        numProVisibles++;
                        if(newMatch.positionable==true) {
                            numProPos++;
                        }
                    }
                }
            }

            // if batch and no match found :
            if(System.isBatch() && matchList.isEmpty()) {
                for(Account acc : accList) {
                    sfMatchList.add( new MatchObjectClass( acc.Name, baseURL+acc.Id+endURL, '', '', '', '', '', null, false, false, '', '', ''));
                }
                for(Projet_LMSG__c prj : prjList) {
                    sfMatchList.add( new MatchObjectClass( '', '', prj.Name, baseURL+prj.Id+endURL, '', '', '', null, false, false, '', '', ''));
                }
            }

            // When called by  LWC update number of Matches :
            if(accList.size() == 1 && !System.isBatch()) {
                accList[0].Nombre_de_Match_visibles__c = numProVisibles;
                accList[0].Nombre_de_matchs_Pros_positionnables__c = numProPos;
                accList[0].Nombre_Total_de_Match__c = matchList.size();
                update accList;
            }
            if(prjList.size() == 1 && !System.isBatch()) {
                prjList[0].Nombre_de_Match_visibles__c = numProVisibles;
                prjList[0].Nombre_de_matchs_Pros_positionnables__c = numProPos;
                prjList[0].Nombre_Total_de_Match__c = matchList.size();
                update prjList;
            }
            return sfMatchList;
   }

    /**
    * @description 
    * @author Hassan Dakhcha | 3/26/2020 
    * @param proIds 
    * @param projectIds 
    * @return HttpResponse 
    **/
    private static HttpResponse getMatchs(List<String> proIds, List<String> projectIds, Boolean filterArchived) {
        
        String projectArg = 'projectIds=';
        if(projectIds != null) {
            for(String prj : projectIds) {
                projectArg= projectArg + prj + ',';
            }
            projectArg = projectArg.substringBeforeLast(',');
            //System.debug('#### HDAK Match : num projects =' + projectIds.size());
        }

        String proArg = 'userIds=';
        if(proIds != null) {
            for(String pro : proIds) {
                proArg= proArg + pro + ',';
            }
            proArg = proArg.substringBeforeLast(',');
            //System.debug('#### HDAK Match : num pros =' + proIds.size());
        }

        Map<WBE_Token__c, Boolean> TokenMap = getToken();
        List<WBE_Token__c> token = new List<WBE_Token__c> (TokenMap.keySet());

        if(token[0] == null)
            return null;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.Label.WBE_Endpoint + '/matches?' + proArg + '&' + projectArg + '&archived=' + (filterArchived==true ? 'false' : 'true'));
        req.setMethod('GET'); 
       // if(System.IsBatch() || System.isQueueable()) {
            req.setTimeout(120000);
     //   }
        req.setHeader('Authorization', 'Bearer ' + token[0].Token__c);
        //System.debug('#### HDAK Match : Token   ' + token[0] + ' pro Id ' + proArg + ' prj Id ' + projectArg );

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if(res != null && TokenMap.get(token[0])==true && res.getStatusCode() == 200 && !System.isFuture() && !System.isBatch()) {
            saveToken(token[0].Token__c, token[0].Expire_Date__c);
        }
        return res;
    }

    /**
    * @description : check and get Token if needed
    * @author Hassan Dakhcha | 3/24/2020 
    * @return String 
    **/
    public static Map<WBE_Token__c, Boolean> getToken() {
        WBE_Token__c wbeToken = WBE_Token__c.getOrgDefaults();
        //WBE_Token__c wbeToken = new WBE_Token__c();
        Datetime nowCmp = Datetime.now(); 
        Integer offsetCmp = UserInfo.getTimezone().getOffset(nowCmp);
        Datetime localCmp = nowCmp.addSeconds(offsetCmp/1000);
        //System.debug('#### HDAK curr token : ' + wbeToken.Token__c);
        //System.debug('#### HDAK curr validity : ' +wbeToken.Expire_Date__c);
        //System.debug('#### HDAK curr local time : ' +localCmp);

        if( wbeToken.Token__c == null || wbeToken.Expire_Date__c < localCmp) {
            // update the token
            //String url = System.Label.WBE_Endpoint;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(System.Label.WBE_Endpoint+ '/oauth/token'); 
            String cred = 'grant_type=client_credentials&scope=any&client_id='+ Label.Match_LMSG_Token_Client_ID +
                          '&client_secret=' + Label.Match_LMSG_Token_Client_Secret;
            req.setBody(cred);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setHeader('Content-Length' , String.valueOf(cred.length()));
            Http http = new Http();
            HttpResponse res = null;
            res = http.send(req);
 
            if (res != null && res.getStatusCode() == 200) {
                Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                wbeToken.Token__c = (String)objMap.get('access_token');
                Datetime now = Datetime.now(); 
                Integer offset = UserInfo.getTimezone().getOffset(now);
                Datetime local = now.addSeconds(offset/1000);
                wbeToken.Expire_Date__c = local.addSeconds(Integer.valueOf((Integer) objMap.get('expires_in'))); 
                //System.debug('#### HDAK Match : token : ' +wbeToken.Token__c);
                //System.debug('#### HDAK Match : validity : ' +wbeToken.Expire_Date__c);
                return new Map<WBE_Token__c, Boolean> { wbeToken => true};
            } else {
                //System.debug('#### HDAK Match : get Token call error : ' + res.getStatusCode());
                //System.debug('#### HDAK Match : get Token call error : ' + res.getBody());
                return null;
            }
        } else {
            //System.debug('#### HDAK Match : Token   VALID ' + wbeToken);
            //Token up to date
            return new Map<WBE_Token__c, Boolean> { wbeToken => false};
        }
    }
    @future
    private static void saveToken(String token , Datetime expireDate) {
        WBE_Token__c wbeToken = WBE_Token__c.getOrgDefaults();
        wbeToken.Name = 'WBE Token';
        wbeToken.Token__c = token;
        wbeToken.Expire_Date__c = expireDate;
        //System.debug('#### HDAK Upsert Token ' + wbeToken);
        upsert wbeToken;
    }

}