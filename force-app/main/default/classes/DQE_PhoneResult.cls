public class DQE_PhoneResult {

    public static Map<String, String> ERROR_MESSAGES = new Map<String, String>
    {
        '0' => 'Téléphone incorrect',
        '1' => 'Téléphone valide'
    };
    
  public static DQEHandler.DQEHandlerResult parse(String jsonToParse) 
  {
    DQEHandler.DQEHandlerResult result = new DQEHandler.DQEHandlerResult();
    result.type = 'PHONE';
    system.debug('>>>>> jsonToParse: ' + jsonToParse);
    JSONParser parser = JSON.createParser(jsonToParse);
    String resultValue;
    String phoneSuggested = null;
    while (parser.nextToken() != null)
    {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
        {
            if (parser.getText() == 'IdError')
            {
                parser.nextToken();
                result.IdError = parser.getText();
                resultValue = parser.getText();
                system.debug('>>>> iderror: ' + parser.getText());
                if (result.IdError != null && result.IdError != '')
                    result.message = DQE_PhoneResult.ERROR_MESSAGES.get(result.IdError);
            }
            if (parser.getText() == 'Tel')
            {
                parser.nextToken();
                phoneSuggested = parser.getText();       
            } 
        }
    }
    
    if (resultValue != null && resultValue == '1')
        result.phoneSuggested = phoneSuggested;
    if (result.IdError == '0')
            result.success = false;        
       else
        result.success = true;
    system.debug('>>>> result: ' + result);
    return (result);
  }
}