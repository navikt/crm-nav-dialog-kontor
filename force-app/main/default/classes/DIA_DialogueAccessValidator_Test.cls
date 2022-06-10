@isTest
public class DIA_DialogueAccessValidator_Test {
    @TestSetup
    static void makeData() {
        DIA_TestDataFactory.createRecord(new Thread__c(CRM_API_Reference__c = '123TESTTHREAD'));
        DIA_TestDataFactory.createRecord(new Conversation_Note__c(CRM_API_Reference__c = '123TESTCONV'));
    }

    @isTest
    static void testThreadAccess() {
        Boolean hasAccess = false;
        Test.startTest();
        hasAccess = DIA_DialogueAccessValidator.validateDialogueAccess(new List<String>{ '123TESTTHREAD' })[0];
        Test.stopTest();

        System.assertEquals(true, hasAccess);
    }

    @isTest
    static void testConvNoteAccess() {
        Boolean hasAccess = false;
        Test.startTest();
        hasAccess = DIA_DialogueAccessValidator.validateDialogueAccess(new List<String>{ '123TESTCONV' })[0];
        Test.stopTest();

        System.assertEquals(true, hasAccess);
    }
}
