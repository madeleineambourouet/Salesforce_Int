@isTest
private class Batch_MAJcreneaux_Test {

	public static String CRON_EXP = '0 26 18 29 3 ? 2022'; // from the 29/3/2022 runs monthly the 29th at 18h26

    @testSetup 
    static void setup() {
		List<Parametrage_Creneau__c> ParamSlotLst = Parametrage_Creneau__c.getall().values();
		Parametrage_Creneau__c ParamSlot = Parametrage_Creneau__c.getvalues('Creneau Part. de Mars 2017');

		Integer iter_heures = 12; // 8h - 20h = 12 heures
		Integer ouverture_crc = 8; // ouverture crc à 8h
		Integer duree_slot = 60;
		Integer nb_slot = Integer.valueOf(Math.floor((iter_heures *60) / duree_slot)); 

		Integer iter_jours = 7; // definition sur une semaine
		String jour, nom;
		Boolean Actif;
		Integer quota;

		List<Def_Creneau__c> reftimeslotLst = new List<Def_Creneau__c>();

		Datetime myDate_debut , myDate_fin;

		for(Integer i=0;i<iter_jours;i++) {

			String si = String.valueOf(i);

			while (si.length() < 2) {
				si = '0' + si;
			}

			if (si == '00') {
				jour='Dimanche';
				Actif =false;
				nom = 'Dim';
				quota = 0;
			} else if (si == '01') {
				jour='Lundi';
				Actif =true;
				nom = 'Lun';
				quota = 5;
			} else if (si == '02') {
				jour='Mardi';
				Actif =true;
				nom = 'Mar';
				quota = 5;
			} else if (si == '03') {
				jour='Mercredi';
				Actif =true;
				nom = 'Mer';
				quota = 5;
			} else if (si == '04') {
				jour='Jeudi';
				Actif =true;
				nom = 'Jeu';
				quota = 5;
			} else if (si == '05') {
				jour='Vendredi';
				Actif =true;
				nom = 'Ven';
				quota = 5;
			} else if (si == '06') {
				jour='Samedi';
				Actif =false;
				nom = 'Sam';
				quota = 0;
			}

			myDate_debut = DateTime.newInstance(2017, 9, 1, ouverture_crc, 0, 0);
			myDate_fin = myDate_debut.addMinutes(duree_slot);


			for(Integer j=0;j<nb_slot;j++) {
				String sj = String.valueOf(j);
				while (sj.length() < 3) {sj = '0' + sj;}

				Def_Creneau__c timeslot = new Def_Creneau__c(Libelle__c = 'J'+si+'-'+sj, Actif__c = Actif, 
				Jour_de_la_semaine__c = jour, Heure_Debut__c=myDate_debut.format('HH')+'h'+myDate_debut.format('mm'), 
					Heure_Fin__c=myDate_fin.format('HH')+'h'+myDate_fin.format('mm'), 
						Quota__c=quota, Groupe_Odigo__c='Accueil Client Part.');
				reftimeslotLst.add(timeslot);
				myDate_debut = myDate_debut.addMinutes(duree_slot);
				myDate_fin = myDate_fin.addMinutes(duree_slot);
			}
		}
		upsert(reftimeslotLst);

  
    }
    
    static testmethod void testScheduledJob() {

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Scheduled Batch_MAJcreneaux ApexTest', CRON_EXP, new Batch_MAJcreneaux());         
        Test.stopTest();

		List<Creneau__c> timeslotLst = new List<Creneau__c>();
		timeslotLst = [SELECT Id FROM Creneau__c WHERE Groupe_Odigo__c = 'Accueil Client Part.'];
		system.debug('timeslotLst : '+timeslotLst.size());
		system.assert(timeslotLst.size()==60);        
    	
    }

}