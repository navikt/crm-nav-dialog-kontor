@isTest
public class DIA_DialogueAccessValidator_Test {
    @isTest
    static void testValidateAccess() {
        Boolean hasAccess = false;

        Thread__c thread = (Thread__c) DIA_TestDataFactory.createRecord(
            new Thread__c(CRM_API_Reference__c = '123TESTTHREAD')
        );
        Conversation_Note__c convNote = (Conversation_Note__c) DIA_TestDataFactory.createRecord(
            new Conversation_Note__c(CRM_API_Reference__c = '123TESTCONV')
        );
        Id[] fixedSearchResults = new Id[2];
        fixedSearchResults[0] = thread.Id;
        fixedSearchResults[1] = convNote.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        hasAccess = DIA_DialogueAccessValidator.validateDialogueAccess(new List<String>{ '123TESTTHREAD' })[0];
        hasAccess = DIA_DialogueAccessValidator.validateDialogueAccess(new List<String>{ '123TESTCONV' })[0];
        Test.stopTest();

        System.assertEquals(true, hasAccess);
    }
}
