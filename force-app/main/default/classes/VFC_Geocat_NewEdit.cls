public class VFC_Geocat_NewEdit 
{
    public Geocat__c thisGeocat {get;set;}
    
    public GeocatMapWrapper mapRecord {get;set;}

    public Boolean newgeo {get; set;}

    
    public VFC_Geocat_NewEdit(ApexPages.StandardController StandardController)
    {
        thisGeocat = (Geocat__c)StandardController.getRecord();
        system.debug('>>>>>>>>>>>>> thisGeocat: ' + thisGeocat);
        newgeo = false;

        mapRecord = new GeocatMapWrapper();

        if (thisGeocat.Id == null)
            newgeo = true;
        if (thisGeocat != null && thisGeocat.Id != null)
        {
            List<Competence__c> lCompGeocat = [SELECT Id, Niveau_1__c, Niveau_2__c FROM Competence__c WHERE Geocat__c =: thisGeocat.Id AND TECH_DeleteOnScreen__c = false];
            mapRecord.populateTreeview(lCompGeocat, thisGeocat.id);
        }
        else
            mapRecord.populateTreeview(null,thisGeocat.id);
    }


    //public PageReference saveGeocat()
    //{
    //    return saveGeocat(false);
    //}

    public PageReference saveGeocat()
    {
        system.debug('>>>>>>>>>> START saveGeocat');
        
        if (manageError())
            return (new PageReference('/' + thisGeocat.Id));
        else
            return null;
    }

    public void saveGeocatBis()
    {
        system.debug('>>>>>>>>>> START saveGeocatBis');
        
        manageError();
        system.debug('>>>>>>>>>> END saveGeocatBis');

        system.debug('VFC GEOCAT : myparam = ' + Apexpages.currentPage().getParameters().get('myParam'));

    }

    public PageReference saveGeocatQuick()
    {
        system.debug('>>>>>>>>>> START saveGeocat');

        newgeo = false;

        if (manageError())
            return (new PageReference('/apex/VF_Geocat_NewEdit?id=' + thisGeocat.Id));
        else
            return null;
    }

    public Boolean manageError() {

        Boolean check = true;

        if(thisGeocat.Date_de_debut__c > thisGeocat.Date_de_fin__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La date de début doit être inférieure a la date de fin'));
            check = false;
            return check;
        }
        
        if((thisGeocat.Date_de_debut__c!= null || thisGeocat.Date_de_fin__c != null) && thisGeocat.Motifs_de_suspension__c == null) {
          
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vous devez renseigner un motif de suspension lorsque la date de début et la date de fin de suspension sont remplies.'));
            
             check = false;
            return check;
        }
       
        if( (thisGeocat.Date_de_debut__c== null && thisGeocat.Date_de_fin__c == null) && thisGeocat.Motifs_de_suspension__c != null) {
          
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vous devez retirer le motif de suspension si les dates de début et de fin de suspension sont vides.'));
            
            check = false;
            return check;
        }
        
        if( (thisGeocat.Date_de_debut__c!= null && thisGeocat.Date_de_fin__c == null) && thisGeocat.Motifs_de_suspension__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Veuillez renseigner les 2 champs ou laisser vide les 2 champs'));
            check = false;
            return check;
        }
        
        if( (thisGeocat.Date_de_debut__c== null && thisGeocat.Date_de_fin__c != null) && thisGeocat.Motifs_de_suspension__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Veuillez renseigner les 2 champs ou laisser vide les 2 champs'));
            check = false;
            return check;
        }
                    
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
                            check = false;
                            return check;
                        }
                    }
                    else if (!(list_exclusion[i].equals(';')))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contenu du champ Exclusion incorrect : Le champ Exclusion ne doit contenir que des codes postaux ou des départements séparés par des points virgules.'));
                        check = false;
                        return check;
                    }
                }
            }
            
            //01/01/2018 CMU : contrôle sur la somme des poids des criteres d'intervention d'un contact
            //Regle desactivé: on force la saisie d'une valeur supérieur à 0. On accepte de dépasser 100 pour la somme des poids des CI
            /*
            List<GeoCat__c> lGeocat = new List<GeoCat__c>();
            lGeocat.add(thisGeocat);
            List<Id> listSumPoidsGeocatOnAccount = GeoCatMethods.checkSumPoidsGeocatOnAccount(lGeocat);
            if(listSumPoidsGeocatOnAccount.size() > 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'La somme des poids des critères d\'intervention sur le compte ne doit pas être supérieure à 100'));
                check = false;
                return check;
            }
            if(thisGeocat.FaminePoids__c<0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Le poids du critère d\'intervention sur le compte ne doit pas être inférieure à 0'));
                check = false;
                return check;
            }*/
            
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
                check = false;
                return check;
            }
        }

        return check;

    }
    
    public PageReference backsaveGeocat()
    {
        String urlBack = '/';
        if (thisGeocat.Id != null) 
            urlback += thisGeocat.Id;
        else 
            urlBack += thisGeocat.Contact__c;
        
        return (new PageReference(urlBack));
    }
}