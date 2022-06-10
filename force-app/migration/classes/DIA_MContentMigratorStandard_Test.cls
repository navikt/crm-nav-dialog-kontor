@IsTest
private class DIA_MContentMigratorStandard_Test {
    
    @TestSetup
    private static void makeData(){
        //we don't want person trigger access handlers to be run on test data insert
        myTriggers.disable(PersonAccessHandler.class);

        DIA_TestDataFactory.createRecord(
           new Person__c(INT_Confidential__c = 'UGRADERT', INT_IsNavEmployee__c = false, INT_FirstName__c='ABC', INT_LastName__c='DEF')
        );
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
       
        //create common code theme
        Common_Code__c themePen=(Common_Code__c) DIA_TestDataFactory.createRecord(
            new Common_Code__c(CRM_Code__c='PEN', CRM_Archive_Theme__c=true, CRM_Code_Set__c='Tema')
        );
       
        Conversation_Note__c convNote=(Conversation_Note__c)DIA_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Created_By_Ident__c=null, CRM_Conversation_Note__c='Test content', CRM_Theme__c=themePen.Id, CRM_Account__c=accountId));
        convNote.CRM_Message_Content__c=null;
        update convNote;


        Thread__c thread = (Thread__c) DIA_TestDataFactory.createRecord(new Thread__c(CRM_Theme__c=themePen.Id, CRM_Account__c=accountId));
        Message__c message=(Message__c)DIA_TestDataFactory.createRecord(new Message__c(CRM_Message_Text__c = 'TEST MESSAGE', CRM_Thread__c = thread.Id));
        message.CRM_Message_Content__c=null;
        update message;
        Delete [SELECT Id FROM Message_Content__c];
    }

    @IsTest
    private static void testConversationNoteMigration(){

        System.assertEquals(0, [SELECT COUNT() FROM Message_Content__c], 'Expect no content record to be created from test data creation');
        Test.startTest();
        DIA_MContentMigratorStandard batchClass = new DIA_MContentMigratorStandard('Conversation_Note__c', '');
        Database.executeBatch(batchClass,1);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Message_Content__c], 'Expect content to be created');
        System.assertEquals(1, [SELECT COUNT() FROM Conversation_Note__c WHERE CRM_Message_Content__c!=null]);

        Id themeGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_PEN' LIMIT 1].Id;
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :themeGroupId],
            'Expected content be shared with theme group PEN'
        );
    }

    @IsTest
    private static void testMessageMigration(){

        System.assertEquals(0, [SELECT COUNT() FROM Message_Content__c], 'Expect no content record to be created from test data creation');
        Test.startTest();
        DIA_MContentMigratorStandard batchClass = new DIA_MContentMigratorStandard('Message__c', '');
        Database.executeBatch(batchClass,1);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Message_Content__c], 'Expect content to be created');
        System.assertEquals(1, [SELECT COUNT() FROM Message__c WHERE CRM_Message_Content__c!=null]);
        Id themeGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_PEN' LIMIT 1].Id;
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :themeGroupId],
            'Expected content be shared with theme group PEN'
        );
    }
}
