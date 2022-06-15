@IsTest
private class DIA_MContentPersonAccessHandler_Test {
    @TestSetup
    private static void makeData(){
         //we don't want person trigger access handlers to be run on test data insert
         myTriggers.disable(PersonAccessHandler.class);

         //create common code theme
         Common_Code__c themePen=(Common_Code__c) DIA_TestDataFactory.createRecord(
            new Common_Code__c(CRM_Code__c='PEN', CRM_Archive_Theme__c=true, CRM_Code_Set__c='Tema')
        );

        //ugradert
         Person__c ugradertPerson=(Person__c)DIA_TestDataFactory.createRecord(
             new Person__c(INT_Confidential__c = 'UGRADERT', INT_IsNavEmployee__c = false, INT_FirstName__c='ABC', INT_LastName__c='DEF')
          );        
         Id ugradertAccountId = [SELECT Id FROM Account WHERE CRM_Person__c = :ugradertPerson.Id LIMIT 1].Id;

        Conversation_Note__c convNoteUgradert=(Conversation_Note__c)DIA_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Created_By_Ident__c=null, CRM_Conversation_Note__c='Test content', CRM_Theme__c=themePen.Id, CRM_Account__c=ugradertAccountId));
       
         //skjemet
         Person__c skjermetPerson=(Person__c)DIA_TestDataFactory.createRecord(
             new Person__c(INT_Confidential__c = 'UGRADERT', INT_IsNavEmployee__c = true, INT_FirstName__c='Skjemet', INT_LastName__c='Person')
          );        
         Id skjermetAccountId = [SELECT Id FROM Account WHERE CRM_Person__c = :skjermetPerson.Id LIMIT 1].Id;

        Conversation_Note__c convNoteSkjermet=(Conversation_Note__c)DIA_TestDataFactory.createRecord(new Conversation_Note__c(CRM_Created_By_Ident__c=null, CRM_Conversation_Note__c='Test content', CRM_Theme__c=themePen.Id, CRM_Account__c=skjermetAccountId));
       

    }
  
    @IsTest
    private static void grantAccess_whePersonIsChagnedToNavEmployee() {
               
        Person__c person= [SELECT Id, CRM_Account__c, INT_Confidential__c, INT_IsNavEmployee__c FROM Person__c WHERE INT_IsNavEmployee__c=false LIMIT 1];
        Id skjermetGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Skjermet_PEN' LIMIT 1].Id;

        Test.startTest();
        system.debug('start-test');
        person.INT_IsNavEmployee__c = true;
        update person;
        system.debug('stop test');
        Test.stopTest();
        Conversation_Note__c note=[SELECT CRM_Message_Content__c FROM Conversation_Note__c WHERE CRM_Account__c=:person.CRM_Account__c LIMIT 1];
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :skjermetGroupId AND ParentId=:note.CRM_Message_Content__c],
            'Expected message content to be shared with group Skjermet_PEN'
        );
    }

    @IsTest
    private static void grantAccess_whePersonIsChagnedFromNavEmployee() {
               
        Person__c person= [SELECT Id, CRM_Account__c, INT_Confidential__c, INT_IsNavEmployee__c FROM Person__c WHERE INT_IsNavEmployee__c=true LIMIT 1];
        Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'Tema_PEN' LIMIT 1].Id;

        Test.startTest();
        person.INT_IsNavEmployee__c = false;
        update person;
        Test.stopTest();
        Conversation_Note__c note=[SELECT CRM_Message_Content__c FROM Conversation_Note__c WHERE CRM_Account__c=:person.CRM_Account__c LIMIT 1];
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Message_Content__Share WHERE RowCause = 'Manual' AND UserOrGroupId = :groupId AND ParentId=:note.CRM_Message_Content__c],
            'Expected message content to be shared with group Tema_PEN'
        );
    }

}
