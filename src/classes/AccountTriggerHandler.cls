/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public with sharing class AccountTriggerHandler implements TriggerHandler {

    public void onBeforeInsert(List<SObject> newRecords) {
    }

    public void onBeforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
    }

    public void onBeforeDelete(List<SObject> oldRecords) {
    }

    public void onAfterInsert(List<SObject> newRecords) {
        SharingModelService.setSharedAccountsForAccounts(newRecords);
    }

    public void onAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        SharingModelService.updateSharedAccountsForAccounts(newRecords, (Map<Id, Account>) oldRecordsMap);
    }

    public void onAfterDelete(List<SObject> oldRecords) {
    }

    public void onAfterUndelete(List<SObject> newRecords) {
    }

}