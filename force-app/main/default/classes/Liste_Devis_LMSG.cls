public class Liste_Devis_LMSG {

    @AuraEnabled
    public static List<Devis_LMSG__c> getAccountRecords() {
        return new List<Devis_LMSG__c>([Select id,Name,Montant_HT__c,Statut__c,Type_de_devis__c from Devis_LMSG__c ]);
    }
    
}