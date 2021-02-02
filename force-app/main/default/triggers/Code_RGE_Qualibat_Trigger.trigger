/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 01-14-2021
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-29-2020   Hassan Dakhcha   Initial Version
**/
trigger Code_RGE_Qualibat_Trigger on Code_Certif_RGE_Qualibat__c (after insert, before update, after delete) {

    // Insert or update 
    Code_RGE_Qualibat_Methods.handleCodes(Trigger.isDelete? Trigger.old : Trigger.new, Trigger.isUpdate);
}