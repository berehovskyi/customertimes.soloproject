/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public with sharing class TerrUserHandler implements TriggerHandler {

    public void onBeforeInsert(List<SObject> newRecords) {
        System.debug('INSIDE TERR USER HANDLER');

        AccountSharingModelService.setSharedAccountsForTerrUsers(newRecords);
    }

    public void onBeforeUpdate(SObject newRecords, SObject oldRecordsMap) {
    }

    public void onBeforeDelete(SObject oldRecords) {
    }

    public void onAfterInsert(SObject newRecords) {
    }

    public void onAfterUpdate(SObject newRecords, SObject oldRecordsMap) {
    }

    public void onAfterDelete(SObject oldRecords) {
    }

    public void onAfterUndelete(SObject newRecords) {
    }

}