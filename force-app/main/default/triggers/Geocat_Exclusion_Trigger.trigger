trigger Geocat_Exclusion_Trigger on GeoCat__c (before insert, before update)
{
    for (Geocat__c geocat: Trigger.new)
    {
        if (String.isEmpty(geocat.Exclusion__c) == false)
        {
            List<String> list_exclusion = (geocat.Exclusion__c).splitByCharacterType();
            
            for (Integer i = 0; i < list_exclusion.size(); i++)
            {
                if (list_exclusion[i].isNumeric())
                {
                    if ((list_exclusion[i].length() != 2) && (list_exclusion[i].length() != 5))
                       geocat.addError('Nb chiffre du champ Exception incorrect.');
                }
                else if (!(list_exclusion[i].equals(';')))      
                    geocat.addError('Contenu du champ Exception incorrect.');
            }
        }
    }
}