/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-06-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-02-2020   Hassan Dakhcha   Initial Version
**/
trigger MessagingSessionTrigger on MessagingSession (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert) {
        system.debug('******* Before INSERT Trigger MS');
        MessagingSessionMethods.updateMSInboundType(Trigger.new);
        MessagingSessionMethods.updateRelationship(Trigger.new);
        system.debug('******* End Trigger MS');
    }
    if(Trigger.isBefore && Trigger.isUpdate) {
        system.debug('******* Before UPDATE Trigger MS');
        MessagingSessionMethods.updateRelationship(Trigger.new);
        system.debug('******* End Trigger MS');
    }
    
  /*  if(Trigger.isAfter && Trigger.isInsert) {
        MessagingSessionMethods.updateMSOutboundType(Trigger.new);
    }*/
}