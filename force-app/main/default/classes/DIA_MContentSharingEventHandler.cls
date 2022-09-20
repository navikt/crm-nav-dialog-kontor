public with sharing class DIA_MContentSharingEventHandler extends RecordSharingEvent {
    private Integer recordIndex=0;
    Map<Integer,Id> recordIdByIndex=new Map<Integer,Id>();
    private List<SobjectWrapper> sobjectWrappers;
    private static LoggerUtility logger = new LoggerUtility('Message Content Sharing');
    List<Id> recordIds=new List<Id>();

    public override void execute(List<RecordSharingEvent__e> recordSharingEvents) {
    try{
       

        for(RecordSharingEvent__e sharingEvent:recordSharingEvents){
            if(sharingEvent.ObjectType__c!='Message_Content__c'){
                continue;
            } 
            recordIds.add(sharingEvent.RecordId__c);
        }

        deleteExistingSharing(recordIds);
        sobjectWrappers=new List<SobjectWrapper>();
        findMessages(recordIds);
        if(recordIds.size()>sobjectWrappers.size()){
            //find conv notes if not all record ids was found in messages
            findConversationNotes(recordIds);
        }
       
        if(sobjectWrappers.size()==0){
            return;
        } 

        List<ShareWrapper> shareWrappers = RecordShareService.grantAccess(sobjectWrappers, 'Message_Content__c');
        List<Message_Content__Share> messageContentShares=new List<Message_Content__Share>();
        for(ShareWrapper share:shareWrappers){
            Message_Content__Share contentShare = new Message_Content__Share();
            contentShare.ParentId = recordIdByIndex.get(share.recordIndex);
            contentShare.UserOrGroupId = share.publicGroupId;
            contentShare.AccessLevel = 'Edit';
            contentShare.RowCause = 'Manual';
            messageContentShares.add(contentShare);
        }
        new CRM_DatabaseOperations().setNumberOfRetries(1).setDomain(CRM_ApplicationDomain.Domain.NKS).insertRecords(messageContentShares);
    } catch (Exception ex) {
        String recordIdsString = String.join( recordIds, ', ' );  
        logger.error('Failed to share records: ' + recordIdsString + '\n' + ex.getMessage() + '\n' + ex.getStackTraceString(), null, CRM_ApplicationDomain.Domain.NKS, null);
    } finally {
        logger.publish();
    }
        
    }

    private void findMessages(List<Id> contentMessageRecordIds){
        for(Message__c message:[SELECT CRM_Thread__r.CRM_Theme__r.CRM_Code__c, CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c, CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c, CRM_Thread__r.CRM_Office_Restriction__c, CRM_Message_Content__c FROM Message__c WHERE CRM_Message_Content__c in:contentMessageRecordIds]){
            SobjectWrapper wrapper = new SobjectWrapper();
            wrapper.recordIndex = recordIndex;
            wrapper.confidential = message.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c;
            wrapper.isNavEmployee = message.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c;
            wrapper.officeRestriction = message.CRM_Thread__r.CRM_Office_Restriction__c;
            wrapper.theme = message.CRM_Thread__r.CRM_Theme__r.CRM_Code__c;
            sobjectWrappers.add(wrapper);
            recordIdByIndex.put(recordIndex,message.CRM_Message_Content__c);
            recordIndex++;
        }
    }

    private void findConversationNotes(List<Id> contentMessageRecordIds){
        for(Conversation_Note__c note:[SELECT CRM_Theme__r.CRM_Code__c, CRM_Account__r.CRM_Person__r.INT_Confidential__c, CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c, CRM_Office_Restriction__c, CRM_Message_Content__c FROM Conversation_Note__c WHERE CRM_Message_Content__c in:contentMessageRecordIds]){
            SobjectWrapper wrapper = new SobjectWrapper();
            wrapper.recordIndex = recordIndex;
            wrapper.confidential = note.CRM_Account__r.CRM_Person__r.INT_Confidential__c;
            wrapper.isNavEmployee = note.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c;
            wrapper.officeRestriction = note.CRM_Office_Restriction__c;
            wrapper.theme = note.CRM_Theme__r.CRM_Code__c;
            sobjectWrappers.add(wrapper);
            recordIdByIndex.put(recordIndex,note.CRM_Message_Content__c);
            recordIndex++;
        }
    }

    private void deleteExistingSharing(List<Id> recordIds){
       
        List<Message_Content__Share> toDelete = [
                SELECT Id
                FROM Message_Content__Share
                WHERE RowCause = 'Manual' AND ParentId=:recordIds
            ];
            if(toDelete.size()>0){
                new CRM_DatabaseOperations().setNumberOfRetries(1).setDomain(CRM_ApplicationDomain.Domain.NKS).deleteRecords(toDelete);
            }
    }
}