/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public with sharing class TriggerFactory {

    public static TriggerHandler createHandler(Schema.SObjectType sObjectType) {
        TriggerHandler handler = getHandler(sObjectType);
        if (handler == null) {
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + sObjectType);
        } else {
            return handler;
        }
    }

    public static TriggerHandler getHandler(Schema.SObjectType sObjectType) {
        if (sObjectType == Account.SObjectType) {
            return new AccountTriggerHandler();
        } else if (sObjectType == TerrUser__c.SObjectType) {
            return new TerrUserTriggerHandler();
        } else if (sObjectType == Reference__c.SObjectType) {
            return new ReferenceTriggerHandler();
        } else if (sObjectType == Territory__c.SObjectType) {
            return new TerritoryTriggerHandler();
        } else {
            return null;
        }
    }
}