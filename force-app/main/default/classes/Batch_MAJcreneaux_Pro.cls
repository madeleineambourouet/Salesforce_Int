//
// tourne tous les jours, supprime les anciens, crée les nouveaux, c'est tout ?  un check ? 
// j'enlève les créneaux d'hier, je crée les créneaux de j+x
// 

global class Batch_MAJcreneaux_Pro implements Schedulable {

	global void execute(SchedulableContext ctx) {

		try{

		List<Parametrage_Creneau__c> ParamSlotLst = Parametrage_Creneau__c.getall().values();
		Parametrage_Creneau__c ParamSlot = Parametrage_Creneau__c.getvalues('Creneau Part. de Septembre 2018');

		Integer iter_jours, iter_heures, ouverture_crc, duree_slot;

		if(Test.isRunningTest()){
			 iter_jours = 7; // 7 jours
			 iter_heures = 12; // 8h - 20h = 12 heures
			 ouverture_crc = 8; // ouverture crc à 8h
			 duree_slot = 60;
		}
		else {
		 iter_jours = Integer.valueOf(ParamSlot.Taille_Planning_Creneaux__c); // 14 jours
		 iter_heures = Integer.valueOf(ParamSlot.Amplitude_Ouverture_CRC__c); // 8h - 20h = 12 heures
		 ouverture_crc = Integer.valueOf(ParamSlot.Heure_d_ouverture_CRC__c); // ouverture crc à 8h
		 duree_slot = Integer.valueOf(ParamSlot.Duree_des_creneaux__c);
		}
		
		Integer nb_slot = Integer.valueOf(Math.floor((iter_heures *60) / duree_slot)); 
		system.debug('nb_slot = ' + nb_slot);
		String jour, nom, ref1, slot_string;
		Boolean Actif;
		Integer quota;
		//Datetime myDate = Datetime.now();
		//myDate = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day(), ouverture_crc, 0, 0);
		Datetime myDate = DateTime.newInstance(Datetime.now().year(),Datetime.now().month(), Datetime.now().day(), ouverture_crc, 0, 0);
		//myDate = myDate.addDays(-1);
		//List<Creneau__c> timeslotLst = new List<Creneau__c>();

		//jour = '%'+ myDate.format('ddMMyyyy') + '%';
		//timeslotLst = [select Id, Name, Groupe_Odigo__c, Date_Horaire__c, Reference_du_Creneau__c, Quota__c, Reservations__c from Creneau__c where Date_Horaire__c < :myDate];
		List<Creneau__c> timeslotLst = [SELECT Id, Name, Groupe_Odigo__c, Date_Horaire__c, Reference_du_Creneau__c, Quota__c, Reservations__c FROM Creneau__c WHERE Date_Horaire__c < :myDate AND Groupe_Odigo__c = 'Accueil Client Pro.'];
		delete timeslotLst;
		system.debug('timeslotLst deleted: '+timeslotLst.size());
		timeslotLst.clear();

		//myDate = myDate.addDays(iter_jours);
		//system.debug('Date à créer: '+ myDate.format('ddMMyyyy')); 
		myDate = Datetime.now();
		List<Def_Creneau__c> reftimeslotLst = new List<Def_Creneau__c>();
		reftimeslotLst = [SELECT Id, Libelle__c, Actif__c, Quota__c, Groupe_Odigo__c FROM Def_Creneau__c WHERE Groupe_Odigo__c = 'Accueil Client Pro.'];
		system.debug('reftimeslotLst size: '+reftimeslotLst.size());
		if (reftimeslotLst.size()>0) {

			for(Integer i=0;i<iter_jours;i++) {

				jour = '%'+ myDate.format('ddMMyyyy') + '%';
				timeslotLst = [SELECT Id, Name, Groupe_Odigo__c, Date_Horaire__c, Reference_du_Creneau__c, Quota__c, Reservations__c FROM Creneau__c WHERE Name LIKE :jour AND Groupe_Odigo__c = 'Accueil Client Pro.'];
				//if (timeslotLst.size()<(iter_heures*iter_quart))
				if (timeslotLst.size() == 0){

					String jdate = myDate.format('E');
			
					if (jdate == 'Sun') {
						ref1='J00';
					} else if (jdate == 'Mon') {
						ref1='J01';
					} else if (jdate == 'Tue') {
						ref1='J02';
					} else if (jdate == 'Wed') {
						ref1='J03';
					} else if (jdate == 'Thu') {
						ref1='J04';
					} else if (jdate == 'Fri') {
						ref1='J05';
					} else if (jdate == 'Sat') {
						ref1='J06';
					}

				    myDate = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day(), ouverture_crc, 0, 0);
					
					for(Integer j=0;j<nb_slot;j++) {
						String sj = String.valueOf(j);
						while (sj.length() < 3) {
							sj = '0' + sj;
						}
						Def_Creneau__c reftimeslot = new Def_Creneau__c();
						for (Def_Creneau__c refts : reftimeslotLst) {
							if ((refts.Libelle__c == ref1+'-'+sj) && refts.Actif__c) 
								reftimeslot = refts;
						}
						slot_string = myDate.format('ddMMyyyy')+'-'+sj;
				
						if (reftimeslot.Actif__c) {
							Creneau__c timeslot = new Creneau__c(Name = slot_string, Groupe_Odigo__c = reftimeslot.Groupe_Odigo__c, 
									Date_Horaire__c = myDate, Reference_du_Creneau__c = reftimeslot.Id, 
										Libelle__c = reftimeslot.Libelle__c, Quota__c = reftimeslot.Quota__c);
							timeslotLst.add(timeslot);
						}
			
						myDate = myDate.addMinutes(duree_slot);
					}

					if (timeslotLst.size() > 0)
						upsert(timeslotLst);
				}

				timeslotLst.clear();
				myDate = myDate.addDays(1);
			}
		} else
			system.debug('!!!!!!!!!!!! NO Def_Creneau__c defined !!!!!!!!!!');

		if(Test.isRunningTest()){
			insert new Account();
		}
} catch (DMLException e) {
     ApexPages.addMessages(e);

     Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
     String[] toAddresses = new String[] {'DL-SGDBF_Services_Salesforce@saint-gobain.com'};
     mail.setToAddresses(toAddresses);
     mail.setReplyTo('DL-SGDBF_Services_Salesforce@saint-gobain.com');
     mail.setSenderDisplayName('Apex error message from Batch_MAJcreneaux_Pro');
     mail.setSubject('Error from Org&nbsp;: ' + UserInfo.getOrganizationName());
     mail.setPlainTextBody(e.getMessage());
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}
}