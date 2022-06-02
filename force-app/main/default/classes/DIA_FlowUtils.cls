public with sharing class DIA_FlowUtils {
    @InvocableMethod(
        label='Get Object Name By API Reference'
        description='Returns list of object names corresponding to the input API References.'
        category='Flow Utils'
    )
    public static List<String> getObjNameByApiRef(List<String> apiRefs) {
        List<String> retList = new List<String>();
        //Get schema information
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

        for (String ref : apiRefs) {
            //Get prefix from API reference
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = ref.substring(0, 3);

            //Loop through all the sObject types returned by Schema
            for (Schema.SObjectType stype : gd.values()) {
                Schema.DescribeSObjectResult sobjRes = stype.getDescribe();
                String prefix = sobjRes.getKeyPrefix();

                //Check if the prefix matches with requested prefix
                if (prefix != null && prefix.equals(myIdPrefix)) {
                    retList.add(sobjRes.getName());
                    break;
                }
            }
        }

        return retList;
    }
}
