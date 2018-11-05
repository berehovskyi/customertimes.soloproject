/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class AccountTriggerTest {

    @IsTest
    static void testInUpdate() {
        Account account = new Account(Name = 'Test');
        insert account;

        account.Name = 'TestName';
        Test.startTest();
            Database.UpsertResult updateResult = Database.upsert(account);
        Test.stopTest();

        System.assert(updateResult.isSuccess());
    }
}