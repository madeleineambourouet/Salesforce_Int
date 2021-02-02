public without sharing class RelatedListGeocat {
	public List<Competence__c> lComp {get;set;}

	public RelatedListGeocat(ApexPages.StandardController std) {
		GeoCat__c geo = (Geocat__c) std.getRecord();
		List<Competence__c> lCompOff = [SELECT Id, Active__c, Niveau1_Key__c, Niveau2_Key__c, Niveau_1_libelle__c, Niveau_2_libelle__c, Prix__c, Name
				FROM Competence__c
				WHERE Active__c = false
				AND Geocat__c = :geo.Id
				ORDER BY Name];
		lComp = [SELECT Id, Active__c, Niveau1_Key__c, Niveau2_Key__c, Niveau_1_libelle__c, Niveau_2_libelle__c, Prix__c, Name
				FROM Competence__c
				WHERE Active__c = true
				AND Geocat__c = :geo.Id
				ORDER BY Name];
		lComp.addAll(lCompOff);
	}
}