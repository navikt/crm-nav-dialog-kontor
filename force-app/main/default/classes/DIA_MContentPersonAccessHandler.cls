global class DIA_MContentPersonAccessHandler extends MyTriggers {

    global override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<String> fieldNamesToCheck = new List<String>{ 'INT_Confidential__c', 'INT_IsNavEmployee__c', 'CRM_ManuallyRecalculatedSharing__c' };
        Set<Id> personIdsWithNewSharing = new Set<Id>();
        system.debug('start DIA');
        for (Person__c person : (List<Person__c>) records) {
              Person__c oldRecord = (Person__c) triggerOldMap.get(person.Id);
            if (MyTriggers.hasChangedFields(fieldNamesToCheck, person, oldRecord)) {
                personIdsWithNewSharing.add(person.Id);
            }
         }
         system.debug(personIdsWithNewSharing.size());
        Set<Id> messageContentIds=new Set<Id>();
        for(Message__c msg: getMessagesFromPersonIds(personIdsWithNewSharing)){
            messageContentIds.add(msg.CRM_Message_Content__c);
        }

        for(Conversation_Note__c convNote: getConvNotesFromPersonIds(personIdsWithNewSharing)){
            messageContentIds.add(convNote.CRM_Message_Content__c);
        }
        system.debug(messageContentIds);
        List<RecordSharingEvent__e> events=new List<RecordSharingEvent__e>();
        for(Id messageContentId:messageContentIds){
            RecordSharingEvent__e event=new RecordSharingEvent__e();
            event.RecordId__c=messageContentId;
            event.ObjectType__c='Message_Content__c';
            events.add(event);
        }
        if(events.size()>0){
            EventBus.publish(events);
        }
         
     }

     private List<Message__c> getMessagesFromPersonIds(Set<Id> personIds) {
        return [
            SELECT CRM_Message_Content__c
            FROM Message__c
            WHERE CRM_Thread__r.CRM_Account__r.CRM_Person__c IN :personIds AND CRM_Message_Content__c!=null
        ];
    }
   
    private List<Conversation_Note__c> getConvNotesFromPersonIds(Set<Id> personIds) {
        return [
            SELECT CRM_Message_Content__c
            FROM Conversation_Note__c
            WHERE CRM_Account__r.CRM_Person__c IN :personIds AND CRM_Message_Content__c!=null
        ];
    }
}
