/**
 * @File Name          : DocumentSDS_Checker_TestMockHttp.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/27/2020, 11:02:57 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/27/2020   Hassan Dakhcha     Initial Version
**/
@isTest
global class DocumentSDS_Checker_TestMockHttp implements HttpCalloutMock {

    public String response;
    public Integer respCode;
    
    public DocumentSDS_Checker_TestMockHttp(String response, Integer respCode) {
        this.response = response;
        this.respCode = respCode;
    }

    global HttpResponse respond(HttpRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(respCode);
        return res;
    }
}