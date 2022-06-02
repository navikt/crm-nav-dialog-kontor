@IsTest
private class DIA_MessageContentMigrator_Test {
    
    @TestSetup
    private static void makeData(){
        Conversation_Note__c convNote=(Conversation_Note__c)DIA_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Created_By_Ident__c=null, CRM_Conversation_Note__c='Test content'));
        convNote.CRM_Message_Content__c=null;
        update convNote;


        Thread__c thread = (Thread__c) DIA_TestDataFactory.createRecord(new Thread__c());
        Message__c message=(Message__c)DIA_TestDataFactory.createRecord(new Message__c(CRM_Message_Text__c = 'TEST MESSAGE', CRM_Thread__c = thread.Id));
        message.CRM_Message_Content__c=null;
        update message;
        Delete [SELECT Id FROM Message_Content__c];
    }

    @IsTest
    private static void testConversationNoteMigration(){

        System.assertEquals(0, [SELECT COUNT() FROM Message_Content__c], 'Expect no content record to be created from test data creation');
        Test.startTest();
        DIA_MessageContentMigrator batchClass = new DIA_MessageContentMigrator('Conversation_Note__c');
        Database.executeBatch(batchClass,1);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Message_Content__c], 'Expect content to be created');
        System.assertEquals(1, [SELECT COUNT() FROM Conversation_Note__c WHERE CRM_Message_Content__c!=null]);
    }

    @IsTest
    private static void testMessageMigration(){

        System.assertEquals(0, [SELECT COUNT() FROM Message_Content__c], 'Expect no content record to be created from test data creation');
        Test.startTest();
        DIA_MessageContentMigrator batchClass = new DIA_MessageContentMigrator('Message__c');
        Database.executeBatch(batchClass,1);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Message_Content__c], 'Expect content to be created');
        System.assertEquals(1, [SELECT COUNT() FROM Message__c WHERE CRM_Message_Content__c!=null]);
    }
}
