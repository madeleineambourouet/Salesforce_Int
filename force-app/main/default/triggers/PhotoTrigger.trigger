/**
* @author Qiuyan Liu
* @date 08/09/2017
*
* @description Created for EB136, calculate the number of photos for pro
*/
trigger PhotoTrigger on Photo__c (after insert, after update, after delete, after undelete) {

	if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete || trigger.isUndelete)) {
		
		PhotoMethods.calculateNumberPhoto(trigger.old, trigger.new);
	}
}