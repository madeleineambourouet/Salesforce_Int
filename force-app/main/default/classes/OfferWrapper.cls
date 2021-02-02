public with sharing class OfferWrapper {
	public Zuora__SubscriptionProductCharge__c offreHOM{get;set;}
	public List<Zuora__SubscriptionProductCharge__c> serviceHomly{get;set;}
	public Boolean geosuspension {get;set;}
	public String NameHOM {get;set;}
	public String CreatedDateHOM {get;set;}
	public String EffectiveStartDateHOM {get;set;}
	public String EffectiveEndDateHOM {get;set;}
	public List<ServiceHomly> serviceList {get;set;}

	public OfferWrapper()
	{
		this.NameHOM = '';
		this.EffectiveStartDateHOM = '';
		this.EffectiveEndDateHOM = '';
		this.serviceHomly = new List<Zuora__SubscriptionProductCharge__c>();
	}

	public void init()
	{
		if (this.offreHOM != null)
			{
				this.NameHOM = this.offreHOM.Name ;
				this.EffectiveStartDateHOM = (this.offreHOM.Zuora__EffectiveStartDate__c != null ? this.offreHOM.Zuora__EffectiveStartDate__c.format() : '');
				this.EffectiveEndDateHOM = (this.offreHOM.Zuora__EffectiveEndDate__c != null ? this.offreHOM.Zuora__EffectiveEndDate__c.format() : '');
				this.CreatedDateHOM = this.offreHOM.CreatedDate.format();
			}

		//if(this.offreCAP != null)
		//	{
		//		this.NameCAP = this.offreCAP.Name ;
		//		this.EffectiveStartDateCAP = (this.offreCAP.Zuora__EffectiveStartDate__c != null ? this.offreCAP.Zuora__EffectiveStartDate__c.format() : '');
		//		this.EffectiveEndDateCAP = (this.offreCAP.Zuora__EffectiveEndDate__c != null ? this.offreCAP.Zuora__EffectiveEndDate__c.format() : '');
		//		this.CreatedDateCap = this.offreCAP.CreatedDate.format('dd/MM/yyyy');
		//	}
		if (this.serviceHomly.size() > 0) {
			for (Zuora__SubscriptionProductCharge__c spc : this.serviceHomly) {
				ServiceHomly sh = new ServiceHomly();
				sh.Name = spc.Name;
				sh.CreatedDate = spc.CreatedDate.format();
				sh.EffectiveStartDate = (spc.Zuora__EffectiveStartDate__c != null ? spc.Zuora__EffectiveStartDate__c.format() : '');
				sh.EffectiveEndDate = (spc.Zuora__EffectiveEndDate__c != null ? spc.Zuora__EffectiveEndDate__c.format() : '');
				serviceList.add(sh);
			}
		}
	}

	public class ServiceHomly {

		public String Name {get;set;}
		public String CreatedDate {get;set;}
		public String EffectiveStartDate {get;set;}
		public String EffectiveEndDate {get;set;}
	}
}