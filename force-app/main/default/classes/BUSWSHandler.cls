/**, ,
 ** Handler class for BUS WS methods
 **/
public class BUSWSHandler 
{
    /**
     ** Handler for the ContactUpdate WS
     **/
    public static void wsContactUpdateHandler(List<Id> lContactId)
    {
        // Split the list to sublist of 100 contacts (to avoid to hit the 100 callouts governors limit)
        if (lContactId != null && lContactId.size() > 100)
        {
            List<List<Id>> lLists = new List<List<Id>>();
            List<Id> lDummy = new List<Id>();
            integer cpt = 0;
            for (Id item : lContactId)
            {
                if (cpt == 100)
                {
                    lLists.add(lDummy.clone());
                    lDummy.clear();
                    lDummy = new List<Id>();
                    cpt = 0;
                }
                
                lDummy.add(item);
                cpt++;
            }
            if (lDummy != null && !lDummy.isEmpty())
                lLists.add(lDummy.clone());
            
            // Send list by list to the webservice method
            for (List<Id> lItems : lLists)
            {
                wsContactUpdateMethod(lItems);
            }
        }
        else // No need to split because less than 100 contacts
            wsContactUpdateMethod(lContactId);
    }
    
    /**
     ** Handler for the ContactUpdate WS
     **/
    @future(callout=true)
    public static void wsContactUpdateMethod(List<Id> lContactId)
    {
        // Retrieve the contact information of the contacts ids in parameters
        List<Contact> lContact = [SELECT Id, Account.Id, Account.Name, Account.Code_client__c, Salutation, Firstname, Lastname, Email, Phone, MobilePhone, Adresse1__c, Code_postal_lkp__r.Name, Ville_Formule__c, Pays_lkp__r.Libelle__c, Contact_Principal_O_N__c, Contact_de_facturation__c
                                    FROM Contact
                                    WHERE Id in: lContactId];
        // Get the Accounts linked to the Contacts retrieved
        List<Id> lAccountIds = new List<Id>();
        for (Contact con : lContact)
            lAccountIds.add(con.Account.Id);
        // Retrieve the active subscriptions of the Accounts
        //List<Zuora__Subscription__c> lSubs = [SELECT Id, Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Account__c in: lAccountIds AND Zuora__Status__c = 'Active'];
        List<Zuora__Subscription__c> lSubs = [SELECT Id, Zuora__Account__c FROM Zuora__Subscription__c WHERE Zuora__Account__c in: lAccountIds];
        
        List<Contact> lContactResult = new List<Contact>();
            
        // Go through the list of Contact to update
        for (Contact con : lContact)
        {
            Contact conResult = new Contact();
            conResult.Id = con.Id;
            conResult.BUSWS_Date_dernier_appel__c = Datetime.now();
            
            try
            {
                // Check if the contact got an active subscription on his parent account
                Boolean activeSub = false;
                for (Zuora__Subscription__c sub : lSubs)
                {
                    if (sub.Zuora__Account__c == con.Account.Id)
                    { activeSub = true; break; }
                }
                
                // If there is an active subscription, update the contact
                if (activeSub == true)
                {                
                    // Prepare the http callout
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(Label.URL_WSBus_UpdateContact + con.Account.Id);
                    req.setHeader('Content-Type', 'application/json');
                    req.setMethod('POST');
                    String body = '{' +
                    				'"name":"' + con.Account.Name + '",' +
                                    '"accountnumber":"' + con.Account.Code_client__c + '",' +
                                    '"salutation":"' + con.Salutation + '",' +
                                    '"firstname":"' + con.Firstname + '",' +
                                    '"lastname":"' + con.Lastname + '",' +
                                    '"billto":"' + con.Contact_de_facturation__c + '",' +
                                    '"soldto":"' + con.Contact_Principal_O_N__c + '",' +
                                    '"email":"' + con.Email + '",' +
                                    '"mobilephone":"' + con.MobilePhone + '",' +
                                    '"phone":"' + con.Phone + '",' +
                                    '"country":"' + con.Pays_lkp__r.Libelle__c + '",' +
                                    '"city":"' + con.Ville_Formule__c + '",'+
                                    '"adress1":"' + con.Adresse1__c + '",' +
                                    '"postalcode":"' + con.Code_postal_lkp__r.Name + '"' +
                                   '}';
                    req.setBody(body);
                    
                    // Send the request, and return a response
                    HttpResponse res;
                    if (!Test.isRunningTest())
                        res = h.send(req);
                    else
                        res = BUSWSMock.respond(req);
                    
                    String result = res.getBody();
        
                    // Checking result
                    if (res.getStatusCode() == 200)
                    {
                        conResult.BUSWS_Resultat__c = 'Succès';
                        conResult.BUSWS_Message__c = (res.getBody().length() >= 32768 ? res.getBody().substring(0, 32767) : res.getBody());
                    }
                    else
                    {
                        conResult.BUSWS_Resultat__c = 'Erreur';
                        String bodyResult = res.getStatusCode() + ': ' + res.getBody();
                        conResult.BUSWS_Message__c = (bodyResult.length() >= 32768 ? bodyResult.substring(0, 32767) : bodyResult);
                    }
                }
                else // No active subscriptions, no update
                {
                    conResult.BUSWS_Resultat__c = 'Erreur';
                    conResult.BUSWS_Message__c = Label.BUSWS_No_Active_Subscription;
                }
                
            } catch (Exception e)
            {
                conResult.Id = con.Id;
                conResult.BUSWS_Date_dernier_appel__c = Datetime.now();
                conResult.BUSWS_Resultat__c = 'Erreur';
                String errorStr = 'Exception : ' + e.getMessage();
                conResult.BUSWS_Message__c = (errorStr.length() >= 32768 ? errorStr.substring(0, 32767) : errorStr);
            }
            
            // Add the contact result to the list
            lContactResult.add(conResult);
        }
        
        // Update the contact results
        if (lContactResult != null && !lContactResult.isEmpty())
            update lContactResult;
    }
}