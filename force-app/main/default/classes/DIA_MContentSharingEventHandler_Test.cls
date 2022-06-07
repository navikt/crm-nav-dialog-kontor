@IsTest
private class DIA_MContentSharingEventHandler_Test {
   
    @TestSetup
    private static void makeData(){
         //we don't want person trigger access handlers to be run on test data insert
         myTriggers.disable(PersonAccessHandler.class);

         DIA_TestDataFactory.createRecord(
            new Person__c(INT_Confidential__c = 'UGRADERT', INT_IsNavEmployee__c = false, INT_FirstName__c='ABC', INT_LastName__c='DEF')
         );

        
    }
    @IsTest
    private static void testExecute_shareConversationNoteContent(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id themeGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_PEN' LIMIT 1].Id;

        //create common code theme
        Common_Code__c themePen=(Common_Code__c) DIA_TestDataFactory.createRecord(
            new Common_Code__c(CRM_Code__c='PEN', CRM_Archive_Theme__c=true, CRM_Code_Set__c='Tema')
        );

        Test.startTest();
        DIA_TestDataFactory.createRecord(
            new Conversation_Note__c(CRM_Account__c = accountId, CRM_Created_By_Ident__c='A12345', 	CRM_Conversation_Note__c='Test content', CRM_Theme__c=themePen.Id)
        );
        Test.stopTest();
        System.assertEquals(3, [SELECT COUNT() FROM Log__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Message_Content__c]);
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share]);
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :themeGroupId],
            'Expected content be shared with theme group PEN'
        );
    }

    @IsTest
    private static void testExecute_shareMessageContent(){
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id themeGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_PEN' LIMIT 1].Id;

        //create common code theme
        Common_Code__c themePen=(Common_Code__c) DIA_TestDataFactory.createRecord(
            new Common_Code__c(CRM_Code__c='PEN', CRM_Archive_Theme__c=true, CRM_Code_Set__c='Tema')
        );

        Thread__c thread = (Thread__c) DIA_TestDataFactory.createRecord(new Thread__c(CRM_Account__c = accountId, CRM_Created_By_Ident__c='A12345',  CRM_Theme__c=themePen.Id));
        Test.startTest();
        DIA_TestDataFactory.createRecord(
            new Message__c(CRM_Message_Text__c = 'TEST MESSAGE', CRM_Thread__c = thread.Id)
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :themeGroupId],
            'Expected content be shared with theme group PEN'
        );
    }
}
