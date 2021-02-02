// 
// Trigger pour créer et gérer les rappels
// 22/04/2017, Leila  Bouaifel, fonction pour maj du champ réservation sur les créneaux    
// 12/05/2017, xavier templet, modification pour récupérer l'id odigo du rappel et pouvoir l'annuler
// 22/05/2017, xavier templet, ajout du trigger after update pour comptabiliser le nombre de rappel sur un projet  

trigger Trigger_Rappel on Rappel__c (after insert, before delete, after update) {

	List<Parametrage_Creneau__c> ParamSlotLst = Parametrage_Creneau__c.getall().values();
	Parametrage_Creneau__c ParamSlot = Parametrage_Creneau__c.getvalues('Creneau Part. de Mars 2017');
	Integer iter_jours;
	if(!Test.isRunningTest()) iter_jours = Integer.valueOf(ParamSlot.Taille_Planning_Creneaux__c); // 14 jours 
	else iter_jours = 7; // 7 jours
	DateTime myDate = datetime.now();
	DateTime myEndDate = myDate.addDays(iter_jours);


	/////// TRIGGER after insert    
	if (Trigger.isAfter && Trigger.isInsert) {	
		for(Rappel__c obj: Trigger.new) { 
	        //system.debug('>>>>>>>> Trigger rappel after insert ' + obj);

			///// Creation d'un rappel dans odigoCTI
	        if(obj.No_de_Rappel__c != null && obj.No_de_Rappel__c != '') {
				//RappelUpdateWS.SaveCallBackOdigo(obj.No_de_Rappel__c, obj.Queue_Odigo__c, obj.Id, obj.Date_Horaire__c);
			    RappelUpdateWS.SaveCallBackOdigo2(obj.No_de_Rappel__c, obj.Queue_Odigo__c, obj.Id, obj.Date_Horaire__c, obj.Type_de_demande__c);
			}
    		else system.debug('Trigger_Rappel: No de Rappel is missing !!! Rappel ID is ' + obj.Id);
		}
    }

	////// TRIGGER after update
	if (Trigger.isAfter && Trigger.isUpdate) {
		String typeCreneau;
		List<Creneau__c> CreneauxMAJ = new List<Creneau__c>();
		for(Rappel__c obj: Trigger.new) { 

			//System.debug('>>>>>> rappel update ' + obj);
	        Rappel__c oldr = Trigger.oldMap.get(obj.Id);

	        if (obj.Queue_Odigo__c == 'accueil_com')
	        	typeCreneau = 'Accueil Client Pro.';
	        else
	        	typeCreneau = 'Accueil Client Part.';

        	// Nouveau rappel programmé
        	if (oldr.Statut_CTI__c != obj.Statut_CTI__c && obj.Statut_CTI__c == 'Planifié') {
        		if (obj.Projet__c != null) {
        			Projet__c prj = [SELECT Id, Nombre_de_rappels__c FROM Projet__c WHERE Projet__c.Id = :obj.Projet__c];
        			if (prj != null) {
        				if (prj.Nombre_de_rappels__c == null) prj.Nombre_de_rappels__c = 1; else prj.Nombre_de_rappels__c = prj.Nombre_de_rappels__c +1;
        				update prj;
        			}
        		}
				// Pour maj de la reservation il faut que la date / heure corresponde à un créneau  
    	    	if (obj.Date_Horaire__c != null)  {          
	        		Creneau__c C = [SELECT Id, Reservations__c, Name, Date_Horaire__c FROM Creneau__c 
	        								WHERE Date_Horaire__c = :obj.Date_Horaire__c
	        								AND Groupe_Odigo__c =:typeCreneau LIMIT 1];
					if (C != null) {       
    	            	C.Reservations__c = C.Reservations__c +1;
        	        	CreneauxMAJ.add(C);
        			}
	        	}
        	}

			// Rappel annulé
        	else if (oldr.Statut_CTI__c != obj.Statut_CTI__c && obj.Statut_CTI__c == 'Supprimé') {
        		if (obj.Projet__c != null) {
	        		Projet__c prj = [SELECT Id, Nombre_de_rappels__c FROM Projet__c WHERE Projet__c.Id = :obj.Projet__c];
	        		if (prj != null) {
    	    			if (prj.Nombre_de_rappels__c == null) prj.Nombre_de_rappels__c = 0; else prj.Nombre_de_rappels__c = prj.Nombre_de_rappels__c -1;
        				update prj;
	        		}
        		}

				// Pour maj de la reservation il faut que la date / heure corresponde à un créneau  
    	    	if (oldr.Statut_CTI__c == 'Planifié' && obj.Date_Horaire__c != null  && 
    	    			obj.Date_Horaire__c.date() >= myDate.date() && obj.Date_Horaire__c.date() <= myEndDate.date())  {          
	        		Creneau__c C = [SELECT Id, Reservations__c, Name, Date_Horaire__c FROM Creneau__c 
	        								WHERE Date_Horaire__c = :obj.Date_Horaire__c
	        								AND Groupe_Odigo__c =:typeCreneau LIMIT 1];
					if (C != null) {       
    	            	C.Reservations__c = C.Reservations__c -1;
        	        	CreneauxMAJ.add(C);
        			}
	        	}
        	}
        	
			// Rappel déjà en attente avec le meme no,  pas de nouveau WCB possible dans odigo
        	else if (oldr.Statut_CTI__c != obj.Statut_CTI__c && obj.Statut_CTI__c == 'Déjà Existant') 
        		if (obj.Projet__c != null) {
	        		Projet__c prj = [SELECT Id, Nombre_de_rappels__c FROM Projet__c WHERE Projet__c.Id = :obj.Projet__c];
	        		if (prj != null) {
    	    			if (prj.Nombre_de_rappels__c == null) prj.Nombre_de_rappels__c = 0; else prj.Nombre_de_rappels__c = prj.Nombre_de_rappels__c +1;
        				update prj;
	        		}
        		}
		}

		if(CreneauxMAJ.size() > 0) update CreneauxMAJ;
		
	}  

	/////// TRIGGER after delete    
	if (Trigger.isDelete) {
		List<Creneau__c> CreneauxMAJ = new List<Creneau__c>();
		String typeCreneau;

		for(Rappel__c obj: Trigger.old) {

			if (obj.Queue_Odigo__c == 'accueil_com')
	        	typeCreneau = 'Accueil Client Pro.';
	        else
	        	typeCreneau = 'Accueil Client Part.';
			if (obj.CallBack_Reference__c != null && obj.CallBack_Reference__c != '') {
				RappelUpdateWS.changeStatusCallBackOdigoAfterDelete(obj.CallBack_Reference__c);

        		if (obj.Projet__c != null && obj.Statut_CTI__c != 'Supprimé' ) {
	        		Projet__c prj = [SELECT Id, Nombre_de_rappels__c FROM Projet__c WHERE Projet__c.Id = :obj.Projet__c];
	        		if (prj != null) {
    	    			if (prj.Nombre_de_rappels__c == null) prj.Nombre_de_rappels__c = 0; else prj.Nombre_de_rappels__c = prj.Nombre_de_rappels__c -1;
        				update prj;
	        		}
        		}

				// Pour maj de la reservation il faut que la date / heure corresponde à un créneau  
    	    	if (obj.Statut_CTI__c == 'Planifié' && obj.Date_Horaire__c != null && 
    	    			obj.Date_Horaire__c.date() >= myDate.date() && obj.Date_Horaire__c.date() <= myEndDate.date())  {          

	        		Creneau__c C = [SELECT Id, Reservations__c, Name, Date_Horaire__c FROM Creneau__c 
	        								WHERE Date_Horaire__c = :obj.Date_Horaire__c
	        								AND Groupe_Odigo__c =:typeCreneau LIMIT 1];
					if (C != null) {       
    	            	C.Reservations__c = C.Reservations__c -1;
        	        	CreneauxMAJ.add(C);
        			}
	        	}

			}
		}
		if(CreneauxMAJ.size() > 0) update CreneauxMAJ;
		
	}	
}