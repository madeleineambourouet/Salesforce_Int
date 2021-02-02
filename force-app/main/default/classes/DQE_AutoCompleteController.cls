global class DQE_AutoCompleteController 
{
    public Integer randomJsIden{get;set;}
    public String cacheField{get;set;} 
    public String searchType {get;set;}
    public Object   controller  {get;set;}
    public String   objectType {get;set;}
    
    public DQE_AutoCompleteController()
    {
        randomJsIden = getRandomNumber(1000000);
    }
    
    
    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }
    
    @RemoteAction
    public static List<String> getDQECities(String pays, String codepostal, String searchType, String param)
    {
        param = String.escapeSingleQuotes(param);
        system.debug('>>>>>>>> param : ' + param);
        // DO DQE callout
        DQEHandler.DQEHandlerResult DQEresult = DQEHandler.getCitiesByPostalCode(codepostal, pays);
        system.debug('>>>>>>> DQEresult: ' + DQEresult);
        if (DQEresult != null && DQEresult.success == true && DQEresult.lCities != null)
        {
            // Parse the results
            List<String> cities = new List<String>();
            for (DQE_CityResult.DQE_City city : DQEresult.lCities)
                cities.add(city.localite);

            List<String> result = new List<String>();
            if (param == null || (param != null && param == ''))
                result = cities;
            else
            {
                for (String value : cities)
                {
                    if (value.toUpperCase().startsWith(param.toUpperCase()))
                        result.add(value);
                }
            }
            return (result);
        }
        
        return (null);
    }
    
    @RemoteAction
    public static List<DQE_CityResult.DQE_City> getDQECities1(String pays, String codepostal, String searchType, String param)
    {
        param = String.escapeSingleQuotes(param);
        system.debug('>>>>>>>> param : ' + param);
        // DO DQE callout
        DQEHandler.DQEHandlerResult DQEresult = DQEHandler.getCitiesByPostalCode(codepostal, pays);
        system.debug('>>>>>>> DQEresult: ' + DQEresult);
        if (DQEresult != null && DQEresult.success == true && DQEresult.lCities != null)
        {
            
            // Parse the results
            if (param == null || (param != null && param == ''))
                return (DQEresult.lCities);
            else
            {
                List<DQE_CityResult.DQE_City> cities = new List<DQE_CityResult.DQE_City>();
                for (DQE_CityResult.DQE_City city : DQEresult.lCities)
                {
                    if (city.localite.toUpperCase().startsWith(param.toUpperCase()))
                        cities.add(city);
                }
                return (cities);
            }
        }
        return (null);
    }
    
    @RemoteAction
    public static List<DQE_StreetResult.DQE_Street> getDQEStreets(String searchType, String inseecode, String pays, String param)
    {
        system.debug('>>>>>>> getDQEStreets' );
        param = String.escapeSingleQuotes(param);
        
        // get insee code
        List<Reference__c> lRef = [SELECT Libelle_2__c FROM Reference__c WHERE Id =: inseeCode];
        system.debug('>>>>>>> lRef INSEECODE:' + lRef);
        if (lRef != null && lRef.size() > 0)
        {
            // DO DQE callout
            DQEHandler.DQEHandlerResult DQEresult = DQEHandler.getStreetsByCities(lRef[0].Libelle_2__c, pays, param);
            if (DQEresult != null && DQEresult.success == true && DQEresult.lStreets != null)
            {
                return (DQEresult.lStreets);
            }
        }
        return (null);
    }
    
    @RemoteAction
    public static List<String> getDQEStreetNumber(String searchType, String inseeCode, String idVoie, String postalCode, String pays, String param)
    {
        param = String.escapeSingleQuotes(param);
        
        // get insee code
        List<Reference__c> lRef = [SELECT Name, Libelle_2__c FROM Reference__c WHERE Id =: inseeCode];
        system.debug('>>>>>>> lRef INSEECODE:' + lRef);
        
        if (lRef != null && lRef.size() > 0)
        {
            // DO DQE callout
            DQEHandler.DQEHandlerResult DQEresult = DQEHandler.getStreetNumbersByStreet(lRef[0].Libelle_2__c, idVoie, lRef[0].Name, pays);
            system.debug('>>>> DQEresult: ' + DQEresult);
            if (DQEresult != null && DQEresult.success == true && DQEresult.lStreetNumbers != null)
            {
                system.debug('>>> RESULT RETURNED OK');
                return (DQEresult.lStreetNumbers);
            }
        }
        system.debug('>>> RESULT RETURNED KO');
        return (null);
    }
}