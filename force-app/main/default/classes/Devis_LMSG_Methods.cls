/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-17-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-25-2020   Hassan Dakhcha   Initial Version
**/
public class Devis_LMSG_Methods {
   // Mise a jour du projet :
   // A la signature du devis on affecte le BD du compte au projet
   // A la signature du devis on copie le montant HT du devis sur le projet
   // A la signature du devis si montant >= 5000 euros on communique aux contacts de l'agence pilote
   //Modification le 19/01/2021 ->montant HT du devis rempli uniquement pour les devis de type Devis

    public static void updateProject(Map<id, Devis_LMSG__c> newMap, Map<id, Devis_LMSG__c> oldMap) {
        Map<id, Devis_LMSG__c> MerQuoteMap = new Map<id, Devis_LMSG__c> ();
        for(id quote : newMap.keySet()) {
            if(newMap.get(quote).Statut__c == 'SIGNED' && newMap.get(quote).Type_de_devis__c == 'INITIAL' && (oldMap==null || oldMap.get(quote).Statut__c != newMap.get(quote).Statut__c )) {
                    if(newMap.get(quote).Mise_en_relation_LMSG__c!=null) {
                        MerQuoteMap.put(newMap.get(quote).Mise_en_relation_LMSG__c, newMap.get(quote));
                    }
                }
        }
        if(MerQuoteMap.isEmpty()) {
            return;
        }
        
        List<Mise_en_relation__c> listMer = [SELECT id, Projet_LMSG__c, Compte_Pro__c, Compte_Pro__r.ownerId, Compte_Pro__r.owner.email, Compte_Pro__r.Agence_User__c
                                             FROM Mise_en_relation__c WHERE id IN :MerQuoteMap.keySet()];
        Map<id, id> projetBdMap = new Map<id, id>();
        Map<id, Decimal> projetMontantHTMap = new Map<id, Decimal>();
        Map<id, id> devisAgenceMap = new Map<id, id>();
        Map<id, String> devisBDMap = new Map<id, String>();
        for(Mise_en_relation__c mer : listMer) {
            if(mer.Projet_LMSG__c != null) {
                projetBdMap.put(mer.Projet_LMSG__c, mer.Compte_Pro__r.ownerId);
                projetMontantHTMap.put(mer.Projet_LMSG__c, MerQuoteMap.get(mer.id).montant_ht__c);
                devisAgenceMap.put(MerQuoteMap.get(mer.id).id, mer.Compte_Pro__r.Agence_User__c);
                devisBDMap.put(MerQuoteMap.get(mer.id).id, mer.Compte_Pro__r.owner.email);
            }
        }

        if(!devisAgenceMap.isEmpty() && !devisBDMap.isEmpty()) {
            emailReseauMethods.notifySignedQuote(newMap, devisAgenceMap, devisBDMap);
        }

        List<Projet_LMSG__c> ProjectList = new List<Projet_LMSG__c>();
        for(Id prjId : projetBdMap.keySet()) {
            ProjectList.add(new Projet_LMSG__c(id = prjId, Bd_associe__c = projetBdMap.get(prjId), montant_HT_devis_signe__c = projetMontantHTMap.get(prjId)));
        }

        if(!ProjectList.isEmpty()) {
            DataBase.SaveResult[] updateResults = DataBase.update(ProjectList, false);
            for(DataBase.SaveResult res : updateResults) {
                if(!res.isSuccess()) { for(Database.Error err : res.getErrors()) {
                        System.debug('### HDAK  DevisLMSGTrigger : echec de l \'update du DB du project : ');                   
                        System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                    }
                }
            }
        }
    }


}