public class DQE_StreetResult 
{
    public class DQE_Street
    {
        public String idLocalite {get;set;}
        public String idVoie {get;set;}
        public String voie {get;set;}
        public DQE_Street()
        {}
    }
    
  public static DQEHandler.DQEHandlerResult parse(String jsonToParse) 
  {
    DQEHandler.DQEHandlerResult result = new DQEHandler.DQEHandlerResult();
    result.type = 'STREET';
    
    List<DQE_Street> lStreets = new List<DQE_Street>();
    
    JSONParser parser = JSON.createParser(jsonToParse);
    
    while (parser.nextToken() != null)
    {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
        {
            DQE_Street street = new DQE_Street();
            if (parser.getText() == 'IDLocalite')
            {
                parser.nextToken();
                street.idLocalite = parser.getText();
                boolean idvoie = false;
                boolean voie = false;
                while (parser.nextToken() != null)
                {
                    if (parser.getText() == 'IDVoie')
                    {
                        parser.nextToken();
                        street.idVoie = parser.getText();
                        idvoie = true;
                    }
                    if (parser.getText() == 'Voie')
                    {
                        parser.nextToken();
                        street.voie = parser.getText();
                        voie = true;
                    }
                    if (voie == true && idvoie == true)
                        break;
                }
                system.debug('>>> street:' + street);
                lStreets.add(street);
            }
        }
    }
    system.debug('>>>> lStreets: ' + lStreets);
    if (lStreets != null && lStreets.size() > 0)
    {
        result.success = true;
        result.lStreets = lStreets;
    }
    else
    {
        result.success = false;
        result.lStreets = null;
    }
    system.debug('>>>> result: ' + result);
    return (result);
  }
}