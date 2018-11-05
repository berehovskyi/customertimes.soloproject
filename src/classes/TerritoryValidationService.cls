/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class TerritoryValidationService {

    public static void validateBasedOnUniquenessInHierarchy(List<Territory__c> territories) {
        Set<Id> parentTerritoryIdsSet = SObjectsHelper.getIdFieldValuesWithNulls(territories, Territory__c.Parent_Territory__c);
        List<Territory__c> siblingTerritories = TerritorySelector.selectByParentTerritoryIdsSet(parentTerritoryIdsSet);
        Map<Id, Set<String>> territoryNamesByParentTerIds = getTerritoryNamesByParentTerIdsMap(siblingTerritories);
        checkTerritoryNameUniqueness(territories, territoryNamesByParentTerIds);
    }

    @TestVisible
    private static Map<Id, Set<String>> getTerritoryNamesByParentTerIdsMap(List<Territory__c> siblingTerritories) {
        Map<Id, Set<String>> territoryNamesByParentTerIds = new Map<Id, Set<String>>();
        for (Territory__c territory : siblingTerritories) {
            Set<String> names = null;
            if (territoryNamesByParentTerIds.containsKey(territory.Parent_Territory__c)) {
                names = territoryNamesByParentTerIds.get(territory.Parent_Territory__c);
            } else {
                names = new Set<String>();
            }
            names.add(territory.Name);
            territoryNamesByParentTerIds.put(territory.Parent_Territory__c, names);
        }
        return territoryNamesByParentTerIds;
    }

    @TestVisible
    private static void checkTerritoryNameUniqueness(List<Territory__c> territories, Map<Id, Set<String>> territoryNamesByParentTerIds) {
        for (Territory__c territory : territories) {
            if (territoryNamesByParentTerIds.containsKey(territory.Parent_Territory__c) && territoryNamesByParentTerIds.get(territory.Parent_Territory__c).contains(territory.Name)) {
                territory.addError('Territory ' + territory.Name + ' already exists at this level');
            }
        }
    }

}