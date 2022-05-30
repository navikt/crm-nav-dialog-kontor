public with sharing class DIA_MContentSharingEventHandler extends SharingEvent {
    public override void execute(Id recordId) {
        deleteExistingSharing(recordId);

       SobjectWrapper sobjectWrapper=getMessage(recordId);
       if(sobjectWrapper==null){
           sobjectWrapper=getConversationNote(recordId);
       }
        if(sobjectWrapper==null) return;

        List<Thread__Share> shareRecords = new List<Thread__Share>();
        List<ShareWrapper> shareWrappers = RecordShareService.grantAccess(new List<SobjectWrapper>{sobjectWrapper}, 'Message_Content__c');

        if(shareWrappers.size()>0){
            Message_Content__Share contentShare = new Message_Content__Share();
            contentShare.ParentId = recordId;
            contentShare.UserOrGroupId = shareWrappers[0].publicGroupId;
            contentShare.AccessLevel = 'Edit';
            contentShare.RowCause = 'Manual';
            insert contentShare;
        }
        
    }

    private SobjectWrapper getMessage(Id contentMessageRecordId){
        List<Message__c> messages=[SELECT CRM_Thread__r.CRM_Theme_Code__c, CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c, CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c, CRM_Thread__r.CRM_Office_Restriction__c FROM Message__c WHERE CRM_Message_Content__c=:contentMessageRecordId];
        if(messages.size()>0){
            SobjectWrapper wrapper = new SobjectWrapper();
            wrapper.recordIndex = 1;
            wrapper.confidential = messages[0].CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c;
            wrapper.isNavEmployee = messages[0].CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c;
            wrapper.officeRestriction = messages[0].CRM_Thread__r.CRM_Office_Restriction__c;
            wrapper.theme = messages[0].CRM_Thread__r.CRM_Theme_Code__c;
            return wrapper;
        }
        return null;
    }

    private SobjectWrapper getConversationNote(Id contentMessageRecordId){
        List<Conversation_Note__c> notes =[SELECT CRM_Theme_Code__c, CRM_Account__r.CRM_Person__r.INT_Confidential__c, CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c, CRM_Office_Restriction__c FROM Conversation_Note__c WHERE CRM_Message_Content__c=:contentMessageRecordId];
        if(notes.size()>0){
            SobjectWrapper wrapper = new SobjectWrapper();
            wrapper.recordIndex = 1;
            wrapper.confidential = notes[0].CRM_Account__r.CRM_Person__r.INT_Confidential__c;
            wrapper.isNavEmployee = notes[0].CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c;
            wrapper.officeRestriction = notes[0].CRM_Office_Restriction__c;
            wrapper.theme = notes[0].CRM_Theme_Code__c;
            return wrapper;
        }
        return null;
    }

    private void deleteExistingSharing(Id recordId){
       
        List<Message_Content__Share> toDelete = [
                SELECT Id
                FROM Message_Content__Share
                WHERE RowCause = 'Manual' AND ParentId=:recordId
            ];
            if(toDelete.size()>0){
                delete toDelete;
            }
    }
}