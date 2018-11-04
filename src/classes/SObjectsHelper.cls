/**
 * Created by oberegovskyi on 03-Nov-18.
 */

public with sharing class SObjectsHelper {

    public static Set<Id> getIdFieldValues(List<SObject> sobjects, SObjectField field){
        String fieldName = field.getDescribe().getName();
        return getIdFieldValues(sobjects, fieldName);
    }

    public static Set<Id> getIdFieldValues(List<SObject> sobjects, String fieldName) {
        Set<Id> result = new Set<Id>();
        for(SObject sobj :sobjects){
            Id value = (Id) sobj.get(fieldName);
            result.add(value);
        }
        result.remove(null);
        return result;
    }

    public static Set<Id> getIdFieldValuesWithNulls(List<SObject> sobjects, SObjectField field){
        String fieldName = field.getDescribe().getName();
        return getIdFieldValuesWithNulls(sobjects, fieldName);
    }

    public static Set<Id> getIdFieldValuesWithNulls(List<SObject> sobjects, String fieldName) {
        Set<Id> result = new Set<Id>();
        for(SObject sobj :sobjects){
            Id value = (Id) sobj.get(fieldName);
            result.add(value);
        }
        return result;
    }


}