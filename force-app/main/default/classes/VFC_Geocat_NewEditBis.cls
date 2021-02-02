public class VFC_Geocat_NewEditBis 
{
    public Geocat__c thisGeocat {get;set;}
    
    public GeocatMapWrapperBis mapRecord {get;set;}
    
    public VFC_Geocat_NewEditBis(ApexPages.StandardController StandardController)
    {
        thisGeocat = (Geocat__c)StandardController.getRecord();
        system.debug('>>>>>>>>>>>>> thisGeocat: ' + thisGeocat);

        mapRecord = new GeocatMapWrapperBis();
        
        if (thisGeocat != null && thisGeocat.Id != null)
        {
            List<CompetenceBis__c> lCompGeocat = [SELECT Id, Niveau_1__c, Niveau_2__c FROM CompetenceBis__c WHERE Geocat__c =: thisGeocat.Id AND TECH_DeleteOnScreen__c = false];
            mapRecord.populateTreeview(lCompGeocat, thisGeocat.Id);
        }
        else
            mapRecord.populateTreeview(null, null);
    }

    public VFC_Geocat_NewEditBis()
    {
        thisGeocat = [SELECT Id, Exclusion__c, Contact__c FROM Geocat__c WHERE Id = :Apexpages.currentPage().getParameters().get('newGeocat') LIMIT 1];
        system.debug('>>>>>>>>>>>>> thisGeocat: ' + thisGeocat);

        mapRecord = new GeocatMapWrapperBis();
        
        if (thisGeocat != null && thisGeocat.Id != null)
        {
            List<CompetenceBis__c> lCompGeocat = [SELECT Id, Niveau_1__c, Niveau_2__c FROM CompetenceBis__c WHERE Geocat__c =: thisGeocat.Id AND TECH_DeleteOnScreen__c = false];
            mapRecord.populateTreeview(lCompGeocat,thisGeocat.Id);
        }
        else
            mapRecord.populateTreeview(null, null);
    }
    
    public PageReference getTest() {
        return (new PageReference(Apexpages.currentPage().getParameters().get('myParam')));
    }

    public PageReference saveGeocat()
    {
        return (saveGeocat(false) == null ? null : saveGeocat(false));
    }

    public PageReference saveGeocat(Boolean threelevel)
    {
        system.debug('>>>>>>>>>> START saveGeocat');
        
        if (thisGeocat != null)
        {
            //Exclusion field verification
            if (String.isEmpty(thisGeocat.Exclusion__c) == false)
            {
                List<String> list_exclusion = (thisGeocat.Exclusion__c).splitByCharacterType();
            
                for (Integer i = 0; i < list_exclusion.size(); i++)
                {
                    if (list_exclusion[i].isNumeric())
                    {
                        if ((list_exclusion[i].length() != 2) && (list_exclusion[i].length() != 5))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                            return (null);
                        }
                    }
                    else if (!(list_exclusion[i].equals(';')))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                        return (null);
                    }
                }
            }
            
            // If compétence selected
            if (mapRecord.isGeocatSelected())
            {
                if (thisGeocat.Id != null)
                {
                    update thisGeocat;
                    mapRecord.manageCompetenceOnGeocat(thisGeocat.Id);
                }
                else
                {
                    insert thisGeocat;
                    mapRecord.manageCompetenceOnGeocat(thisGeocat.Id);
                }
            }
            else
            {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il faut sélectionner au moins une compétence.'));
             return (null);
            }  
        }

        system.debug('>>>>>>>>>> END saveGeocat');

        system.debug('VFC GEOCAT : myparam = ' + Apexpages.currentPage().getParameters().get('myParam'));

        return (new PageReference('/' + thisGeocat.Id));
    }

    public void saveGeocatBis()
    {
        system.debug('>>>>>>>>>> START saveGeocat');
        
        if (thisGeocat != null)
        {
            //Exclusion field verification
            if (String.isEmpty(thisGeocat.Exclusion__c) == false)
            {
                List<String> list_exclusion = (thisGeocat.Exclusion__c).splitByCharacterType();
            
                for (Integer i = 0; i < list_exclusion.size(); i++)
                {
                    if (list_exclusion[i].isNumeric())
                    {
                        if ((list_exclusion[i].length() != 2) && (list_exclusion[i].length() != 5))
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                        }
                    }
                    else if (!(list_exclusion[i].equals(';')))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                    }
                }
            }
            
            // If compétence selected
            if (mapRecord.isGeocatSelected())
            {
                if (thisGeocat.Id != null)
                {
                    update thisGeocat;
                    mapRecord.manageCompetenceOnGeocat(thisGeocat.Id);
                }
                else
                {
                    insert thisGeocat;
                    mapRecord.manageCompetenceOnGeocat(thisGeocat.Id);
                }
            }
            else
            {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il faut sélectionner au moins une compétence.'));
            }  
        }
        system.debug('>>>>>>>>>> END saveGeocat');

        system.debug('VFC GEOCAT : myparam = ' + Apexpages.currentPage().getParameters().get('myParam'));

    }
    
    public PageReference backsaveGeocat()
    {
        String urlBack = '/';
        if (thisGeocat.Id != null) 
            urlBack += thisGeocat.Id;
        else 
            urlBack += thisGeocat.Contact__c;
        
        return (new PageReference(urlBack));
    }
}