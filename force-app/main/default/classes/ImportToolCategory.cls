/*
Auteur: Fred MBoungou
Description: Classe permettant la migration des catégories partenaires sur les projets
*/

public with sharing class ImportToolCategory {
	 public Blob contentFile {get;set;}
	 public String contentLog {get;set;}
	 public string nameFile {get;set;}
	 public List<Projet__c> projets {get;set;}
	 public Date date_debut {get;set;}
	 String[] filelines = new String[]{};
	 String[] filecode = new String[]{};
	 RecordType idRecordTypeCat;
	 Map<String, String> couple;

	 /*
	 Fonction principale, elle lit le fichier passé dans l'input
	 */
	 private Boolean ReadFile() {
	 	system.debug('TITLE : FILE ' + nameFile);
	 	if (contentFile != null && nameFile.right(4) == '.csv' ){
			 	idRecordTypeCat = [SELECT  Id FROM RecordType WHERE  DeveloperName = 'Categorie' LIMIT 1];
			 	couple = new Map<String, String>();
			 	nameFile=contentFile.toString();
			 	filelines = nameFile.split('\n');

			 	if (filelines.size() >= 2) {
				 	for (Integer i = 1;  i < filelines.size(); i++) {
				 	 	couple.put(filelines[i].split(';')[0], filelines[i].split(';')[1].left(4));
				 	}
				return true;
				} else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Le fichier doit comporter au moins une ligne hors en-tête'));
					return false;
				} 
		} else {
			if (contentFile == null)
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Veuillez selectionner un fichier'));
			else if (nameFile.right(4) != '.csv')
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Le fichier doit être au format CSV'));

			return false;
		}

	 }

	/*
	Fonction qui met a jour les nouvelles catégories par rapport aux anciennes sur les projets
	*/
	public Pagereference UpsertCategorie() {
	  	
	  	//List<Projet__c> projets;
	  	List<Reference__c> oldcat;
	  	List<Reference__c> newcat;
	  	List<Reference__c> categorie_up = new List<Reference__c>();
	  	Map<String,Reference__c> oldcatmap = new Map<String,Reference__c>();
	  	Map<String,Reference__c> newcatmap = new Map<String,Reference__c>();

	  	//Date dt = Date.newInstance(2017, 1, 1);
	  	//Date dt = Date.newInstance(Integer year, Integer month, Integer day);

	  	system.debug('TEST : UpsertCategorie : date_debut = ' + date_debut);
	  	system.debug('TEST : UpsertCategorie :  UserInfo.getLocale() = ' + UserInfo.getLocale());

	  	if (ReadFile()) {
	  		contentLog = 'Id;Name;Code_categorie__c;Name_categorie;Quand\n';
		  	projets = [SELECT Id, Name, Categorie_lkp__c, Code_categorie__c,Categorie_lkp__r.Key__c, Categorie_lkp__r.Name
		  								FROM Projet__c
		  								WHERE CreatedDate >= :date_debut
		  								AND ((MER_selectionnees_1_filtre__c >= 1) OR (Etat__c != 'ODC close' AND Etat__c != 'Contact part clos'))
		  								AND Categorie_lkp__c IN (SELECT Id FROM Reference__c WHERE RecordTypeId = :idRecordTypeCat.Id AND Key__c IN :couple.keyset())];
		  								
		  	contentLog += contentCSV(projets, 'Avant');
		  	system.debug('TEST FRED : projets' + projets);
		  	oldcat = [SELECT Id, Key__c 
		  						FROM Reference__c 
		  						WHERE RecordTypeId = :idRecordTypeCat.Id
		  						AND Key__c IN :couple.keyset()];
		  	if (projets.size() == 0) {
		  		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Il n\'y a aucuns projets contenant les catégories dites sources'));
				return null;
		  	} else if(date_debut == null) {
		  		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Veuillez renseigner une date au format locale'));
				return null;
		  	} else {

			  	Set<String> couple_values = new Set<String>(couple.values());

			  	newcat = [SELECT Id, Key__c 
			  						FROM Reference__c 
			  						WHERE RecordTypeId = :idRecordTypeCat.Id
			  						AND Key__c IN :couple_values];
			  	system.debug('TEST : ImportToolCategory : UpsertCategorie : newcat = ' + newcat);
			  	for (Reference__c r : oldcat){
			  		oldcatmap.put(r.Key__c, r);}

			  	for (Reference__c r : newcat){
			  		newcatmap.put(r.Key__c, r);}
			  	system.debug('TEST : ImportToolCategory : UpsertCategorie : newcatmap = ' + newcatmap);


			  	for (Projet__c p : projets){
			  		if(oldcatmap.containsKey(p.Code_categorie__c)) {
			  			system.debug('TEST : ImportToolCategory : UpsertCategorie : oldcatmap.get(p.Code_categorie__c) = ' +  oldcatmap.get(p.Code_categorie__c) );
			  			categorie_up.add(oldcatmap.get(p.Code_categorie__c));
			  			system.debug('TEST : ImportToolCategory : UpsertCategorie : newcatmap.get(p.Code_categorie__c) = ' +  newcatmap.get(p.Code_categorie__c) );
			  			if (newcatmap.get(couple.get(p.Code_categorie__c)) != null)
			  				p.Categorie_lkp__c = newcatmap.get(couple.get(p.Code_categorie__c)).Id;
			  			//p.Code_categorie__c.calculatedValue();
			  		}
			  	}
			  	update projets;
			  	projets = [SELECT Id, Name, Categorie_lkp__c, Code_categorie__c,Categorie_lkp__r.Key__c, Categorie_lkp__r.Name
			  								FROM Projet__c
			  								WHERE Id IN :projets];

			  	system.debug('TEST : FRED : projets ' + projets);
			  	contentLog += contentCSV(projets, 'Apres');

			  	PageReference reRend = new PageReference('/apex/DownloadCSV');
    			reRend.setRedirect(false);
				return reRend;
			  }

		  } else {
		  		return null;
		  }

		
	  }

	  private String contentCSV(List<Projet__c> projets, String sequence) {
	  	String content = '';
	  	for (Projet__c p : projets) {
	  		content += p.Id + ';' + p.Name + ';' + p.Categorie_lkp__r.Key__c + ';' + p.Categorie_lkp__c + ';' + p.Categorie_lkp__r.Name +';' + sequence + '\n';
	  	}

	  	return content;
	  }
}