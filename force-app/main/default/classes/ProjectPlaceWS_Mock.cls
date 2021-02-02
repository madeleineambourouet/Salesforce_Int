/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 09-22-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-08-2020   Hassan Dakhcha   Initial Version
**/
public class ProjectPlaceWS_Mock implements HttpCalloutMock {
   
    public String responseBody;
    public void setBody(String json) {
        responseBody = json;
    }
    String responseStatus;
    public void setStatus(String stat) {
        responseStatus = stat;
    }
    Integer responseCode;
    public void setCode(Integer code) {
        responseCode = code;
    }

    String endPoint;
    public void setEP(String ep) {
        endPoint = ep;
    }

    String methodName;
    public void setMD(String md) {
        methodName = md;
    }

    public HttpResponse respond(HttpRequest req) {
        System.assertEquals(true, req.getEndPoint().contains(this.endPoint));
        System.assertEquals(this.methodName, req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setBody(this.responseBody);       
        res.setStatusCode(this.responseCode);
        res.setStatus(this.responseStatus);
        return res;
    }
   
}