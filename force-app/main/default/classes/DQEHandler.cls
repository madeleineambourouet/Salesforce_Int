/**
 * public class DQEHandler
 * -----------------------
 * Class managing DQE callouts and treatments
 **/
public class DQEHandler 
{

    public class DQEHandlerResult
    {
        // COMMON
        public Boolean  success {get;set;}
        public String   message {get;set;}
        public String   type {get;set;} // EMAIL, CITIES, PHONE, SIRET
        
        // EMAIl
        public String   IdError {get;set;}
        public String   eMailSuggested {get;set;}
      
        // PHONE
        public String phoneSuggested {get;set;}
        // CITY
        public List<DQE_CityResult.DQE_City> lCities {get;set;}
      
        // STREET
        public List<DQE_StreetResult.DQE_Street> lStreets {get;set;}
      
        // STREETNUMBER
        public List<String> lStreetNumbers {get;set;} 
        public DQEHandlerResult()
        {}
    }

    /**
     * public static DQEHandlerResult validateEmail(String)
     * ------------------------------------------
     * Do the DQE email validation callout
     **/
    public static DQEHandlerResult validateEmail(String email)
    {
        // Get the URL
        String url = Label.DQE_ServerURL + 'DQEEMAILLOOKUP/?Email=' + email + '&Licence=' + Label.DQE_Licence;
        
        // Preparing the request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and get the response
        DQEHandlerResult result;
        try
        {
            String jsonToParse;
            if (!Test.isRunningTest()) { HttpResponse res = h.send(req); jsonToParse = res.getBody(); }
            else { jsonToParse = '{"1": {"Redressement": 0, "eMailOrigine": "test@gmail.com", "IdError": "00", "eMail": "test@gmail.com"}}'; } 
            system.debug('>>>> jsonToParse: ' + jsonToParse);
            
            // Parse the result
            result = DQE_EmailResult.parse(jsonToParse);  
            system.debug('>>>> result: ' + result);
        } catch (Exception e)
        {
            result = new DQEHandlerResult();
            result.success = false;
            result.message = e.getMessage();
            System.debug('>>>>> Failed because : ' + e.getMessage());
            result.type = 'EMAIL';
        }
        // Return the result
        return (result);
    }
    
        /**
     * public static DQEHandlerResult validatePhone(String, String)
     * ------------------------------------------
     * Do the DQE phone validation callout
     **/
    public static DQEHandlerResult validatePhone(String phone, String pays)
    {
        // Get the URL
        String url = Label.DQE_ServerURL + 'TEL/?Pays=' + pays + '&Tel=' + phone + '&Format=3&Licence=' + Label.DQE_Licence;
        
        // Preparing the request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and get the response
        DQEHandlerResult result;
        try
        {
            String jsonToParse;
            if (!Test.isRunningTest()) { HttpResponse res = h.send(req); jsonToParse = res.getBody(); }
            else { jsonToParse = '{"1": {"TelOrigine": "0635136116", "Tel": "+33 635136116", "IdError": 1}}'; } 
            system.debug('>>>> jsonToParse: ' + jsonToParse);
            
            // Parse the result
            result = DQE_PhoneResult.parse(jsonToParse);  
            system.debug('>>>> result: ' + result);
        } catch (Exception e)
        {
            result = new DQEHandlerResult();
            result.success = false;
            result.message = e.getMessage();
            result.type = 'PHONE';
        }
        // Return the result
        return (result);
    }
    
      /**
     * public static DQEHandlerResult validateSIRET(String)
     * ------------------------------------------
     * Do the DQE SIRET validation callout
     **/
     public static DQEHandlerResult validateSIRET(String SIRET)
    {
        // Get the URL
        String url = Label.DQE_ServerURL + 'RECSIRET/?CompanyNumber=' + SIRET + '&Dictionary=Y&Country=FRA&Licence=' + Label.DQE_Licence;
        //https://prod2.dqe-software.com/RECSIRET/?CompanyNumber=80029014000014&Dictionary=Y&Country=FRA&Licence=XY_TEST0107_hhYHF5
        
        
        // Preparing the request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and get the response
        DQEHandlerResult result = new DQEHandlerResult();
        if (SIRET != '' && SIRET.length() != 14) { 
            result.success = false; 
            result.message = 'SIRET invalide : le SIRET doit être constitué de 14 chiffres';
            result.type = 'SIRET';
            return result;
        }
        else {
            try
            {
                String jsonToParse;
                if (!Test.isRunningTest()) { HttpResponse res = h.send(req); jsonToParse = res.getBody(); }
                else { jsonToParse = '{"DATA1": {"MainCompanyFlag": "1", "Locality": "PARIS 17", "CompanySIC_NAME_2": "", "Locality_2": "", "SEARCH_REF": "21977938", ' 
                                        + '"IncorporationDate": "2014-01-02", "StaffCount": "0", "CompanyName_2": "", "CompanyCName_2": "", "CompanyAddress1_2": "", '
                                        + '"ZIP_Code": "75017", "MainCompanyFlag_2": "", "CompanyStatus": "1", "CompanyStatus_2": "", "Country": "", "CompanySIC": "4120A", '
                                        + '"CompanyAddress3_2": "", "CompanyAddress2_2": "", "CompanyNumber": "800xxxxxxxx014", "CompanyCName": "R.D. BATIMENT", ' 
                                        + '"CompanyName": "SARL B&amp;D", "CompanyAddress2": "10 RUE D ARMAILLE", "CompanyAddress3": "", "CompanyAddress1": "RUE D BATIMENT", ' 
                                        + '"County": "", "DissolutionDate": "", "TurnOver": "528199"}}'; } 
                system.debug('>>>> jsonToParse: ' + jsonToParse);
            
                // Parse the result
                result = DQE_SIRETResult.parse(jsonToParse);  
                system.debug('>>>> result: ' + result);
            } catch (Exception e)
            {
                result = new DQEHandlerResult();
                result.success = false;
                result.message = e.getMessage();
                result.type = 'SIRET';
            }
            // Return the result
            return (result);
        }
    }
    
     /**
     * public static DQEHandlerResult getCitiesByPostalCode(String, String)
     * ------------------------------------------
     * Do the DQE callout to retrieve the cities corresponding to the postal code and country code filled
     **/
    public static DQEHandlerResult getCitiesByPostalCode(String postalCode, String pays)
    {
        // Get the URL
        String url = Label.DQE_ServerURL + 'CP/?CodePostal=' + postalCode + '&Alpha=false&Instance=0&Pays=' + pays + '&Licence=' + Label.DQE_Licence; //'&Licence=BUSI7466';
        
        // Preparing the request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and get the response
        DQEHandlerResult result;
        try
        {
            String jsonToParse = '';
            if (!Test.isRunningTest()) {HttpResponse res = h.send(req); jsonToParse = res.getBody();}
            else { jsonToParse = '{"1": {"Province": "*", "IDLocalite": "44130", "Pays": "FRA", "Longitude": "-1.58333", "Instance": "0", "CodePostal": "44860", "SousLocalite": "", "LieuDit": "", "Latitude": "47.1167", "Localite": "PONT ST MARTIN"}, "3": {"Province": "*", "IDLocalite": "44150", "Pays": "FRA", "Longitude": "-1.63274", "Instance": "0", "CodePostal": "44860", "SousLocalite": "", "LieuDit": "", "Latitude": "47.123", "Localite": "ST AIGNAN GRANDLIEU"}, "2": {"Province": "*", "IDLocalite": "44130", "Pays": "FRA", "Longitude": "-1.58333", "Instance": "0", "CodePostal": "44860", "SousLocalite": "", "LieuDit": " VIAIS", "Latitude": "47.1167", "Localite": "PONT ST MARTIN "}}'; }
            system.debug('>>>> jsonToParse: ' + jsonToParse);
            result = DQE_CityResult.parse(jsonToParse);
            return (result);
        } catch (Exception e)
        {
            result = new DQEHandlerResult();
            result.success = false;
            result.message = e.getMessage();
            result.type = 'ADDRESS';
        }
        return (null);
    }

    /**
     * public static DQEHandlerResult getStreet(String, String)
     * ------------------------------------------
     * Do the DQE callout to retrieve the cities corresponding to the postal code and country code filled
     **/
    public static DQEHandlerResult getStreetsByCities(String inseeCode, String pays, String streetFilled)
    {
        // Get the URL
        String url = Label.DQE_ServerURL + 'ADR/?IDLocalite=' + inseeCode + '&Adresse=' + streetFilled + '&Instance=0&Pays=' + pays + '&Licence=' + Label.DQE_Licence;
        
        // Preparing the request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and get the response
        DQEHandlerResult result;
        try
        {
            String jsonToParse = '';
            if (!Test.isRunningTest()) {HttpResponse res = h.send(req); jsonToParse = res.getBody();}
            else { jsonToParse = '{"1": {"IDLocalite": "44150", "Latitude": "47.130558", "Saisie": "PIN", "Pays": "FRA", "IDVoie": "862271", "Voie": "ROUTE DU PINIER", "Numero": "", "Instance": "0", "ListeNumero": "", "Num": "", "CodePostal": "44860", "Longitude": "-1.610179", "Nbnumero": "", "Localite": "ST AIGNAN GRANDLIEU", "CodeVoie": "862271"}, "3": {"IDLocalite": "44150", "Latitude": "47.126615", "Saisie": "PIN", "Pays": "FRA", "IDVoie": "4409092", "Voie": "RUE DU PIN PARASOL", "Numero": "", "Instance": "0", "ListeNumero": "", "Num": "", "CodePostal": "44860", "Longitude": "-1.610330", "Nbnumero": "", "Localite": "ST AIGNAN GRANDLIEU", "CodeVoie": "4409092"}, "2": {"IDLocalite": "44150", "Latitude": "47.131680", "Saisie": "PIN", "Pays": "FRA", "IDVoie": "862190", "Voie": "IMPASSE LE PINIER", "Numero": "", "Instance": "0", "ListeNumero": "", "Num": "", "CodePostal": "44860", "Longitude": "-1.604795", "Nbnumero": "", "Localite": "ST AIGNAN GRANDLIEU", "CodeVoie": "862190"}}'; }
            system.debug('>>>> jsonToParse: ' + jsonToParse);
            result = DQE_StreetResult.parse(jsonToParse);
        } catch (Exception e)
        {
            result = new DQEHandlerResult();
            result.success = false;
            result.message = e.getMessage();
            result.type = 'ADDRESS';
        }
        
        return (result);
    }
    
    /**
     * public static DQEHandlerResult getStreet(String, String)
     * ------------------------------------------
     * Do the DQE callout to retrieve the cities corresponding to the postal code and country code filled
     **/
    public static DQEHandlerResult getStreetNumbersByStreet(String inseeCode, String idVoie, String codepostal, String pays)
    {
        // Get the URL
        String url = Label.DQE_ServerURL + '/NUM/?IDVoie=' + idVoie + '&IDLocalite=' + inseeCode + '&CodePostal=' + codepostal + '&Pays=' + pays + '&Licence=' + Label.DQE_Licence;
        
        // Preparing the request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        // Send the request, and get the response
        DQEHandlerResult result;
        try
        {
            String jsonToParse = '';
            if (!Test.isRunningTest()) {HttpResponse res = h.send(req); jsonToParse = res.getBody();}
            else { jsonToParse = '{"1": {"Province": "", "IDLocalite": "44150", "Nbnumero": "50", "IDVoie": "862271", "ListeNumero": "1;2;2B;3;4;4B;5;6;6B;8;10;11;11B;11T;12;12B;13;14;14B;15;15B;15Q;15T;16;16B;16T;17;18;18B;19;20;21;22;24;26;28;30;32;34;36;38;40;42;44;46;48;50;60;62;62A", "CodePostal": "44860", "SousLocalite": "", "Localite": ""}}'; }
            system.debug('>>>> jsonToParse: ' + jsonToParse);
            result = DQE_StreetNumberResult.parse(jsonToParse);
        } catch (Exception e)
        {
            result = new DQEHandlerResult();
            result.success = false;
            result.message = e.getMessage();
            result.type = 'ADDRESS';
        }
        
        return (result);
    }
}