/**
* @author Clement Musabimana
* @date 13/08/2018
* @description Batch permettant de clôturer automatiquement les requêtes du type : Motif = « Demande de Pro » - Statut = « en cours » ou « nouvelle » - Date de de création = « aujourd’hui() – 5 jours »
**/
public class Batch_Cloture_Requete implements Database.Batchable<sObject>{
	public static final String MOTIF_DEMANDE_DE_PRO = 'Motif_R_45';
	public static final String STATUT_EN_COURS = 'En cours';
	public static final String STATUT_NOUVELLE = 'Nouvelle';
	public static final String STATUT_FERMEE = 'Fermée';

   	public Database.QUERYLocator start(Database.BatchableContext BC){
   		//String dateDebutString = '14-08-2018'+' 00:00:00.000Z';
		//DateTime createdDateMoins5 = DateTime.ValueofGmt(dateDebutString.replace('T', ' ')); 
		String nbJourString = System.Label.Batch_Cloture_Requete_Period;
		Integer nbJour = Integer.valueOf(nbJourString);
		nbJour = 1 - nbJour;
		if (Test.isRunningTest()) {
			nbJour = 1;
		}
		DateTime createdDateMoins5 = (Date.today()).addDays(nbJour); // On fait moins 4 pour inclure le 5eme jour entierement
		String formattedDate = createdDateMoins5.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		System.debug('Batch_Cloture_Requete nbJour '+nbJour);
		System.debug('Batch_Cloture_Requete createdDateMoins5 '+createdDateMoins5);
   		String QUERY = 'select Id, Status from case where Motif__r.Key__c = \''+MOTIF_DEMANDE_DE_PRO+'\' and (Status = \''+STATUT_EN_COURS+'\' or Status = \''+STATUT_NOUVELLE+'\') and CreatedDate < '+formattedDate;
		System.debug('Batch_Cloture_Requete QUERY '+QUERY);
    	return Database.getQUERYLocator(QUERY);
   	}

   	public void execute(Database.BatchableContext BC, List<Case> scope){
 		for (Case requete : scope){
			requete.Status = STATUT_FERMEE;
		}  
		System.debug('Batch_Cloture_Requete scope '+scope);  	
		update scope; 
   	}

   	public void finish(Database.BatchableContext BC){

   	}

      
}