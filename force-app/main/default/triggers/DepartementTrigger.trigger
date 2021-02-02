/*
 * Departement Trigger : handels some logic before the departement is inserted
 * Test Method : HerokuConnectTest
 * Created by : Hassan
 * Created Date : 26 Dec 2019
 */

trigger DepartementTrigger on Departement__c (before insert, before update) {
	
    if(Trigger.isBefore && Trigger.isInsert) {
        DepartementMethods.setIsUpdatedBySF(Trigger.New);
        DepartementMethods.AttachHKConnectDepToContact(Trigger.New);
        DepartementMethods.initKey(Trigger.New, null, true);
    }
    if(Trigger.isUpdate && Trigger.isBefore) {
        DepartementMethods.setIsUpdatedBySF(Trigger.New);
        DepartementMethods.initKey(Trigger.new, Trigger.oldMap, false);
    } 

}