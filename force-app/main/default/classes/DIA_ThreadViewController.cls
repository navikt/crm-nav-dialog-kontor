public with sharing class DIA_ThreadViewController {
    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessagesFromThread(Id threadId) {
        return CRM_MessageHelper.getMessagesFromThread(threadId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Conversation_Note__c> getConvNotes(Id convNoteId) {
        List<Message__c> returnMsgs = new List<Message__c>();
        Conversation_Note__c masterNote = [
            SELECT CRM_Henvendelse_BehandlingskjedeId__c
            FROM Conversation_Note__c
            WHERE Id = :convNoteId
        ];

        return [
            SELECT
                Id,
                CRM_Date_Time_Registered__c,
                CRM_Created_By_Ident__c,
                CRM_Created_By_NAV_Unit__c,
                CRM_Conversation_Note__c,
                CreatedById
            FROM Conversation_Note__c
            WHERE CRM_Henvendelse_BehandlingskjedeId__c = :masterNote.CRM_Henvendelse_BehandlingskjedeId__c
        ];
    }
}
