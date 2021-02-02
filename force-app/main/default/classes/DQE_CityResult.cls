public class DQE_CityResult 
{
    public class DQE_City
    {
        public String localite {get;set;}
        public String idLocalite {get;set;}
        public DQE_City()
        {}
    }
    
  public static DQEHandler.DQEHandlerResult parse(String jsonToParse) 
  {
    DQEHandler.DQEHandlerResult result = new DQEHandler.DQEHandlerResult();
    result.type = 'CITIES';
    
    List<DQE_City> lCities = new List<DQE_City>();
    
    JSONParser parser = JSON.createParser(jsonToParse);
    
    while (parser.nextToken() != null)
    {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
        {
            DQE_City city = new DQE_City();
            if (parser.getText() == 'IDLocalite')
            {
                parser.nextToken();
                city.idLocalite = parser.getText();
                while (parser.nextToken() != null)
                {
                    if (parser.getText() == 'Localite')
                    {
                        parser.nextToken();
                        city.localite = parser.getText();
                        break;
                    }
                }
                lCities.add(city);
            }
        }
    }
    
    if (lCities != null && lCities.size() > 0)
    {
        result.success = true;
        result.lCities = lCities;
    }
    else
    {
        result.success = false;
        result.lCities = null;
    }
    system.debug('>>>> result: ' + result);
    return (result);
  }
}