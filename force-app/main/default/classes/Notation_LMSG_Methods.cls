/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-28-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-18-2020   Hassan Dakhcha   Initial Version
**/
public class Notation_LMSG_Methods {
    
    public static void attachPart(List<Notation_LMSG__c> newList) {
            // attach to the particular
        Map<id, Notation_LMSG__c> projectRatingMap = new Map<id, Notation_LMSG__c>();
        for(Notation_LMSG__c rating : newList) {  
            System.debug('#### attachPart : '+ rating.projet_lmsg__c + ' ' + rating);  
            projectRatingMap.put(rating.projet_lmsg__c, rating);
        }
        if(!projectRatingMap.isEmpty()) {
            Map<id, Projet_LMSG__c> projectLMSG = new Map<id, Projet_LMSG__c> ([SELECT id, Particulier__c 
                                                                                FROM Projet_LMSG__c 
                                                                                WHERE ID IN:projectRatingMap.keySet()]);
        for(id project : projectRatingMap.keySet()) {
                System.debug('#### projet : '+ projectLMSG.get(project).Particulier__c);  
                projectRatingMap.get(project).Particulier__c = projectLMSG.get(project).Particulier__c;
           }
           for(Notation_LMSG__c rating : newList) {  
            System.debug('#### rating part : '+ rating.Particulier__c + ' ' + rating);  
           }

        }
    }

    public static void updateProRating(List<Notation_LMSG__c> newList, Map<id, Notation_LMSG__c> oldMap) {
    // Calcul de la note global du pro :
        Set<id> proToUpdateSet = new Set<id>();
        for(Notation_LMSG__c rating : newList) {   
            if(oldMap==null || oldMap.get(rating.id).rate__c != rating.rate__c) { 
                proToUpdateSet.add(rating.compte_pro__c);
            }
        }
        if(!proToUpdateSet.isEmpty()) {
            List<Notation_LMSG__c> notationList = [SELECT id, Compte_Pro__c, rate__c FROM Notation_LMSG__c 
                                                   WHERE Compte_pro__c IN :proToUpdateSet AND Status__c ='PUBLISHED'];
            Map<id , List<Decimal>> accRatingMap = new Map<id , List<Decimal>>();
            for(Notation_LMSG__c rating : notationList) {
                //System.debug('#### Notation : '+ rating.Compte_Pro__c + ' ' + rating.rate__c);
                List<Decimal> ratingList = accRatingMap.get(rating.Compte_Pro__c);
                if(ratingList == null) {
                    ratingList = new List<Decimal>();
                    accRatingMap.put(rating.Compte_Pro__c, ratingList);
                }
                //System.debug('#### adding rate : '+ rating.rate__c);
                ratingList.add(rating.rate__c==null ? 0 : rating.rate__c);
            }
            List<Account> updateRating = new List<Account>();
            if(!accRatingMap.isEmpty()) {
                for(Id acc : accRatingMap.keySet()) {
                    List<Decimal> intList = accRatingMap.get(acc);
                    Decimal aver = 0;
                    for(Decimal sum : intList) {
                        //System.debug('#### sum : '+ sum);
                        aver+= sum;
                    }
                    //System.debug('#### total sum : '+ aver);
                    aver = aver/intList.size();
                    //System.debug('#### average : '+ aver);
                    //System.debug('#### round : '+ aver.round(System.RoundingMode.HALF_EVEN));
                    updateRating.add(new Account(id = acc, rating__c= aver.setScale(2)));
                }
            }
            if(!updateRating.isEmpty()) {
                Database.SaveResult[] results = Database.update(updateRating, false);
                for(Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        for(Database.Error err : result.getErrors()) {
                            System.debug('### Notation LMSG  : Erreur update rating sur le compte ');                   
                            System.debug('### Notation LMSG : ' + err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('### Notation LMSG Champs origine de l\'erreur : '  + err.getFields());
                        }
                    }
                }
            }
        }
    }
}