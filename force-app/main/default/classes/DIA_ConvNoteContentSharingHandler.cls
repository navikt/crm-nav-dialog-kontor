global class DIA_ConvNoteContentSharingHandler extends MyTriggers {
    global override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<String> fieldNamesToCheck = new List<String>{'CRM_Theme__c'};
        Set<Id> convNoteIdsWithChangedTheme =new Set<Id>();

        for (Conversation_Note__c note : (List<Conversation_Note__c>) records) {
            Conversation_Note__c oldRecord = (Conversation_Note__c) triggerOldMap.get(note.Id);
            if (MyTriggers.hasChangedFields(fieldNamesToCheck, note, oldRecord)) {
                convNoteIdsWithChangedTheme.add(note.Id);
            }
        }

        if (convNoteIdsWithChangedTheme.size() > 0) {
            List<SharingEvent__e> events=new List<SharingEvent__e>();
           //get all messages related to changed threads
           for(Conversation_Note__c note:[SELECT CRM_Message_Content__c FROM Conversation_Note__c WHERE Id in :convNoteIdsWithChangedTheme]){
            SharingEvent__e event=new SharingEvent__e();
            event.RecordId__c=note.CRM_Message_Content__c;
            event.ObjectType__c='Message_Content__c';
            events.add(event);
           }

           if(events.size()>0){
            EventBus.publish(events);
            }

       }
    }
}


