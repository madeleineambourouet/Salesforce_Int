public class GeocatMapWrapper 
{
    public class GeocatMapItem
    {
        public Reference__c         key {get;set;}
        public List<CompetenceMapItem>   refNiveau2 {get;set;}
        
        public GeocatMapItem(Reference__c ref, List<CompetenceMapItem> lRef)
        {
            this.key = ref;
            this.refNiveau2 = lRef;
        }
    }

    public class CompetenceMapItem
    {
        public Reference__c   refNiveau2 {get;set;}
        public Integer        totalCat   {get;set;}
        public Integer        exCat      {get;set;}
        public Boolean        afficheCount {get;set;}
        public Boolean        selected {get;set;}

        public CompetenceMapItem(Reference__c niveau2, Integer total, Integer exclu)
        {
            this.refNiveau2 = niveau2;
            this.totalCat = total;
            this.exCat = exclu;
            if (exclu > 0)
                this.afficheCount = true;
            else
                this.afficheCount = false;
            selected = false;
        }

    }
    

    public List<GeocatMapItem> lReference {get;set;}
    
    public GeocatMapWrapper()
    {
        //varNiveau = new Map<GeocatMapKey, List<Reference__c>>();
        lReference = new List<GeocatMapItem>();
    }
    
    public void populateTreeview(List<Competence__c> lComp, Id geocatid )
    {
        system.debug('>>>>>>>>>> START populateTreeView');
        
        if (lReference != null) lReference.clear();
        
        // set varNiveau
        //
        //Ancienne requete
        //
        //List<Reference__c> varNiveau1 = [SELECT Id, Libelle__c, Key__c, Parent__c, Selected__c, Ordre__c FROM Reference__c WHERE RecordType.DeveloperName = 'Competence' AND Parent__c = '0' ORDER BY Ordre__c];
        //List<Reference__c> varNiveau2 = [SELECT Id, Libelle__c, Key__c, Parent__c, Selected__c, Ordre__c FROM Reference__c WHERE RecordType.DeveloperName = 'Competence' AND Parent__c != '0' ORDER BY Ordre__c];


        //Nouvelle requete
        List<Reference__c> varNiveau1 = [SELECT Id, Libelle__c, Key__c, Parent__c, Selected__c, Ordre__c FROM Reference__c WHERE RecordType.DeveloperName = 'Competence' AND Parent__c = '0' AND Obsolete__c = false ORDER BY Libelle__c];
        List<Reference__c> varNiveau2 = [SELECT Id, Libelle__c, Key__c, Parent__c, Selected__c, Ordre__c FROM Reference__c WHERE RecordType.DeveloperName = 'Competence' AND Parent__c != '0' AND Obsolete__c = false  ORDER BY Libelle__c];
        List<CompetenceCategorie__c> exclusion = new List<CompetenceCategorie__c>();
        if (geocatid != null)
            exclusion = [SELECT Id, Categorie__c, Geocat__c, Categorie_libelle__c FROM CompetenceCategorie__c WHERE Geocat__c = :geocatid];
        // List<Mapping_CC__c> mapping = [SELECT Id, Categorie_ref__c, Competence_ref__c, Categorie_libelle__c, Inclus__c FROM Mapping_CC__c WHERE Competence_ref__c IN :varNiveau2 ORDER BY Competence_ref__c];

        Map<Id, Integer> countMapping = new Map<Id, Integer>();
        Map<Id, Integer> countExclusion = new Map<Id, Integer>();
        Set<Id> exclu = new Set<Id>();
        Set<Id> exclucomp = new Set<Id>();

        for (CompetenceCategorie__c cc : exclusion)
        {
            exclu.add(cc.Categorie__c);
        }

        for (Mapping_CC__c m : [SELECT Competence_ref__c FROM Mapping_CC__c WHERE Categorie_ref__c IN :exclu])
        {
            exclucomp.add(m.Competence_ref__c);
        }

        //List<Mapping_CC__c> mapping = [SELECT Id, Categorie_ref__c, Competence_ref__c, Categorie_libelle__c, Inclus__c
        //                                FROM Mapping_CC__c
        //                                WHERE Competence_ref__c IN :exclucomp];

        //List<Mapping_CC__c> mappingExclu = [SELECT Id, Categorie_ref__c, Competence_ref__c, Categorie_libelle__c, Inclus__c FROM Mapping_CC__c WHERE Categorie_ref__c IN :exclu ORDER BY Competence_ref__c];

        AggregateResult[] mapping = [SELECT COUNT(Id), Competence_ref__c
                                        FROM Mapping_CC__c
                                        WHERE Competence_ref__c IN :exclucomp
                                        GROUP BY Competence_ref__c];

        AggregateResult[] mappingExclu = [SELECT COUNT(Id), Competence_ref__c
                                            FROM Mapping_CC__c
                                            WHERE Categorie_ref__c IN :exclu
                                            GROUP BY Competence_ref__c];

        system.debug('TEST : FRED : countExclusion = ' + countExclusion);

        if (exclusion.size() > 0 ) 
        {
            for (Reference__c r : varNiveau2)
            {
                Integer total = 0;
                Integer ex = 0;
                for (AggregateResult m : mapping)
                {
                    //if(m.Competence_ref__c == r.Id)
                    //    total = total + 1;

                    if(m.get('Competence_ref__c') == r.Id)
                        total = (integer) m.get('expr0');
                }

                for (AggregateResult m : mappingExclu)
                {
                    //if(m.Competence_ref__c == r.Id)
                    //    ex = ex + 1;

                    if(m.get('Competence_ref__c') == r.Id)
                        ex = (integer) m.get('expr0');

                }

                countMapping.put(r.Id, total);
                countExclusion.put(r.Id, ex);
            }
        }
       

        for (Reference__c ref1 : varNiveau1)
        {
            //List<Reference__c> niv2List = new List<Reference__c>();
            List<CompetenceMapItem> niv2Lists = new List<CompetenceMapItem>();
            // get level 2 of this level 1
            for (Reference__c ref2 : varNiveau2)
            {
                if (ref2.Parent__c == ref1.Key__c)
                {
                    //niv2List.add(ref2);
                    if (countExclusion.containsKey(ref2.Id))
                        niv2Lists.add(new CompetenceMapItem(ref2, countMapping.get(ref2.Id), countExclusion.get(ref2.Id)));
                    else
                        niv2Lists.add(new CompetenceMapItem(ref2, 0, 0));
                    // If list of competence in parameters, select the options
                    
                }
            }
            //varNiveau.put(ref1, niv2List);
            //varNiveau.put(new GeocatMapKey(ref1), niv2List);
            //lReference.add(new GeocatMapItem(ref1, niv2List));
            lReference.add(new GeocatMapItem(ref1, niv2Lists));
        }

        for (GeocatMapItem gcm : lReference)
        {
            for (CompetenceMapItem cmi : gcm.refNiveau2)
            {
                if (lComp != null) {
                    for (Competence__c comp : lComp)
                        {
                        if (comp.Niveau_2__c == cmi.refNiveau2.Id)
                                cmi.selected = true;
                        }
                }
            }
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
            for (CompetenceMapItem ref2 : item.refNiveau2)
            {
                if (ref2.selected == true)
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
        List<Competence__c> lCompToUpsert = [SELECT Id,Niveau_1__c , Niveau_2__c, Niveau2_Key__c FROM Competence__c WHERE Geocat__c =: geocatId AND Active__c = true];
        List<Competence__c> lCompToDelete = new List<Competence__c>();
        Map<String,Competence__c> mComp = new Map<String,Competence__c>();

        if (lCompToUpsert != null && lCompToUpsert.size() > 0)
        {
            // tick the system delete to autorize the delete
            for (Competence__c comp : lCompToUpsert){
                comp.TECH_DeleteOnScreen__c = true;
                mComp.put(comp.Niveau2_Key__c, comp);
            }
            update lCompToUpsert;
            //if (lCompToDelete != null && lCompToDelete.size() > 0)
            //    delete lCompToDelete;
        }
        
        // Get the geocat information and competence selected
        List<Competence__c> lCompetence = new List<Competence__c>();
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
        for (GeocatMapItem item : lReference)
        {
            for (CompetenceMapItem ref2 : item.refNiveau2)
            {
                if (ref2.selected == true && !mComp.containsKey(ref2.refNiveau2.Key__c))
                    {
                    Competence__c comp = new Competence__c();
                    comp.Geocat__c = geocatId;
                   // comp.Niveau_1__c = ref.Id;
                    comp.Niveau_1__c = item.key.Id;
                    comp.Niveau_2__c = ref2.refNiveau2.Id;
                    comp.Name = ref2.refNiveau2.Libelle__c;
                    lCompetence.add(comp);
                    system.debug('>>>>>>>> comp: ' + comp);
                    }
                else if (ref2.selected == true && mComp.containsKey(ref2.refNiveau2.Key__c))
                    {
                        mComp.get(ref2.refNiveau2.Key__c).TECH_DeleteOnScreen__c = false;
                        lCompetence.add(mComp.get(ref2.refNiveau2.Key__c));
                    }
            }
        }
        
        system.debug('FRED : GeocatMapWrapper : lCompetence = ' + lCompetence);
        
        upsert lCompetence;

        for (Competence__c comp : lCompetence) {
            if (mComp.containsKey(comp.Niveau2_Key__c)) {
                mComp.remove(comp.Niveau2_Key__c);
            }
        }

        if (mComp.values().size() > 0)
            delete mComp.values();
            
        system.debug('>>>>>>>>>> END manageCompetenceOnGeocat');
    }
}