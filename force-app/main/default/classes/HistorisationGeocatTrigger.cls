public without sharing class HistorisationGeocatTrigger {

	public static void GetBackChanges(List<GeoCat__c> geocat, Map<Id,GeoCat__c> geocatold) {
		List<Historisation__c> histoList = new List<Historisation__c>();
        
		for (GeoCat__c g : geocat) {
			system.debug('TEST : geocat.source = ' + g.Source__c);
			system.debug('TEST : geocat.oldsource = ' + geocatold.get(g.Id).Source__c);
			if (!checkRecursiveSFDC.runGEOCAT) {
				System.debug('TEST : passage a vide');
			} else {

				if (g != geocatold.get(g.Id)){

					if (g.DDP__c != geocatold.get(g.Id).DDP__c ) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.DDP__c != null ? g.DDP__c.format() :null);
						h.ancien__c = (geocatold.get(g.Id).DDP__c != null ?geocatold.get(g.Id).DDP__c.format() :null);
						h.Champs__c = 'Opportunités de chantier';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Zone_d_intervention__c != geocatold.get(g.Id).Zone_d_intervention__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Zone_d_intervention__c != null ? g.Zone_d_intervention__c.format() : null);
						h.ancien__c = (geocatold.get(g.Id).Zone_d_intervention__c != null ? geocatold.get(g.Id).Zone_d_intervention__c.format() : null);
						h.Champs__c = 'Rayon d\'intervention en km';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Exclusion__c != geocatold.get(g.Id).Exclusion__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = g.Exclusion__c;
						h.ancien__c = geocatold.get(g.Id).Exclusion__c;
						h.Champs__c = 'Exclusion';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Adresse__c != geocatold.get(g.Id).Adresse__c) {
						Historisation__c h = new Historisation__c();
						String old;
						String cp;
						for (Reference__c r :[SELECT Key__c FROM Reference__c WHERE (Id = :g.Adresse__c OR Id = :geocatold.get(g.Id).Adresse__c)]) {
							if (g.Adresse__c == r.id)
								cp = r.Key__c;

							if (geocatold.get(g.Id).Adresse__c == r.id)
								old = r.Key__c;
						}
						//system.debug('TEST : CP : ' + g.Adresse__r.Key__c);
						h.actuel__c = cp;
						h.ancien__c = old;
						h.Champs__c = 'Code postal';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Categorie_niveau__c != geocatold.get(g.Id).Categorie_niveau__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Categorie_niveau__c == null ? '' : g.Categorie_niveau__c);
						h.ancien__c = (geocatold.get(g.Id).Categorie_niveau__c == null ? '' : geocatold.get(g.Id).Categorie_niveau__c);
						h.Champs__c = 'Compétence';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Categorie_de_niveau_TECH__c != geocatold.get(g.Id).Categorie_de_niveau_TECH__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Categorie_de_niveau_TECH__c == null ? '' : g.Categorie_de_niveau_TECH__c);
						h.ancien__c = (geocatold.get(g.Id).Categorie_de_niveau_TECH__c == null ? '' : geocatold.get(g.Id).Categorie_de_niveau_TECH__c);
						h.Champs__c = 'Compétence code';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Date_de_debut__c != geocatold.get(g.Id).Date_de_debut__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Date_de_debut__c != null ? g.Date_de_debut__c.format() :null);
						h.ancien__c = (geocatold.get(g.Id).Date_de_debut__c != null ? geocatold.get(g.Id).Date_de_debut__c.format() :null);
						h.Champs__c = 'Début de suspension';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Date_de_fin__c != geocatold.get(g.Id).Date_de_fin__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Date_de_fin__c != null ? g.Date_de_fin__c.format() :null);
						h.ancien__c = (geocatold.get(g.Id).Date_de_fin__c != null ?geocatold.get(g.Id).Date_de_fin__c.format() :null);
						h.Champs__c = 'Fin de suspension';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Categorie_exclu__c != geocatold.get(g.Id).Categorie_exclu__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Categorie_exclu__c == null ? '' : g.Categorie_exclu__c);
						h.ancien__c = (geocatold.get(g.Id).Categorie_exclu__c == null ? '' : geocatold.get(g.Id).Categorie_exclu__c);
						h.Champs__c = 'Categorie exclue';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Categorie_exclue_TECH__c != geocatold.get(g.Id).Categorie_exclue_TECH__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Categorie_exclue_TECH__c == null ? '' : g.Categorie_exclue_TECH__c);
						h.ancien__c = (geocatold.get(g.Id).Categorie_exclue_TECH__c == null ? '' : geocatold.get(g.Id).Categorie_exclue_TECH__c);
						h.Champs__c = 'Categorie exclue code';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Rayon_preconise__c != geocatold.get(g.Id).Rayon_preconise__c ) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Rayon_preconise__c != null ? g.Rayon_preconise__c.format() :null);
						h.ancien__c = (geocatold.get(g.Id).Rayon_preconise__c != null ? geocatold.get(g.Id).Rayon_preconise__c.format() :null);
						h.Champs__c = 'Rayon préconisé';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}
                    
                    if (g.Motifs_de_suspension__c != geocatold.get(g.Id).Motifs_de_suspension__c) {
						Historisation__c h = new Historisation__c();
						h.actuel__c = (g.Motifs_de_suspension__c == null ? '' : g.Motifs_de_suspension__c);
						h.ancien__c = (geocatold.get(g.Id).Motifs_de_suspension__c == null ? '' : geocatold.get(g.Id).Motifs_de_suspension__c);
						h.Champs__c = 'Motifs de suspension';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}

					if (g.Utilisateur_carte_ITC__c != geocatold.get(g.Id).Utilisateur_carte_ITC__c) {
						Historisation__c h = new Historisation__c();
						for (User u : [SELECT Id, Name FROM User WHERE (Id = :g.Utilisateur_carte_ITC__c OR Id = :geocatold.get(g.Id).Utilisateur_carte_ITC__c)]) {
							if (u.Id == g.Utilisateur_carte_ITC__c)
								h.actuel__c = u.Name;
							if (u.Id == geocatold.get(g.Id).Utilisateur_carte_ITC__c)
								h.ancien__c = u.Name;
						}

						h.Champs__c = 'Dernier Utilisateur de la carte';
						h.GeoCat__c = g.Id;
						h = sourceGeocat(h, g);
						histoList.add(h);
					}
                }
			}
		}
        
        Insert histoList;
		//System.debug('TEST : historique effectué : histoList = ' + histoList);
        if (histoList.size() != 0 ) {
			checkRecursiveSFDC.runGEOCAT = false;
        }
	}

	public static Historisation__c sourceGeocat(Historisation__c his, GeoCat__c geo) {
		if (geo.Source__c == 'carte_itc') {
			his.Source__c = 'Carte ITC';
		} else {
			his.Source__c = 'Critère d\'intervention';
		}

		return his;
	}
}