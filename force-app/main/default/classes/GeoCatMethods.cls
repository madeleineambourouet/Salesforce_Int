public class GeoCatMethods 
{
    public static void calculateCategories(List<Geocat__c> lGeocat)
    {
        // Get the competence of a geocat
        List<Competence__c> lResults = [SELECT Niveau_2_libelle__c, Niveau2_Key__c, Geocat__c FROM Competence__c WHERE Geocat__c in: lGeoCat AND Active__c = true];
        system.debug('>>>>>>>>>> lResults: ' + lResults);
        // For each geocat, retrieve the categorie
        for (Geocat__c geo : lGeocat)
        {
            String categorie_niveau = '';
            String categorie_code = '';
            for (Competence__c comp : lResults) 
            {
                if (comp.Geocat__c == geo.Id)
                {
                    if (categorie_niveau != '')
                        categorie_niveau += ', ';
                    categorie_niveau += comp.Niveau_2_libelle__c;
                    if (categorie_code != '')
                        categorie_code += ', ';
                    categorie_code += comp.Niveau2_Key__c;
                }
            }
            system.debug('>>>>>> categorie_niveau: ' + categorie_niveau);
            geo.Categorie_niveau__c = categorie_niveau;
            geo.Categorie_de_niveau_TECH__c = categorie_code;
        }
    }

    public static void calculateExclusion(List<Geocat__c> lGeocat)
    {
        List<CompetenceCategorie__c> lResults = [SELECT Categorie__c, Categorie_key__c, Categorie_libelle__c, Geocat__c FROM CompetenceCategorie__c WHERE Geocat__c IN :lGeocat];
        for (Geocat__c geo : lGeocat)
        {
            String categorie_niveau = '';
            String categorie_code = '';

            for(CompetenceCategorie__c cc : lResults)
            {
                if(cc.Geocat__c == geo.Id)
                {
                    if (categorie_niveau != '')
                        categorie_niveau += ', ';
                    categorie_niveau += cc.Categorie_libelle__c;

                    if (categorie_code != '')
                        categorie_code += ', ';
                    categorie_code += cc.Categorie_key__c;
                }
            }

            geo.Categorie_exclu__c = categorie_niveau;
            geo.Categorie_exclue_TECH__c = categorie_code;
        } 
    }
    
    public static void calculateTechTextQuote(List<GeoCat__c> lGeoCat)
    {
        for (GeoCat__c geocat : lGeoCat)
        {
            if (geoCat.Categorie_niveau__c != null)
            {
                String txt = Label.GeoCat_Tech_Texte_Quote;
                txt = txt.replace('{!CategorieNiveau}', (geoCat.Categorie_niveau__c != null ? geoCat.Categorie_niveau__c : ''));
                txt = txt.replace('{!KM}', (String.valueOf(geoCat.Zone_d_intervention__c) != null ? String.valueOf(geoCat.Zone_d_intervention__c) : ''));
                txt = txt.replace('{!Ville}', (geoCat.Ville__c != null ? geoCat.Ville__c : ''));
                txt = txt.replace('{!CodePostal}', (geoCat.Code_postal__c != null ? geoCat.Code_postal__c : ''));
                txt = txt.replace('{!Exception}', (geoCat.Exclusion__c != null ? geoCat.Exclusion__c : 'Aucun'));
                txt = txt.replace('{!DDP}', (String.valueOf(geoCat.DDP__c) != null ? String.valueOf(geoCat.DDP__c) : ''));
                
                geoCat.TECH_Texte_Quote__c = txt;
            } 
        }
    }
    
    public static void setAccountWithContact(List<Geocat__c> lGeocat)
    {
        for (Geocat__c geo : lGeocat)
            geo.Account__c = geo.TECH_Account_Id__c;
    }
    
    public static void calculateNBGeocatOnAccount(List<GeoCat__c> lGeocat)
    {
        // Get all the account attached to the geocats in parameters
        List<Id> lAccountIds = new List<Id>();
        for (Geocat__c geo : lGeocat)
            lAccountIds.add(geo.Account__c);
        
        AggregateResult[] groupedResults = [SELECT Account__c, count(Id) FROM Geocat__c WHERE Account__c in: lAccountIds GROUP BY Account__c];
        List<Account> lAccounts = new List<Account>();
        for (AggregateResult ar : groupedResults)  
        {
            System.debug('Account__c: ' + ar.get('Account__c'));
            System.debug('count: ' + ar.get('expr0'));
            Account acc = new Account();
            acc.Id = String.valueOf(ar.get('Account__c'));
            acc.Nb_Geocat__c = Integer.valueOf(ar.get('expr0'));
            lAccounts.add(acc);
        }    
        
        if (lAccounts != null && lAccounts.size() > 0)
            update lAccounts;
    }
    
    public static void checkIfNotLastGeocat(List<Geocat__c> lGeocat)
    {
        system.debug('>>>>>>>>>>>>>>>>>>>> START checkIfNotLastGeocat');
        
        // Get the contact linked to the geocat
        List<Id> lContactIds = new List<Id>();
        for (Geocat__c geo : lGeoCat)
            lContactIds.add(geo.Contact__c);
        List<Contact> lContact = [SELECT Id, AccountId, PXS_Nb_Geocat_With_Competence__c FROM Contact WHERE Id in: lContactIds];
        system.debug('>>>>>>>>>> lContact: ' + lContact);
        
        // go through the contacts and their geocat to delete
        for (Contact con : lContact)
        {
            // Check if the account of the contact have a intermediation offer active, if so continues otherwise do not
            if (SubscriptionMethods.isIntermediationSubscriptionActive(con.AccountId) == true)
            {
                Integer nbGeocatToDelete = 0;
                Geocat__c geoSave = null;
                for (Geocat__c geo : lGeocat)
                {
                    if (geo.Contact__c == con.Id)
                    {
                        nbGeocatToDelete++;
                        geoSave = geo;
                    }
                }
                if (nbGeocatToDelete == con.PXS_Nb_Geocat_With_Competence__c)
                    geoSave.AddError(Label.Geocat_Error_DeleteLastWhenIntermediationActive);
            }
        }
        
        system.debug('>>>>>>>>>>>>>>>>>>>> END checkIfNotLastGeocat');
    }

     /**
    * @author Clement Musabimana
    * @date 01/10/2018
    * @description fonction qui permet de vérifier et retourner la liste de contacts ayant la somme de poids sur les CI supérieure à 100
    **/   
    public static  List<Id> checkSumPoidsGeocatOnAccount(List<GeoCat__c> lGeocat)
    {
        List<Id> lAccountIdsRejetSumPoids = new List<Id>();
        system.debug('checkSumPoidsGeocatOnAccount lGeocat '+lGeocat);
        // Get all the account attached to the geocats in parameters
        List<Id> lcontactsIds = new List<Id>();
        List<Id> lGeocatIds = new List<Id>();
        for (Geocat__c geo : lGeocat){
            if(geo.Contact__c != null){
                lcontactsIds.add(geo.Contact__c);
                lGeocatIds.add(geo.Id);
            }
        }
        
        //Récupération de la somme, en base, des poids des Critères d'intervention par compte
        //////FAIRE LA SOMME DANS LA BOUCLE
        AggregateResult[] groupedResults = [SELECT Contact__c, SUM(FaminePoids__c) FROM Geocat__c WHERE Contact__c in: lcontactsIds and Id not in: lGeocatIds GROUP BY Contact__c];
        system.debug('checkSumPoidsGeocatOnAccount groupedResults '+groupedResults);
        Map<Id,Decimal> mapAccountsSumPoidsFamine = new Map<Id,Decimal>();
        for (AggregateResult ar : groupedResults)  
        { 
            System.debug('Contact__c: ' + ar.get('Contact__c'));
            System.debug('count: ' + ar.get('expr0'));
            Id acc = Id.valueOf((String)ar.get('Contact__c'));
            Decimal poidsCi = (Decimal)ar.get('expr0');
            poidsCi = (poidsCi != null ? poidsCi : 0);
            if(mapAccountsSumPoidsFamine.get(acc) == null){
               mapAccountsSumPoidsFamine.put(acc,poidsCi);
            }
            else {
                Decimal sumPoids = (mapAccountsSumPoidsFamine.get(acc) != null ? mapAccountsSumPoidsFamine.get(acc) : 0);
                sumPoids = sumPoids + poidsCi;
                mapAccountsSumPoidsFamine.put(acc,sumPoids);
            }
        }
       
        //Vérification pour chaque compte que la mise à jour des sommes des poids ne dépassent pas 100
        for (GeoCat__c geocat : lGeocat)
        {
            if(geocat.Contact__c != null){
                if(mapAccountsSumPoidsFamine.get(geocat.Contact__c) != null){
                    Decimal sumPoids = (mapAccountsSumPoidsFamine.get(geocat.Contact__c) != null ? mapAccountsSumPoidsFamine.get(geocat.Contact__c) : 0);
                    sumPoids = sumPoids + (geocat.FaminePoids__c != null ? geocat.FaminePoids__c : 0);
                    mapAccountsSumPoidsFamine.put(geocat.Contact__c,sumPoids);
                    if(sumPoids > 100 && !lAccountIdsRejetSumPoids.contains(geocat.Contact__c)){
                        lAccountIdsRejetSumPoids.add(geocat.Contact__c);
                    }
                }
                else{
                    Decimal sumPoids = (geocat.FaminePoids__c != null ? geocat.FaminePoids__c : 0);
                    mapAccountsSumPoidsFamine.put(geocat.Contact__c,sumPoids);
                    if(sumPoids > 100 && !lAccountIdsRejetSumPoids.contains(geocat.Contact__c)){
                        lAccountIdsRejetSumPoids.add(geocat.Contact__c);
                    }
                }

            }
        } 
        return lAccountIdsRejetSumPoids;
    }
}