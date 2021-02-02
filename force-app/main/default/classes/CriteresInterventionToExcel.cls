public class CriteresInterventionToExcel {
    public List<GeoCat__c> listCi{get; set;}
    public List<Id> listIdContacts{get; set;}
    public Map<Id,String> mapci{get; set;}
    public CriteresInterventionToExcel()
    {
        listCi = new List<GeoCat__c>();
        listIdContacts = new List<Id>();
        mapci = new Map<Id,String>();
        AggregateResult[] groupedResults = [Select MIN(id), MIN(Contact__r.LastName), Contact__c,Adresse__r.key__c  
			from GeoCat__c where contact__r.Account.Statut_de_la_souscription__c = 'Active'   
            group by Adresse__r.key__c,Contact__c having count(Id) >=2];
        for (AggregateResult ar : groupedResults)  {
            mapci.put((Id)ar.get('Contact__c'), (String)ar.get('key__c'));
            listIdContacts.add((Id)ar.get('Contact__c'));
            System.debug('***** expr0 '+ar.get('expr0'));
            System.debug('***** Contact__c '+ar.get('Contact__c'));
            System.debug('***** key__c '+ar.get('key__c'));
            System.debug('***** LastName '+ar.get('expr1'));
        }
        for (GeoCat__c geo : [Select Id, contact__c, Contact__r.LastName, Adresse__r.Key__c  from GeoCat__c where contact__c in:listIdContacts])  {
            if(mapci.get(geo.contact__c) != null && geo.Adresse__r.Key__c == mapci.get(geo.contact__c)){
                listCi.add(geo);
            }
        }
        
    }
}