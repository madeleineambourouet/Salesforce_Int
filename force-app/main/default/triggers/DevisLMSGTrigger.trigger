/**
 * @File Name          : DevisLMSGTrigger.trigger
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 12-16-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/16/2020   Hassan Dakhcha     Initial Version
**/
trigger DevisLMSGTrigger on Devis_LMSG__c (before insert, after insert, before update, after update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            Indicateur_LMSG.devisLMSG(Trigger.new, null);
        }
        when AFTER_INSERT {
            Devis_LMSG_Methods.updateProject(Trigger.newMap, null);
        }
        when BEFORE_UPDATE {
            Indicateur_LMSG.devisLMSG(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            Devis_LMSG_Methods.updateProject(Trigger.newMap, Trigger.oldMap);
        }
    }
}