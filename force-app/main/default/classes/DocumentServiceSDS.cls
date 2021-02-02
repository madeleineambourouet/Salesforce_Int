/**
 * @File Name          : DocumentServiceSDS.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 07-20-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    1/16/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class DocumentServiceSDS {
    
    
    public class DocumentFile {
        String name;
        String uri;
    }

    @AuraEnabled
    public static Map<String, String> callDocumentType() {
        Schema.DescribeFieldResult fieldResult = Document__c.Type_de_document__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        Map<String, String> returnMap = new Map<String, String>();
        for( Schema.PicklistEntry v : values) {
          returnMap.put(v.getValue(), v.getLabel());
        }
        System.debug('>>>>>>>>>>>>>>>>>>>>> returnMap ' + returnMap);
        return returnMap;
    }
    
    @AuraEnabled
    public static String saveTheFile(String fileName, String base64Data, String mimeType, String sobjecttype, String recordId, String typeDocument) { 
        List<Reference__c> listrefNewDoc = [select id  from Reference__c where Lov_Type__c ='Statut_Document' and Key__c='NEW' limit 1];
        Reference__c refNewDoc = null;
        if(!listrefNewDoc.isEmpty()){
            refNewDoc = listrefNewDoc[0];
        }
        String retour = '';
        String jsonInput = '';
        String idDocument = '';
        String idVersion = '';
        String idObject = '';
        system.debug('fileName '+fileName);
        system.debug('base64Data '+base64Data);
        system.debug('mimeType '+mimeType);
        system.debug('typeDocument '+typeDocument);
        /*
base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
String jsonStr = base64Data;
Attachment attach = new Attachment();
attach.contentType = contentType;
attach.name = fileName;
attach.parentId = '0013E000014LJs9QAG'; 
attach.body = EncodingUtil.base64Decode(base64Data);
insert attach;
system.debug('attach '+attach);*/ 
        
        String url_callout_serviceSDS = System.Label.URL_serviceSDSEndpoint;
        system.debug('url_callout_serviceSDS '+url_callout_serviceSDS);
        string contentType = HttpFormBuilder.GetContentType();
        string form64 = '';
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBlobBodyParameter('file', base64Data, fileName, mimeType);
        //form64 += HttpFormBuilder.WriteBoundary();
        //form64 += HttpFormBuilder.WriteBodyParameter('type', 'type');
        form64 += HttpFormBuilder.WriteBoundary(null);
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        String username = System.Label.ServiceSDSEndpoint_User;
        String password = System.Label.ServiceSDSEndpoint_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization', authorizationHeader);
        String urlws = url_callout_serviceSDS+'document/create?type='+typeDocument;
        httpRequest.setEndpoint(urlws); 
        Http http = new Http();
        
        if (!Test.isRunningTest()){
            HttpResponse response = http.send(httpRequest);
            jsonInput = response.getBody();
        }
        else{
            jsonInput = '{"message":"created document","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
        }
        
        Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        
        String message = (String)mBody.get('message');
        if(message == 'created document'){
            Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
            idDocument = (String)mData.get('idDocument'); 
            idVersion = (String)mData.get('idVersion');
            idObject = (String)mData.get('idObject');
            if(idDocument != null && idDocument != '' && sobjecttype != '' && recordId != '' && typeDocument != ''){
                Document__c document = new Document__c();
                system.debug('saveTheFile sobjecttype '+sobjecttype);
                if(sobjecttype == 'Account'){
                    document.Compte_Pro__c = recordId;
                }
                else if(sobjecttype == 'Projet_LMSG__c'){
                    document.Projet__c = recordId;
                } else if(sobjecttype == 'UBO__c') {
                    document.UBO__c = recordId;
                }
                //document.Name = idDocument;
                document.Type_de_document__c = typeDocument; 
                system.debug('saveTheFile document.Compte_Pro__c '+document.Compte_Pro__c);
                system.debug('saveTheFile document.Projet__c '+document.Projet__c);
                if(refNewDoc !=null){
                    document.Statut__c = refNewDoc.Id;
                }
                document.idDocument__c = idDocument;
                system.debug('saveTheFile document '+document);

                try {
                    retour ='Le document a été ajouté avec succès';
                    insert document;
                    system.debug('saveTheFile document2 '+document);
                } catch(dmlexception e) {
                    retour = e.getMessage();
                }

            }
            else {
                retour = 'Une erreur est survenue. idDocument:'+idDocument+' sobjecttype:'+sobjecttype+' recordId:'+recordId+' typeDocument:'+typeDocument;
            }
        }
        else {
            retour = 'Une erreur est survenue: '+message;
        }
        return retour;
    }
    
    @AuraEnabled
    public static String addFileToDocument(String fileName, String base64Data, String mimeType, String recordId, String documentId) { 
        String retour = '';
        String jsonInput = '';
        String idDocument = '';
        String idVersion = '';
        String idObject = '';
        String url_callout_serviceSDS = System.Label.URL_serviceSDSEndpoint;    
        system.debug('fileName '+fileName);
        system.debug('base64Data '+base64Data);
        system.debug('mimeType '+mimeType);        
        string contentType = HttpFormBuilder.GetContentType();
        string form64 = '';
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBlobBodyParameter('file', base64Data, fileName, mimeType);
        form64 += HttpFormBuilder.WriteBoundary(null);
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        String username = System.Label.ServiceSDSEndpoint_User;
        String password = System.Label.ServiceSDSEndpoint_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization', authorizationHeader);

        if(documentId !=null && documentId != ''){
            String urlws = url_callout_serviceSDS+'document/add/'+documentId;
            httpRequest.setEndpoint(urlws); 
            Http http = new Http();        
            if (!Test.isRunningTest()){
                HttpResponse response = http.send(httpRequest);
                jsonInput = response.getBody();
            }
            else{
                jsonInput = '{"message":"attached new object to last version of documentId","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
            }
             Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            
            String message = (String)mBody.get('message');
            if(message.startsWith('attached new object to last version')){
                Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
                idDocument = (String)mData.get('idDocument'); 
                idVersion = (String)mData.get('idVersion');
                idObject = (String)mData.get('idObject');
                if(idDocument != null && idDocument != ''&& recordId != ''){
                    retour ='Le document a été ajouté avec succès';
                }
                else {
                    retour = 'Une erreur est survenue. idDocument:'+idDocument+' recordId:'+recordId;
                }
            }
            else {
                retour = 'Une erreur est survenue: '+message;
            }
        }
        else{
            retour = 'Veuillez renseigner un type de document, sur le document avant d\'ajouter un fichier';
            List<Document__c> docListRecord = [select Type_de_document__c  from Document__c where id =: recordId];
            if(docListRecord != null &&  docListRecord.size() > 0 && docListRecord[0].Type_de_document__c != null && docListRecord[0].Type_de_document__c != ''){
                String typeDocument = docListRecord[0].Type_de_document__c;
                String urlws = url_callout_serviceSDS+'document/create?type='+typeDocument;
                httpRequest.setEndpoint(urlws); 
                Http http = new Http();
                
                if (!Test.isRunningTest()){
                    HttpResponse response = http.send(httpRequest);
                    jsonInput = response.getBody();
                }
                else{
                    jsonInput = '{"message":"created document","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
                }
                
                Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
                String message = (String)mBody.get('message');
                if(message == 'created document'){
                    Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
                    idDocument = (String)mData.get('idDocument'); 
                    idVersion = (String)mData.get('idVersion');
                    idObject = (String)mData.get('idObject');
                    if(recordId != '' && typeDocument != ''){
                        docListRecord[0].idDocument__c = idDocument;
                        try {
                            retour ='Le document a été ajouté avec succès';
                            update docListRecord[0];
                        } catch(dmlexception e) {
                            retour = e.getMessage();
                        }
                    }
                    else {
                        retour = 'Une erreur est survenue. idDocument:'+idDocument+' recordId:'+recordId+' typeDocument:'+typeDocument;
                    }
                }
                else {
                    retour = 'Une erreur est survenue: '+message;
                }
            }            
        }

        return retour;
    }    
    
    @AuraEnabled
    public static List<Object> showDocumentFiles(String documentId) { 
        String retour = '';
        String jsonInput = '';
        String idDocument = '';
        String idVersion = '';
        String idObject = '';    
        List<Object> mObjects  = null;
        String url_callout_serviceSDS = System.Label.URL_serviceSDSEndpoint;
        
        String username = System.Label.ServiceSDSEndpoint_User;
        String password = System.Label.ServiceSDSEndpoint_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization', authorizationHeader);
        String urlws = url_callout_serviceSDS+'document/get/'+documentId;
        httpRequest.setEndpoint(urlws); 
        Http http = new Http();     
        if (!Test.isRunningTest()){
            HttpResponse response = http.send(httpRequest);
            jsonInput = response.getBody(); 
        }
        else{
            jsonInput = '{"idDocument":"f4f62d6c-3f77-4b13-9dc0-092ef89d325e","idVersion":"f7bf54cb-834b-427a-9d4c-0a9c08a9c9f4","versionNumber":3,"objectCount":2,"documentCreatedDate":"2019-12-02T10:15:42.093Z","versionCreatedDate":"2019-12-02T10:25:43.769Z","enumDocType":"certification","enumObjectType":"pdf","objects":[{"idObject":"8c434e18-c728-48d2-aff1-00e1109129d4","uri":"https://sdsblobstore2.blob.core.windows.net/8c434e18-c728-48d2-aff1-00e1109129d4/certification%20-%20page%201.pdf","size":355436,"hrSize":"355.4 kB","order":1,"name":"certification - page 1.pdf","deleted":false,"deletedAt":null},{"idObject":"53620f6b-23db-4b4e-b1cb-1614bb5aaf29","uri":"https://sdsblobstore2.blob.core.windows.net/53620f6b-23db-4b4e-b1cb-1614bb5aaf29/certification%20-%20page%202.pdf","size":355436,"hrSize":"355.4 kB","order":2,"name":"certification - page 2.pdf","deleted":false,"deletedAt":null}],"deleted":false,"deletedAt":null}';
        }
        
        retour = jsonInput;
        system.debug('showDocumentFiles jsonInput '+jsonInput);
        
        Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        
        idDocument = (String)mBody.get('idDocument');
        system.debug('showDocumentFiles mBody '+mBody);
        system.debug('showDocumentFiles idDocument '+idDocument);
        system.debug('showDocumentFiles documentId '+documentId);
        if(idDocument == documentId){
            mObjects = (List<Object>)mBody.get('objects'); 
        }
        //Récupération message erreur dans le cas où l'ID document n'est pas récupéré
        else{
            mObjects = new List<Object>();
            mObjects.add((Object)mBody.get('message'));
            
        }
        system.debug('showDocumentFiles mObjects '+mObjects);
        return mObjects;
    }  

    //@InvocableMethod
    @AuraEnabled
    public static List<String> showDocumentFiles_FLOW(String recordId) { 
        
        system.debug('### HDAK recordID '+ recordId);
        Document__c doc = [SELECT id, idDocument__c FROM Document__c WHERE id =:recordId];


        String jsonInput = '';
        String idDocument = '';
        String idVersion = '';
        String idObject = '';    
        String url_callout_serviceSDS = System.Label.URL_serviceSDSEndpoint;
        
        String username = System.Label.ServiceSDSEndpoint_User;
        String password = System.Label.ServiceSDSEndpoint_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization', authorizationHeader);
        String urlws = url_callout_serviceSDS+'document/get/'+doc.idDocument__c;
        httpRequest.setEndpoint(urlws); 
        Http http = new Http();     
        if (!Test.isRunningTest()){
            HttpResponse response = http.send(httpRequest);
            jsonInput = response.getBody(); 
        }
        else{
            jsonInput = '{"idDocument":"f4f62d6c-3f77-4b13-9dc0-092ef89d325e","idVersion":"f7bf54cb-834b-427a-9d4c-0a9c08a9c9f4","versionNumber":3,"objectCount":2,"documentCreatedDate":"2019-12-02T10:15:42.093Z","versionCreatedDate":"2019-12-02T10:25:43.769Z","enumDocType":"certification","enumObjectType":"pdf","objects":[{"idObject":"8c434e18-c728-48d2-aff1-00e1109129d4","uri":"https://sdsblobstore2.blob.core.windows.net/8c434e18-c728-48d2-aff1-00e1109129d4/certification%20-%20page%201.pdf","size":355436,"hrSize":"355.4 kB","order":1,"name":"certification - page 1.pdf","deleted":false,"deletedAt":null},{"idObject":"53620f6b-23db-4b4e-b1cb-1614bb5aaf29","uri":"https://sdsblobstore2.blob.core.windows.net/53620f6b-23db-4b4e-b1cb-1614bb5aaf29/certification%20-%20page%202.pdf","size":355436,"hrSize":"355.4 kB","order":2,"name":"certification - page 2.pdf","deleted":false,"deletedAt":null}],"deleted":false,"deletedAt":null}';
        }
        
        system.debug('### HDAK showDocumentFiles jsonInput '+jsonInput);
        
        Map<String, String> mBody = (Map<String, String>)JSON.deserializeUntyped(jsonInput);
        
        idDocument = mBody.get('idDocument');
        system.debug('### HDAK showDocumentFiles mBody '+ mBody);
        system.debug('### HDAK showDocumentFiles idDocument '+ idDocument);
        system.debug('### HDAK showDocumentFiles documentId '+ mBody.get('idDocument'));
        List<String> result = new List<String>();
        String subJson;
        List<String> uriList= new List<String>();
        if(idDocument == doc.idDocument__c){
            system.debug('### HDAK SUBJSON =  ' + (String)mBody.get('objects'));
            JSONParser parser = JSON.createParser(mBody.get('objects'));
            String uriStr;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.END_OBJECT) && uriStr!='') {
                    uriList.add(uriStr);
                } else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() =='uri')) {
                    parser.nextToken();
                    uriStr = parser.getText();
                } else if((parser.getCurrentToken() == JSONToken.START_OBJECT)) {
                    uriStr ='';
                }
            }
        }
        //Récupération message erreur dans le cas où l'ID document n'est pas récupéré
        else{
            uriList.add(mBody.get('message'));
        }
          
        return uriList;
    }  

    public static void removeFile(List<Document__c> docToBeDeleted) {
        list<String> idSdsList = new List<String>();
        for(Document__c doc : docToBeDeleted) {
            if(doc.idDocument__c != null && doc.idDocument__c != '') {
                idSdsList.add(doc.idDocument__c);
            }
        }
        for(String str : idSdsList) {
            sendRequest('DELETE', 'document/delete/'+str);
        }
    }

    @future(callout = true)
    public static void sendRequest(String method, String arg) {
        String url_callout_serviceSDS = System.Label.URL_serviceSDSEndpoint;
        String username = System.Label.ServiceSDSEndpoint_User;
        String password = System.Label.ServiceSDSEndpoint_Password;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod(method);
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization', authorizationHeader);
        httpRequest.setEndpoint(url_callout_serviceSDS+arg); 
        Http http = new Http(); 
        
        if(Test.isRunningTest()) {
            return;
            //'{"message": "document deletion requested","data": {"idDocument": "28ffb3f3-b4fd-4967-b390-c5a8a3a73f57"}}';
        }
       
        http.send(httpRequest).getBody();
     }
}