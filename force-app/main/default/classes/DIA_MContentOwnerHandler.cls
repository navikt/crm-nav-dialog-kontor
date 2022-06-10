public with sharing class DIA_MContentOwnerHandler extends MyTriggers {
    public override void onBeforeInsert() {
        Id newOwnerId = RecordOwnerService.getDefaultOwner();

        if (newOwnerId != null) {
            for (Message_Content__c content : (List<Message_Content__c>) records) {
                content.OwnerId=newOwnerId;
            }
        }
    }
}
