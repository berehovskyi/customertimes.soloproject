/**
 * Created by oberegovskyi on 04-Nov-18.
 */

@IsTest
private class AccountSelectorTest {

//    @TestSetup
//    static void setupData() {
//
//        Territory__c parentTerritory = new Territory__c(Name = 'Parent');
//        insert parentTerritory;
//
//        List<Territory__c> territories = new List<Territory__c>();
//        for (Integer i = 0; i < 100; i++) {
//            territories.add(
//                    new Territory__c(
//                            Name = 'Name' + i,
//                            Parent_Territory__c = parentTerritory.Id
//            ));
//        }
//        insert territories;
//
//        List<Account> accounts = new List<Account>();
//        for (Integer i = 0; i < 100; i++) {
//            accounts.add(
//                    new Account (
//                            Name = 'TestName' + i,
//                            Territory__c = territories.get(i).Id
//                    )
//            );
//        }
//        insert accounts;
//
//        List<Contact> contacts = new List<Contact>();
//        for (Integer i = 0; i < 100; i++) {
//            contacts.add(new Contact ());
//        }
//        insert contacts;
//
//        List<Reference__c> references = new List<Reference__c>();
//        for (Integer i = 0; i < 100; i++) {
//            references.add(
//                    new Reference__c (
//                            Account__c = accounts.get(i).Id,
//                            Contact__c = contacts.get(i).Id
//                    )
//            );
//        }
//        insert references;
//
//    }
//
//    @IsTest
//    static void selectByTerritoriesTest() {
//        Territory__c territory = new Territory__c();
//        Set<Id> territoryIdsSet = new Set<Id>();
//        territoryIdsSet.add(territory.Id);
//        Test.startTest();
//            List<Account> account = AccountSelector.selectByTerritories(territoryIdsSet);
//        Test.startTest();
//    }
}