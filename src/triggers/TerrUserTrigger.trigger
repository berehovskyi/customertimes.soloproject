/**
 * Created by oberegovskyi on 01-Nov-18.
 */

trigger TerrUserTrigger on TerrUser__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerHandler handler = TriggerFactory.createHandler(TerrUser__c.SObjectType);

    System.debug('TRIGGER HANDLER: ' + handler);

//    if (Trigger.isBefore) {
//        if (Trigger.isInsert) {
//            handler.onBeforeInsert(Trigger.new);
//        }
//        if (Trigger.isUpdate) {
//            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
//        }
//        if (Trigger.isDelete) {
//            handler.onBeforeDelete(Trigger.old);
//        }
//    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.new);
        }
//        if (Trigger.isUpdate) {
//            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
//        }
        if (Trigger.isDelete) {
            handler.onAfterDelete(Trigger.old);
        }
//        if (Trigger.isUndelete) {
//            handler.onAfterUndelete(Trigger.new);
//        }
    }
}