@isTest
public class DIA_NavTaskSyncCtrl_TEST {
    @isTest
    static void testSyncOpenAndAssigned() {
        ApiMock.setTestMock('GET_OPPGAVE', 200, 'OK');

        Test.startTest();
        DIA_NavTaskSyncCtrl.syncOpenAndAssigned();
        Test.stopTest();
    }
}
