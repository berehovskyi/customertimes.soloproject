/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class TerritoryTriggerHandler implements TriggerHandler {

    public void onBeforeInsert(List<SObject> newRecords) {
        TerritoryValidationService.validateBasedOnUniquenessInHierarchy(newRecords);
    }

    public void onBeforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        TerritoryValidationService.validateBasedOnUniquenessInHierarchy(newRecords);
    }

    public void onBeforeDelete(List<SObject> oldRecords) {
    }

    public void onAfterInsert(List<SObject> newRecords) {
    }

    public void onAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
    }

    public void onAfterDelete(List<SObject> oldRecords) {
    }

    public void onAfterUndelete(List<SObject> newRecords) {
    }
}