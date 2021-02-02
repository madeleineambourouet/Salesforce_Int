public without sharing class CategorieExclusionTrigger {
	public static void OnIHM(List<CompetenceCategorie__c> lExclusion)
	{
		for (CompetenceCategorie__c cc : lExclusion)
		{
			if (cc.ON_IHM__c == true)
				cc.ON_IHM__c = false;
			else
				break;
		}
	}

	public static void GetBackChanges(List<CompetenceCategorie__c> lExclusion) {
		Set<Id> idGeocat = new Set<Id>();
		Set<CompetenceCategorie__c> exclusionTraitee = new set<CompetenceCategorie__c>();

		for (CompetenceCategorie__c cc : lExclusion)
		{
			idGeocat.add(cc.Geocat__c);
			if (cc.ON_IHM__c == false)
			{
				exclusionTraitee.add(cc);
			}
		}
		
		

		if (exclusionTraitee.size() > 0) {

			Geocat__c geo = [SELECT Id, Categorie_exclu__c, Categorie_exclue_TECH__c
							FROM Geocat__c
							WHERE Id IN :idGeocat];

			String categorie_niveau = (geo.Categorie_exclu__c == null ? '' : geo.Categorie_exclu__c);
			String categorie_code = (geo.Categorie_exclue_TECH__c == null ? '' : geo.Categorie_exclue_TECH__c);
			

            for(CompetenceCategorie__c cc : exclusionTraitee)
            {
                if(cc.Geocat__c == geo.Id)
                {
                    //if (categorie_niveau != '')
                    //    categorie_niveau += ', ';
                    //categorie_niveau += cc.Categorie_libelle__c;

                    categorie_niveau = categorie_niveau.remove(', ' + cc.Categorie_libelle__c);
                    categorie_code = categorie_code.remove(', ' + cc.Categorie_key__c );
                    //if (categorie_code != '')
                    //	categorie_code += ', ';
                    //categorie_code += cc.Categorie_key__c;
                }
            }
            system.debug('TEST : categorie_code = ' + categorie_code);
            system.debug('TEST : geo.Categorie_exclue_TECH__c = ' + geo.Categorie_exclue_TECH__c);

           if (categorie_code != geo.Categorie_exclue_TECH__c){
           		if (String.isNotBlank(categorie_code) && String.isNotBlank(geo.Categorie_exclue_TECH__c)) {
		           List<Historisation__c> h = new List<Historisation__c>();
		           h.add(new Historisation__c(GeoCat__c = geo.Id, ancien__c = geo.Categorie_exclu__c, actuel__c = categorie_niveau, Champs__c = 'Categorie exclue'));
		           h.add(new Historisation__c(GeoCat__c = geo.Id, ancien__c = geo.Categorie_exclue_TECH__c, actuel__c = categorie_code, Champs__c = 'Categorie exclue code'));
		           system.debug('TEST : List h = ' + h);
		           insert h;
		       }
	       }
           update geo;
         }
	}
}