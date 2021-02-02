trigger HistorisationGeocat on Geocat__c (after update) {
	HistorisationGeocatTrigger.GetBackChanges(trigger.new, trigger.oldMap);
}