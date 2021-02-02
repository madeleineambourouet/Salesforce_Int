public class GeocatListWrapper {
	public List<geocatUnit> geocatunit {get;set;}
	public List<Geocat__c> geocats {get;set;}
	public Map<Id, Integer> match {get;set;}
	public Map<Id, Integer> mer {get;set;}
	public Integer rejet {get;set;}

	public GeocatListWrapper() {
		this.geocatunit = new List<geocatUnit>();
	}

	public class geocatUnit {
		public Geocat__c geo {get;set;}
		public Decimal countMatch {get;set;}
		public Decimal countMer {get;set;}
		public Decimal pAlimentation {get;set;}
		public Decimal pSelection {get;set;}
		public Integer multiple {get;set;}

		public geocatUnit(Geocat__c geocat, Integer nbrMatch, Integer nbrMer, Integer mul) {
			this.geo = geocat;
			this.countMatch =(Decimal) nbrMatch;
			this.countMer = (Decimal) nbrMer;
			this.multiple = mul;
			calculate();
		}

		public void calculate() {
			if (this.countMatch > 0) {
				this.pSelection = (this.countMer / this.countMatch).setscale(2) * 100;
			system.debug('TEST : calculate : this.pSelection = ' + this.pSelection);
			system.debug('TEST : calculate : this.countMer = ' + this.countMer);
			system.debug('TEST : calculate : this.countMatch = ' + this.countMatch);

			} else {
				this.pSelection = 0;
			}

			if(this.countMer > 0 && this.geo.DDP__c > 0) {
				this.pAlimentation =  (this.countMer / (this.geo.DDP__c * this.multiple)).setscale(2) * 100 ;
			} else {
				this.pAlimentation = 0;
			}
		}

	}

	public void initGeo(Integer mul) {
		for (Geocat__c g : geocats)
		{	
			Integer mertmp = 0;
			Integer matchtmp = 0;

			if (this.match.containsKey(g.Id)) 
				matchtmp = this.match.get(g.Id);

			if (this.mer.containsKey(g.Id))
				mertmp = this.mer.get(g.Id);

			this.geocatunit.add(new geocatUnit(g,matchtmp,mertmp,mul));


		}
	}
}