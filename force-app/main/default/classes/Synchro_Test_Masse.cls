/**
 * @File Name          : Synchro_Test_Masse.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 07-23-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/25/2020   Hassan Dakhcha     Initial Version
**/
public with sharing class Synchro_Test_Masse {
    public static List<Account> createAccounts(Integer nmbrPro, String prefixKey, String prefixEmail, String emailDomain, Boolean doOnboard, Set<String> siretList) {

        String CP = 'a023E000000xrQaQAI';
        String Pays = 'a023E000000xm4LQAQ';
        String RTAcc = '0123E00000006KhQAI';
        String siret = '39527681900038';
        String stju = 'a023E000004GbrCQAS';
        String email = '';
        List<String> siretStr = new List<String>(siretList);
        if(siretList == null) {
            siretStr.add(siret);
        }

        List<Account> accList = new List<Account>();
        for(integer i=1 ; i<=nmbrPro; i++ ) {
            email = prefixEmail + prefixKey+ i + emailDomain;
            accList.add(new Account( Code_postal__c = CP,
                                    Login__c = email,
                                    Name = prefixKey,
                                    Pays_LKP__c = Pays,
                                    recordTypeId = RTAcc,
                                    Compte_Nouvelles_Offres__c = true,
                                    Pro_Pilote__c=true,
                                    SIRET_texte__c = siretStr[siretList==null? 0 : i-1],
                                    Statut_Juridique__c = stju));
        }
        insert accList;
        return accList;
    }
       
    public static List<String> createContacts(List<Account> accList) {

        List<Contact> ctcList = new List<Contact>();
        for( Account acc : accList) {
            ctcList.add(new Contact( Salutation = 'M.', FirstName = acc.Name, LastName = 'Nom ',
                                     Contact_Principal_O_N__c = true,
                                     mobilephone = '+33635136116', email = acc.Login__c , AccountId =acc.id));
        }
        insert ctcList;
        
        List<String> ctcSList = new List<String>();
        for(Contact ctc : ctcList)
            ctcSList.add(ctc.id);

    
        return ctcSList;
    }

    public static void createDocs(List<Account> accList) {

      // Set docs at valid
        Set<id> accSet = new Set<id>();
        for(Account acc : accList){
            accSet.add(acc.id);
        }
        List<document__c> docList = [SELECT id, Statut__c, Date_de_validite__c, type_de_document__c 
                                     FROM Document__c Where Compte_Pro__c IN :accSet AND Statut__r.Key__c='MISSING'];
        reference__c valid = [SELECT id from reference__c Where key__c ='VALIDATED'];
        reference__c docAssu  = [SELECT id FRom reference__c where recordType.developerName = 'Document_Nom_Assureur' LIMIT 1];


        for(document__c doc : docList) {
            doc.Statut__c = valid.id;
            doc.Date_de_validite__c = system.today() + 10;
            if(doc.type_de_document__c == 'insurance_dc')
                doc.Nom_Assureur__c = docAssu.id;    
           // doc.idDocument__c = 'd6573634-5375-4634-8c48-7f3b14311d0e';
        }
        update docList;


        Map<String, String> docMap = new Map<String, String>();
        for(document__c doc :docList) {
            docMap.put(doc.id, doc.type_de_document__c);
        }
        //callSDS(docMap);
        
    }


    @future
    public static void insertMetier(List<String> ctcList) {
        
        List<reference__c> refMetier = [Select id from reference__c Where recordType.developerName='metier'];
        List<Metier__c> metierList = new List<Metier__c>();
        for( String ctc : ctcList ){
            for(Integer i = 0 ; i<refMetier.size() ; i++) {
                metierList.add(new metier__c(Contact__c = ctc , metier__c = refMetier[i].id));
            }   
        }
        insert metierList;

    } 

    @future
    public static void insertPC(List<String> ctcList) {
  
       List<reference__c> refPC = [Select id from reference__c Where recordType.developerName='prestation' AND parent__c!='' LIMIT 50];
        List<prestation_contact__c> PCList = new List<prestation_contact__c>();

        for( String ctc : ctcList ){
            for(Integer i = 0 ; i<refPC.size() ; i++) {
                PCList.add(new prestation_Contact__c(Contact__c = ctc , prestation__c = refPC[i].id));
            }   
        }
        insert PCList;
    }

    @future
    public static void insertDpt(List<String> ctcList) {
  
        Set<String> dptToCreate = new Set<String>{'dep_75','dep_94','dep_69', 'dep_06', 'dep_83','dep_04', 'dep_05', 'dep_13'};
        List<reference__c> refDpt = [Select id from reference__c Where recordType.developerName='departement' AND key__c IN :dptToCreate];
        List<departement__c> dptList = new List<Departement__c>();

        for(String ctc : ctcList) {
            for(Integer i = 0 ; i<refDpt.size() ; i++) {
                dptList.add(new Departement__c(Contact__c = ctc, departement__c = refDpt[i].id));
            }
        }
        insert dptList;
    }
   

    @future (callout=true)
    public static void callSDS(Map<String, String> docMap) {
        // Call SDS and add files :

                List<Document__c> docToUpdate = new List<Document__c>();
                for(String docId : docMap.keySet()) {
                    
                String url_callout_serviceSDS = System.Label.URL_serviceSDSEndpoint;
                string contentType = HttpFormBuilder.GetContentType();
                 String base64Data = 'JVBERi0xLjQKJcfsj6IKNSAwIG9iago8PC9MZW5ndGggNiAwIFIvRmlsdGVyIC9GbGF0ZURlY29kZT4+CnN0cmVhbQp4nE2LuwrDMAxF6SsFfYVGe4gryXbkrIUu'+
                                     '3Vq8lU6BZsoQ+v9QJVCI7qDDfcxIgQVp0R+GCS5PxfELhCPMUEJcbs22PEx4rVYtKBQoYf0AByLKvMaM0lEo2qOS/YJ1gpfbeevkmN3et+YmTaru4Fs2ZlJ39BJy'+
                                     'oSTutJhJNHeuMVO4z+zOPhqVPm83jS9BKHVsm3e9w63Cw/QDUHkpVGVuZHN0cmVhbQplbmRvYmoKNiAwIG9iagoxNTgKZW5kb2JqCjQgMCBvYmoKPDwvVHlwZS9Q'+
                                     'YWdlL01lZGlhQm94IFswIDAgNjEyIDc5Ml0KL1JvdGF0ZSAwL1BhcmVudCAzIDAgUgovUmVzb3VyY2VzPDwvUHJvY1NldFsvUERGIC9UZXh0XQovRXh0R';

                string form64 = '';
                form64 += HttpFormBuilder.WriteBoundary();
                form64 += HttpFormBuilder.WriteBlobBodyParameter('file', base64Data, 'fichierTst_assurrance.pdf', 'application/pdf');
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
                String urlws = url_callout_serviceSDS+'document/create?type='+docMap.get(docId);
               // String urlws = url_callout_serviceSDS+'document/add/'+ 'd6573634-5375-4634-8c48-7f3b14311d0e';
               httpRequest.setEndpoint(urlws); 
                Http http = new Http();
                HttpResponse response = http.send(httpRequest);
                String jsonInput = response.getBody();
                
                Map<String, Object> mBody = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
                String message = (String)mBody.get('message');
                if(message == 'created document') {
                    Map<String, Object> mData = (Map<String, Object>)mBody.get('data');
                    docToUpdate.add(new Document__c(id = docId, idDocument__c = (String)mData.get('idDocument')));
                } else {
                    System.debug('### Erreur SDS : ' + message);
                    System.debug('### doc : '+ docId + ' ' + docMap.get(docId));
                }
            }

                update docToUpdate;
            }
        
}

/*
for(Account acc : accList) {
    acc.Compte_Nouvelles_Offres__c = true;
	acc.Pro_Pilote__c = true;
}
update accList;
*/