/**
 * @File Name          : MER_LMSG_Trigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 01-12-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/22/2020   Hassan Dakhcha     Initial Version
**/
trigger MER_LMSG_Trigger on Mise_en_relation__c (before insert, after insert, before update, after update, after delete) {
    
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            // Mise a jours des counter des MER sous le projet:
            MER_LMSG_Methods.update_NumMer(Trigger.new, false);
            MER_LMSG_Methods.updateStatusCount(Trigger.New, null, true);
            Indicateur_LMSG.merLMSG(Trigger.new, null);
            MER_LMSG_Methods.updateTransactionIdLastUpdatedBySF(Trigger.new);
        }
        when AFTER_INSERT {
            emailReseauMethods.notifySelectedPro(Trigger.newMap, null);
        }
        when BEFORE_UPDATE {
            // Positionné / selectionné 
            MER_LMSG_Methods.updateStatusCount(Trigger.New, Trigger.oldMap, false);
            Indicateur_LMSG.merLMSG(Trigger.new, Trigger.oldMap);
            MER_LMSG_Methods.updateTransactionIdLastUpdatedBySF(Trigger.new);
        }
        when AFTER_UPDATE {
            emailReseauMethods.notifySelectedPro(Trigger.newMap, Trigger.oldMap);
        }
        when AFTER_DELETE {
            // Mise a jours des counter des MER sous le projet:
            MER_LMSG_Methods.update_NumMer(Trigger.old, true);
            MER_LMSG_Methods.updateStatusCount(Trigger.old, null, false);
        }
    }
}