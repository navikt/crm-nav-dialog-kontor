@IsTest
private class DIA_ConvNoteContentSharingHandler_Test {
    
    @TestSetup
    private static void makeData(){
         //we don't want person trigger access handlers to be run on test data insert
         myTriggers.disable(PersonAccessHandler.class);

         DIA_TestDataFactory.createRecord(
            new Person__c(INT_Confidential__c = 'UGRADERT', INT_IsNavEmployee__c = false, INT_FirstName__c='ABC', INT_LastName__c='DEF')
         );

        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;

        //create thread with tow messages
        DIA_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Account__c = accountId, CRM_Created_By_Ident__c='A12345'));
    }

    @IsTest
    private static void testUpdateConvNoteTheme(){
        //create common code theme
        Common_Code__c themePen=(Common_Code__c) DIA_TestDataFactory.createRecord(
            new Common_Code__c(CRM_Code__c='PEN', CRM_Archive_Theme__c=true, CRM_Code_Set__c='Tema')
        );

        Id ingenGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_INGEN' LIMIT 1].Id;
        Id penGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_PEN' LIMIT 1].Id;

        Test.startTest();
        //set thread theme
        Conversation_Note__c note=[SELECT Id, CRM_Theme__c FROM Conversation_Note__c LIMIT 1];
        note.CRM_Theme__c=themePen.Id;
        update note;
        Test.stopTest();

        System.assertEquals(
            0,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :ingenGroupId],
            'Expected content not be shared with theme group INGEN'
        );

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :penGroupId],
            'Expected content to be shared with theme group PEN'
        );
    }
}