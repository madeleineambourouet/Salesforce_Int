public class ExampleFileSend {
    
    public class DocumentFile {
        String name;
        String uri;
    }
    
    @AuraEnabled
    public static String saveTheFile(String fileName, String base64Data, String mimeType, String sobjecttype, String recordId, String typeDocument) { 
        String retour = '';
        String jsonInput = '';
        String idDocument = '';
        String idVersion = '';
        String idObject = '';
        system.debug('fileName '+fileName);
        system.debug('base64Data '+base64Data);
        system.debug('mimeType '+mimeType);
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
        
        string contentType = HttpFormBuilder.GetContentType();
        string form64 = '';
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBlobBodyParameter('file', base64Data, fileName, mimeType);
        //form64 += HttpFormBuilder.WriteBoundary();
        //form64 += HttpFormBuilder.WriteBodyParameter('type', 'type');
        form64 += HttpFormBuilder.WriteBoundary(null);
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        String username = 'sf';
        String password = '5&MZuy9%*3H@JnDDg^XC'; 
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
        httpRequest.setEndpoint('https://sds-1574875616794.azurewebsites.net/document/create?type='+typeDocument); 
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        // Parse the JSON response
        //if (response.getStatusCode() != 200) {
        jsonInput = response.getBody();
        //}
        
        //system.debug('httpRequest.getBody() '+httpRequest.getBody());
        //jsonInput = '{"message":"created document","data":{"idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
        Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        
        String message = (String)mBody.get('message');
        if(message == 'created document'){
            Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
            idDocument = (String)mData.get('idDocument'); 
            idVersion = (String)mData.get('idVersion');
            idObject = (String)mData.get('idObject');
            if(idDocument != null && idDocument != '' && sobjecttype != '' && recordId != '' && typeDocument != ''){
                Document__c document = new Document__c();
                if(sobjecttype == 'Account')
                    document.Compte_Pro__c = recordId;
                //document.Name = idDocument;
                document.Type_de_document__c = typeDocument;  
                document.idDocument__c = idDocument;
                insert document;
                retour ='Le document a été ajouté avec succès';
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
        
        String username = 'sf';
        String password = '5&MZuy9%*3H@JnDDg^XC'; 
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
        httpRequest.setEndpoint('https://sds-1574875616794.azurewebsites.net/document/add/'+documentId); 
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        // Parse the JSON response
        //if (response.getStatusCode() != 200) {
        jsonInput = response.getBody();
        //}
        
        //system.debug('httpRequest.getBody() '+httpRequest.getBody());
        //jsonInput = '{"message":"created document","data":{"idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
        Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        
        String message = (String)mBody.get('message');
        if(message.startsWith('attached new object to last version of documentId')){
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
        
        String username = 'sf';
        String password = '5&MZuy9%*3H@JnDDg^XC'; 
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization', authorizationHeader);
        httpRequest.setEndpoint('https://sds-1574875616794.azurewebsites.net/document/get/'+documentId); 
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        // Parse the JSON response
        //if (response.getStatusCode() != 200) {
        jsonInput = response.getBody();
        //}
        retour = jsonInput;
        system.debug('showDocumentFiles jsonInput '+jsonInput);
        
        //jsonInput = '{"idDocument":"f4f62d6c-3f77-4b13-9dc0-092ef89d325e","idVersion":"f7bf54cb-834b-427a-9d4c-0a9c08a9c9f4","versionNumber":3,"objectCount":2,"documentCreatedDate":"2019-12-02T10:15:42.093Z","versionCreatedDate":"2019-12-02T10:25:43.769Z","enumDocType":"certification","enumObjectType":"pdf","objects":[{"idObject":"8c434e18-c728-48d2-aff1-00e1109129d4","uri":"https://sdsblobstore2.blob.core.windows.net/8c434e18-c728-48d2-aff1-00e1109129d4/certification%20-%20page%201.pdf","size":355436,"hrSize":"355.4 kB","order":1,"name":"certification - page 1.pdf","deleted":false,"deletedAt":null},{"idObject":"53620f6b-23db-4b4e-b1cb-1614bb5aaf29","uri":"https://sdsblobstore2.blob.core.windows.net/53620f6b-23db-4b4e-b1cb-1614bb5aaf29/certification%20-%20page%202.pdf","size":355436,"hrSize":"355.4 kB","order":2,"name":"certification - page 2.pdf","deleted":false,"deletedAt":null}],"deleted":false,"deletedAt":null}';
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
}