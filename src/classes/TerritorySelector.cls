/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class TerritorySelector {

    public static List<Territory__c> selectByTerritoryIdsSet(Set<Id> territoryIdsSet) {
        return [
                SELECT Id, Name, Parent_Territory__c, (
                        SELECT User__c
                        FROM TerrUsers__r
                )
                FROM Territory__c
                WHERE Id IN :territoryIdsSet
        ];
    }

    public static List<Territory__c> selectByParentTerritoryIdsSet(Set<Id> parentTerritoryIdsSet) {
        return [
                SELECT Id, Name, Parent_Territory__c
                FROM Territory__c
                WHERE Parent_Territory__c IN :parentTerritoryIdsSet
        ];
    }

}