global class DIA_ThreadContentSharingHandler extends MyTriggers {
    global override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<String> fieldNamesToCheck = new List<String>{'CRM_Theme__c'};
        Set<Id> threadIdsWithChangedTheme =new Set<Id>();

        for (Thread__c thread : (List<Thread__c>) records) {
            Thread__c oldRecord = (Thread__c) triggerOldMap.get(thread.Id);
            if (MyTriggers.hasChangedFields(fieldNamesToCheck, thread, oldRecord)) {
                threadIdsWithChangedTheme.add(thread.Id);
            }
        }

        if (threadIdsWithChangedTheme.size() > 0) {
            List<RecordSharingEvent__e> events=new List<RecordSharingEvent__e>();
           //get all messages related to changed threads
           for(Message__c message:[SELECT CRM_Message_Content__c FROM Message__c WHERE CRM_Thread__c in :threadIdsWithChangedTheme]){
            RecordSharingEvent__e event=new RecordSharingEvent__e();
            event.RecordId__c=message.CRM_Message_Content__c;
            event.ObjectType__c='Message_Content__c';
            events.add(event);
           }

           if(events.size()>0){
            EventBus.publish(events);
            }

       }
    }
}


