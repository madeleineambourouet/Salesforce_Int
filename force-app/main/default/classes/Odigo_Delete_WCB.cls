/**
 * @File Name          : Odigo_Delete_WCB.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/15/2020, 2:36:19 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/15/2020   Hassan Dakhcha     Initial Version
**/
global class Odigo_Delete_WCB {

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
    global static CallBackBean makeCallBackBean(String phoneNumber, String skillKeyWord) {
        return makeCallBackBean(phoneNumber, skillKeyWord, null, null, null);
    }
    @AuraEnabled
    global static CallBackBean makeCallBackBean(String phoneNumber, String skillKeyWord, String data) {
        return makeCallBackBean(phoneNumber, skillKeyWord, data, null, null);
    }
    @AuraEnabled
    global static CallBackBean makeCallBackBean(String phoneNumber, String skillKeyWord, String data, DateTime datetime_x) {
        return makeCallBackBean(phoneNumber, skillKeyWord, data, datetime_x, null);
    }
    @AuraEnabled
    global static CallBackBean makeCallBackBean(String phoneNumber, String skillKeyWord, String data, DateTime datetime_x, string agentId) {
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
        callBackBean.priority=5;
        callBackBean.type_x=0;
        return callBackBean;
    }

    //    
    // Operation SaveCallBack   
    //    

    @AuraEnabled
    global static Result SaveCallBack(String phoneNumber, String skillKeyWord) {
       return SaveCallBack(makeCallBackBean(phoneNumber, skillKeyWord, null));
    }
    @AuraEnabled
    global static Result SaveCallBack(String phoneNumber, String skillKeyWord, String data) {
        return SaveCallBack(makeCallBackBean(phoneNumber, skillKeyWord, data));
    }
    @AuraEnabled
    global static Result SaveCallBack(String phoneNumber, String skillKeyWord, String data, DateTime datetime_x) {
        return SaveCallBack(makeCallBackBean(phoneNumber, skillKeyWord, data, datetime_x));
    }
    @AuraEnabled
    global static Result SaveCallBack(String phoneNumber, String skillKeyWord, String data, DateTime datetime_x, string agentId) {
        return SaveCallBack(makeCallBackBean(phoneNumber, skillKeyWord, data, datetime_x, agentId));
    }
    @AuraEnabled
    global static Result SaveCallBack(CallbackBean callBackBean) {

        System.debug('Odigo_WCB - SaveCallBack - Start');
        
        Result result = new Result();
        /*
        System.debug('Odigo_WCB - SaveCallBack - Retreive Configuration');
        //Conf__c cs = Conf__c.getInstance(System.Label.Odigo_VFP04Conf_Name);
        String cs = [SELECT Id, OdigoCti__Odigo_Conf__c FROM User WHERE Id =: userInfo.getUserId()].OdigoCti__Odigo_Conf__c;       
        
        //Save Callback
        WSodigoProsodieComWebcallback.WebCallBackHttpsSoap11Endpoint wsCallBack = new WSodigoProsodieComWebcallback.WebCallBackHttpsSoap11Endpoint();
        wsCallBack.endpoint_x = 'https://odigo2.prosodie.com/monchantier_rec/servlet/services/WebCallBack.WebCallBackHttpsSoap11Endpoint/'; 
        //wsCallBack.endpoint_x = cs.URLSmartCallWS__c;
        
        System.debug('WS99API - SaveCallBack - Transfert call Bean: '+callBackBean);
        WSodigoProsodieWebcallbackWsBeanModel.CallBackBean callBackBeanX = new WSodigoProsodieWebcallbackWsBeanModel.CallBackBean();
        callBackBeanX.phoneNumber=callBackBean.phoneNumber;
        callBackBeanX.skillKeyWord=callBackBean.skillKeyWord;
        callBackBeanX.data=callBackBean.data;
        callBackBeanX.date_x=callBackBean.datetime_x.getTime()/1000;
        callBackBeanX.priority=callBackBean.priority;
        callBackBeanX.type_x=callBackBean.type_x;
        callBackBeanX.agentId=callBackBean.agentId;
        
        WSodigoProsodieAdministrationBeanModel.UserBean userBean = new WSodigoProsodieAdministrationBeanModel.UserBean();
        //userBean.login=cs.CTI_Applogin__c;
        //userBean.password=cs.CTI_AppPwd__c;
        userBean.login='WSODIGO';
        userBean.password='WSODIGO';
        
        System.debug('WS99API - SaveCallBack - call SaveCallBack with: '+callBackBeanX+' / '+userBean);
        
        integer resultWS=0;
        
        if (!Test.isRunningTest()) resultWS=wsCallBack.SaveCallBack(callBackBeanX, userBean);
        
        if (resultWS!=1) {
            String message='Sorry, we enconter a problem (Code: '+resultWS+') to record a CallBack on '+callBackBeanX.skillKeyWord+' ('+callBackBeanX.phoneNumber+')'; 
            result.code='KO:'+resultWS;
            result.message=message;
        } else {
            String message='Callback save on '+callBackBeanX.skillKeyWord+' ('+callBackBeanX.phoneNumber+'). He will be called in few minutes !'; 
            result.code='OK';
            result.message=message;
        }
        */
        result.code='KO:';
        result.message='Odigo has been shutdown';
        System.debug('WS99API - SaveCallBack - End - '+result);

        return result ;
    }

   
    // Operation Retreive OdigoLogin   
    //    
    @AuraEnabled
    global static String retreiveOdigoLogin() {
       System.debug('WS99API - retreiveOdigoLogin- Start');
       //String Odigo_login = 'ofize';
       // String Odigo_login = [SELECT Id, OdigoCti__Odigo_login__c FROM User WHERE Id =: userInfo.getUserId()].OdigoCti__Odigo_login__c;       
       //return Odigo_login;
       return '';
    }
    
   
}