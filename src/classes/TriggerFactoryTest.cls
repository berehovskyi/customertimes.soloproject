/**
 * Created by oberegovskyi on 05-Nov-18.
 */

@IsTest
private class TriggerFactoryTest {

    @IsTest
    static void createHandlerSuccessTest(){
        Test.startTest();
            TriggerHandler handler = TriggerFactory.createHandler(Account.SObjectType);
        Test.stopTest();
        System.assertNotEquals(null, handler);
    }

    @IsTest
    static void createHandlerErrorTest(){
        try {
            Test.startTest();
            TriggerHandler handler = TriggerFactory.createHandler(Group.SObjectType);
            Test.stopTest();
        } catch (Exception exc) {
            System.assertEquals('No Trigger Handler registered for Object Type: Group', exc.getMessage());
        }
    }

    @IsTest
    static void getAccountHandlerTest() {
        Test.startTest();
            TriggerHandler handler = TriggerFactory.getHandler(Account.SObjectType);
        Test.stopTest();
        Boolean hasTheSameClass = handler instanceof AccountTriggerHandler;
        System.assertEquals(true, hasTheSameClass);
    }

    @IsTest
    static void getTerrUserHandlerTest() {
        Test.startTest();
        TriggerHandler handler = TriggerFactory.getHandler(TerrUser__c.SObjectType);
        Test.stopTest();
        Boolean hasTheSameClass = handler instanceof TerrUserTriggerHandler;
        System.assertEquals(true, hasTheSameClass);
    }

    @IsTest
    static void getReferenceHandlerTest() {
        Test.startTest();
        TriggerHandler handler = TriggerFactory.getHandler(Reference__c.SObjectType);
        Test.stopTest();
        Boolean hasTheSameClass = handler instanceof ReferenceTriggerHandler;
        System.assertEquals(true, hasTheSameClass);
    }

    @IsTest
    static void getTerritoryHandlerTest() {
        Test.startTest();
        TriggerHandler handler = TriggerFactory.getHandler(Territory__c.SObjectType);
        Test.stopTest();
        Boolean hasTheSameClass = handler instanceof TerritoryTriggerHandler;
        System.assertEquals(true, hasTheSameClass);
    }

    @IsTest
    static void getNonHandlerTest() {
        Test.startTest();
        TriggerHandler handler = TriggerFactory.getHandler(Group.SObjectType);
        Test.stopTest();
        System.assertEquals(null, handler);
    }

}