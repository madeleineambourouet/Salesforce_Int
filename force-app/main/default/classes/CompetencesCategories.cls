public without sharing class CompetencesCategories {
	public List<mappingWrapper> currentMapping {get;set;}
	public String nivo1 {get;set;}
	public String nivo2 {get;set;}
	public List<CompetenceCategorie__c> exclusion {get;set;}
	public Boolean render {get;set;}

	public CompetencesCategories() {
		Id current_Id = apexpages.currentpage().getparameters().get('id');
		Id current_niv1_Id = apexpages.currentpage().getparameters().get('niv1');
		Id current_geocat = apexpages.currentpage().getparameters().get('geocat');
		if (apexpages.currentpage().getparameters().get('check') == '0')
			render = true;
		else
			render = false;


		//Reference__c niv2 = apexpages.currentpage().getparameters().get('niv2');		
		Reference__c currentCompetence = [SELECT Id, Libelle__c, Key__c FROM Reference__c WHERE Id = :current_Id LIMIT 1];
		Reference__c niv1 = [SELECT Id, Libelle__c FROM Reference__c WHERE Id = :current_niv1_Id LIMIT 1] ;
		exclusion = [SELECT Id, Categorie__c, Geocat__c, Categorie_libelle__c FROM CompetenceCategorie__c WHERE Geocat__c = :current_geocat];

		//construction du set contenus les categories exclues
		Set<Id> idexclu = new Set<Id>(); 
		for (CompetenceCategorie__c cc : exclusion) {
			idexclu.add(cc.Categorie__c);
		}

		nivo1 = niv1.Libelle__c;
		nivo2 = currentCompetence.Libelle__c;

		currentMapping = new List<mappingWrapper>();
		if (currentCompetence != null){
			List<Mapping_CC__c> mapping = [SELECT Id, Categorie_ref__c, Competence_ref__c, Categorie_libelle__c, Inclus__c FROM Mapping_CC__c WHERE Competence_ref__c = :currentCompetence.Id];
				for (Mapping_CC__c  m : mapping) {
					if (!idexclu.isEmpty() && idexclu.contains(m.Categorie_ref__c)) {
						//m.Inclus__c = false;
						currentMapping.add(new mappingWrapper(m, false));
					}
					else
						currentMapping.add(new mappingWrapper(m, true));
				}
			//currentMapping = mapping;
		}
		system.debug('TEST : FRED : currentMapping = ' + currentMapping);
	}

	public PageReference savemapping() {
		List<CompetenceCategorie__c> exclus =  new List<CompetenceCategorie__c>();
		List<CompetenceCategorie__c> inclus =  new List<CompetenceCategorie__c>();
		List<CompetenceCategorie__c> exclusInsert =  new List<CompetenceCategorie__c>();
		Map<Id, CompetenceCategorie__c> excluByCat = new Map<Id, CompetenceCategorie__c>();
		Boolean OnceCategorie = false;

		for (CompetenceCategorie__c cc : exclusion) {
			excluByCat.put(cc.Categorie__c,cc);
		}

		
		
		for (mappingWrapper m : currentMapping) {
			if (m.inclus == false && !excluByCat.containsKey(m.mapping.Categorie_ref__c)){
				exclus.add(new CompetenceCategorie__c(Categorie__c=m.mapping.Categorie_ref__c, Geocat__c=apexpages.currentpage().getparameters().get('geocat'), ON_IHM__c = true));
			}

			if (m.inclus == true) {

				OnceCategorie = true;
			}
			if (m.inclus == true && excluByCat.containsKey(m.mapping.Categorie_ref__c))
			{
				CompetenceCategorie__c cc = excluByCat.get(m.mapping.Categorie_ref__c);
				cc.ON_IHM__c = true;
				inclus.add(cc);
			}
		}

		if (OnceCategorie == false) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Il faut sélectionner au moins une catégorie.'));
            return (null);
		} else {

			delete inclus;
			insert exclus;
			checkRecursiveSFDC.runEXCLU = false;
			return backsavemapping();
		}
	}

	public PageReference backsavemapping()
    {
        String urlBack = '/';
        if (apexpages.currentpage().getparameters().get('geocat') != null ) 
        	if (apexpages.currentpage().getparameters().get('bis') == '1')
            	urlBack += 'apex/VF_Geocat_NewEditBis?scontrolCaching=1&id=' + apexpages.currentpage().getparameters().get('geocat');
            else
            	urlBack += 'apex/VF_Geocat_NewEdit?scontrolCaching=1&id=' + apexpages.currentpage().getparameters().get('geocat');
        		
        return (new PageReference(urlBack));
    }

    public class mappingWrapper {
    	public Mapping_CC__c mapping {get;set;}
    	public Boolean inclus {get;set;}
    	public String Name {get;set;}

    	public mappingWrapper(Mapping_CC__c mapp, Boolean inclu)
    	{
    		this.mapping = mapp;
    		this.inclus = inclu;
    		this.Name = mapp.Categorie_libelle__c;
    	}
    }
}