global class BUSWSMock implements HttpCalloutMock 
{
    public class applicationException extends Exception {}
    
    global static HTTPResponse respond(HTTPRequest req) 
    {
        // Send a HTTP status code 200 => Success
        if (req.getBody().contains('Contact200'))
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            return res;
        }
        else if (req.getBody().contains('Contact500'))
        {
            // Send a HTTP status code 500 => Error
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message": "Zuora account not found with idClient [0013E000008d5sUQA]", "logDataId": "97e2e9df", "serviceMethod": "sfUpdateContact" }');
            res.setStatusCode(500);
            return res;
        }
        else
        {
            throw new applicationException('ERROR');
        }
    }
}