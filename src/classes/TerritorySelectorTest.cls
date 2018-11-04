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
    public static void test() {
        Test.startTest();
            List<Territory__c> territories = TerritorySelector.selectByTerritoryIdsSet(new Set<Id>());
        Test.stopTest();
    }
}