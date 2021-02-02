trigger CompetenceTrigger on Competence__c (after insert, after update, before delete, after delete) 
{
    /**
    // BEFORE INSERT
    if (trigger.isInsert && trigger.isAfter)
    {
        CompetenceMethods.calculateCategorie(trigger.new);
    }
    
    // BEFORE UPDATE
    if (trigger.isUpdate && trigger.isafter)
    {
        CompetenceMethods.calculateCategorie(trigger.old);
    }
    **/
    
    // BEFORE DELETE
    if (trigger.isDelete && trigger.isBefore)
    {
        CompetenceMethods.checkIfNotLastCompetence(trigger.old);
    }
    
    /**
    // AFTER DELETE
    if (trigger.isDelete && trigger.isAfter)
    {
        CompetenceMethods.calculateCategorie(trigger.old);
    }
    **/
}