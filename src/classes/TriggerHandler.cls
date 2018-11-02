/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public interface TriggerHandler {

    void onBeforeInsert(List<SObject> newRecords);

    void onBeforeUpdate(SObject newRecords, SObject oldRecordsMap);

    void onBeforeDelete(SObject oldRecords);

    void onAfterInsert(SObject newRecords);

    void onAfterUpdate(SObject newRecords, SObject oldRecordsMap);

    void onAfterDelete(SObject oldRecords);

    void onAfterUndelete(SObject newRecords);

}