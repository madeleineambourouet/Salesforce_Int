/**
 * @File Name          : Synchronization_Data_Checker_Scheduler.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/5/2020, 7:35:35 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/5/2020   Hassan Dakhcha     Initial Version
**/
global class Synchronization_Data_Checker_Scheduler implements Schedulable {
  
    public void execute(SchedulableContext context) {
        Synchronization_Data_Checker b = new Synchronization_Data_Checker('ACCOUNT'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('CONTACT'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('METIER'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('DEPARTEMENT'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('PRESTATION'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('PART'); 
        database.executebatch(b);
        b = new Synchronization_Data_Checker ('PROJET'); 
        database.executebatch(b);
      }
}