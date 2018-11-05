/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class TerrUserTriggerTest {

    @IsTest
    static void onInsertTest() {
        Territory__c terr = new Territory__c(
                Name = 'TestName'
        );
        insert terr;

        TerrUser__c terrUser = new TerrUser__c(
                Territory__c = terr.Id
        );
        Test.startTest();
            Database.SaveResult result = Database.insert(terrUser);
        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @IsTest
    static void onDeleteTest() {
        Territory__c terr = new Territory__c(
                Name = 'TestName'
        );
        insert terr;

        TerrUser__c terrUser = new TerrUser__c(
                Territory__c = terr.Id
        );
        insert terrUser;

        Test.startTest();
            Database.DeleteResult result = Database.delete(terrUser);
        Test.stopTest();

        System.assert(result.isSuccess());
    }
}