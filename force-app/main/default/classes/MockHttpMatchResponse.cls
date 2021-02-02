/**
 * @File Name          : MockHttpMatchResponse.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 4/6/2020, 12:52:21 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/6/2020   Hassan Dakhcha     Initial Version
**/
@isTest
global class MockHttpMatchResponse implements HttpCalloutMock {

    public String responseBody;
    public String reqEndPointArgs;
    public void setResponseBody(String json) { responseBody = json;}
    public void setEndPointArgs(String args) { reqEndPointArgs = args;}

    global HttpResponse respond(HttpRequest request) {
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(request.getEndPoint().endsWith('token')) {
            System.assertEquals(System.Label.WBE_Endpoint + '/oauth/token', request.getEndpoint());
            System.assertEquals('POST', request.getMethod());
            res.setBody('{"access_token": "34dbcee9-e43e-4ed1-811f-5eccb24245e6", "token_type": "bearer", "expires_in": 899, "scope": "any"}');
        } else {
            System.assertEquals(System.Label.WBE_Endpoint + '/matches?' + reqEndPointArgs , request.getEndpoint());  
            System.assertEquals('GET', request.getMethod());
            res.setBody(responseBody);
        }
       
        res.setStatusCode(200);
        return res;
    }

}