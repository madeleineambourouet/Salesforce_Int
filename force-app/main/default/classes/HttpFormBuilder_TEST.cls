@isTest
public without sharing class HttpFormBuilder_TEST {
    static testMethod void Test_GetContentType() {
        Test.startTest();
        HttpFormBuilder.GetContentType();
        Test.stopTest();
    }
    
    static testMethod void Test_SafelyPad() {
        Test.startTest();   
        HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.Cr);
        HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.None);
        Test.stopTest();
    }
    
    static testMethod void Test_WriteBlobBodyParameter() {
        Test.startTest();   
        HttpFormBuilder.WriteBlobBodyParameter('string key', 'string file64==', 'string filename', 'string mimeType');
        HttpFormBuilder.WriteBlobBodyParameter('string key', 'string file64=', 'string filename', 'string mimeType');
        HttpFormBuilder.WriteBodyParameter('string key','string value');
        Test.stopTest();
    }
    
}