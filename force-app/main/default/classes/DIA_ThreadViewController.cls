public with sharing class DIA_ThreadViewController {
    @AuraEnabled(cacheable=true)
    public static List<Message__c> getMessagesFromThread(Id threadId) {
        try {
            List<Message__c> msgList = new List<Message__c>();
            for (Message__c msg : [
                SELECT
                    Id,
                    CRM_Message_Content__r.CRM_Message_Text__c,
                    CRM_Type__c,
                    CRM_Event_Type__c,
                    CRM_Sent_date__c,
                    CRM_From_User__c,
                    CRM_From_Contact__c,
                    CRM_From_First_Name__c,
                    CRM_External_Message__c,
                    CRM_From_Label__c
                FROM Message__c
                WHERE CRM_Thread__c = :threadId
                ORDER BY CRM_Sent_date__c ASC
            ]) {
                msg.CRM_Message_Text__c = String.isBlank(msg.CRM_Message_Content__r.CRM_Message_Text__c)
                    ? Label.DIA_Message_No_Access
                    : msg.CRM_Message_Content__r.CRM_Message_Text__c;
                msgList.add(msg);
            }
            return msgList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
