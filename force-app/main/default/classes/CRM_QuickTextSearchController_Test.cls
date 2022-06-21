@isTest
public class CRM_QuickTextSearchController_Test {
    @TestSetup
    static void makeData() {
        DIA_TestDataFactory.createRecord(new QuickText(Name = 'Abb', Message = 'Dette er en melding'));
    }

    @isTest
    static void searchRecordsTest() {
        Test.startTest();
        List<CRM_QuickTextSearchController.QuickTextMessage> msgList = CRM_QuickTextSearchController.searchRecords(
            'Melding'
        );
        Test.stopTest();
        System.assertEquals(msgList.isempty(), false);
    }
    @isTest
    static void getQuicktext_Test() {
        List<QuickText> qList = CRM_QuickTextSearchController.getQuicktexts();
    }
}
