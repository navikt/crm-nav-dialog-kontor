@isTest
public class DIA_ThreadViewController_TEST {
    @isTest
    static void testGetMessagesFromThread() {
        //Create testdata
        Thread__c thread = (Thread__c) DIA_TestDataFactory.createRecord(new Thread__c());
        DIA_TestDataFactory.createRecord(
            new Message__c(CRM_Message_Text__c = 'TEST MESSAGE', CRM_Thread__c = thread.Id)
        );
        Test.startTest();
        Id threadId = DIA_ThreadViewController.getThreadByRecordId(thread.Id);
        List<Message__c> messages = DIA_ThreadViewController.getMessagesFromThread(thread.Id);
        Test.stopTest();

        System.assert(messages.size() > 0, 'No messages!');
    }

    @isTest
    static void testGetConvNotes() {
        //Create testdata
        Conversation_Note__c convNote = (Conversation_Note__c) DIA_TestDataFactory.createRecord(
            new Conversation_Note__c()
        );
        Test.startTest();
        List<Conversation_Note__c> convNotes = DIA_ThreadViewController.getConvNote(convNote.Id);
        Test.stopTest();

        System.assert(convNotes.size() > 0, 'No conversation notes!');
    }

    @isTest
    static void testGetDialogueByApiReference() {
        //Create testdata
        Conversation_Note__c convNote = (Conversation_Note__c) DIA_TestDataFactory.createRecord(
            new Conversation_Note__c()
        );

        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = convNote.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
        String dialogue = DIA_ThreadViewController.getDialogueByApiReference('testference');
        Test.stopTest();

        System.assertNotEquals(null, dialogue);
    }
}
