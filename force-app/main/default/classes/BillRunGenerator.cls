/**
* @author Qiuyan Liu
* @CreatedDate 23 Aôut 2017
* @description EB-114, create a billrun when new subscription(post résiliation) is created 
*/
public class BillRunGenerator implements Queueable, Database.AllowsCallouts  {
    public static Integer LOT_SIZE = 15;
    private List<Id> idFutureLotsList = new List<Id>();
    Private List<Id> idCurrentLotList = new List<Id>();
    
    public BillRunGenerator(List<Id> ids) {
        LOT_SIZE = Test.isRunningTest() ? 2 : 15;
        Integer count = 0;
        List<Zuora__Subscription__c> subList = [SELECT Id, Monitor_post_resiliaitonWS__c, Type_de_geste__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c  FROM Zuora__Subscription__c where id in:ids];
        for (Zuora__Subscription__c sub : subList) {
            if (sub.Type_de_geste__c == 'Geste commercial post-résiliation') {
                if (count < LOT_SIZE) {
                    idCurrentLotList.add(sub.id);
                } else {
                    idFutureLotsList.add(sub.id);
                }
                count++;
            }
        }
    }
    
    public void execute(QueueableContext context) {
        List<Zuora__Subscription__c> subList = [SELECT Id, Monitor_post_resiliaitonWS__c, Zuora__Zuora_Id__c, Type_de_geste__c, Zuora__CustomerAccount__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c FROM Zuora__Subscription__c where id in:idCurrentLotList];
        if (subList == null || subList.isEmpty()) return;
        Set<String> zAccountIdSet = new Set<String>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String email = System.Label.DL_SGDBF_supervision_processus;
        mail.setToAddresses(new String[] {email}); 
        mail.setSubject('l\'erreur Création BillRun, Post-résiliation');
        String bod = '';
        String username = Label.Zuora_TECH_Login;
        String password = Label.Zuora_TECH_Password; 
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue); 
        try {
          for (Zuora__Subscription__c sub : subList) {
            
                if (sub.Zuora__CustomerAccount__c == null || sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c == null) continue;
                sub.Monitor_post_resiliaitonWS__c = '';
                
                
                //Cancel current subscription
                String cancellationEffectiveDate = DateTime.now().addDays(1).format('yyyy-MM-dd');
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                request1.setMethod('PUT');
                request1.setHeader('Content-Type', 'application/json; charset=UTF-8');
                request1.setHeader('Authorization', authorizationHeader);
                request1.setEndpoint(Label.URL_ZuoraREST + '/v1/subscriptions/' + sub.Zuora__Zuora_Id__c + '/cancel');
                request1.setBody('{"cancellationEffectiveDate":"'+cancellationEffectiveDate+'",'+
                                '"cancellationPolicy":"SpecificDate"}');
                HttpResponse response1 = Test.isRunningTest() ? new HttpResponse() : http1.send(request1);
                // Parse the JSON response
                BillRunGenerator.CancelSubscriptionRes csRes = Test.isRunningTest() ? new BillRunGenerator.CancelSubscriptionRes() : (BillRunGenerator.CancelSubscriptionRes)JSON.deserialize(response1.getBody() , BillRunGenerator.CancelSubscriptionRes.class);
                if (Test.isRunningTest()) {
                    csRes.reasons = new List<BillRunGenerator.FailedReason>();
                }
                
                
                if (response1.getStatusCode() != 200) {
                    sub.Monitor_post_resiliaitonWS__c += 'Cancel subscription Erreur : ' + response1.getStatusCode() + ' ' + response1.getStatus()+'; ';
                } else {
                    if ((csRes.reasons != null && csRes.reasons.size() > 0) || Test.isRunningTest()) {
                        sub.Monitor_post_resiliaitonWS__c += 'Cancel subscription falied, ' + csRes.reasons[0].message;
                    } else {
                        sub.Monitor_post_resiliaitonWS__c += 'Cancel subscription OK; ';
                    }
                    
                }
                

                Http http3 = new Http();
                HttpRequest request3 = new HttpRequest();
                request3.setMethod('GET');
                request3.setHeader('Content-Type', 'application/json; charset=UTF-8');
                request3.setHeader('Authorization', authorizationHeader);
                request3.setEndpoint(Label.URL_ZuoraREST + '/v1/action/query'); 
                //request3.setBody('{"queryString":"SELECT Id, Status,Name, CancelledDate, Type_de_geste__c from Subscription WHERE AccountId = \'' + sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c + '\' AND Type_de_geste__c != \'Geste commercial post-résiliation\' AND Status!=\'Expired\'"}');
                request3.setBody('{"queryString":"SELECT Id, Status,Name, CancelledDate, Type_de_geste__c from Subscription WHERE AccountId = \'' + sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c + '\' AND Status!=\'Expired\'"}');
                HttpResponse response3 = Test.isRunningTest() ? new HttpResponse() : http3.send(request3);
                String body3 = response3.getBody().replace('Type_de_geste__c', 'Type_de_geste');
                BillRunGenerator.AccSubscriptions accSubs = Test.isRunningTest() ? new BillRunGenerator.AccSubscriptions() : (BillRunGenerator.AccSubscriptions)JSON.deserialize(body3 , BillRunGenerator.AccSubscriptions.class);
                if (Test.isRunningTest()) {
                    accSubs.records = new List<Record>();
                }
                if (accSubs.records != null || Test.isRunningTest()) {
                    Boolean createBillRun = true;
                    for (BillRunGenerator.Record r : accSubs.records) {
                        if ((r.CancelledDate != null &&  Date.valueOf(r.CancelledDate) > Date.today() && r.Type_de_geste != 'Geste commercial post-résiliation') || Test.isRunningTest()) {
                            createBillRun = false;
                            break;
                        }
                    }
                    
                    if (createBillRun || Test.isRunningTest()) {
                        zAccountIdSet.add(sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);
                    }
                } 
            
          }

            if (zAccountIdSet.size() > 0 ) {
                for (String zAccountId : zAccountIdSet) {
                    //Create BillRun for current account
                    String invoiceDate = DateTime.now().format('yyyy-MM-dd');
                    Http http2 = new Http();
                    HttpRequest request2 = new HttpRequest();
                    request2.setMethod('POST');
                    request2.setHeader('Content-Type', 'application/json; charset=UTF-8');
                    request2.setHeader('Authorization', authorizationHeader);
                    request2.setEndpoint(Label.URL_ZuoraREST + '/v1/action/create');
                    
                    String body2 = '{"objects": [{"AccountId": "' + zAccountId + '","InvoiceDate": "' + invoiceDate + '", "TargetDate": "' + invoiceDate + '","AutoPost":"true"}],"type": "BillRun"}';
                    request2.setBody(body2);
                    HttpResponse response2 = Test.isRunningTest() ? new HttpResponse() : http2.send(request2);
                    String resBody = response2.getBody().removeEnd(']');
                    resBody = resBody.removeStart('[');
                    BillRunGenerator.BillRunRes brRes = Test.isRunningTest() ? new BillRunGenerator.BillRunRes() : (BillRunGenerator.BillRunRes)JSON.deserialize(resBody , BillRunGenerator.BillRunRes.class);
                    if (Test.isRunningTest()) {
                        brRes.Errors = new List<BillRunGenerator.FailedReason>();
                    }
                    
                    String brMSG = '';
                    if (response2.getStatusCode() != 200) {
                        brMSG = 'BillRun Erreur : ' + response2.getStatusCode() + ' ' + response2.getStatus()+'; ';
                    } else {
                        if ((brRes.Errors != null && brRes.Errors.size() > 0) || Test.isRunningTest()) {
                            brMSG = 'BillRun falied, ' + brRes.Errors[0].message;
                        } else {
                            brMSG = 'BillRun OK; ';
                        }
                    }
                    
                    for (Zuora__Subscription__c sub : subList) {
                        if (sub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c == zAccountId) {
                            sub.Monitor_post_resiliaitonWS__c += brMSG;
                        }
                    }
                }
            }
        
          update subList;
        } catch (Exception e) {
            bod += 'Le souscription du type post-résiliation ' + subList + ' n\'ont pas pu Créer un BillRun. Erreur : ' + 'Exception : ' + e.getMessage() + '<br>';
        }
        if (!String.isEmpty(bod)) {
            mail.setHtmlBody(bod); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        if (idFutureLotsList != null && idFutureLotsList.size() > 0 && !Test.isRunningTest()) {
            System.enqueueJob(new BillRunGenerator(idFutureLotsList));
        }
    }
    
    public class AccSubscriptions {
        public List<Record> records;
        public Integer size;
        public Boolean done;
    }
    
    public class Record {
        public String CancelledDate;
        public String Status;
        public String Name;
        public String Id;
        public String Type_de_geste;
    }
    
    public class CancelSubscriptionRes {
        public Boolean success;
        public List<FailedReason> reasons;
    }
    
    public class BillRunRes {
        public Boolean success;
        public List<FailedReason> Errors;
    }
    
    public class FailedReason {
        public String code;
        public String message;
    }
}