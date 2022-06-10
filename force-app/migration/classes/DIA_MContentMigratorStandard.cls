public with sharing class DIA_MContentMigratorStandard implements Database.Batchable<sObject> {
    private String query='';
    private String parentObject;
   
    public DIA_MContentMigratorStandard(String parentObject, String whereClause){
        this.parentObject=parentObject;
        
        if(this.parentObject=='Conversation_Note__c'){
            query='SELECT Id, CRM_Account__c, CRM_Theme_Code__c, CRM_Conversation_Note__c FROM Conversation_Note__c ';
            query+=whereClause;
        }

        if(this.parentObject=='Message__c'){
            query='SELECT Id, CRM_Thread__r.CRM_Account__c, CRM_Thread__r.CRM_Theme_Code__c, CRM_Message_Text__c FROM Message__c ';
            query+=whereClause;
         }

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
    

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        List<SobjectWrapper> sobjects = new List<SobjectWrapper>();
        Map<Id,Id> contentIdByParentId=new Map<Id,Id>();
        Map<Integer, Message_Content__c> messageContentByIndex=new Map<Integer,Message_Content__c>();
        Set<Id> accountIds=new Set<Id>();
        List<Message_Content__Share> shareRecords=new List<Message_Content__Share>();
        List<Message_Content__c> contentToBeInserted=new List<Message_Content__c>();

       if(parentObject=='Conversation_Note__c'){
        List<Conversation_Note__c> notes=(List<Conversation_Note__c>) scope;
        Map<Id,Conversation_Note__c> notesById=new Map<Id,Conversation_Note__c>();
        
        for(Conversation_Note__c note:notes){
            Message_Content__c content=new Message_Content__c();
            content.CRM_Message_Text__c=note.CRM_Conversation_Note__c;
            content.CRM_Parent_Record_Id__c=note.Id;
            contentToBeInserted.add(content);

            accountIds.add(note.CRM_Account__c);
            notesById.put(note.Id,note);
           
        }
        insert contentToBeInserted;
        Map<Id,Person__c> personByAccountId=getPersons(accountIds);
        
        Integer i=0;
        for(Message_Content__c content:contentToBeInserted){
            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);
            Conversation_Note__c note=notesById.get(content.CRM_Parent_Record_Id__c);
            Person__c person=personByAccountId.get(note.CRM_Account__c);
            SobjectWrapper wrapper = new SobjectWrapper();
            wrapper.recordIndex = i;
            wrapper.confidential = person.INT_Confidential__c;
            wrapper.isNavEmployee = person.INT_IsNavEmployee__c;
            wrapper.officeRestriction = false;
            wrapper.theme = note.CRM_Theme_Code__c;
            sobjects.add(wrapper);
            messageContentByIndex.put(i,content);
            i++;
        }

        for(Conversation_Note__c note:notes){
            note.CRM_Message_Content__c=contentIdByParentId.get(note.Id);
        }
        update notes;
       }


       if(parentObject=='Message__c'){
        List<Message__c> messages=(List<Message__c>) scope;
        Map<Id,Message__c> messageById=new Map<Id,Message__c>();
        
        for(Message__c msg:messages){
            Message_Content__c content=new Message_Content__c();
            content.CRM_Message_Text__c=msg.CRM_Message_Text__c;
            content.CRM_Parent_Record_Id__c=msg.Id;
            contentToBeInserted.add(content);

            accountIds.add(msg.CRM_Thread__r.CRM_Account__c);
            messageById.put(msg.Id,msg);
        }
        insert contentToBeInserted;

        Map<Id,Person__c> personByAccountId=getPersons(accountIds);
        Integer i=0;
        for(Message_Content__c content:contentToBeInserted){
            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);

            Message__c msg=messageById.get(content.CRM_Parent_Record_Id__c);
            Person__c person=personByAccountId.get(msg.CRM_Thread__r.CRM_Account__c);
            SobjectWrapper wrapper = new SobjectWrapper();
            wrapper.recordIndex = i;
            wrapper.confidential = person.INT_Confidential__c;
            wrapper.isNavEmployee = person.INT_IsNavEmployee__c;
            wrapper.officeRestriction = false;
            wrapper.theme = msg.CRM_Thread__r.CRM_Theme_Code__c;
            sobjects.add(wrapper);
            messageContentByIndex.put(i,content);
            i++;

        }

        for(Message__c msg:messages){
            msg.CRM_Message_Content__c=contentIdByParentId.get(msg.Id);
        }
        update messages;
       }
       
       List<ShareWrapper> shareWrappers = RecordShareService.grantAccess(sobjects, 'Message_Content__c');
       for (ShareWrapper share : shareWrappers) {
           Message_Content__Share mShare = new Message_Content__Share();
           Message_Content__c content = MessageContentByIndex.get(share.recordIndex);
           mShare.ParentId = content.Id;
           mShare.UserOrGroupId = share.publicGroupId;
           mShare.AccessLevel = 'Edit';
           mShare.RowCause = 'Manual';
           shareRecords.add(mShare);
       }
       insert shareRecords;
     }
   
     public void finish(Database.BatchableContext context) {
       return;
     }
     
     private Map<Id,Person__c> getPersons(Set<Id> accountIds){
        List<Person__c> persons=[
            SELECT INT_Confidential__c, INT_IsNavEmployee__c, CRM_Account__c
            FROM Person__C
            WHERE CRM_Account__c IN :accountIds
        ];
        Map<Id,Person__c> personByAccountId=new Map<Id,Person__c>();
        for(Person__c person:persons){
            personByAccountId.put(person.CRM_Account__c,person);
        }
        return personByAccountId;
     }

    
}
