/**
 * @File Name          : DocumentSDS_Checker.cls
 * @Description        : Iterate on Documents with SDS id and gets the objects of the id then checks with GET http request the URI then fills in a result table
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/30/2020, 7:19:54 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/27/2020   Hassan Dakhcha     Initial Version
**/
public class DocumentSDS_Checker implements Queueable, Database.allowsCallouts {

    public static void run( String DocQuery, Integer NumDocByJobs, Boolean purgeTable) {
        
        //[select id, Statut__r.name, idDocument__c, Compte_Pro__c, Compte_Pro__r.name, Compte_Pro__r.Owner.name, Compte_Pro__r.Statut_activation__c,
        //  Compte_Pro__r.Pro_Pilote__c from Document__c 
        // where Type_de_document__c ='insurance_rc' AND Statut__r.Key__c = 'VALIDATED'
        // and idDocument__c !=null and Compte_Pro__r.Pro_Pilote__c = true LIMIT 20];
        if(purgeTable) {
           delete [Select id From Piece_Jointe_SDS__c];
        }
        List<Document__c> docList = Database.query(DocQuery);
        if(docList!=null && !docList.isEmpty()) {
            System.enqueueJob(new DocumentSDS_Checker(docList, NumDocByJobs));
        }
    }

    private List<Document__c> docList;
    private Integer bulkSize;
    private List<Piece_Jointe_SDS__c> table_SDS;
    
    public DocumentSDS_Checker(List<Document__c> docList, Integer NumDocByJobs) {
        this.docList = new List<Document__c>(docList);
        this.table_SDS = new List<Piece_Jointe_SDS__c> ();
        this.bulkSize = NumDocByJobs==0? 1 : NumDocByJobs;
    }
    public void execute(QueueableContext context) {
        System.debug('##### HDAK EXECUTE on #docs = ' + this.docList.size());

        Integer numDocs = 0;
        List<Document__c> remainingDocs = new List<Document__c>(this.docList);

        for(Document__c doc : this.docList) {
            if(numDocs >= this.bulkSize) {
                break;
            }
            numDocs++;
            System.debug('##### HDAK numDocs = ' + numDocs + ' bulkSize='+this.bulkSize);
            table_SDS.addAll(processDoc(doc));
            remainingDocs.remove(remainingDocs.indexOf(doc));
        }
        DataBase.insert(table_SDS, false);

        if(!remainingDocs.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new DocumentSDS_Checker(remainingDocs, this.bulkSize));
        }
    }

    private List<Piece_Jointe_SDS__c> processDoc(Document__c doc) {
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
        String urlws = url_callout_serviceSDS+'document/get/'+doc.idDocument__c;
        System.debug('##### HDAK : urlws = ' + urlws + ' auth' + username +'/'+password);
        httpRequest.setEndpoint(urlws); 
        Http http = new Http();     
        HttpResponse response = http.send(httpRequest);
        jsonInput = response.getBody(); 

        Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);

        mObjects = (List<Object>)mBody.get('objects');
        List<Piece_Jointe_SDS__c> PJList = new List<Piece_Jointe_SDS__c>();

        if(mObjects==null || mObjects.isEmpty()) {
            PJList.add(new Piece_Jointe_SDS__c( Name = 'Pas de pièce jointe', 
                                                Type_de_document_SDS__c= (String)mBody.get('docType'),
                                                Mime_type__c = (String)mBody.get('enumObjectType'),
                                                objectCount__c = (Integer)mBody.get('objectCount'),
                                                documentCreatedDate__c = getDate((String)(mBody.get('documentCreatedDate'))),
                                                versionCreatedDate__c = getDate((String)mBody.get('versionCreatedDate')),
                                                versionNumber__c = (Integer)mBody.get('versionNumber'),
                                                Document__c = doc.id,
                                                Compte_Pro__c = doc.Compte_Pro__c ));
        } else {
            for(Object obj : mObjects) {
                Map<String, Object> oBody = (Map<String, Object>) obj;
                String uri = (String)oBody.get('thumbUri');
                //for(String str : oBody.keySet()) {
                //system.debug('#### objUri = ' + obj.deleted);
                //}

                HttpRequest req = new HttpRequest();
                req.setHeader('Content-Type', 'application/json');
                req.setMethod('GET');
                req.setEndpoint(uri);
                Http http2 = new Http();     
                HttpResponse resp = http2.send(req);

                //if(resp.getStatusCode()!=200 && resp.getStatus().contains('The specified blob does not exist')) {
                system.debug('#### idDoc : '+ mBody.get('idDocument'));
                system.debug('#### uri = ' + uri);
                system.debug('#### response : '+ resp);
                system.debug('#### error : '+ resp.getStatus());
                system.debug('#### documentCreatedDate  : '+  mBody.get('documentCreatedDate'));


                PJList.add(new Piece_Jointe_SDS__c( Name = (String)oBody.get('filename'), 
                                                    hrSize__c = (String)oBody.get('hrSize'),
                                                    order__c = (Integer)oBody.get('order'),
                                                    size_num__c = (Integer)oBody.get('size'),
                                                    idObjectSDS__c = (String)oBody.get('idObject'),
                                                    deleted__c = (Boolean)oBody.get('deleted'),
                                                    deletedAt__c = getDate((String)oBody.get('deletedAt')),
                                                    Type_de_document_SDS__c= (String)mBody.get('docType'),
                                                    Mime_type__c = (String)mBody.get('objectType'),
                                                    objectCount__c = (Integer)mBody.get('objectCount'),
                                                    documentCreatedDate__c = getDate((String)(mBody.get('documentCreatedDate'))),
                                                    versionCreatedDate__c = getDate((String)mBody.get('versionCreatedDate')),
                                                    versionNumber__c = (Integer)mBody.get('versionNumber'),
                                                    Response_Code__c = resp.getStatusCode(),
                                                    Document__c = doc.id,
                                                    Piece_jointe__c = uri,// URL
                                                    Compte_Pro__c = doc.Compte_Pro__c,
                                                    Check_Message__c = resp.getStatus(),
                                                    cree_par__c =  (String)mBody.get('createdBy')));
                //}
            }
        }
        return PJList;            
    }

    private DateTime getDate(String inputDate) {
        if(inputDate==null) 
            return null;
        List<String> dateStr = inputDate.split('T');
        List<String> calendar = dateStr[0].split('-');
        List<String> hours = dateStr[1].split(':');
        hours[2] = hours[2].substringBefore('.');

        return Datetime.newInstance(Integer.valueOf(calendar[0]),
                             Integer.valueOf(calendar[1]),
                             Integer.valueOf(calendar[2]),
                             Integer.valueOf(hours[0]), 
                             Integer.valueOf(hours[1]), 
                             Integer.valueOf(hours[2]));
    }
}
/* SDS RESPONSE : 

    "idDocument": "5030be50-6f15-4fc2-a5e4-fbca63ae3162",
    "idVersion": "f3d98957-d28b-48de-8dc1-c5578bee4c37",
    "versionNumber": 1,
    "objectCount": 1,
    "documentCreatedDate": "2020-06-17T15:45:01.377361Z",
    "versionCreatedDate": "2020-06-17T15:45:01.377368Z",
    "docType": "kbis",
    "objectType": "pdf",
    "objectMimeType": "application/pdf",
    "objects": [
        {
            "idObject": "04569955-29fe-4193-b3eb-bcb3092c356b",
            "uri": "https://lmsgdevsdsstoragea.blob.core.windows.net/04569955-29fe-4193-b3eb-bcb3092c356b/kbis.pdf?sig=eCoE5hR6Q2uGZHaZMBsbUcC8BWghxJInJWLmYiK1UjM%3D&st=2020-06-27T07%3A52%3A05Z&se=2020-06-27T09%3A52%3A05Z&sv=2019-02-02&sp=r&sr=b",
            "size": 151041,
            "hrSize": "151.0 kB",
            "order": 1,
            "name": "KBIS",
            "filename": "kbis.pdf",
            "deleted": false,
            "deletedAt": null,
            "createdBy": "wbe",
            "thumbAvailable": false,
            "thumbUri": "https://lmsgdevsdsstoragea.blob.core.windows.net/04569955-29fe-4193-b3eb-bcb3092c356b/kbis.pdf?sig=eCoE5hR6Q2uGZHaZMBsbUcC8BWghxJInJWLmYiK1UjM%3D&st=2020-06-27T07%3A52%3A05Z&se=2020-06-27T09%3A52%3A05Z&sv=2019-02-02&sp=r&sr=b",
            "webVersionAvailable": false,
            "webVersionUri": "https://lmsgdevsdsstoragea.blob.core.windows.net/04569955-29fe-4193-b3eb-bcb3092c356b/kbis.pdf?sig=eCoE5hR6Q2uGZHaZMBsbUcC8BWghxJInJWLmYiK1UjM%3D&st=2020-06-27T07%3A52%3A05Z&se=2020-06-27T09%3A52%3A05Z&sv=2019-02-02&sp=r&sr=b",
            "width": 0,
            "heigth": 0,
            "ratio": null,
            "orientation": null
        }
    ],
    "deleted": false,
    "deletedAt": null,
    "createdBy": "wbe",
    "hasValidity": false,
    "validity": null,
    "name": "KBIS"
}

*/