/**
 * Created by oberegovskyi on 01-Nov-18.
 */

public with sharing class SharingModelService {

    public static void setSharedAccountsAndContactsForTerrUsers(List<TerrUser__c> newTerrUsers) {
        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = getUserIdsSetByTerritoryIdMap(newTerrUsers);
        addHierarchicalRelationships(userIdsSetByTerritoryIdMap);
        List<Account> accounts = getAccountsWithReferences(userIdsSetByTerritoryIdMap.keySet());
        List<AccountShare> accountShares = new List<AccountShare>();
        List<ContactShare> contactShares = new List<ContactShare>();
        for (Account acc : accounts) {
            for (Id userId : userIdsSetByTerritoryIdMap.get(acc.Territory__c)) {
                AccountShare accountShare = createAccountShare(acc, userId);
                accountShares.add(accountShare);
                createContactShares(acc, userId, contactShares);
            }
        }

        insert accountShares;
        insert contactShares;

    }

    public static void deleteSharedAccountsAndContactsForTerrUsers(List<TerrUser__c> oldTerrUsers) {
        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = getUserIdsSetByTerritoryIdMap(oldTerrUsers);
        addHierarchicalRelationships(userIdsSetByTerritoryIdMap);
        Set<Id> usersIds = getUsersIds(userIdsSetByTerritoryIdMap);
        List<Account> accounts = getAccountsWithReferences(userIdsSetByTerritoryIdMap.keySet());
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

    public static void updateSharedAccountsForAccounts(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        List<Account> newAccountsWithChangedTerritory = getNewAccountsWithChangedTerritory(newAccounts, oldAccountsMap);
        List<AccountShare> accountSharesToDelete = getAccountSharesByAccounts(newAccountsWithChangedTerritory);
        List<Reference__c> relatedReferences = getRelatedReferencesByAccounts(newAccountsWithChangedTerritory);
        Map<Id, Set<Id>> contactIdsSetByAccountIdFromReferenceMap = getContactIdsSetByAccountIdByReferencesMap(relatedReferences);
        Set<Id> contactIdsFromRelatedReferences = SObjectsHelper.getIdFieldValues(relatedReferences, Reference__c.Contact__c);
        List<ContactShare> contactShares = getContactSharesByContactIdsSet(contactIdsFromRelatedReferences);
        Map<Id, List<ContactShare>> contactSharesListByContactIdMap = getContactSharesListByContactIdMap(contactShares);
        List<ContactShare> contactSharesToDelete = getContactSharesToDelete(
                newAccountsWithChangedTerritory, contactIdsSetByAccountIdFromReferenceMap, contactSharesListByContactIdMap);

        delete accountSharesToDelete;
        delete contactSharesToDelete;

        setSharedAccountsForAccounts(newAccountsWithChangedTerritory);
    }

    public static void setSharedContactsForReferences(List<Reference__c> newReferences) {
        Map<Id, Set<Id>> contactIdsSetByAccountIdMap = getContactIdsSetByAccountIdByReferencesMap(newReferences);
        List<AccountShare> alreadyExistedAccountShares = getAccountSharesByAccountIdsSet(contactIdsSetByAccountIdMap.keySet());
        List<ContactShare> contactSharesToInsert = createContactSharesToInsert(alreadyExistedAccountShares, contactIdsSetByAccountIdMap);

        insert contactSharesToInsert;
    }

    public static void deleteSharedContactsForReferences(List<Reference__c> oldReferences) {
        Map<Id, Set<Id>> accountIdsSetByContactIdMap = getAccountIdsSetByContactIdMap(oldReferences);
        Set<Id> accountIdsSet = SObjectsHelper.getIdFieldValues(oldReferences, Reference__c.Account__c);
        List<AccountShare> relatedAccountShares = getAccountSharesByAccountIdsSet(accountIdsSet);
        Map<Id, Set<Id>> userIdsSetByAccountIdMap = getUserIdsSetByAccountIdMap(relatedAccountShares);
        Set<Id> contactIds = new Set<Id>(accountIdsSetByContactIdMap.keySet());
        List<ContactShare> potentialContactSharesToDelete = getContactSharesByContactIdsSet(contactIds);
        List<ContactShare> contactSharesToDelete = getFilteredContactSharesToDelete(
                potentialContactSharesToDelete, accountIdsSetByContactIdMap, userIdsSetByAccountIdMap
        );

        delete contactSharesToDelete;
    }

    @TestVisible
    private static List<ContactShare> getFilteredContactSharesToDelete(
            List<ContactShare> potentialContactSharesToDelete,
            Map<Id, Set<Id>> accountIdsSetByContactIdMap,
            Map<Id, Set<Id>> userIdsSetByAccountIdMap) {
        List<ContactShare> contactSharesToDelete = new List<ContactShare>();
        for (ContactShare share : potentialContactSharesToDelete) {
            Set<Id> accountIds = accountIdsSetByContactIdMap.get(share.ContactId);
            for (Id accId : accountIds) {
                Set<Id> userIds = userIdsSetByAccountIdMap.get(accId);
                if (userIds.contains(share.UserOrGroupId)) {
                    contactSharesToDelete.add(share);
                }
            }
        }
        return contactSharesToDelete;
    }

    @TestVisible
    private static List<ContactShare> getContactSharesToDelete(
            List<Account> newAccountsWithChangedTerritory,
            Map<Id, Set<Id>> contactIdsSetByAccountIdFromReferenceMap,
            Map<Id, List<ContactShare>> contactSharesListByContactIdMap) {
        List<ContactShare> contactSharesToDelete = new List<ContactShare>();
        for (Account acc : newAccountsWithChangedTerritory) {
            if (contactIdsSetByAccountIdFromReferenceMap.containsKey(acc.Id)) {
                Set<Id> relatedContactIds = contactIdsSetByAccountIdFromReferenceMap.get(acc.Id);
                for (Id relatedContactId : relatedContactIds) {
                    if (contactSharesListByContactIdMap.containsKey(relatedContactId)) {
                        contactSharesToDelete.addAll(contactSharesListByContactIdMap.get(relatedContactId));
                    }
                }
            }
        }
        return contactSharesToDelete;
    }

    @TestVisible
    private static List<ContactShare> getContactSharesToDelete(
            List<ContactShare> contactShares,
            Map<Id, List<Reference__c>> referencesByContactIdsMap,
            Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
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

    @TestVisible
    private static Map<Id, List<ContactShare>> getContactSharesListByContactIdMap(List<ContactShare> contactSharesToPotentialDelete) {
        Map<Id, List<ContactShare>> contactSharesListByContactIdMap = new Map<Id, List<ContactShare>>();
        for (ContactShare contactShare : contactSharesToPotentialDelete) {
            List<ContactShare> contactShares = null;
            if (contactSharesListByContactIdMap.containsKey(contactShare.ContactId)) {
                contactShares = contactSharesListByContactIdMap.get(contactShare.ContactId);
            } else {
                contactShares = new List<ContactShare>();
            }
            contactShares.add(contactShare);
            contactSharesListByContactIdMap.put(contactShare.ContactId, contactShares);
        }
        return contactSharesListByContactIdMap;
    }

    @TestVisible
    private static List<Account> getNewAccountsWithChangedTerritory(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        List<Account> newAccountsWithChangedTerritory = new List<Account>();
        for (Account acc : newAccounts) {
            Account oldAcc = oldAccountsMap.get(acc.Id);
            if (acc.Territory__c != oldAcc.Territory__c) {
                newAccountsWithChangedTerritory.add(acc);
            }
        }
        return newAccountsWithChangedTerritory;
    }

    @TestVisible
    private static List<ContactShare> createContactSharesToInsert(List<AccountShare> alreadyExistedAccountShares, Map<Id, Set<Id>> contactIdsSetByAccountIdMap) {
        List<ContactShare> contactSharesToInsert = new List<ContactShare>();
        for (AccountShare accShare : alreadyExistedAccountShares) {
            for (Id contactId : contactIdsSetByAccountIdMap.get(accShare.AccountId)) {
                ContactShare newContactShare = createContactShare(contactId, accShare);
                contactSharesToInsert.add(newContactShare);
            }
        }
        return contactSharesToInsert;
    }



    @TestVisible
    private static List<AccountShare> getAccountSharesForParentTerritories(List<Account> newAccounts, Map<Id, Territory__c> relatedTerritoriesByIdMap) {
        List<AccountShare> acctAccountSharesToInsert = new List<AccountShare>();
        Map<Id, Account> accountsWithReferences = getAccountsWithReferencesById(newAccounts);
        List<ContactShare> contShareToInsert = new List<ContactShare>();
        for (Account acc : newAccounts) {
            if (relatedTerritoriesByIdMap.containsKey(acc.Territory__c)) {
                Territory__c currentTerritory = relatedTerritoriesByIdMap.get(acc.Territory__c);
                Boolean hasParent = false;
                do {
                    for (TerrUser__c terrUser : currentTerritory.TerrUsers__r) {
                        AccountShare accShare = createAccountShare(acc, terrUser.User__c);
                        acctAccountSharesToInsert.add(accShare);
                        for (Reference__c reference : accountsWithReferences.get(acc.Id).References__r) {
                            ContactShare contShare = createContactShare(reference, terrUser.User__c);
                            contShareToInsert.add(contShare);
                        }
                    }
                    hasParent = currentTerritory.Parent_Territory__c != null;
                    if (hasParent) {
                        currentTerritory = relatedTerritoriesByIdMap.get(currentTerritory.Parent_Territory__c);
                    }
                } while (hasParent);
            }
        }

        insert contShareToInsert;
        return acctAccountSharesToInsert;
    }

    @TestVisible
    private static List<AccountShare> getAccountSharesToDelete(List<AccountShare> accountShares, Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        List<AccountShare> accountSharesToDelete = new List<AccountShare>();
        for (AccountShare accShare : accountShares) {
            if (userIdsSetByTerritoryIdMap.get(accShare.Account.Territory__c).contains(accShare.UserOrGroupId)) {
                accountSharesToDelete.add(accShare);
            }
        }
        return accountSharesToDelete;
    }

    @TestVisible
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

    @TestVisible
    private static Set<Id> getUsersIds(Map<Id, Set<Id>> userIdsSetByTerritoryIdMap) {
        Set<Id> usersIds = new Set<Id>();
        for (Set<Id> usersIdsSet : userIdsSetByTerritoryIdMap.values()) {
            usersIds.addAll(usersIdsSet);
        }
        return usersIds;
    }

    @TestVisible
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


    @TestVisible
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

    @TestVisible
    private static Map<Id, Set<Id>> getUserIdsSetByTerritoryIdMap(List<TerrUser__c> terrUsers) {
        Map<Id, Set<Id>> userIdsSetByTerritoryIdMap = new Map<Id, Set<Id>>();
        for (TerrUser__c terrUser : terrUsers) {
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

    @TestVisible
    private static Map<Id, Set<Id>> getContactIdsSetByAccountIdByReferencesMap(List<Reference__c> references) {
        Map<Id, Set<Id>> contactIdsSetByAccountIdByReferenceMap = new Map<Id, Set<Id>>();
        for (Reference__c reference : references) {
            Set<Id> contactIdsSet = null;
            if (contactIdsSetByAccountIdByReferenceMap.containsKey(reference.Account__c)) {
                contactIdsSet = contactIdsSetByAccountIdByReferenceMap.get(reference.Account__c);
            } else {
                contactIdsSet = new Set<Id>();
            }
            contactIdsSet.add(reference.Contact__c);
            contactIdsSetByAccountIdByReferenceMap.put(reference.Account__c, contactIdsSet);
        }
        return contactIdsSetByAccountIdByReferenceMap;
    }

    @TestVisible
    private static Map<Id, Set<Id>> getAccountIdsSetByContactIdMap(List<Reference__c> references) {
        Map<Id, Set<Id>> accountIdsSetByContactIdMap = new Map<Id, Set<Id>>();
        for (Reference__c reference : references) {
            Set<Id> accountIds = null;
            if (accountIdsSetByContactIdMap.containsKey(reference.Contact__c)) {
                accountIds = accountIdsSetByContactIdMap.get(reference.Contact__c);
            } else {
                accountIds = new Set<Id>();
            }
            accountIds.add(reference.Account__c);
            accountIdsSetByContactIdMap.put(reference.Contact__c, accountIds);
        }
        return accountIdsSetByContactIdMap;
    }

    @TestVisible
    private static Map<Id, Set<Id>> getUserIdsSetByAccountIdMap(List<AccountShare> relatedAccountShares) {
        Map<Id, Set<Id>> userIdsSetByAccountIdMap = new Map<Id, Set<Id>>();
        for (AccountShare accShare : relatedAccountShares) {
            Set<Id> userIds = null;
            if (userIdsSetByAccountIdMap.containsKey(accShare.AccountId)) {
                userIds = userIdsSetByAccountIdMap.get(accShare.AccountId);
            } else {
                userIds = new Set<Id>();
            }
            userIds.add(accShare.UserOrGroupId);
            userIdsSetByAccountIdMap.put(accShare.AccountId, userIds);
        }
        return userIdsSetByAccountIdMap;
    }

    @TestVisible
    private static void createContactShares(Account acc, Id userId, List<ContactShare> contactShares) {
        for (Reference__c reference : acc.References__r) {
            ContactShare contactShare = createContactShare(reference, userId);
            contactShares.add(contactShare);
        }
    }

    @TestVisible
    private static List<Account> getAccountsWithReferences(Set<Id> territoryIdsSet) {
        return AccountSelector.selectByTerritories(territoryIdsSet);
    }

    @TestVisible
    private static Map<Id, Account> getAccountsWithReferencesById(List<Account> newAccounts) {
        return AccountSelector.selectByIds(newAccounts);
    }

    @TestVisible
    private static List<Territory__c> getParentTerritories(Set<Id> territoryIds) {
        return TerritorySelector.selectByTerritoryIdsSet(territoryIds);
    }

    @TestVisible
    private static List<Territory__c> getChildTerritories(Set<Id> parentIds) {
        return TerritorySelector.selectByParentTerritoryIdsSet(parentIds);
    }

    @TestVisible
    private static List<Reference__c> getRelatedReferencesByAccounts(List<Account> newAccountsWithChangedTerritory) {
        return ReferenceSelector.selectByAccounts(newAccountsWithChangedTerritory);
    }

    @TestVisible
    private static List<AccountShare> getAccountSharesByAccounts(List<Account> newAccountsWithChangedTerritory) {
        return AccountShareSelector.selectByAccounts(newAccountsWithChangedTerritory);
    }

    @TestVisible
    private static List<AccountShare> getAccountSharesByAccountIdsSet(Set<Id> accountIdsSet) {
        return AccountShareSelector.selectByAccountIdsSet(accountIdsSet);
    }

    @TestVisible
    private static List<AccountShare> getAccountShares(List<Account> accounts, Set<Id> usersIds) {
        return AccountShareSelector.selectByAccountAndUserIdsSet(accounts, usersIds);
    }

    @TestVisible
    private static List<ContactShare> getContactSharesByContactIdsSet(Set<Id> contactIdsFromRelatedReferences) {
        return ContactShareSelector.selectByContactIdsSet(contactIdsFromRelatedReferences);
    }

    @TestVisible
    private static List<ContactShare> getContactShares(Set<Id> contactIdsSet, Set<Id> userIdsSet) {
        return ContactShareSelector.selectByContactIdsAndUserIds(contactIdsSet, userIdsSet);
    }

    @TestVisible
    private static AccountShare createAccountShare(Account acc, Id userId) {
        return SObjectCreator.createAccountShare(acc, userId);
    }

    @TestVisible
    private static ContactShare createContactShare(Reference__c reference, Id userId) {
        return SObjectCreator.createContactShare(reference, userId);
    }

    @TestVisible
    private static ContactShare createContactShare(Id contactId, AccountShare accShare) {
        return SObjectCreator.createContactShare(contactId, accShare);
    }

}