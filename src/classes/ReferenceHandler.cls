/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class ReferenceHandler implements TriggerHandler {

    public void onBeforeInsert(List<SObject> newRecords) {
    }

    public void onBeforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
    }

    public void onBeforeDelete(List<SObject> oldRecords) {
    }

    public void onAfterInsert(List<SObject> newRecords) {
        SharingModelService.setSharedContactsForReferences(newRecords);
    }

    public void onAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
    }

    public void onAfterDelete(List<SObject> oldRecords) {
        SharingModelService.deleteSharedContactsForReferences(oldRecords);
    }

    public void onAfterUndelete(List<SObject> newRecords) {
    }

}