public without sharing class GodSon {

	public String IdFilleul {get;set;}
	public Id IdParrain {get;set;}
	public String text {get;set;}


	public GodSon(ApexPages.StandardSetController std) {
		this.IdParrain = ApexPages.currentPage().getParameters().get('Id');
		this.text = '';
	}

	public List<SelectOption> getItems() {
	        List<SelectOption> options = new List<SelectOption>();
	        for(Account a : [SELECT Id , Name 
	        				FROM Account 
	        				WHERE Statut_global__c = 'NON CLIENT' 
	        				AND Parrain__c = null
	        				AND RecordTypeId IN (SELECT Id FROM RecordType WHERE DeveloperName LIKE '%Professionnel%')
	        				AND (SIRET_texte__c LIKE '%:text%' OR Name LIKE '%:text%')
	        				ORDER BY Name ASC]) {
	        	options.add(new SelectOption(a.Id, a.Name));
	        }
	        return options;
	}

	public PageReference save() {
		Account acc;
		for (Account a : [SELECT Id, Parrain__c FROM Account WHERE Id = :this.IdFilleul])
			acc = a;

		acc.Parrain__c = this.IdParrain;
		update acc;

		return new PageReference('/'+ this.IdParrain);
	}
}