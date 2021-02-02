/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 09-18-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   09-18-2020   Hassan Dakhcha   Initial Version
**/
public class RelanceSMS_LMSG_ShortURL {

    @InvocableMethod(label = 'ShortURL' description = 'Permet de racourcir l\'URL')
    public static List<String> generateShortURL(List<String> args) {
        System.debug('#### HDAK args = ' + args);
        List<String> inputs = args[0].split(';');
        generateShortURL(inputs[0], inputs[1]);
        return new List<String>();
    }

    @future(callout = true)
    private static void generateShortURL(String projectID, String longURL) {

        HttpRequest req = new HttpRequest();	        
        req.setEndpoint(	            
            'callout:Bilty_Short_URL/v4/shorten' +	            
            '?access_token=' + getToken() +	           
            '&longUrl=' + EncodingUtil.urlEncode( longURL, 'UTF-8' ) +	            
            '&format=txt'	        
        );	       
        req.setMethod('GET');	
        Http http = new Http();	        
        HttpResponse res = http.send(req);

        String url = longURL;
        if(res.getStatusCode() == 200) {
            url = res.getBody();
        }
        Database.update(new Projet_LMSG__c(id = projectID, SMS_URL_Projet_PP__c = url));        
    }

    private static String getToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Bilty_Short_URL/oauth/access_token');	        
        req.setMethod('POST');	
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        Http http = new Http();	       
        HttpResponse res = http.send(req);	        
        return res.getBody();
    }
}