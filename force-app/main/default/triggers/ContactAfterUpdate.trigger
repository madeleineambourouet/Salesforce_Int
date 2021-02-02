trigger ContactAfterUpdate on Contact (after update) 
{
    // Bypass trigger if Bypass_trigger_ContactAfterUpdate__c ticked on the current user
    User currentUser = [SELECT Bypass_trigger_ContactAfterUpdate__c FROM User WHERE Id =: UserInfo.getUserId()];
    if (currentUser != null && currentUser.Bypass_trigger_ContactAfterUpdate__c == false)
    {
        
        // Get the list of Contact matching the criteria to send to the BUS WS.
        List<Id> lContactToSend = new List<Id>();
        for (Contact con : Trigger.new)
        {
            if (
                ( con.Salutation != trigger.oldmap.get(con.Id).Salutation ||
                  con.Firstname != trigger.oldmap.get(con.Id).Firstname ||
                  con.Lastname != trigger.oldmap.get(con.Id).Lastname ||
                  con.Email != trigger.oldmap.get(con.Id).Email ||
                  con.Phone != trigger.oldmap.get(con.Id).Phone ||
                  con.MobilePhone != trigger.oldmap.get(con.Id).MobilePhone ||
                  con.Adresse1__c != trigger.oldmap.get(con.Id).Adresse1__c ||
                  con.Code_postal_lkp__c != trigger.oldmap.get(con.Id).Code_postal_lkp__c ||
                  con.Pays_lkp__c != trigger.oldmap.get(con.Id).Pays_lkp__c ||
                  con.Contact_Principal_O_N__c != trigger.oldmap.get(con.Id).Contact_Principal_O_N__c ||
                  con.Contact_de_facturation__c != trigger.oldmap.get(con.id).Contact_de_facturation__c
                )
                &&
                ( con.Contact_Principal_O_N__c == true || con.Contact_de_facturation__c == true)
               )
            {
                lContactToSend.add(con.Id);
            }
        }

        // If contact to send to the BUS WS
        if (lContactToSend != null && !lContactToSend.isEmpty())
        {
            // Send the contacts to the WS handler method
            BUSWSHandler.wsContactUpdateHandler(lContactToSend);
        }
    }
}