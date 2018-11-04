/**
 * Created by oberegovskyi on 04-Nov-18.
 */

public with sharing class SObjectCreator {


    public static AccountShare createAccountShare(Account acc, Id userId) {
        return new AccountShare(
                AccountId = acc.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'None',
                UserOrGroupId = userId,
                RowCause = 'Manual'
        );
    }

    public static ContactShare createContactShare(Reference__c reference, Id userId) {
        return new ContactShare(
                ContactId = reference.Contact__c,
                ContactAccessLevel = 'Edit',
                UserOrGroupId = userId,
                RowCause = 'Manual'
        );
    }

    public static ContactShare createContactShare(Id contactId, AccountShare accShare) {
        return new ContactShare(
                ContactId = contactId,
                UserOrGroupId = accShare.UserOrGroupId,
                ContactAccessLevel = 'Edit',
                RowCause = 'Manual'
        );
    }

}