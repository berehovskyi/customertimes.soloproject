/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public interface TriggerHandler {

    void onBeforeInsert(List<SObject> newRecords);

    void onBeforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap);

    void onBeforeDelete(List<SObject> oldRecords);

    void onAfterInsert(List<SObject> newRecords);

    void onAfterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap);

    void onAfterDelete(List<SObject> oldRecords);

    void onAfterUndelete(List<SObject> newRecords);

}