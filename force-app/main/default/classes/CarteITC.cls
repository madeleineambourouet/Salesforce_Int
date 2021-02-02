public without sharing class CarteITC {
	
	public GeoCat__c geo {get;set;}
	
	public CarteITC(ApexPages.StandardController std) {
		geo = [SELECT Id, LastModifiedDate FROM Geocat__c WHERE Id = :std.getId()];
	}

	public PageReference redirecto() {
		return new PageReference(System.Label.LIEN_CARTE_ITC +'user=' + UserInfo.getUserId() + '&geocat=' + geo.Id + '&lastmodifieddate=' + String.valueOf(geo.LastModifiedDate).replace(' ', 'T')+ 'z');
	}
}