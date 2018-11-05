/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class ReferenceTriggerTest {

    @TestSetup
    static void setupData(){
        Account acc = new Account(
                Name = 'TestName'
        );
        insert acc;

        Contact con = new Contact(
                LastName = 'TestName'
        );
        insert con;
    }

    @IsTest
    static void onInsertTest() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Reference__c reference = new Reference__c(
                Account__c = acc.Id,
                Contact__c = con.Id
        );

        Test.startTest();
            Database.SaveResult result = Database.insert(reference);
        Test.stopTest();

        System.assert(result.isSuccess());
    }

    @IsTest
    static void onDeleteTest() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Reference__c reference = new Reference__c(
                Account__c = acc.Id,
                Contact__c = con.Id
        );
        insert reference;

        Test.startTest();
            Database.DeleteResult result = Database.delete(reference);
        Test.stopTest();

        System.assert(result.isSuccess());

    }
}