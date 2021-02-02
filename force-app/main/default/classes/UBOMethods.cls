/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-17-2020   Hassan Dakhcha   Initial Version
**/
public class UBOMethods implements Queueable, Database.AllowsCallouts {
    private Account Compte_pro;
    private String jsonStr;

    public UBOMethods(Account acc) {
        this.Compte_pro = acc;
        this.jsonStr = '';
    }
    public void execute(QueueableContext context) {
        Integer statusCode;
        try {
            System.debug('#### HDAK UBO Starting Extraction'); 

            statusCode = this.callHyso();
            if(this.jsonStr!='') {
                // Generate UBO Objects
                this.generate();
            } else {
                 // update status code
                update (new Account(id = this.Compte_pro.id, Statut_UBO__c = 'MISSING', Tech_extract_UBO__c = String.valueof(statusCode)));
            }
        } catch(Exception e) {    
            System.debug('#### HDAK Exception lors de la generation des UBO: ' + e.getMessage());
            update (new Account(id = this.Compte_pro.id, Tech_extract_UBO__c = String.valueof(statusCode)));
        }
    }

    // Call Hyso WS to get the Infogreffe JSON of UBOs
    private Integer callHyso() {
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(Label.hyso_UserName + ':' + Label.hyso_Password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(System.Label.hysoUBO_EndPoint + this.Compte_pro.Siret_Texte__c);
        Http http = new Http();
        HttpResponse response = http.send(req);
        if(response != null && response.getStatusCode()==200) {
            System.debug('#### HDAK UBO JSON' + response.getBody()); 
            this.jsonStr = response.getBody();
        } 
        return response.getStatusCode();
    }

    // Read the Json file and create objects
    private void generate() {
        // Get ubo recordtypes
        List<RecordType> rtList = [ SELECT id, developerName 
                                    FROM RecordType
                                    WHERE SobjectType='UBO__c'];
        Map<String, RecordType> uboRTMap = new Map<String, RecordType>();
        for(RecordType rt : rtList) {
            uboRTMap.put(rt.developerName, rt);
        }
        
        Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(this.jsonStr);
        // Read the beneficial Owners :
        List<UBO__c> uboList = new List<UBO__c> ();
        List<Object> ownerList = (List<Object>)objMap.get('beneficialOwners');
        Integer num = 0;
        for(Object owner : ownerList) {
            num++;
            Map<String, Object> benificialMap = (Map<String, Object>)owner;
            Map<String, Object> personMap = (Map<String, Object>)benificialMap.get('person');
            String type = (String)personMap.get('type');
            Decimal prcShares = (Decimal)benificialMap.get('sharesPercentage');
            UBO__c ubo = new UBO__c (// Name = 'UBO-' + type +'-0'+ num + ' ' + this.Compte_pro.Name.left(15), 
                    Account__c = this.Compte_pro.id,
                    sharesCount__c = (Decimal)benificialMap.get('sharesCount'),
                    share__c = prcShares,
                    Statut__c = prcShares <25 ? 'INVALIDABLE' : 'MISSING'
            );

            //Integer sharesCount = benificialMap.get('sharesCount');
            //Decimal share = benificialMap.get('sharesPercentage');
            if(type == 'PM') {
                ubo.Statut__c = 'INVALIDABLE';
                ubo.recordTypeId = uboRTMap.get('PM').id;
                ubo.denomination__c = (String)personMap.get('denomination');
                ubo.legalCategoryLabel__c = (String)personMap.get('legalCategoryLabel');
                String siren = (String)personMap.get('siren');
                if(siren != null && siren!='') {
                    ubo.siren__c = Decimal.valueOf(siren);
                }
                Map<String, Object> addressMap = (Map<String, Object>) personMap.get('address');
                ubo.streetName__c = (String)addressMap.get('streetName');
                ubo.additionalAddress__c = (String)addressMap.get('additionalAddress');
                ubo.zipCode__c = (String)addressMap.get('postalCode');
                ubo.cityName__c = (String)addressMap.get('cityName');
            }
            if(type == 'PP') {
                ubo.recordTypeId = uboRTMap.get('PP').id;
                ubo.title__c = (String)personMap.get('civility');
                ubo.lastName__c = (String)personMap.get('lastName');
                ubo.birthName__c = (String)personMap.get('birthName');
                ubo.firstName__c = (String)personMap.get('firstName');
                List<Object> dtObj = (List<Object>)personMap.get('birthdate');
                System.debug('### dtObj ' + dtObj);
                if(dtObj!=null && dtObj.size()>2) {
                    ubo.birthdate__c = Date.valueOf(dtObj[0]+'-'+dtObj[1]+'-'+dtObj[2]);
                    System.debug('### result ' + ubo.birthdate__c);
                }
                ubo.birthCityName__c = (String)personMap.get('birthCityName');
            }
            System.debug('#### HDAK UBO = ' + ubo); 
            uboList.add(ubo);
        }
        Database.SaveResult[] results = Database.insert(uboList, false);
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    System.debug('### UBO  : Insertion des UBOs a échouée ');                   
                    System.debug('### UBO : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### UBO Champs origine de l\'erreur : '  + err.getFields());
                }
            }
        }

        // Set up account to 
        Account acc = new Account(id = Compte_pro.id, Statut_UBO__c = 'TO_COMPLETE',
                                  Tech_extract_UBO__c = '200',
                                  ubo_json__c = this.jsonStr);
        Database.update(acc, false);
    }

    // A l'activation de la nouvelle offre appel on traite les UBO si 
    // ils n'ont pas été generés auparavant :
    public static void extractUBOs(List<Account> accounts, Map<id, Account> oldMap) {
        Map<Id, Account> accMap = new Map<Id,Account> (); 
        for(Account acc : accounts) {
            if( acc.isPersonAccount == false && acc.Compte_Nouvelles_Offres__c == true &&
                (( (Label.ActivateUBOExtractionOnPositionnable =='TRUE' || Test.isRunningTest()==true) 
                    && acc.Statut_activation__c != oldMap.get(acc.id).Statut_activation__c &&
                    acc.Statut_activation__c == 'Pro_actif_positionnable') 
                || (acc.Tech_GenerateUBOs__c != oldMap.get(acc.id).Tech_GenerateUBOs__c &&
                    acc.Tech_GenerateUBOs__c == true)) ) {
                accMap.put(acc.id, acc);
            }
        } 
        
        if(!accMap.isEmpty()) {
            List<UBO__c> uboList = [SELECT id, Account__c FROM UBO__c WHERE Account__c IN :accMap.keySet()];
            for(UBO__c ubo : uboList) {
                accMap.remove(ubo.Account__c);
            }
         
            if(!accMap.isEmpty()) {
                // Check for EI/EIRL :
                Map<id, reference__c> EiEirl = new Map<id, reference__c> ([SELECT id FROM Reference__c 
                                                                            WHERE RecordType.DeveloperName='Statut_juridique' AND (key__c='EI' OR key__c ='EIRL')]);
                Set<id> refId = new Set<id>();
                refId.addAll(EiEirl.keySet());

                for(Id acc : accMap.keySet()) {
                    if(refId.contains(accMap.get(acc).Statut_Juridique__c)) {
                        if(accMap.get(acc).Statut_UBO__c!='VALIDABLE' && accMap.get(acc).Statut_UBO__c!='VALIDATED') {
                            accMap.get(acc).Statut_UBO__c = 'VALIDABLE';
                            accMap.get(acc).nbr_ubo__c = 0;
                        }
                    } else {
                        System.enqueueJob(new UBOMethods(accMap.get(acc)));
                    }
                }
            }
        }
    }

    // Envoyer les ubo a Hipay
    // Called before update on account trigger
    public static void EnvoyerUboDuPro(Map<id, Account> newMap, Map<id, Account> oldMap) {
        Set<id> accSet = new Set<id>();
        for(id accId : newMap.keySet()) {
            if(newMap.get(accId).statut_ubo__c == 'VALIDABLE' && newMap.get(accId).statut_ubo__c != oldMap.get(accId).statut_ubo__c) {
                accSet.add(accId);
                if(newMap.get(accId).nbr_ubo__c == null) {
                    newMap.get(accId).nbr_ubo__c = 0;
                }
                if(newMap.get(accId).nbr_ubo_pm__c == null) {
                    newMap.get(accId).nbr_ubo_pm__c = 0;
                }
            }
        }
        
        if(accSet.isEmpty()){
            return;
        }
        List<UBO__c> uboList = [SELECT id, Account__c, Statut__c FROM UBO__c 
                                WHERE Account__c IN :accSet 
                                AND RecordType.developerName='PP'
                                AND Statut__c != 'INVALIDABLE'];
        
        Map<id, Integer> accNumUBOMap = new Map<id, Integer>();
        for(UBO__c ubo : uboList) {
            Integer numUbo = accNumUBOMap.get(ubo.Account__c);
            if(numUbo==null) {
                accNumUBOMap.put(ubo.Account__c, 1);
            } else {
                accNumUBOMap.put(ubo.Account__c, ++numUbo);
            }
            if(ubo.Statut__c != 'SENT' && ubo.Statut__c != 'VALIDATED' && ubo.Statut__c != 'VALIDABLE') {
                newMap.get(ubo.Account__c).addError('Tous les UBOs (Personne Physique) du pro doivent être validés. Merci de verifier le statut de chaque UBO');
            }
        }
        for(id accId : accNumUBOMap.keySet()) {
            newMap.get(accId).nbr_ubo__c = accNumUBOMap.get(accId);
        }
    }
}