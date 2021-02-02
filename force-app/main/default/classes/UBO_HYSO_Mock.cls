/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 08-13-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-19-2020   Hassan Dakhcha   Initial Version
**/
public class UBO_HYSO_Mock implements HttpCalloutMock {
   
    public String responseBody;
    public void setBody(String json) {
        responseBody = json;
    }
    public HttpResponse respond(HttpRequest req) {
        System.debug('#### HDAK endPoint ' + req.getEndPoint());
        System.assertEquals(true, req.getEndPoint().contains('hyso-app-service.azurewebsites.net/companies/capital/'));
        System.assertEquals('GET', req.getMethod());
     
        HttpResponse res = new HttpResponse();
        res.setBody(responseBody);       
        res.setStatusCode(200);
        return res;
    }
}