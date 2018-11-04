/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class ContactShareSelector {

    public static List<ContactShare> selectByContactIdsAndUserIds(Set<Id> contactIdsSet, Set<Id> userIdsSet) {
        return [
                SELECT Id, ContactId, UserOrGroupId
                FROM ContactShare
                WHERE (ContactId IN :contactIdsSet AND UserOrGroupId IN :userIdsSet AND RowCause = 'Manual')
        ];
    }

    public static List<ContactShare> selectByContactIdsSet(Set<Id> contactIdsSet) {
        return [
                SELECT Id, ContactId, UserOrGroupId
                FROM ContactShare
                WHERE (ContactId IN :contactIdsSet AND RowCause = 'Manual')
        ];
    }

}