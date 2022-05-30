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

    /**
     * Get a thread by using the record ID passed from LWC. Can be either a thread ID by itself, or any other SF ID
     * @author Stian Ruud Schikora | 05-26-2022
     * @param recordId
     * @return Id
     **/
    @AuraEnabled
    public static Id getThreadByRecordId(Id recordId) {
        try {
            if (recordId.getSobjectType().getDescribe().getName() == 'Thread__c')
                return recordId;

            return [SELECT Id FROM Thread__c WHERE CRM_Related_Object__c = :recordId LIMIT 1]?.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get a conversation note by using the api reference as input
     * @author Stian Ruud Schikora | 05-26-2022
     * @param recordId
     * @return Id
     **/
    @AuraEnabled(cacheable=true)
    public static String getDialogueByApiReference(String reference) {
        Map<String, String> retMap = new Map<String, String>();
        try {
            List<List<SObject>> dialogs = [
                FIND :reference
                IN ALL FIELDS
                RETURNING Thread__c(Id), Conversation_Note__c(Id)
            ];
            return dialogs[0].size() > 0 ? JSON.serialize(dialogs[0][0]) : JSON.serialize(dialogs[1][0]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Conversation_Note__c> getConvNote(Id convNoteId) {
        List<Conversation_Note__c> convNotes = [
            SELECT
                Id,
                CRM_Date_Time_Registered__c,
                CRM_Created_By_Ident__c,
                CRM_Created_By_NAV_Unit__c,
                CRM_Message_Content__r.CRM_Message__c,
                CreatedById
            FROM Conversation_Note__c
            WHERE Id = :convNoteId
        ];

        for (Conversation_Note__c convNote : convNotes) {
            convNote.CRM_Conversation_Note__c = String.isBlank(convNote.CRM_Message_Content__r.CRM_Message__c)
                ? Label.DIA_Message_No_Access
                : convNote.CRM_Message_Content__r.CRM_Message__c;
        }

        return convNotes;
    }
}
