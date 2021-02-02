trigger OnOdigoTaskCreation on Task (before insert, after insert, after update, after delete) {
    if (trigger.isBefore && trigger.isInsert) {
        for (Task t: Trigger.new){
            if(t.status.equals('Completed')){
                t.status = 'Achevée';
            }
        }
    }
    
    /*if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete)) {
        
        TaskMethods.calculateNumberTask(trigger.old, trigger.new);
    } */
}