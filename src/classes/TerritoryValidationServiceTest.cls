/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class TerritoryValidationServiceTest {

    @TestSetup
    static void setupData() {
        Territory__c parentTerritory = new Territory__c(Name = 'TestParent');
        insert parentTerritory;

        List<Territory__c> territories = new List<Territory__c>();
        for (Integer i = 0; i < 100; i++) {
            territories.add(
                    new Territory__c (
                            Name = 'Name' + i,
                            Parent_Territory__c = parentTerritory.Id
                    )
            );
        }
        insert territories;
    }

    @IsTest
    static void getTerritoryNamesByParentTerIdsMapTest() {
        List<Territory__c> territories = [SELECT Id, Name, Parent_Territory__c FROM Territory__c];

        Test.startTest();
        Map<Id, Set<String>> territoryNamesByParentTerIds = TerritoryValidationService.getTerritoryNamesByParentTerIdsMap(territories);
        Test.stopTest();

        for (Territory__c terr : territories) {
            System.assertEquals(true, territoryNamesByParentTerIds.containsKey(terr.Parent_Territory__c), 'Incorrect Parent Territory');
        }
    }

    @IsTest
    static void checkTerritoryNameUniquenessTest() {
        List<Territory__c> territories = [SELECT Id, Name, Parent_Territory__c FROM Territory__c];
        territories.get(0).Name = territories.get(1).Name;
        Map<Id, Set<String>> territoryNamesByParentTerIds = TerritoryValidationService.getTerritoryNamesByParentTerIdsMap(territories);

        try {
            Test.startTest();
                TerritoryValidationService.checkTerritoryNameUniqueness(territories, territoryNamesByParentTerIds);
            Test.stopTest();
        } catch (Exception exc) {
            System.assert(exc.getMessage().contains('Territory Name0 already exists at this level'));
        }

    }
}