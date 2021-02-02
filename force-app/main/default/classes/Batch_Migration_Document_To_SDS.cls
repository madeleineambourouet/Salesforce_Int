/**
* @author Clement Musabimana
* @date 31/03/2020
* @description Gestion de migration des documents salesforce vers SDS
**/
public class  Batch_Migration_Document_To_SDS implements Database.Batchable<sObject>, Database.AllowsCallouts  {
	public String queryString = 'SELECT id,idDocument__c,Type_de_document__c from document__c where idDocument__c = null';

   	public Database.QUERYLocator start(Database.BatchableContext BC){
		System.debug('Batch_Migration_Document_To_SDS queryString '+queryString);
    	return Database.getQUERYLocator(queryString);
   	}



   	public void execute(Database.BatchableContext BC, List<sObject> scope){
    	String  mailBody = '';
   		List<document__c> listeDocumentToUpdate = new List<document__c>();
   		set<id> listDocumentId = new set<id>();
   		Map<String,List<String>> listeDocumentContentDocument = new Map<String,List<String>>();
   		Map<String,List<ContentVersion>> listeContentDocumentVersion = new Map<String,List<ContentVersion>>();
   		List<String> listeContentDocumentId = new List<String>();
   		Map<String,String> mapExtensionMimeTye = new Map<String,String>();
   		mapExtensionMimeTye.put('pdf','application/pdf');
   		mapExtensionMimeTye.put('jpeg','image/jpeg');
   		mapExtensionMimeTye.put('jpg','image/jpeg');
   		mapExtensionMimeTye.put('png','image/png');
   		mapExtensionMimeTye.put('xls','application/vnd.ms-excel');
   		mapExtensionMimeTye.put('doc','application/msword');
   		mapExtensionMimeTye.put('docx','application/vnd.openxmlformats-officedocument.wordprocessingml.document');
		System.debug('Batch_callBus_subscriptionService scope '+scope);
		for (document__c documentItem : (list<document__c>)scope) {
            listDocumentId.add(documentItem.id);
            List<String> listeVide = new List<String>();
            listeDocumentContentDocument.put(documentItem.Id,listeVide);
        }

        for(ContentDocumentLink contentDocumentLink: [SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType, ContentDocument.FileExtension, ContentDocument.id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: listDocumentId]){
        	List<String> listeDocs = listeDocumentContentDocument.get(contentDocumentLink.LinkedEntityId);
        	listeContentDocumentId.add(contentDocumentLink.ContentDocumentId);
        	listeDocs.add(contentDocumentLink.ContentDocumentId);
        	listeDocumentContentDocument.put(contentDocumentLink.LinkedEntityId,listeDocs);
            List<ContentVersion> listeVide = new List<ContentVersion>();
            listeContentDocumentVersion.put(contentDocumentLink.ContentDocumentId,listeVide);
        }


		for (ContentVersion cv: [SELECT ContentModifiedById,ContentDocumentId,FileExtension,FileType,ContentSize,ContentUrl,Id,VersionData,VersionNumber,Title FROM ContentVersion where ContentDocumentId in: listeContentDocumentId]){
			blob dataVersion = cv.VersionData;
			String mimeType = cv.FileType;
			String base64Data = EncodingUtil.base64Encode(cv.VersionData);
			List<ContentVersion> listeContentVersion = listeContentDocumentVersion.get(cv.ContentDocumentId);
        	listeContentVersion.add(cv);
        	listeContentDocumentVersion.put(cv.ContentDocumentId,listeContentVersion);
		}

		mailBody = mailBody + 'Batch_Migration_Document_To_SDS Creation SDS ---------------<br/>';
		mailBody = mailBody + '--------------------------------------------------<br/>';
		for (document__c documentItem : (list<document__c>)scope) {
            String idDocument =  '';
            Boolean errorExist = false;
      		system.debug('Batch_Migration_Document_To_SDS documentItem '+documentItem);
            for (String contentDocumentId : listeDocumentContentDocument.get(documentItem.Id)) {
            	List<ContentVersion> listeContentVersion = listeContentDocumentVersion.get(contentDocumentId);
        	    blob dataVersion = listeContentVersion[0].VersionData;
			    String mimeType = listeContentVersion[0].FileType;
			    String fileName = listeContentVersion[0].Title;
			    String base64Data = EncodingUtil.base64Encode(listeContentVersion[0].VersionData);
			    if(listeContentVersion[0] != null && listeContentVersion[0].FileExtension != null && mapExtensionMimeTye.get(listeContentVersion[0].FileExtension) != null){
			    	mimeType = mapExtensionMimeTye.get(listeContentVersion[0].FileExtension);	
	      			system.debug('Batch_Migration_Document_To_SDS contentDocumentId '+contentDocumentId);
	      			system.debug('Batch_Migration_Document_To_SDS mimeType '+mimeType);
	      			system.debug('Batch_Migration_Document_To_SDS idDocument '+idDocument);
				    String rtTemp = addFileBlobToDocumentSDS(fileName, mimeType, base64Data, idDocument, documentItem.Type_de_document__c);
				    //Si erreur dans l'upload d'un document; on continue les autres documents
				    List<String> resSplit = rtTemp.split('##', 2);
                    String rt  = resSplit[0];
                    if(rt == 'ERREURSDS'){
				    	errorExist = true;
				    	//break;
				    }
				    else{
				    	idDocument = rt;
                        if(resSplit.size() > 1){
                            filename = resSplit[1];
                        }
				    }
			    }
			    else{
			    	errorExist = true;
			    	//break;
			    }

            
        	}
        	if(idDocument != ''){
	        	document__c docToUpdate = new document__c();
	        	docToUpdate.Id = documentItem.Id;
	        	docToUpdate.idDocument__c = idDocument;
	        	listeDocumentToUpdate.add(docToUpdate);
        	}
        	if(errorExist == true){
	            mailBody = mailBody + '- ' + documentItem.Id + ': <span style="color:red;font-weight:bold">KO</span> ID_SDS: '+idDocument+' un ou plusieurs fichiers non migrés<br/>'; 
		    }
		    else{
		    	if(listeDocumentContentDocument.get(documentItem.Id) != null && listeDocumentContentDocument.get(documentItem.Id).size()> 0){    
		    		mailBody = mailBody + '- ' + documentItem.Id + ': <span style="color:green;font-weight:bold">OK</span> ID_SDS: '+idDocument+'<br/>'; 
				}
				else {
					mailBody = mailBody + '- ' + documentItem.Id + ': <span> Pas de document en PJ</span><br/>'; 
				}
	        }
        }


      	system.debug('Batch_Migration_Document_To_SDS listeDocumentToUpdate '+listeDocumentToUpdate);
        if (listeDocumentToUpdate.size() > 0) {

            Database.SaveResult[] results = Database.update(listeDocumentToUpdate, false);
            Integer cnt = 0;
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess() || Test.isRunningTest()) {
                	String erreurSave = 'id: '+listeDocumentToUpdate.get(cnt);
                    for(Database.Error err : sr.getErrors()) {            
                        erreurSave = erreurSave +'  StatusCode '+ err.getStatusCode() + ': getMessage ' + err.getMessage() +' getFields '+err.getFields()+'<br/>';
                    }

    				mailBody = mailBody + 'Erreur Update Documents---------------------------<br/>'; 
            		mailBody = mailBody + erreurSave; 
                }
                cnt++;
            }

        }
    	//Si des erreurs ont été récupérés, on envoie un mail a la supervision
    	if(mailBody != null && mailBody != ''){
    		System.debug('enregistrerNotations **** envoi mail ');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String email = System.Label.DL_SGDBF_supervision_processus;
            //String email = UserInfo.getUserEmail();
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {email}); 
            mail.setSubject('Traitement Batch_Migration_Document_To_SDS terminé - logs');
            mailBody = '<html><body>' + mailBody + '</body></html>';
            mail.setHtmlBody(mailBody); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			System.debug('enregistrerNotations **** envoi mail ok');
    	}

   	}

   	public void finish(Database.BatchableContext BC){

   	}



public static String addFileBlobToDocumentSDS(String fileName, String mimeType, String base64Data, String documentId, String typeDocument) { 
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
            	system.debug('test fileName '+fileName);
                if (fileName.contains('fileNameTest1.pdf')){
	                jsonInput = '{"message":"error attached new object to last version of documentId","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
	            }
	            else{
	                jsonInput = '{"message":"attached new object to last version of documentId","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
	            }
            }
             Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            
            String message = (String)mBody.get('message');
            if(message.startsWith('attached new object to last version')){
                Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
                idDocument = (String)mData.get('idDocument'); 
                if(idDocument != null && idDocument != ''){
                    retour = idDocument;
                }
            }
            else {
                system.debug('Une erreur est survenue: '+message);
                retour = 'ERREURSDS';
            }
            system.debug('retour '+retour); 
        }
        else{
            String urlws = url_callout_serviceSDS+'document/create?type='+typeDocument;
            httpRequest.setEndpoint(urlws); 
            Http http = new Http();
            
            if (!Test.isRunningTest()){
                HttpResponse response = http.send(httpRequest);
                jsonInput = response.getBody();
            }
            else{

            	system.debug('test fileName '+fileName);
                if (fileName.contains('fileNameTest1.pdf')){
	                jsonInput = '{"message":" error created document","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
	            }
	            else{
	                jsonInput = '{"message":"created document","data":{"filename":"assurance - page 1.pdf","idDocument":"0431e509-ec28-48a9-bbaf-e992819d1ad6","idVersion":"033bd676-e178-4561-847a-a0669ff1e838","idObject":"9ecacda5-d389-416e-8ac7-c9b529b22b26"}}';
	            }
                
            }
            
            Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            
            String message = (String)mBody.get('message');
            if(message == 'created document'){
                Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
                idDocument = (String)mData.get('idDocument');
                filename = (String)mData.get('filename'); 
                retour = idDocument+'##'+fileName;
            }
            else {
                system.debug('Une erreur est survenue: '+message);
                retour = 'ERREURSDS';
            }
            system.debug('retour '+retour);           
        }

        return retour;
    }
}