public class GeocatMapWrapperBis 
{
    public class GeocatMapItem
    {
        public Reference__c         key         {get;set;}
        public List<Reference__c>   refNiveau2  {get;set;}
        public GeoCat__c            geocat      {get;set;}
        //public List<CompetenceCategorie__c>  mappingNiveau3 {get;set;}
        
        public GeocatMapItem(Reference__c ref, List<Reference__c> lRef)
        {
            this.key = ref;
            this.refNiveau2 = lRef;


        }





    }
    
   // public Map<Reference__c, List<Reference__c>> varNiveau {get;set;}
    //public Map<GeocatMapKey, List<Reference__c>> varNiveau {get;set;}
    public List<GeocatMapItem> lReference {get;set;}
    
    public GeocatMapWrapperBis()
    {
        //varNiveau = new Map<GeocatMapKey, List<Reference__c>>();
        lReference = new List<GeocatMapItem>();
    }
    
    public void populateTreeview(List<CompetenceBis__c> lComp, String geocatId)
    {
        system.debug('>>>>>>>>>> START populateTreeView');
        
        if (lReference != null) lReference.clear();
        
        // set varNiveau
        List<Reference__c> varNiveau1 = [SELECT Id, Libelle__c, Key__c, Parent__c, Selected__c, Ordre__c FROM Reference__c WHERE RecordType.DeveloperName = 'Competence' AND Parent__c = '0' AND Obsolete__c = true ORDER BY Libelle__c];
        List<Reference__c> varNiveau2 = [SELECT Id, Libelle__c, Key__c, Parent__c, Selected__c, Ordre__c FROM Reference__c WHERE RecordType.DeveloperName = 'Competence' AND Parent__c != '0' AND Obsolete__c = true ORDER BY Libelle__c];
        //List<Mapping_CC__c> varMapping = [SELECT Id ,Categorie_ref__c, Categorie_key__c, Competence_ref__c, Competence_key__c, Auto_selection__c FROM Mapping_CC__c WHERE Competence_ref__c IN :varNiveau2];

        for (Reference__c ref1 : varNiveau1)
        {
            List<Reference__c> niv2List = new List<Reference__c>();
            List<MapppingMapItem> niv2Lists = new List<MapppingMapItem>();
            //List<Mapping_CC__c> niv3List = new List<Mapping_CC__c>();
            // get level 2 of this level 1
            for (Reference__c ref2 : varNiveau2)
            {
                if (ref2.Parent__c == ref1.Key__c)
                {
                    niv2List.add(ref2);
                    
                    // If list of competence in parameters, select the options
                    if (lComp != null)
                    {
                        for (CompetenceBis__c comp : lComp)
                        {
                            if (comp.Niveau_2__c == ref2.Id)
                                ref2.Selected__c = true;

                            //for (Mapping_CC__c maps :varMapping) {
                            //    if (ref2.Key__c == maps.Competence_key__c){
                            //        niv3List.add(maps);
                            //    }
                            //}
                        }
                    }
                    //niv2Lists.add(new MapppingMapItem(ref2, niv3List));

                }
            }
            //varNiveau.put(ref1, niv2List);
            //varNiveau.put(new GeocatMapKey(ref1), niv2List);
            lReference.add(new GeocatMapItem(ref1, niv2List));
        }
        
        system.debug('>>>>>>>>>> END populateTreeView');
    }
    
    public boolean isGeocatSelected()
    {
        boolean result = false;
        //for (Reference__c ref : varNiveau.keySet())
        /*
        for (GeocatMapKey mapKey : varNiveau.keySet())
        {
            //List<Reference__c> niveau2 = varNiveau.get(ref);
            List<Reference__c> niveau2 = varNiveau.get(mapKey);
            // go through the list of second item
            for (Reference__c ref2 : niveau2)
            {
                if (ref2.Selected__c == true)
                {
                    result = true;
                    break;
                }
            }
        }
        **/
        
        for (GeocatMapItem item : lReference)
        {
            for (Reference__c ref2 : item.refNiveau2)
            {
                if (ref2.Selected__c == true)
                {
                    result = true;
                    break;
                }
            }
        }
        
        return (result);
    }
    
    public void manageCompetenceOnGeocat(Id geocatId)
    {
        system.debug('>>>>>>>>>> START manageCompetenceOnGeocat');
        
        // Delete the competence in the geocat if some
        List<CompetenceBis__c> lCompToUpsert = [SELECT Id,Niveau_1__c , Niveau_2__c, Niveau2_Key__c FROM CompetenceBis__c WHERE Geocat__c =: geocatId];
        GeoCat__c geocat_current = [SELECT Id, Categorie_niveau__c, Categorie_de_niveau_TECH__c FROM GeoCat__c WHERE Id = :geocatId LIMIT 1];

        List<CompetenceBis__c> lCompToDelete = new List<CompetenceBis__c>();
        Map<String,CompetenceBis__c> mComp = new Map<String,CompetenceBis__c>();
        if (lCompToUpsert != null && lCompToUpsert.size() > 0)
        {
            // tick the system delete to autorize the delete
            for (CompetenceBis__c comp : lCompToUpsert)
            {

                comp.TECH_DeleteOnScreen__c = true;
                mComp.put(comp.Niveau2_Key__c, comp);
            }
                //comp.Etat_Tech__c = 'old';
            update lCompToUpsert;
            
            // MODIF Fred MBoungou
            // Suppression de la suppression
            //if (lCompToDelete != null && lCompToDelete.size() > 0)
            //   delete lCompToDelete;
        }
        
        // Get the geocat information and competence selected
        List<CompetenceBis__c> lCompetence = new List<CompetenceBis__c>();
        //for (Reference__c ref : varNiveau.keySet())
        /*
        for (GeocatMapKey mapKey : varNiveau.keySet())
        {
            //List<Reference__c> niveau2 = varNiveau.get(ref);
            List<Reference__c> niveau2 = varNiveau.get(mapKey);
            // go through the list of second item
            for (Reference__c ref2 : niveau2)
            {
                if (ref2.Selected__c == true)
                {
                    Competence__c comp = new Competence__c();
                    comp.Geocat__c = geocatId;
                   // comp.Niveau_1__c = ref.Id;
                    comp.Niveau_1__c = mapKey.ref.Id;
                    comp.Niveau_2__c = ref2.Id;
                    lCompetence.add(comp);
                    system.debug('>>>>>>>> comp: ' + comp);
                }
            }
        }
        **/
        /*for (GeocatMapItem item : lReference)
        {
            for (Reference__c ref2 : item.refNiveau2)
            {

                 
                    if (ref2.Selected__c == true)
                    {

                        CompetenceBis__c comp = new CompetenceBis__c();
                        comp.Geocat__c = geocatId;
                        //comp.Niveau_1__c = ref.Id;
                        comp.Niveau_1__c = item.key.Id;
                        comp.Niveau_2__c = ref2.Id;
                        comp.Name = ref2.Libelle__c;
                        lCompetence.add(comp);
                        system.debug('>>>>>>>> comp: ' + comp);
                    }
            }
        }*/

        for (GeocatMapItem item : lReference)
        {
            for (Reference__c ref2 : item.refNiveau2)
            {

                 
                    if (ref2.Selected__c == true && !mComp.containsKey(ref2.Key__c))
                    {

                        CompetenceBis__c comp = new CompetenceBis__c();
                        comp.Geocat__c = geocatId;
                        //comp.Niveau_1__c = ref.Id;
                        comp.Niveau_1__c = item.key.Id;
                        comp.Niveau_2__c = ref2.Id;
                        comp.Name = ref2.Libelle__c;
                        lCompetence.add(comp);
                        system.debug('>>>>>>>> comp: ' + comp);
                    }
                    else if (ref2.Selected__c == true && mComp.containsKey(ref2.Key__c))
                    {
                        mComp.get(ref2.Key__c).TECH_DeleteOnScreen__c = false;
                        lCompetence.add(mComp.get(ref2.Key__c));
                    }

            }
        }

        upsert lCompetence;
        system.debug('GeocatMapWrapperBis : DEBUG : lCompetence = ' + lCompetence);


        for (CompetenceBis__c comp : lCompetence) {
            if (mComp.containsKey(comp.Niveau2_Key__c)) {
                mComp.remove(comp.Niveau2_Key__c);
            }
        }

        if (mComp.values().size() > 0)
            delete mComp.values();

        geocat_current.recalculateFormulas();
        
        system.debug('>>>>>>>>>> END manageCompetenceOnGeocat');
    }

    public class MapppingMapItem {

        public Reference__c comp {get;set;}
        public List<Mapping_CC__c> lMap {get;set;}
        public Integer nombre_categories {get;set;}

        public MapppingMapItem (Reference__c comp, List<Mapping_CC__c> lCat) {
            this.comp = comp;
            this.lMap = lCat;
        }
    }
}