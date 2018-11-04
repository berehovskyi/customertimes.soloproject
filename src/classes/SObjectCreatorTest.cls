/**
 * Created by oberegovskyi on 04-Nov-18.
 */

@IsTest
private class SObjectCreatorTest {

    @IsTest
    static void createAccountShareTest() {
        Account account = new Account(Name = 'TestName');
        Id userId = '000000000000000001';

        Test.startTest();
            AccountShare accShare = SObjectCreator.createAccountShare(account, userId);
        Test.stopTest();

        System.assertEquals('000000000000000001', accShare.UserOrGroupId);
    }

    @IsTest
    static void createContactShareByTest() {
        Reference__c reference = new Reference__c(Contact__c = '000000000000000002');
        Id userId = '000000000000000001';

        Test.startTest();
            ContactShare contactShare = SObjectCreator.createContactShare(reference, userId);
        Test.stopTest();

        System.assertEquals('000000000000000002', contactShare.ContactId);
        System.assertEquals('000000000000000001', contactShare.UserOrGroupId);
    }

    @IsTest
    static void createContactShareTest() {
        Id contactId = '000000000000000001';
        AccountShare accountShare = new AccountShare();

        Test.startTest();
            ContactShare contactShare = SObjectCreator.createContactShare(contactId, accountShare);
        Test.stopTest();

        System.assertEquals('000000000000000001', contactShare.ContactId);
    }
}