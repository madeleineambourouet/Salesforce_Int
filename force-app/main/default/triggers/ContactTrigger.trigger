/**
 * @File Name          : ContactTrigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 09-08-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/19/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger ContactTrigger on Contact (before insert, before update, after Insert, after Update, before delete) {
    
    
    if (Trigger.isInsert && Trigger.isBefore ) {
        contactMethods.setIsUpdatedBySF(Trigger.New);
        ContactMethods.copyMailAdress(Trigger.new, true);        
        contactMethods.AttachHKConnectContactToAccount(Trigger.new);
        ContactMethods.checkContactPrincipal(Trigger.new);
        ContactMethods.setAccountDoNotCall(Trigger.new);
        
    }
    //AJOUT LEILA
    if (Trigger.isAfter && Trigger.isInsert) {
        ContactMethods.InsertContactPrincipal(Trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        
        // set modified by SF
        contactMethods.setIsUpdatedBySF(Trigger.New);

        List<Contact> toUpdatePrincipal = new List<Contact>();
        List<Contact> toUpdateDoNotCall = new List<Contact>();
        List<Contact> toUpdateEmail     = new List<Contact>();
        for (Contact ctc : Trigger.new){
            if (
                (Trigger.oldMap.get(ctc.id).Contact_Principal_O_N__c != Trigger.newMap.get(ctc.id).Contact_Principal_O_N__c
                 && Trigger.newMap.get(ctc.id).Contact_Principal_O_N__c == true)
                || (Trigger.newMap.get(ctc.id).Contact_Principal_O_N__c == true 
                    && Trigger.oldMap.get(ctc.id).Email != Trigger.newMap.get(ctc.id).Email)
                || (Trigger.oldMap.get(ctc.id).Contact_de_facturation__c != Trigger.newMap.get(ctc.id).Contact_de_facturation__c
                    && Trigger.newMap.get(ctc.id).Contact_de_facturation__c == true)
                || (Trigger.newMap.get(ctc.id).Contact_de_facturation__c == true 
                    && Trigger.oldMap.get(ctc.id).Email != Trigger.newMap.get(ctc.id).Email)
            ) { toUpdatePrincipal.add(ctc); }
            if (Trigger.oldMap.get(ctc.id).DoNotCall != Trigger.newMap.get(ctc.id).DoNotCall) { toUpdateDoNotCall.add(ctc); }
            if (Trigger.oldMap.get(ctc.id).Email != Trigger.newMap.get(ctc.id).Email) { toUpdateEmail.add(ctc);}
        }
        
        System.debug('>>>>>>>>>>>> UPDATE NE PAS RAPPELER ' + toUpdateDoNotCall);
        
        if (toUpdatePrincipal.size() > 0) {ContactMethods.checkContactPrincipal(toUpdatePrincipal);}
        if (toUpdateDoNotCall.size() > 0) {ContactMethods.setAccountDoNotCall(toUpdateDoNotCall);}
        if (!toUpdateEmail.isEmpty())  {ContactMethods.copyMailAdress(toUpdateEmail, false);} 
        
        // Before update of the new email from the Project Place
        ProjectPlaceWS.emailChangeCompletedPro(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isUpdate && Trigger.isAfter) {
        // After Update 
        // Check if we modify the AccountId on the Contact
        // Si le compte principal change sur le contact on révalue son positionnement.
        MandatoryDocs_StatusSetter.evaluatePCOnContact(Trigger.oldMap, Trigger.newMap);    
        
        // add calls if needed
        Relance_ProPart_LMSG.createProCallFileMembers(Trigger.new, Trigger.oldMap);
    }
 
}