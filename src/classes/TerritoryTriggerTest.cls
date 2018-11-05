/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class TerritoryTriggerTest {
    @IsTest
    static void onInsertTest() {
        Territory__c territory = new Territory__c();
        Test.startTest();
            Database.SaveResult result = Database.insert(territory);
        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @IsTest
    static void onUpdateTest() {
        Territory__c territory = new Territory__c();
        insert territory;

        territory.Name = 'TestName';
        Test.startTest();
            Database.UpsertResult result = Database.upsert(territory);
        Test.stopTest();

        System.assert(result.isSuccess());
    }
}