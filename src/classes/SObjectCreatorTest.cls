/**
 * Created by oberegovskyi on 04-Nov-18.
 */

@IsTest
private class SObjectCreatorTest {

    @TestSetup
    static void setupData() {
        Group gr = new Group(
                Name = 'TestName'
        );
        insert gr;

        Contact con = new Contact(
                LastName = 'TestLastName'
        );
        insert con;

    }

    @IsTest
    static void createAccountShareTest() {
        Group gr = [SELECT Id FROM Group LIMIT 1];
        Account account = new Account(Name = 'TestName');

        Test.startTest();
            AccountShare accShare = SObjectCreator.createAccountShare(account, gr.Id);
        Test.stopTest();

        System.assertEquals(gr.Id, accShare.UserOrGroupId);
    }

    @IsTest
    static void createContactShareByTest() {
        Group gr = [SELECT Id FROM Group LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Reference__c reference = new Reference__c(Contact__c = con.Id);

        Test.startTest();
            ContactShare contactShare = SObjectCreator.createContactShare(reference, gr.Id);
        Test.stopTest();

        System.assertEquals(con.Id, contactShare.ContactId);
        System.assertEquals(gr.Id, contactShare.UserOrGroupId);
    }

    @IsTest
    static void createContactShareTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        AccountShare accountShare = new AccountShare();

        Test.startTest();
            ContactShare contactShare = SObjectCreator.createContactShare(con.Id, accountShare);
        Test.stopTest();

        System.assertEquals(con.Id, contactShare.ContactId);
    }
}