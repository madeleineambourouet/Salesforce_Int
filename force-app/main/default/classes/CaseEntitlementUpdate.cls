public class CaseEntitlementUpdate {
@InvocableMethod
 public static void updateEntilement(List < String > caseIds) {
  // get all accounts
  Set < String > accIds = new Set < String > ();
  Set < String > contactId = new Set < String > ();

  List<Case> caseList = [Select Id, AccountId, ContactId from Case where Id in: caseIds];

  for (Case c: caseList) {
   if (c.AccountId != null) {
    accIds.add(c.AccountId);
   } else if (c.ContactId != null) {
    contactId.add(c.ContactId);
   }
  }

  System.Debug('AccIds size (1): ' + accIds.size()); // 0
  System.Debug('ContactId size: ' + contactId.size()); // 1

  if (accIds.size() > 0 || contactId.size() > 0) {

   List < Contact > contList = [select Id, AccountId from Contact where Id IN: contactId];

   System.Debug('ContList size: ' + contList.size()); // 1

   for (Contact c: contList) accIds.add(c.AccountId);

   System.Debug('accIds size (2): ' + accIds.size()); // 1

   // get all active entitlements for accounts
   List < Entitlement > entls = [select StartDate, Id, EndDate, AccountId From Entitlement where AccountId in : accIds and EndDate >= Today And StartDate <= Today];

   if (entls != null) System.Debug('entls size: ' + entls.size()); // 1

   // create map
   Map < String, Entitlement > entlsMap = new Map < String, Entitlement > ();
   if (entls != null && entls.size() > 0) {
    for (Entitlement e: entls) {
     entlsMap.put(e.AccountId, e);
     System.Debug('e.AccountId: ' + e.AccountId); 
     System.Debug('e.id: ' + e.id); 
    }
   }

   for (Case c: caseList) {
    System.Debug('c.CaseNumber: ' + c.CaseNumber); // null

    if (c.AccountId != null) System.Debug('c.AccountId (check if null): ' + c.AccountId); // c.AccountId is null
    if (entlsMap.get(c.AccountId) != null) System.Debug('got entitlement'); // c.AccountId is null

    if (c.AccountId != null && entlsMap.get(c.AccountId) != null) {
     c.EntitlementId = entlsMap.get(c.AccountId).Id;
     System.Debug('Entitlement id: ' + entlsMap.get(c.AccountId).Id);
    }
   }
  }

}
}