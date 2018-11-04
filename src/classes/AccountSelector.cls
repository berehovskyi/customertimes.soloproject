/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class AccountSelector {

    public static List<Account> selectByTerritories(Set<Id> territoryIdsSet) {
        return [
                SELECT Id, Territory__c, (
                        SELECT Account__c, Account__r.Territory__c, Contact__c
                        FROM References__r
                )
                FROM Account
                WHERE Territory__c IN :territoryIdsSet
        ];
    }

    public static Map<Id, Account> selectByIds(List<Account> accounts) {
        return new Map<Id, Account>([
                SELECT Id, (
                        SELECT Account__c, Contact__c
                        FROM References__r
                )
                FROM Account
                WHERE Id IN :accounts
        ]);
    }
}