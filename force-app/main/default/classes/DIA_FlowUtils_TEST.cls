@isTest
public class DIA_FlowUtils_TEST {
    @TestSetup
    static void makeData() {
        insert new Thread__c();
    }

    @isTest
    static void testGetObjNameByAPIReference() {
        String apiRef = [SELECT CRM_API_Reference__c FROM Thread__c LIMIT 1]?.CRM_API_Reference__c;

        Test.startTest();
        List<String> objNames = DIA_FlowUtils.getObjNameByApiRef(new List<String>{ apiRef });
        Test.stopTest();

        System.assertEquals('Thread__c', objNames[0]);
    }
}
