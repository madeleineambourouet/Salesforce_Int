public class DQE_EmailResult 
{
    // Return by DQE
/*  public Integer Redressement {get;set;}
  public String eMailOrigine {get;set;}
  public String IdError {get;set;}
  public String eMail {get;set;}

    // Added
    public String msg {get;set;}
*/
    public static Map<String, String> ERROR_MESSAGES = new Map<String, String>
    {
        '91' => 'Erreur de syntaxe',
        '92' => 'Domaine inconnu',
        '93' => 'Doamine en blacklist',
        '94' => 'Adresse e-mail considérée comme spam',
        '99' => 'Service non disponible',
        '02' => 'Adresse e-mail non trouvée pour ce domaine',
        '01' => 'E-mail correct mais le nom n\'a pas pu être contrôlé',
        '00' => 'E-mail valide'
    };
    
  public static DQEHandler.DQEHandlerResult parse(String jsonToParse) 
  {
    DQEHandler.DQEHandlerResult result = new DQEHandler.DQEHandlerResult();
    result.type = 'EMAIL';
    
    JSONParser parser = JSON.createParser(jsonToParse);
    Integer redressement;
    String emailsuggested = null;
    while (parser.nextToken() != null)
    {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
        {
            if (parser.getText() == 'IdError')
            {
                parser.nextToken();
                result.IdError = parser.getText();
                if (result.IdError != null && result.IdError != '')
                    result.message = DQE_EmailResult.ERROR_MESSAGES.get(result.IdError);
            }
            if (parser.getText() == 'Redressement')
            {
                parser.nextToken();
                if (parser.getText() != null && parser.getText() != '')
                    redressement = Integer.valueOf(parser.getText());     
            }
            if (parser.getText() == 'eMail')
            {
                parser.nextToken();
                emailsuggested = parser.getText();       
            }
        }
    }
    
    if (redressement != null && redressement == 1)
        result.eMailSuggested = emailsuggested;
    if (result.IdError == '00' || result.IdError == '01')
        result.success = true;
       else
        result.success = false;
    system.debug('>>>> result: ' + result);
    return (result);
  }
}