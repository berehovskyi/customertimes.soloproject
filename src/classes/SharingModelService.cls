/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public with sharing class SharingModelService {

    public static void setSharedAccountsAndContactsForTerrUsers(List<TerrUser__c> newTerrUsers) {
        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = getUserIdsSetByTerritoryIdMap(newTerrUsers);
        addHierarchicalRelationships(userIdsSetByTerritoryIdMap);
        List<Account> accounts = getAccountsOf(userIdsSetByTerritoryIdMap);
        List<AccountShare> accountShares = new List<AccountShare>();
        List<ContactShare> contactShares = new List<ContactShare>();
        for (Account acc : accounts) {
            for (Id userId : userIdsSetByTerritoryIdMap.get(acc.Territory__c)) {
                AccountShare accountShare = createAccountShare(acc, userId);
                accountShares.add(accountShare);
                createContactSharesOf(acc, userId, contactShares);
            }
        }

        insert accountShares;
        insert contactShares;

    }

    public static void deleteSharedAccountsAndContactsForTerrUsers(List<TerrUser__c> oldTerrUsers) {
        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = getUserIdsSetByTerritoryIdMap(oldTerrUsers);
        addHierarchicalRelationships(userIdsSetByTerritoryIdMap);
        Set<Id> usersIds = getUsersIds(userIdsSetByTerritoryIdMap);
        List<Account> accounts = getAccountsOf(userIdsSetByTerritoryIdMap);
        List<AccountShare> accountShares = getAccountShares(accounts, usersIds);
        List<AccountShare> accountSharesToDelete = getAccountSharesToDelete(accountShares, userIdsSetByTerritoryIdMap);
        Map<Id, List<Reference__c>> referencesByContactIdsMap = getReferencesByContactIdsMap(accounts);
        List<ContactShare> contactShares = getContactShares(referencesByContactIdsMap.keySet(), usersIds);
        List<ContactShare> contactSharesToDelete = getContactSharesToDelete(
                contactShares, referencesByContactIdsMap, userIdsSetByTerritoryIdMap
        );

        delete accountSharesToDelete;
        delete contactSharesToDelete;
    }

    public static void setSharedAccountsForAccounts(List<Account> newAccounts) {
        Map<Id, Territory__c> relatedTerritoriesByIdMap = getRelatedTerritoriesByIdMap(newAccounts);
        List<AccountShare> accountShares = getAccountSharesForParentTerritories(newAccounts, relatedTerritoriesByIdMap);

        insert accountShares;
    }

    public static void updateSharedAccountsForAccounts(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        List<Account> newAccountsWithChangedTerritory = new List<Account>();
        for(Account acc :newAccounts){
            Account oldAcc = oldAccountsMap.get(acc.Id);
            if(acc.Territory__c != oldAcc.Territory__c){
                newAccountsWithChangedTerritory.add(acc);
            }
        }
        delete [
            select id
            from AccountShare
            where AccountId in :newAccountsWithChangedTerritory and RowCause = 'Manual'
            ];
        setSharedAccountsForAccounts(newAccountsWithChangedTerritory);
    }


    private static Map<Id, Territory__c> getRelatedTerritoriesByIdMap(List<Account> newAccounts) {
        Set<Id> territoriesIds = SObjectsHelper.getIdFieldValues(newAccounts, Account.Territory__c);
        Map<Id, Territory__c> relatedTerritoriesByIdMap = new Map<Id, Territory__c>();

        Set<Id> parentIds = new Set<Id>(territoriesIds);
        do {
            List<Territory__c> territories = getParentTerritories(parentIds);
            for (Territory__c territory : territories) {
                relatedTerritoriesByIdMap.put(territory.Id, territory);
            }
            parentIds.clear();
            parentIds = SObjectsHelper.getIdFieldValues(territories, Territory__c.Parent_Territory__c);
        } while (!parentIds.isEmpty());
        return relatedTerritoriesByIdMap;
    }


    private static List<AccountShare> getAccountSharesForParentTerritories(List<Account> newAccounts, Map<Id, Territory__c> relatedTerritoriesByIdMap) {
        List<AccountShare> acctAccountSharesToInsert = new List<AccountShare>();
        for (Account acc : newAccounts) {
            if (relatedTerritoriesByIdMap.containsKey(acc.Territory__c)) {
                Territory__c currentTerritory = relatedTerritoriesByIdMap.get(acc.Territory__c);
                Boolean hasParent = false;
                do {
                    for (TerrUser__c terrUser : currentTerritory.TerrUsers__r) {
                        AccountShare accShare = createAccountShare(acc, terrUser.User__c);
                        acctAccountSharesToInsert.add(accShare);
                    }
                    hasParent = currentTerritory.Parent_Territory__c != null;
                    if (hasParent) {
                        currentTerritory = relatedTerritoriesByIdMap.get(currentTerritory.Parent_Territory__c);
                    }
                } while (hasParent);
            }
        }
        return acctAccountSharesToInsert;
    }


    private static List<ContactShare> getContactSharesToDelete(List<ContactShare> contactShares, Map<Id, List<Reference__c>> referencesByContactIdsMap, Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        List<ContactShare> contactSharesToDelete = new List<ContactShare>();
        for (ContactShare conShare : contactShares) {
            for (Reference__c reference : referencesByContactIdsMap.get(conShare.ContactId)) {
                if (userIdsSetByTerritoryIdMap.get(reference.Account__r.Territory__c).contains(conShare.UserOrGroupId)) {
                    contactSharesToDelete.add(conShare);
                }
            }
        }
        return contactSharesToDelete;
    }


    private static List<AccountShare> getAccountSharesToDelete(List<AccountShare> accountShares, Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        List<AccountShare> accountSharesToDelete = new List<AccountShare>();
        for (AccountShare accShare : accountShares) {
            if (userIdsSetByTerritoryIdMap.get(accShare.Account.Territory__c).contains(accShare.UserOrGroupId)) {
                accountSharesToDelete.add(accShare);
            }
        }
        return accountSharesToDelete;
    }


    private static Map<Id, List<Reference__c>> getReferencesByContactIdsMap(List<Account> accounts) {
        Map<Id, List<Reference__c>> referencesByContactIdsMap = new Map<Id, List<Reference__c>>();
        for (Account acc : accounts) {
            for (Reference__c reference : acc.References__r) {
                Id contactId = reference.Contact__c;
                List<Reference__c> references = null;
                if (referencesByContactIdsMap.containsKey(contactId)) {
                    references = referencesByContactIdsMap.get(contactId);
                } else {
                    references = new List<Reference__c>();
                }
                references.add(reference);
                referencesByContactIdsMap.put(contactId, references);
            }
        }
        return referencesByContactIdsMap;
    }

    private static Set<Id> getUsersIds(Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        Set<Id> usersIds = new Set<Id>();
        for (Set<Id> usersIdsSet : userIdsSetByTerritoryIdMap.values()) {
            usersIds.addAll(usersIdsSet);
        }
        return usersIds;
    }


    private static void addHierarchicalRelationships(Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        Set<Id> parentIds = new Set<Id>(userIdsSetByTerritoryIdMap.keySet());
        do {
            List<Territory__c> childTerritories = getChildTerritories(parentIds);
            parentIds.clear();
            for (Territory__c territory : childTerritories) {
                parentIds.add(territory.Id);
                Set<Id> usersIds = userIdsSetByTerritoryIdMap.get(territory.Parent_Territory__c);
                userIdsSetByTerritoryIdMap.put(territory.Id, usersIds);
            }
        } while (!parentIds.isEmpty());
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
            ContactShare contactShare = createContactShare(reference, userId);
            contactShares.add(contactShare);
        }
    }

    private static List<Territory__c> getParentTerritories(Set<Id> parentIds) {
        return [
                SELECT Id, Name, Parent_Territory__c, (
                        SELECT User__c
                        FROM TerrUsers__r
                )
                FROM Territory__c
                WHERE Id IN :parentIds
        ];
    }

    private static List<Territory__c> getChildTerritories(Set<Id> parentIds) {
        return [
                SELECT Id, Parent_Territory__c
                FROM Territory__c
                WHERE Parent_Territory__c IN :parentIds
        ];
    }

    private static List<Account> getAccountsOf(Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        return [
                SELECT Id, Territory__c, (SELECT Account__c, Account__r.Territory__c, Contact__c FROM References__r)
                FROM Account
                WHERE Territory__c IN :userIdsSetByTerritoryIdMap.keySet()
        ];
    }

    private static List<AccountShare> getAccountShares(List<Account> accounts, Set<Id> usersIds) {
        return [
                SELECT Id, AccountId, Account.Territory__c, UserOrGroupId
                FROM AccountShare
                WHERE (AccountId IN :accounts AND UserOrGroupId IN :usersIds)
        ];
    }

    private static List<ContactShare> getContactShares(Set<Id> contIdsSet, Set<Id> usersIds) {
        return [
                SELECT Id, ContactId, UserOrGroupId
                FROM ContactShare
                WHERE (ContactId IN :contIdsSet AND UserOrGroupId IN :usersIds)
        ];
    }

    private static AccountShare createAccountShare(Account acc, Id userId) {
        return new AccountShare(
                AccountId = acc.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'None',
                UserOrGroupId = userId,
                RowCause = 'Manual'
        );
    }

    private static ContactShare createContactShare(Reference__c reference, Id userId) {
        return new ContactShare(
                ContactId = reference.Contact__c,
                ContactAccessLevel = 'Edit',
                UserOrGroupId = userId,
                RowCause = 'Manual'
        );
    }

}