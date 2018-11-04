/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class AccountShareSelector {

    public static List<AccountShare> selectByAccountAndUserIdsSet(List<Account> accounts, Set<Id> usersIds) {
        return [
                SELECT Id, AccountId, Account.Territory__c, UserOrGroupId
                FROM AccountShare
                WHERE (AccountId IN :accounts AND UserOrGroupId IN :usersIds AND RowCause = 'Manual')
        ];
    }

    public static List<AccountShare> selectByAccountIdsSet(Set<Id> accountIdsSet) {
        return [
                SELECT Id, AccountId, UserOrGroupId
                FROM AccountShare
                WHERE (AccountId IN :accountIdsSet AND RowCause = 'Manual')
        ];
    }

    public static List<AccountShare> selectByAccounts(List<Account> accounts) {
        return [
                SELECT Id
                FROM AccountShare
                WHERE (AccountId IN :accounts AND RowCause = 'Manual')
        ];
    }

}