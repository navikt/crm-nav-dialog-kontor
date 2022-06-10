@IsTest
private class DIA_MContentOwnerHandler_Test {

    @IsTest
    private static void testInsertNewMessageContent() {
        //we don't want person trigger access handlers to be run on test data insert
        myTriggers.disable(PersonAccessHandler.class);
        
        Group queue = [SELECT Id FROM Group WHERE DeveloperName='Message_Content_Queue'];

        //mock custom settings for default owner
        insert new DefaultRecordOwner__c(SetupOwnerId = UserInfo.getProfileId(), UserOrQueueId__c = queue.Id);
     
        Test.startTest();
        DIA_TestDataFactory.createRecord(
            new Message_Content__c()
         );
        Test.stopTest();

        Message_Content__c newContent = [SELECT OwnerId FROM Message_Content__c LIMIT 1];
        System.assertEquals(queue.Id, newContent.OwnerId);
    }

    @IsTest
    private static void testInsertNewThread_whenDefaultOwnerIsNotSet() {
        //we don't want person trigger access handlers to be run on test data insert
        myTriggers.disable(PersonAccessHandler.class);
       
        Test.startTest();
        DIA_TestDataFactory.createRecord(
            new Message_Content__c()
         );
        Test.stopTest();

        Message_Content__c newContent = [SELECT OwnerId FROM Message_Content__c LIMIT 1];
        System.assertEquals(UserInfo.getUserId(), newContent.OwnerId);
    }
}
