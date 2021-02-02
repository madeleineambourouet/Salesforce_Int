@isTest
public without sharing class DocumentServiceSDS_TEST {
    static testMethod void Test_saveTheFile() {
      Test.startTest();
      String fileName = 'fileName.png';
      String base64Data = 'base64Data';
      String mimeType = 'mimeType';
      String sobjecttype = 'sobjecttype';
      String recordId = 'recordId';
      String typeDocument = 'insurance';
      DocumentServiceSDS.saveTheFile(fileName, base64Data, mimeType, sobjecttype, recordId, typeDocument);
      Test.stopTest();
    }
    static testMethod void Test_addFileToDocument_with_DocumentId() {
      Test.startTest();
      String fileName = 'fileName.png';
      String base64Data = 'base64Data';
      String mimeType = 'mimeType';
      String sobjecttype = 'sobjecttype';
      String recordId = 'recordId';
      String documentId = '0431e509-ec28-48a9-bbaf-e992819d1ad6';
      DocumentServiceSDS.addFileToDocument(fileName, base64Data, mimeType, recordId, documentId);
      Test.stopTest();
    }
    static testMethod void Test_addFileToDocument_without_DocumentId() {
      Test.startTest();
      List<reference__c> listRef = new List<reference__c> ();
      listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
      insert listRef;

      String fileName = 'fileName.png';
      String base64Data = 'base64Data';
      String mimeType = 'mimeType';
      String sobjecttype = 'sobjecttype';
      String recordId = 'recordId';
      String documentId = null;

      Document__c document = new Document__c();
      //document.Name = idDocument;
      document.Type_de_document__c = 'insurance'; 
      document.Statut__c = listRef[0].Id;
      document.idDocument__c = documentId;
      insert document;

      DocumentServiceSDS.addFileToDocument(fileName, base64Data, mimeType, document.Id, documentId);
      Test.stopTest();
    }
    static testMethod void Test_showDocumentFiles() {
      Test.startTest();
      String documentId = 'f4f62d6c-3f77-4b13-9dc0-092ef89d325e';
      DocumentServiceSDS.showDocumentFiles(documentId);
      Test.stopTest();
    }
    static testMethod void Test_callDocumentType() {
      Test.startTest();
      Map<String, String> documentTypes = DocumentServiceSDS.callDocumentType();
      System.assert(documentTypes.size() > 0);
      Test.stopTest();
    }
}