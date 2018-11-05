/**
 * Created by oberegovskyi on 04-Nov-18.
 */

@IsTest
public with sharing class TerritorySelectorTest {

    @TestSetup
    public static void setupData() {
        Territory__c parentTerritory = new Territory__c(Name = 'TestParent');
        insert parentTerritory;

        List<Territory__c> territories = new List<Territory__c>();
        for (Integer i = 0; i < 10; i++) {
            territories.add(
                    new Territory__c (
                            Name = 'TestName' + i,
                            Parent_Territory__c = parentTerritory.Id
                    )
            );
        }

        insert territories;

    }

    @IsTest
    public static void selectByTerritoryIdsSetTest() {
        List<Territory__c> parentTerritories = [SELECT Id FROM Territory__c WHERE Name = 'TestParent'];
        Set<Id> parentTerIds = new Set<Id>();
        for (Territory__c ter : parentTerritories) {
            parentTerIds.add(ter.Id);
        }
        List<Territory__c> terList = [SELECT Id, Parent_Territory__c FROM Territory__c WHERE Parent_Territory__c IN :parentTerIds];
        Set<Id> terrIds = new Set<Id>();
        for (Territory__c ter: terList) {
            terrIds.add(ter.Id);
        }

        Test.startTest();
            List<Territory__c> territories = TerritorySelector.selectByTerritoryIdsSet(parentTerIds);
        Test.stopTest();

        for (Territory__c ter : territories) {
            System.assertEquals(true, parentTerIds.contains(ter.Id));
        }
    }

    @IsTest
    public static void selectByParentTerritoryIdsSetTest() {
        List<Territory__c> parentTerritories = [SELECT Id FROM Territory__c WHERE Name = 'TestParent'];
        Set<Id> parentTerIds = new Set<Id>();
        for (Territory__c ter : parentTerritories) {
            parentTerIds.add(ter.Id);
        }
        List<Territory__c> terList = [SELECT Id, Parent_Territory__c FROM Territory__c WHERE Parent_Territory__c IN :parentTerIds];
        Set<Id> terrIds = new Set<Id>();
        for (Territory__c ter: terList) {
            terrIds.add(ter.Id);
        }

        Test.startTest();
        List<Territory__c> territories = TerritorySelector.selectByParentTerritoryIdsSet(parentTerIds);
        Test.stopTest();

        for (Territory__c ter : territories) {
            System.assertEquals(true, parentTerIds.contains(ter.Parent_Territory__c));
        }
    }
}