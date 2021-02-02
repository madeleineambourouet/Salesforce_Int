/**
* @author Clement Musabimana
* @date 28/06/2018
* @description Scheduler pour le batch Batch_Notations_Baazarvoice
**/
global class Batch_Notations_Baazarvoice_Schedulable implements Schedulable {

    global void execute(SchedulableContext context){
        
		Datetime date2 = Datetime.now();
		Datetime date1 = date2.addDays(-1);
		String date1String = date1.format('yyyy-MM-dd');
		String date2String = date2.format('yyyy-MM-dd');

		System.debug('Batch_Notations_Baazarvoice_Schedulable date1String '+date1String);
		System.debug('Batch_Notations_Baazarvoice_Schedulable date2String '+date2String);

        Batch_Notations_Baazarvoice batch = new Batch_Notations_Baazarvoice(date1String,date2String);
        Database.executeBatch(batch,1);
    }
}