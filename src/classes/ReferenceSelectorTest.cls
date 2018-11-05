/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class ReferenceSelectorTest {

    @TestSetup
    static void setupData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            accounts.add(
                    new Account (
                            Name = 'TestName' + i
                    )
            );
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            contacts.add(
                    new Contact(
                            LastName = 'TestName' + i
                    )
            );
        }
        insert contacts;

        List<Reference__c> references = new List<Reference__c>();
        for (Integer i = 0; i < 10; i++) {
            references.add(
                    new Reference__c(
                            Account__c = accounts.get(i).Id,
                            Contact__c = contacts.get(i).Id
                    )
            );
        }
        insert references;
    }

    @IsTest
    static void selectByAccountsTest() {
        List<Account> accounts = [SELECT Id FROM Account];
        Set<Id> accIds = new Set<Id>();
        for (Account acc: accounts) {
            accIds.add(acc.Id);
        }

        Test.startTest();
            List<Reference__c> references = ReferenceSelector.selectByAccounts(accounts);
        Test.stopTest();

        for (Reference__c ref : references) {
            System.assertEquals(true, accIds.contains(ref.Account__c));
        }
    }
}