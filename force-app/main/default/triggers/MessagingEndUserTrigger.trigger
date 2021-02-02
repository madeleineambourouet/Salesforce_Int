/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-14-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-03-2020   Hassan Dakhcha   Initial Version
**/
trigger MessagingEndUserTrigger on MessagingEndUser (before insert, before update) {

    // check and update AccountID or ContactID on the MU :
    List<MessagingEndUser> needAccountId = new List<MessagingEndUser> ();
    Set<id> contactIds = new Set<id>();
    List<MessagingEndUser> needContactId = new List<MessagingEndUser> ();
    Set<id> accountIds = new Set<id>();
    for(MessagingEndUser mu : Trigger.new) {
        if(mu.contactId == null && mu.accountId != null) {
            needContactId.add(mu);
            accountIds.add(mu.accountId);
        } else if(mu.contactId != null && mu.accountId == null) {
            needAccountId.add(mu);
            contactIds.add(mu.contactId);
        }
    }

    Map<id, contact> ctcMap = null;
    if(!contactIds.isEmpty()) {
        ctcMap = new Map<id, Contact> ([SELECT id, AccountId FROM Contact WHERE AccountId IN :contactIds]);
    }

    Map<id, Account> accMap = null;
    if(!accountIds.isEmpty()) {
        accMap = new Map<id, Account>([SELECT id, PersonContactId, Contact_principal__c, isPersonAccount FROM Account WHERE id IN:accountIds]);
    }

    for(MessagingEndUser mu : needAccountId) {
        contact ctc = ctcMap.get(mu.ContactId);
        if(ctc!=null) {
            mu.AccountId = ctc.AccountId;
        }
    }

    for(MessagingEndUser mu : needContactId) {
        Account acc = accMap.get(mu.AccountId);
        if(acc!=null) {
            mu.ContactId = acc.IsPersonAccount? acc.PersonContactId : acc.Contact_principal__c;
        }
    }

}