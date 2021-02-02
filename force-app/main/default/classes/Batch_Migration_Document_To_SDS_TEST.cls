@isTest
public class Batch_Migration_Document_To_SDS_TEST {

    static testMethod void Test_migration_doc1() {
		Test.startTest();
		List<reference__c> listRef = new List<reference__c> ();
		listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
		insert listRef;

		String fileName2 = 'fileNameTest2.pdf';
		String fileName = 'fileNameTest1.pdf';
		String base64Data = 'JVBERi0xLjUNCjQgMCBvYmoNCjw8L1R5cGUgL1BhZ2UvUGFyZW50IDMgMCBSL0NvbnRlbnRzIDUgMCBSL01lZGlhQm94IFswIDAgNTk1LjI5OTk4Nzc5IDg0MS45MDAwMjQ0MV0vUmVzb3VyY2VzPDwvRm9udDw8L0ZBQUFBSCA3IDAgUi9GQUFBQkIgMTEgMCBSL0ZBQUFCRSAxNCAwIFIvRkFBQUJIIDE3IDAgUi9GQUFBQ0EgMjAgMCBSL0ZBQUFDRCAyMyAwIFIvRkFBQUNHIDI2IDAgUi9GQUFBQ0ogMjkgMCBSL0ZBQUFERSAzNCAwIFI+Pi9YT2JqZWN0PDwvWDEgOSAwIFI+Pj4+L0dyb3VwIDw8L1R5cGUvR3JvdXAvUy9UcmFuc3BhcmVuY3kvQ1MvRGV2aWNlUkdCPj4+Pg0KZW5kb2JqDQo1IDAgb2JqDQo8PC9MZW5ndGggMzYgMCBSL0ZpbHRlciAvR';
		String mimeType = 'application/pdf';

		Document__c document = new Document__c();
		document.Type_de_document__c = 'insurance'; 
		document.Statut__c = listRef[0].Id;
		insert document;

		List<ContentVersion>cvList = new List<ContentVersion>();
	    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.Title = fileName2;
        testContentInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert.PathOnClient = '/' + fileName2 ;
        cvList.add(testContentInsert);
        ContentVersion testContentInsert2 = new ContentVersion();
        testContentInsert2.Title = fileName;
        testContentInsert2.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert2.PathOnClient = '/' + fileName ;
        cvList.add(testContentInsert2);

	    
	    insert cvList;
	    cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = cvList[0].ContentDocumentId;
        cl.LinkedEntityId = document.Id; //Shared with record ID
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        cdlList.add(cl);
        ContentDocumentLink cl2 = new ContentDocumentLink();
        cl2.ContentDocumentId = cvList[1].ContentDocumentId;
        cl2.LinkedEntityId = document.Id; //Shared with record ID
        cl2.ShareType = 'V';
        cl2.Visibility = 'AllUsers';
        cdlList.add(cl2);
	    insert cdlList;


        Batch_Migration_Document_To_SDS bmd = new Batch_Migration_Document_To_SDS();
        Database.executeBatch(bmd);
        Document__c document2 = [SELECT id, idDocument__c FROM Document__c limit 1 ];
        System.assertNotEquals(document2.idDocument__c, '');


      	Test.stopTest();
    }

    static testMethod void Test_migration_doc2() {
		Test.startTest();
		List<reference__c> listRef = new List<reference__c> ();
		listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
		insert listRef;

		String fileName2 = 'fileNameTest2.pdf';
		String fileName = 'fileNameTest3.pdf';
		String base64Data = 'JVBERi0xLjUNCjQgMCBvYmoNCjw8L1R5cGUgL1BhZ2UvUGFyZW50IDMgMCBSL0NvbnRlbnRzIDUgMCBSL01lZGlhQm94IFswIDAgNTk1LjI5OTk4Nzc5IDg0MS45MDAwMjQ0MV0vUmVzb3VyY2VzPDwvRm9udDw8L0ZBQUFBSCA3IDAgUi9GQUFBQkIgMTEgMCBSL0ZBQUFCRSAxNCAwIFIvRkFBQUJIIDE3IDAgUi9GQUFBQ0EgMjAgMCBSL0ZBQUFDRCAyMyAwIFIvRkFBQUNHIDI2IDAgUi9GQUFBQ0ogMjkgMCBSL0ZBQUFERSAzNCAwIFI+Pi9YT2JqZWN0PDwvWDEgOSAwIFI+Pj4+L0dyb3VwIDw8L1R5cGUvR3JvdXAvUy9UcmFuc3BhcmVuY3kvQ1MvRGV2aWNlUkdCPj4+Pg0KZW5kb2JqDQo1IDAgb2JqDQo8PC9MZW5ndGggMzYgMCBSL0ZpbHRlciAvR';
		String mimeType = 'application/pdf';

		Document__c document = new Document__c();
		document.Type_de_document__c = 'insurance'; 
		document.Statut__c = listRef[0].Id;
		insert document;

		List<ContentVersion>cvList = new List<ContentVersion>();
	    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.Title = fileName;
        testContentInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert.PathOnClient = '/' + fileName ;
        cvList.add(testContentInsert);
        ContentVersion testContentInsert2 = new ContentVersion();
        testContentInsert2.Title = fileName2;
        testContentInsert2.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert2.PathOnClient = '/' + fileName2 ;
        cvList.add(testContentInsert2);

	    
	    insert cvList;
	    cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = cvList[0].ContentDocumentId;
        cl.LinkedEntityId = document.Id; //Shared with record ID
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        cdlList.add(cl);
        ContentDocumentLink cl2 = new ContentDocumentLink();
        cl2.ContentDocumentId = cvList[1].ContentDocumentId;
        cl2.LinkedEntityId = document.Id; //Shared with record ID
        cl2.ShareType = 'V';
        cl2.Visibility = 'AllUsers';
        cdlList.add(cl2);
	    insert cdlList;

        Batch_Migration_Document_To_SDS bmd = new Batch_Migration_Document_To_SDS();
        Database.executeBatch(bmd);

      	Test.stopTest();
        Document__c document2 = [SELECT id, idDocument__c FROM Document__c limit 1 ];
        System.assertNotEquals(document2.idDocument__c, '');
    }

    static testMethod void Test_migration_doc3() {
		Test.startTest();
		List<reference__c> listRef = new List<reference__c> ();
		listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
		insert listRef;

		String fileName2 = 'fileNameTest2.pdf';
		String fileName = 'fileNameTest1.pdf';
		String base64Data = 'JVBERi0xLjUNCjQgMCBvYmoNCjw8L1R5cGUgL1BhZ2UvUGFyZW50IDMgMCBSL0NvbnRlbnRzIDUgMCBSL01lZGlhQm94IFswIDAgNTk1LjI5OTk4Nzc5IDg0MS45MDAwMjQ0MV0vUmVzb3VyY2VzPDwvRm9udDw8L0ZBQUFBSCA3IDAgUi9GQUFBQkIgMTEgMCBSL0ZBQUFCRSAxNCAwIFIvRkFBQUJIIDE3IDAgUi9GQUFBQ0EgMjAgMCBSL0ZBQUFDRCAyMyAwIFIvRkFBQUNHIDI2IDAgUi9GQUFBQ0ogMjkgMCBSL0ZBQUFERSAzNCAwIFI+Pi9YT2JqZWN0PDwvWDEgOSAwIFI+Pj4+L0dyb3VwIDw8L1R5cGUvR3JvdXAvUy9UcmFuc3BhcmVuY3kvQ1MvRGV2aWNlUkdCPj4+Pg0KZW5kb2JqDQo1IDAgb2JqDQo8PC9MZW5ndGggMzYgMCBSL0ZpbHRlciAvR';
		String mimeType = 'application/pdf';

		Document__c document = new Document__c();
		document.Type_de_document__c = 'insurance'; 
		document.Statut__c = listRef[0].Id;
		insert document;

		List<ContentVersion>cvList = new List<ContentVersion>();
	    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentVersion testContentInsert = new ContentVersion();
        testContentInsert.Title = fileName;
        testContentInsert.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert.PathOnClient = '/' + fileName ;
        cvList.add(testContentInsert);
        ContentVersion testContentInsert2 = new ContentVersion();
        testContentInsert2.Title = fileName2;
        testContentInsert2.VersionData = EncodingUtil.base64Decode(base64Data);
        testContentInsert2.PathOnClient = '/' + fileName2 ;
        cvList.add(testContentInsert2);

	    
	    insert cvList;
	    cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :cvList];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = cvList[0].ContentDocumentId;
        cl.LinkedEntityId = document.Id; //Shared with record ID
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        cdlList.add(cl);
        ContentDocumentLink cl2 = new ContentDocumentLink();
        cl2.ContentDocumentId = cvList[1].ContentDocumentId;
        cl2.LinkedEntityId = document.Id; //Shared with record ID
        cl2.ShareType = 'V';
        cl2.Visibility = 'AllUsers';
        cdlList.add(cl2);
	    insert cdlList;

        Batch_Migration_Document_To_SDS bmd = new Batch_Migration_Document_To_SDS();
        Database.executeBatch(bmd);

      	Test.stopTest();
        Document__c document2 = [SELECT id, idDocument__c FROM Document__c limit 1 ];
        System.assertNotEquals(document2.idDocument__c, '');
    }

    static testMethod void Test_migration_doc4() {
        Test.startTest();
        List<reference__c> listRef = new List<reference__c> ();
        listRef.add(TestFactory.createReference('StatutDocument', 'Manquant','NEW','Manquant'));
        listRef.add(TestFactory.createReference('StatutDocument', 'Validé','VALIDATED','Validé'));
        insert listRef;

        Document__c document = new Document__c();
        document.Type_de_document__c = 'insurance'; 
        document.Statut__c = listRef[0].Id;
        insert document;


        Batch_Migration_Document_To_SDS bmd = new Batch_Migration_Document_To_SDS();
        Database.executeBatch(bmd);

        Test.stopTest();
        Document__c document2 = [SELECT id, idDocument__c FROM Document__c limit 1 ];
        System.assertEquals(document2.idDocument__c, null);
    }
    
}