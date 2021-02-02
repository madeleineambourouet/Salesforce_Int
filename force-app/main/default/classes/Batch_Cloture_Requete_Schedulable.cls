/**
* @author Clement Musabimana
* @date 14/08/2018
* @description Scheduler pour le batch Batch_Cloture_Requete
**/
public class Batch_Cloture_Requete_Schedulable implements Schedulable {

    public void execute(SchedulableContext context){
        Batch_Cloture_Requete batch = new Batch_Cloture_Requete();
        Database.executeBatch(batch,1);
    }
}