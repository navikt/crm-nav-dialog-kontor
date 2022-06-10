public with sharing class DIA_DialogueAccessValidator {
    @InvocableMethod(
        label='Check Dialogue Access'
        description='Verifies if the running user has access to the whole dialogue by api reference'
        category='Access Utilities'
    )
    public static List<Boolean> validateDialogueAccess(List<String> apiRefs) {
        return new List<Boolean>{ checkDialogueAccess(getDialogue(apiRefs[0])) };
    }

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

    private static Boolean checkDialogueAccess(SObject dialogue) {
        Id dialogueId = (Id) dialogue.get('Id');

        return dialogueId.getSobjectType().getDescribe().getName() == 'Thread__c'
            ? hasThreadAccess((Thread__c) dialogue)
            : hasConvNoteAccess((Conversation_Note__c) dialogue);
    }

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

    private static Boolean hasThreadAccess(Thread__c thread) {
        Set<Id> msgContIds = new Set<Id>();

        for (Message__c msg : [SELECT Id, CRM_Message_Content__c FROM Message__c WHERE CRM_Thread__c = :thread.Id]) {
            msgContIds.add(msg.CRM_Message_Content__c);
        }

        Integer numContents = [SELECT COUNT() FROM Message_Content__c WHERE Id IN :msgContIds];

        return thread.CRM_Number_of_Messages__c == numContents;
    }
}
