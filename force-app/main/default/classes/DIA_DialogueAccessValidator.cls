public with sharing class DIA_DialogueAccessValidator {
    @InvocableMethod(
        label='Check Dialogue Access'
        description='Verifies if the running user has access to the whole dialogue by api reference'
        category='Access Utilities'
    )
    public static List<Boolean> validateDialogueAccess(List<String> apiRefs) {
        return new List<Boolean>{ checkDialogueAccess(getDialogue(apiRefs[0])) };
    }

    /**
     * SOSL query for the dialogue by API Reference in the Thread__c and Conversation_Note__c table
     * @author Stian Ruud Schikora | 06-10-2022
     * @param apiReference
     * @return SObject
     **/
    private static SObject getDialogue(String apiReference) {
        List<List<SObject>> dialogs = [
            FIND :apiReference
            IN ALL FIELDS
            RETURNING
                Thread__c(Id, CRM_Number_of_Messages__c),
                Conversation_Note__c(Id, CRM_Message_Content__c WHERE CRM_API_Reference__c = :apiReference)
        ];

        return dialogs[0].size() > 0 ? dialogs[0][0] : dialogs[1][0];
    }

    /**
     * Check if user can access the dialogue
     * @author Stian Ruud Schikora | 06-10-2022
     * @param dialogue
     * @return Boolean
     **/
    private static Boolean checkDialogueAccess(SObject dialogue) {
        Id dialogueId = (Id) dialogue.get('Id');

        return dialogueId.getSobjectType().getDescribe().getName() == 'Thread__c'
            ? hasThreadAccess((Thread__c) dialogue)
            : hasConvNoteAccess((Conversation_Note__c) dialogue);
    }

    /**
     * Check if the user has access to the related Message_Content__c record
     * @author Stian Ruud Schikora | 06-10-2022
     * @param convNote
     * @return Boolean
     **/
    private static Boolean hasConvNoteAccess(Conversation_Note__c convNote) {
        Boolean hasAccess = false;

        List<Message_Content__c> conts = [
            SELECT Id
            FROM Message_Content__c
            WHERE Id = :convNote.CRM_Message_Content__c
        ];
        hasAccess = conts.size() > 0;

        return hasAccess;
    }

    /**
     * Verify that running user has access to ALL Message_Content__c record on the thread
     * @author Stian Ruud Schikora | 06-10-2022
     * @param thread
     * @return Boolean
     **/
    private static Boolean hasThreadAccess(Thread__c thread) {
        Set<Id> msgContIds = new Set<Id>();

        for (Message__c msg : [SELECT Id, CRM_Message_Content__c FROM Message__c WHERE CRM_Thread__c = :thread.Id]) {
            msgContIds.add(msg.CRM_Message_Content__c);
        }

        Integer numContents = [SELECT COUNT() FROM Message_Content__c WHERE Id IN :msgContIds];

        return thread.CRM_Number_of_Messages__c == numContents;
    }
}
