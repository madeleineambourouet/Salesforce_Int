public class DQE_StreetNumberResult 
{
    public class DQE_StreetNumber
    {
        public List<String> lNumbers {get;set;}
        public DQE_StreetNumber()
        {}
    }
    
  public static DQEHandler.DQEHandlerResult parse(String jsonToParse) 
  {
    DQEHandler.DQEHandlerResult result = new DQEHandler.DQEHandlerResult();
    result.type = 'STREETNUMBER';
    
    JSONParser parser = JSON.createParser(jsonToParse);
        List<String> lNumbers = new List<String>();
    while (parser.nextToken() != null)
    {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
        {
            if (parser.getText() == 'ListeNumero')
            {
                parser.nextToken();
                String numbers = parser.getText();
                lNumbers = numbers.split(';');
            }
        }
    }
    system.debug('>>>> lNumbers: ' + lNumbers);
    if (lNumbers != null && lNumbers.size() > 0)
    {
        result.success = true;
        result.lStreetNumbers = lNumbers;
    }
    else
    {
        result.success = false;
        result.lStreetNumbers = null;
    }
    system.debug('>>>> result: ' + result);
    return (result);
  }
}