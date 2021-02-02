/**
 * @File Name          : Projet_LMSG_AffiliationWS_Test_Mock.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 5/19/2020, 11:31:56 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/19/2020   Hassan Dakhcha     Initial Version
**/
@isTest
global class Projet_LMSG_AffiliationWS_Test_Mock implements HttpCalloutMock {

    public String responseBody;
    public String reqEndPointArgs;
    public Integer reqStatusCode;
    public Boolean throwException;
    public Boolean CheckEndPoint;
    public Projet_LMSG_AffiliationWS_Test_Mock(String json, String endPoint, Integer code, Boolean thr, Boolean checkEPoint) {
        responseBody = json;
        reqEndPointArgs = endPoint;
        reqStatusCode = code;
        throwException = thr;
        CheckEndPoint = checkEPoint;
    }

    global HttpResponse respond(HttpRequest request) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(CheckEndPoint == true)
            System.assertEquals(Label.URL_Projet_LMSG_AffiliationWSEndpoint + reqEndPointArgs , request.getEndpoint()); 

        System.assertEquals('PUT', request.getMethod());
        res.setBody(responseBody);
        res.setStatusCode(reqStatusCode);

        if(throwException == true) {
            CalloutException e = new CalloutException();
            e.setMessage('Test Exception from Partnership!');
            throw e;
        }
        return res;
    }

}