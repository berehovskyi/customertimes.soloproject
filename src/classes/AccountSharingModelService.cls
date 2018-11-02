/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public with sharing class AccountSharingModelService {

    public static void setSharedAccountsForTerrUsers(List<TerrUser__c> newTerrUsers) {

        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = getUserIdsSetByTerritoryIdMap(newTerrUsers);


        List<Account> accounts = getAccountsOf(userIdsSetByTerritoryIdMap);

        List<AccountShare> accountShares = new List<AccountShare>();
        List<ContactShare> contactShares = new List<ContactShare>();
        for (Account acc : accounts) {
            for (Id userId : userIdsSetByTerritoryIdMap.get(acc.Territory__c)) {

                AccountShare accountShare = getAccountShare(acc, userId);
                accountShares.add(accountShare);

                createContactSharesOf(acc, userId, contactShares);

            }
        }
        insert accountShares;
        insert contactShares;

    }

    private static Map<Id, Set<Id>> getUserIdsSetByTerritoryIdMap(List<TerrUser__c> newTerrUsers) {
        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = new Map<Id, Set<Id>>();
        for (TerrUser__c terrUser : newTerrUsers) {
            Id terrId = terrUser.Territory__c;
            Set<Id> usersIds = null;
            if (userIdsSetByTerritoryIdMap.containsKey(terrId)) {
                usersIds = userIdsSetByTerritoryIdMap.get(terrId);
            } else {
                usersIds = new Set<Id>();
            }
            usersIds.add(terrUser.User__c);
            userIdsSetByTerritoryIdMap.put(terrId, usersIds);
        }
        return userIdsSetByTerritoryIdMap;
    }

    private static void createContactSharesOf(Account acc, Id userId, List<ContactShare> contactShares) {
        for (Reference__c reference : acc.References__r) {
            ContactShare contactShare = getContactShare(reference, userId);
            contactShares.add(contactShare);
        }
    }

    private static List<Account> getAccountsOf(Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        List<Account> accounts = [
                SELECT Id, Territory__c, (SELECT Contact__c FROM References__r)
                FROM Account
                WHERE Territory__c IN :userIdsSetByTerritoryIdMap.keySet()
        ];
        return accounts;
    }

    private static AccountShare getAccountShare(Account acc, Id userId) {
        AccountShare accountShare = new AccountShare(
                AccountId = acc.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'None',
                UserOrGroupId = userId
        );
        return accountShare;
    }

    private static ContactShare getContactShare(Reference__c reference, Id userId) {
        ContactShare contactShare = new ContactShare(
                ContactId = reference.Contact__c,
                ContactAccessLevel = 'Edit',
                UserOrGroupId = userId
        );
        return contactShare;
    }

}