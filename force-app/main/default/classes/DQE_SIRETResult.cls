public class DQE_SIRETResult {

  /* public class DQE_SIRET
    {
        public List<String> lSIRET {get;set;}
        public DQE_StreetNumber()
        {}
    }*/
    
    public static Map<String, String> ERROR_MESSAGES = new Map<String, String>
    {
        '0' => 'SIRET inexistant',
        '1' => 'SIRET valide',
        '2' => 'Attention : plusieurs SIRET trouvés'
    };
    
    
  public static DQEHandler.DQEHandlerResult parse(String jsonToParse) 
  {
    DQEHandler.DQEHandlerResult result = new DQEHandler.DQEHandlerResult();
    result.type = 'SIRET';
    
    JSONParser parser = JSON.createParser(jsonToParse);
        //List<String> lSIRET = new List<String>();
        Integer count = 0;
    while (parser.nextToken() != null)
    {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
        {
            if (parser.getText() == 'MainCompanyFlag')
            {
                parser.nextToken();
                count++;
            }
        }
    }
    system.debug('>>>> count: ' + count);
    if (count == 0)
    {
        result.success = false;
        result.message = DQE_SIRETResult.ERROR_MESSAGES.get('0');
    }
    else if (count == 1)
    {
        result.success = true;
        result.message = DQE_SIRETResult.ERROR_MESSAGES.get('1');
    }
    else 
    {
        result.success = true;
        result.message = DQE_SIRETResult.ERROR_MESSAGES.get('2');
    }
    system.debug('>>>> result: ' + result);
    return (result);
  }

}