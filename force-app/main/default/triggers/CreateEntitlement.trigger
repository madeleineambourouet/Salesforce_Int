trigger CreateEntitlement on Account (after update) {

List<Entitlement> createentitlement_recredit = new List <Entitlement> {};
List<Entitlement> createentitlement_resiliation = new List <Entitlement> {}; 
List<Entitlement> createentitlement_Rbtsolde = new List <Entitlement> {};    

for (Account acc : trigger.new) {

if (acc.Statut_global__c == 'CLIENT') /* If the Account custom field Statut_global__c = CLIENT */
{
createentitlement_recredit.add(new Entitlement(
Name = 'Recrédit', /* Give a motif name*/
AccountId = acc.Id, /* Link the Entitlement to the account */
StartDate = system.Today(),
Type = 'Support téléphonique',    
SlaProcessId = '5523E00000000o1QAA' /* Link it to a defined entitlement process */
));
createentitlement_resiliation.add(new Entitlement(
Name = 'Demande de résiliation', /* Give a motif name*/
AccountId = acc.Id, /* Link the Entitlement to the account */
StartDate = system.Today(),
Type = 'Support téléphonique',    
SlaProcessId = '5523E00000000opQAA' /* Link it to a defined entitlement process */
));  
createentitlement_Rbtsolde.add(new Entitlement(
Name = 'Remboursement solde créditeur', /* Give a motif name*/
AccountId = acc.Id, /* Link the Entitlement to the account */
StartDate = system.Today(),
Type = 'Support téléphonique',    
SlaProcessId = '5523E00000000p9' /* Link it to a defined entitlement process */
));      
}
}
try {
insert createentitlement_recredit;
insert createentitlement_resiliation; 
insert createentitlement_Rbtsolde;    
}
catch (Exception Ex)
{
system.debug(Ex);
}
}