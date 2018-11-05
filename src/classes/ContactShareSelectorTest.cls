/**
 * Created by oberegovskyi on 04-Nov-18.
 */

@IsTest
private class ContactShareSelectorTest {

    @TestSetup
    static void setupData() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            contacts.add(
                    new Contact(
                            LastName = 'TestName' + i
                    )
            );
        }
        insert contacts;

        List<Group> groups = new List<Group>();
        for (Integer i = 0; i < 10; i++) {
            groups.add(
                    new Group (
                            Name = 'TestName' + i
                    )
            );
        }
        insert groups;

        List<ContactShare> contactShares = new List<ContactShare>();
        for (Integer i = 0; i < 10; i++) {
            contactShares.add(
                    new ContactShare (
                            ContactId = contacts.get(i).Id,
                            UserOrGroupId = groups.get(i).Id,
                            RowCause = 'Manual',
                            ContactAccessLevel = 'Edit'
                    )
            );
        }
        insert contactShares;
    }

    @IsTest
    static void selectByContactIdsAndUserIdsTest() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        Set<Id> contactIds = new Set<Id>();
        for (Contact contact : contacts) {
            contactIds.add(contact.Id);
        }

        Test.startTest();
            List<ContactShare> contactShares = ContactShareSelector.selectByContactIdsSet(contactIds);
        Test.stopTest();

        System.assertEquals(contacts[0].Id, contactShares[0].ContactId);
        System.assertEquals(10, contactShares.size());
    }

    @IsTest
    static void selectByContactIdsSetTest() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        Set<Id> contactIds = new Set<Id>();
        for (Contact contact : contacts) {
            contactIds.add(contact.Id);
        }
        List<Group> groups = [SELECT Id FROM Group];
        Set<Id> groupIds = new Set<Id>();
        for (Group gr : groups) {
            System.debug('group Id' + gr.Id);
            groupIds.add(gr.Id);
        }

        Test.startTest();
            List<ContactShare> contactShares = ContactShareSelector.selectByContactIdsAndUserIds(contactIds, groupIds);
        Test.stopTest();

        for (ContactShare conShare : contactShares) {
            System.assertEquals(true, contactIds.contains(conShare.ContactId));
        }

        System.assertEquals(10, contactShares.size());
    }
}