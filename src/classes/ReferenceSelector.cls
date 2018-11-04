/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class ReferenceSelector {

    public static List<Reference__c> selectByAccounts(List<Account> accounts) {
        return [
                SELECT Account__c, Contact__c
                FROM Reference__c
                WHERE Account__c IN :accounts
        ];
    }

}