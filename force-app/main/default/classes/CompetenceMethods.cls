public class CompetenceMethods 
{
    /**
     * BASCULE SUR LE TRIGGER D'UPDATE D'UN GEOCAT
    public static void calculateCategorie(List<Competence__c> lComp)
    {
        // Get all the contact attached to the Competence        
        List<Id> lContactId = new List<Id>();
        String contactId = '';
        
        if (lComp == null)
            return;
            
        for (Competence__c comp : lcomp)
        {
            if (contactId.contains(comp.TECH_ContactId__c) == false)
            {
                contactId += ' ' + comp.TECH_ContactId__c;
                lContactId.add(comp.TECH_ContactId__c);
            }
        }
        
        // Get the geocat linked to the compétences
        List<GeoCat__c> lGeoCat = [SELECT Id, Categorie_niveau__c FROM GeoCat__c WHERE Contact__c in: lContactId];
        // Get all the Competence of the geocat
        List<Competence__c> lCompetence = [SELECT Id, GeoCat__c, Niveau_2_libelle__c FROM Competence__c WHERE GeoCat__c in: lGeoCat];
        
        // Erase catégorie de niveau in geocat list
        List<GeoCat__c> lGeoCatUpdated = new List<GeoCat__c>();
        for (GeoCat__c geo : lGeoCat)
        {
            geo.Categorie_niveau__c = '';
            lGeoCatUpdated.add(geo);
        }
        
        // calculate catégorie de niveau for geocat list
        for (Competence__c comp : lCompetence)
        {
            // Get the geocat corresponding
            Integer idx = 0;
            for (GeoCat__c geo : lGeoCatUpdated)
            {
                if (geo.Id == comp.GeoCat__c)
                    break;
                idx++;
            }
            
            // Add the competence categorie to the geocat
            GeoCat__c geo = lGeoCatUpdated.get(idx);
            if (geo.Categorie_niveau__c != '')
                geo.Categorie_niveau__c += ', ';
            geo.Categorie_niveau__c += comp.Niveau_2_libelle__c;
            
            // Update the list element
            lGeoCatUpdated.set(idx, geo);
        }
        
        if (lGeoCatUpdated != null && lGeoCatUpdated.size() > 0)
            update lGeoCatUpdated;
    }
    **/
    
    public static void checkIfNotLastCompetence(List<Competence__c> lComp)
    {
        system.debug('>>>>>>>>>>>>>>>>>>>> START checkIfNotLastCompetence');
        
        // Get the geocat linked to the compétences
        List<Id> lGeocatIds = new List<Id>();
        for (Competence__c comp : lComp)
            lGeocatIds.add(comp.Geocat__c);
        List<GeoCat__c> lGeoCat = [SELECT Id, Nb_Competence__c, Account__c FROM GeoCat__c WHERE Id in: lGeocatIds];
        system.debug('>>>>>>>>>> lGeocat: ' + lGeoCat);
        
        // go through the geocat and their competence to delete
        for (Geocat__c geo : lGeocat)
        {
            // Check if the account of the geocat have a intermediation offer active, if so continues otherwise do not
            // Not the rule to integrate
            //if (SubscriptionMethods.isIntermediationSubscriptionActive(geo.Account__c) == true)
            //{
                Integer nbCompetenceToDelete = 0;
                Competence__c compSave = null;
                for (Competence__c comp : lComp)
                {
                    if (comp.Geocat__c == geo.Id && comp.TECH_DeleteOnScreen__c == false)
                    {
                        nbCompetenceToDelete++;
                        compSave = comp;
                    }
                }
                if (nbCompetenceToDelete == geo.Nb_Competence__c)
                    compSave.AddError(Label.Competence_Error_DeleteLastWhenIntermediationActive);
            //}
        }
        
        system.debug('>>>>>>>>>>>>>>>>>>>> END checkIfNotLastCompetence');
    }
}