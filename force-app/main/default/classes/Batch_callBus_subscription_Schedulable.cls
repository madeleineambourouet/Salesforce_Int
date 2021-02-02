/**
* @author Clement Musabimana
* @date 13/03/2019
* @description Scheduler Gestion de l'activation et suspension des services de souscription par le biais du BUS
**/
public class Batch_callBus_subscription_Schedulable implements Schedulable {
	
	public void execute(SchedulableContext context) {
		Date dateDebut = Date.today();
		DateTime todayDateTime = dateDebut;
		String dateDebutString = todayDateTime.formatGMT('yyyy-MM-dd');
		system.debug('Batch_callBus_subscriptionService dateDebutString '+dateDebutString);
        Batch_callBus_subscriptionService b = new Batch_callBus_subscriptionService(dateDebutString); 
        database.executebatch(b);
    }
}