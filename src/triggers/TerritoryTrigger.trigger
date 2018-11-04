/**
 * Created by oberegovskyi on 04-Nov-18.
 */

trigger TerritoryTrigger on Territory__c (before insert, before update/*, before delete, after insert, after update, after delete, after undelete*/) {

    TriggerHandler handler = TriggerFactory.createHandler(Territory__c.SObjectType);

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
//        if (Trigger.isDelete) {
//            handler.onBeforeDelete(Trigger.old);
//        }
//    }

//    if (Trigger.isAfter) {
//        if (Trigger.isInsert) {
//            handler.onAfterInsert(Trigger.new);
//        }
//        if (Trigger.isUpdate) {
//            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
//        }
//        if (Trigger.isDelete) {
//            handler.onAfterDelete(Trigger.old);
//        }
//        if (Trigger.isUndelete) {
//            handler.onAfterUndelete(Trigger.new);
//        }
    }

}