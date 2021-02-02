trigger GeoCatTrigger on GeoCat__c (before insert, after insert, before update, after update, before delete, after delete) 
{   
    // BEFORE INSERT
    if (trigger.isInsert && trigger.isBefore)
    {
        GeoCatMethods.setAccountWithContact(trigger.new);
        GeoCatMethods.calculateTechTextQuote(trigger.new);    
    }
    
    // AFTER INSERT
    if (trigger.isInsert && trigger.isAfter)
    {
        GeoCatMethods.calculateNBGeocatOnAccount(trigger.new);
    }
    
    // BEFORE UPDATE
    if (trigger.isUpdate && trigger.isBefore)
    {
        GeoCatMethods.setAccountWithContact(trigger.new);
        GeoCatMethods.calculateCategories(trigger.new);
        GeoCatMethods.calculateExclusion(trigger.new);
        GeoCatMethods.calculateTechTextQuote(trigger.new);
    }

    // AFTER UPDATE
    if (trigger.isUpdate && trigger.isAfter)
    {
        GeoCatMethods.calculateNBGeocatOnAccount(trigger.new);
    }
    
    // BEFORE DELETE
    if (trigger.isDelete && trigger.isBefore)
    {
        GeoCatMethods.checkIfNotLastGeocat(trigger.old);
    }
    
    // AFTER DELETE
    if (trigger.isDelete && trigger.isAfter)
    {
        GeoCatMethods.calculateNBGeocatOnAccount(trigger.old);
    }    
}