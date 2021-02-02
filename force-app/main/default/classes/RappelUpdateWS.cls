// 
// Classe support pour gérer les rappels en utilisant les webservices
// 22/04/2017, xavier templet, création   
// 12/05/2017,  xavier templet, ajout des fonctions pour annuler des rappels
// 22/05/2017,  xavier templet, ajout des fonctions pour gérer les priorotés des rappels
//


global class RappelUpdateWS {


    //
    // API to call ODIGO Webservice
    //    

    //    
    // Result
    //    
    global class Result {
        @AuraEnabled
        global String code { get; set; }
        @AuraEnabled
        global String message { get; set; }
        //@AuraEnabled (Car Pb de nom ne commencant pas par get !!!)
        global boolean isSuccess() {
            if (code==null||!code.equals('OK')) {
                return false;
            } else {
                return true;
            }
        }
    }

    //    
    // Callback Bean 
    //    
    global class CallBackBean {
        public String phoneNumber;
        public String skillKeyWord;
        public String data;
        public DateTime datetime_x;
        public Integer priority;
        public Integer type_x;
        public String agentId;
    }

    @AuraEnabled
    global static CallBackBean makeCallBackBean(String phoneNumber, String skillKeyWord, String data, DateTime datetime_x, string agentId, String TypeDemande) {
        CallBackBean callBackBean = new CallBackBean();
        callBackBean.phoneNumber=phoneNumber;
        callBackBean.skillKeyWord=skillKeyWord;
        if (data==null) { 
            callBackBean.data='';
        } else {
            callBackBean.data=data;
        }
        if (datetime_x==null) { 
            callBackBean.datetime_x=Datetime.newInstance(1970, 1, 1);
        } else {
            callBackBean.datetime_x=datetime_x;
        }
        if (agentId==null) { 
            callBackBean.agentId='';
        } else {
            callBackBean.agentId=agentId;
        }
        // Plus le chiffre est élevé plus le callback est prioritaire
        if (TypeDemande == 'Click2Call') callBackBean.priority=6; 
        else if (TypeDemande == 'WCB Créneau') callBackBean.priority=5; 
            else if (TypeDemande == 'WCB Journée') callBackBean.priority=4; 
                else if (TypeDemande == 'WCB Auto') callBackBean.priority=3; 
                    else callBackBean.priority=2;
        callBackBean.type_x=0;
        return callBackBean;
    }

    @AuraEnabled
    global static Result SaveCallBack2(String phoneNumber, String skillKeyWord, String data, DateTime datetime_x, String TypeDemande, List<String> wcbID) {
        return SaveCallBack2(makeCallBackBean(phoneNumber, skillKeyWord, data, datetime_x, null, TypeDemande), wcbID);
    }

    @AuraEnabled
    global static Result SaveCallBack2(CallbackBean callBackBean, List<String> wcbID) {

        System.debug('SaveCallBack2 - Start');
        
        Result result = new Result();

        System.debug('SaveCallBack2 - Retreive Configuration');
        //Conf__c cs = Conf__c.getInstance(System.Label.Odigo_VFP04Conf_Name);
        //String cs = [SELECT Id, OdigoCti__Odigo_Conf__c FROM User WHERE Id =: userInfo.getUserId()].OdigoCti__Odigo_Conf__c;//       
        
        //Save Callback
        WSodigo_ComWebCallBack.WebCallBackHttpsSoap11Endpoint wsCallBack = new WSodigo_ComWebCallBack.WebCallBackHttpsSoap11Endpoint();
        //wsCallBack.endpoint_x = 'https://odigo2.prosodie.com/monchantier_rec/servlet/services/WebCallBack.WebCallBackHttpsSoap11Endpoint/'; 
        wsCallBack.endpoint_x = System.Label.Odigo_endpoint_x;
        //wsCallBack.endpoint_x = cs.URLSmartCallWS__c;
        
        System.debug('SaveCallBack2 - Transfert call Bean: '+callBackBean);
        WSodigo_WebCallBackWsBeanModel.CallBackBean callBackBeanX = new WSodigo_WebCallBackWsBeanModel.CallBackBean();
        callBackBeanX.phoneNumber=callBackBean.phoneNumber;
        callBackBeanX.skillKeyWord=callBackBean.skillKeyWord;
        callBackBeanX.data=callBackBean.data;
        callBackBeanX.date_x=callBackBean.datetime_x.getTime()/1000;
        callBackBeanX.priority=callBackBean.priority;
        callBackBeanX.type_x=callBackBean.type_x;
        callBackBeanX.agentId=callBackBean.agentId;
        
        WSodigo_AdministrationBeanModel.UserBean userBean = new WSodigo_AdministrationBeanModel.UserBean();
        //userBean.login=cs.CTI_Applogin__c;
        //userBean.password=cs.CTI_AppPwd__c;
        userBean.login=System.Label.Odigo_Login;
        userBean.password=System.Label.Odigo_Password;
        
        System.debug('SaveCallBack2 - call SaveCallBack with: '+callBackBeanX+' / '+userBean);
        
        WSodigo_WebCallBackWsBeanModel.SaveCallBackResponseBean returnWS;        
        
        //if (!Test.isRunningTest()) resultWS=wsCallBack.SaveCallBack(callBackBeanX, userBean);
        returnWS=wsCallBack.SaveCallBack2(callBackBeanX, userBean);
        
        integer resultWS=0;
        if (returnWS!=null) {
            resultWS = returnWS.status;
            wcbID.add(String.ValueOf(returnWS.callBackId));

            if ((resultWS == 1) ) {
                String message='Callback save on '+callBackBeanX.skillKeyWord+' ('+callBackBeanX.phoneNumber+'). He will be called in few minutes !'; 
                result.code='OK';
                result.message=message;
            } else {
                String message='Sorry, we enconter a problem (Code: '+resultWS+') to record a CallBack on '+callBackBeanX.skillKeyWord+' ('+callBackBeanX.phoneNumber+')'; 
                result.code='KO:'+resultWS;
                result.message=message;
            }
        }

        System.debug('SaveCallBack2 - End - '+result);

        return result ;
    }

/*
    @future(callout=true)
    public static void SaveCallBackOdigo(String phoneNumber, String skillKeyWord, String attachment, Datetime DateHoraire) {


        OdigoCti.WS99API.Result result = new OdigoCti.WS99API.Result();
        if (phoneNumber !=null && skillKeyWord !=null && attachment != null) {
            if(!Test.isRunningTest()){
                result = OdigoCti.WS99API.saveCallback(phoneNumber, skillKeyWord, attachment, DateHoraire);
                if (!result.isSuccess()) System.debug('Error: ('+ result.Code +') '+ result.message);
            }

   
            Rappel__c Rpp = [select Id from Rappel__c where Id =:attachment limit 1];
            if(Rpp !=null) {
                Rpp.Statut_CTI__c = result.code;
                Rpp.Statut_Message_CTI__c = result.message;
                update Rpp;
            }
        }
        
    }
*/  

    @AuraEnabled
    global static Result changeStatusCallBack(Integer[] callbackIdList, Integer[] callBackIdErrorList) {

        Result result = new Result();

        System.debug('changeStatusCallBack - Retreive Configuration');
        //Conf__c cs = Conf__c.getInstance(System.Label.Odigo_VFP04Conf_Name);
        //String cs = [SELECT Id, OdigoCti__Odigo_Conf__c FROM User WHERE Id =: userInfo.getUserId()].OdigoCti__Odigo_Conf__c;//       
        
        //change Status CallBack
        WSodigo_ComWebCallBack.WebCallBackHttpsSoap11Endpoint wsCallBack = new WSodigo_ComWebCallBack.WebCallBackHttpsSoap11Endpoint();
        //wsCallBack.endpoint_x = 'https://odigo2.prosodie.com/monchantier_rec/servlet/services/WebCallBack.WebCallBackHttpsSoap11Endpoint/'; 
        wsCallBack.endpoint_x = System.Label.Odigo_endpoint_x;
        //wsCallBack.endpoint_x = cs.URLSmartCallWS__c;

        string odigo_login=System.Label.Odigo_Login;
        string odigo_password=System.Label.Odigo_Password;
        WSodigo_WebCallBackWsBeanModel.ChangeStatusCallBackResponseBean returnWS;


        //if (!Test.isRunningTest()) .....
        // Operation >> 0: ACTIVATE, 1: CANCEL, 2: DELETE
        //public WSodigo_WebCallBackWsBeanModel.ChangeStatusCallBackResponseBean changeStatusCallBack(String wsLogin,String wsPassword,Integer[] callbackIdList,Integer operation,Integer campaignId)
        returnWS = wsCallBack.changeStatusCallBack(odigo_login, odigo_password, callbackIdList, 1, null);
        
        integer resultWS=0;
        if (returnWS!=null) {
            resultWS = returnWS.status;
            callBackIdErrorList = returnWS.callBackIdErrorList;

            if (resultWS!=0) {
                String message='Sorry, we enconter a problem (Code: '+resultWS+') to cancel a CallBack on IDs '+callBackIdErrorList; 
                result.code='KO:'+resultWS;
                result.message=message;
            } else {
                String message='Callback canceled for IDs '+callbackIdList; 
                result.code='OK';
                result.message=message;
            }
        }

        return result ;
    }

  
    @future(callout=true)
    public static void SaveCallBackOdigo2(String phoneNumber, String skillKeyWord, String attachment, Datetime DateHoraire, String TypeDemande) {

        Result result = new Result();
        List<String> wcbID = new List<String>();  

        Rappel__c Rpp = new Rappel__c();
        if (attachment != null) {
            Rpp.Id = attachment; 
            if(Test.isRunningTest()) { 
                result.code = 'OK'; result.message = 'Test Callback saved'; wcbID.add('99'); 
            }

            // il faut vérifier que la date / heure corresponde bien à un créneau définit (et avec de la disponibilité) 
            List<Creneau__c> CreneauxDispo = [SELECT Id, Reservations__c, Disponible__c, Name, Date_Horaire__c FROM Creneau__c];
            Boolean trouve = false;
            for (Creneau__c C : CreneauxDispo)  
                //if (DateHoraire != null && DateHoraire == C.Date_Horaire__c && C.Disponible__c > 0) trouve = true;
                if (DateHoraire != null && DateHoraire == C.Date_Horaire__c) trouve = true;
        
            if (phoneNumber !=null && skillKeyWord !=null && trouve) {
                system.debug('skillKeyWord = ' + skillKeyWord);
                system.debug('attachment = ' + attachment);
                system.debug('TypeDemande = ' + TypeDemande);
                
                if(!Test.isRunningTest()) {
                    //result = saveCallback2(phoneNumber, skillKeyWord, attachment, DateHoraire, TypeDemande, wcbID);
                    if (skillKeyWord == 'accueil_com')
                        result = saveCallback2(phoneNumber, skillKeyWord, attachment, DateHoraire, TypeDemande, wcbID);
                    else
                        result = saveCallback2(phoneNumber, skillKeyWord, attachment, Datetime.now().addMinutes(Integer.valueOf(System.Label.Delai_Tampon_Rappel)), TypeDemande, wcbID);
                    System.debug('RappelUpdateWS.SaveCallBackOdigo2: saveCallback2 result: ('+ result.Code +') '+ result.message);
                }
                if(Rpp !=null) {
                    Rpp.Statut_Message_CTI__c = result.message;
                    if ((result.code == 'OK') && (wcbID != null)) {
                        Rpp.Statut_CTI__c = 'Planifié';
                        Rpp.CallBack_Reference__c = wcbID[0];
                    } 
                    else if ( result.code == 'KO:2' ) Rpp.Statut_CTI__c = 'Déjà Existant';
                    else Rpp.Statut_CTI__c = 'KO technique';
                    if(!Test.isRunningTest()) update Rpp;
                }
            }
            else {
                if (!trouve && Rpp !=null) {
                    Rpp.Statut_CTI__c = 'Créneau Indisponible';
                }
                else if (Rpp !=null){ 
                    Rpp.Statut_CTI__c = 'Paramètres incorrects';
                    System.debug('RappelUpdateWS.SaveCallBackOdigo2 error: value required for phoneNumber or skillKeyWord');
                }
                if(!Test.isRunningTest() && Rpp !=null) update Rpp;
            }
        }
        else System.debug('RappelUpdateWS.SaveCallBackOdigo2 error: value required for ID rappel');
    }


/*
    global class callBackId {
        Id ObjectId;    
        Integer OdigoId;
        Result result;
    }

    private static boolean ContainsCallBack(Integer OdigoId, List<Integer> callBackIdErrorList){
        boolean bresult = false;
        for(Integer i : callBackIdErrorList) if (i == OdigoId) bresult = true;
        return bresult;
    }
*/    


    @future(callout=true)
    public static void changeStatusCallBackOdigo(Id RappelID, String callbackId) {

        Rappel__c Rpp = new Rappel__c();
        Rpp.Id = RappelID;
        //Rpp = [select Id, CallBack_Reference__c from Rappel__c where CallBack_Reference__c =:callbackId limit 1];
        if(Test.isRunningTest()) { 
                Rpp.Date_Horaire__c = Date.today(); Rpp.No_de_Rappel__c = '0600000000'; Rpp.Type_de_demande__c ='WCB Créneau'; Rpp.Queue_Odigo__c = 'accueil_client_part';
        }                       

        Result result = new Result();
        List<Integer> callBackIdErrorList = new List<Integer>();
        List<Integer> IdList = new List<Integer>();
        if (callbackId != null && callbackId !='') {
            IdList.add(Integer.valueOf(callbackId));
            if(!Test.isRunningTest()) { 
                result = changeStatusCallBack(IdList, callBackIdErrorList);
                System.debug('Error: ('+ result.Code +') '+ result.message + 'callBackIdErrorList: ' + callBackIdErrorList);
            }
            else {
                result.code = 'OK'; result.message = 'Test d\'annulation du Callback'; 
            }
        }
        // ToDo: il faut récupérer le Statut CTI dans l'argument de la fonction pour le test ci-dessous
        else if (Rpp !=null && Rpp.Statut_CTI__c == 'Déjà Existant') {
            result.code = 'NA'; result.message = 'Pas d\'annulation à faire dans Odigo'; 
        }
        
    
        if(Rpp !=null) {
            Rpp.Statut_Message_CTI__c = result.message;
            if ((result.code == 'OK') || (result.code == 'NA')) Rpp.Statut_CTI__c = 'Supprimé';
            else Rpp.Statut_CTI__c = 'Echec Annulation';    
            if(!Test.isRunningTest()) update Rpp;
        }
        else System.debug('RappelUpdateWS:changeStatusCallBackOdigo Debug >>>>> Pas de Rappel ID');
    }
    
    @future(callout=true)
    public static void changeStatusCallBackOdigoAfterDelete(String callbackId) {

        Result result = new Result();
        List<Integer> callBackIdErrorList = new List<Integer>();
        List<Integer> IdList = new List<Integer>();
                
        if (callbackId != null && callbackId !='') {
            IdList.add(Integer.valueOf(callbackId));
            if(!Test.isRunningTest()) {
                result = changeStatusCallBack(IdList, callBackIdErrorList);
                System.debug('Error: ('+ result.Code +') '+ result.message + 'callBackIdErrorList: ' + callBackIdErrorList);
            }
        }
    }
    
    webservice static void changeStatusCallBackOdigoWS(Id RappelID, String callbackId){
        changeStatusCallBackOdigo(RappelID, callbackId);
    }
     
}