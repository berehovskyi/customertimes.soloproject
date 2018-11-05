/**
 * Created by oberegovskyi on 04-Nov-18.
 */

@IsTest
private class AccountShareSelectorTest {

    @TestSetup
    static void setupTest() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            accounts.add(
                    new Account (
                            Name = 'TestName' + i
                    )
            );
        }
        insert accounts;

        List<Group> groups =  new List<Group>();
        for (Integer i = 0; i < 100; i++) {
            groups.add(
                    new Group (
                            Name = 'TestName' + i
                    )
            );
        }
        insert groups;

        List<AccountShare> accountShares = new List<AccountShare>();
        for (Integer i = 0; i < 100; i++) {
            accountShares.add(
                    new AccountShare (
                            AccountId = accounts.get(i).Id,
                            UserOrGroupId = groups.get(i).Id,
                            RowCause = 'Manual',
                            AccountAccessLevel = 'Edit',
                            OpportunityAccessLevel = 'None'
                    )
            );
        }
        insert accountShares;
    }



    @IsTest
    static void selectByAccountAndUserIdsSetTest() {
        List<Account> accounts = [SELECT Id FROM Account];
        List<User> users = [SELECT Id FROM User];
        Set<Id> userIds = new Set<Id>();
        for (User us : users) {
            userIds.add(us.Id);
        }

        Test.startTest();
            List<AccountShare> accountShares = AccountShareSelector.selectByAccountAndUserIdsSet(accounts, userIds);
        Test.stopTest();

        for (AccountShare accShare : accountShares) {
            System.assertEquals(true, userIds.contains(accShare.UserOrGroupId), 'Incorrect UserOrGroupId');
        }
    }

    @IsTest
    static void selectUserIdsSetTest() {
        List<User> users = [SELECT Id FROM User];
        Set<Id> userIds = new Set<Id>();
        for (User us : users) {
            userIds.add(us.Id);
        }

        Test.startTest();
        List<AccountShare> accountShares = AccountShareSelector.selectByAccountIdsSet(userIds);
        Test.stopTest();

        for (AccountShare accShare : accountShares) {
            System.assertEquals(true, userIds.contains(accShare.UserOrGroupId), 'Incorrect UserOrGroupId');
        }
    }

    @IsTest
    static void selectByAccountsTest() {
        List<Account> accounts = [SELECT Id FROM Account];
        Set<Id> accIds = new Set<Id>();
        for (Account acc: accounts) {
            accIds.add(acc.Id);
        }

        Test.startTest();
            List<AccountShare> accountShares = AccountShareSelector.selectByAccounts(accounts);
        Test.stopTest();

        for (AccountShare accShare : accountShares) {
            System.assertEquals(true, accIds.contains(accShare.AccountId), 'Incorrect AccountId');
        }
    }
}