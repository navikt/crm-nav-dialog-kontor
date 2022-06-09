public with sharing class DIA_MessageContentMigrator implements Database.Batchable<sObject> {
    private String query='';
    private String parentObject;
    private String themeCode;
   
    public DIA_MessageContentMigrator(String parentObject, String themeCode, String whereClause){
        this.parentObject=parentObject;
        this.themeCode=themeCode;
        Id themeId=null;
        if(themeCode!='Ingen'){
            themeId=[SELECT Id FROM Common_Code__c WHERE CRM_Code__c=:themeCode AND CRM_Active__c=true AND 	CRM_Archive_Theme__c=true LIMIT 1].Id;    
        }
        

        if(this.parentObject=='Conversation_Note__c'){
           query='SELECT Id, CRM_Message_Content__c, CRM_Conversation_Note__c, CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c, CRM_Account__r.CRM_Person__r.INT_Confidential__c FROM Conversation_Note__c WHERE ';
           if(themeId!=null){
                query+='CRM_Theme__c=\'' + themeId + '\'';
           }
           else{
                query+='CRM_Theme__c=null';
           }
            query+=whereClause;
        }

        if(this.parentObject=='Message__c'){
            query='SELECT Id, CRM_Message_Content__c, CRM_Message_Text__c, CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c, CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c FROM Message__c WHERE ';
            if(themeId!=null){
                query+='CRM_Thread__r.CRM_Theme__c=\'' + themeId + '\'';
           }
           else{
            query+='CRM_Thread__r.CRM_Theme__c=null';
           }
            query+=whereClause;
         }

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
    

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        //get theme groups for sharing
        String developerName='TEMA_' + themeCode;
        Id themeGroupId = [SELECT Id FROM Group WHERE DeveloperName =:developerName LIMIT 1].Id;
        developerName='SKJERMET_' + themeCode;
        Id skjermetGroupId = [SELECT Id FROM Group WHERE DeveloperName =:developerName LIMIT 1].Id;
        developerName='FORTROLIG_' + themeCode;
        Id fortroligGroupId = [SELECT Id FROM Group WHERE DeveloperName =:developerName LIMIT 1].Id;
        developerName='FORTROLIG_SKJERMET_' + themeCode;
        Id fortroligSkjermetGroupId = [SELECT Id FROM Group WHERE DeveloperName =:developerName LIMIT 1].Id;


        Map<Id,Id> contentIdByParentId=new Map<Id,Id>();
        Map<Id,Id> groupIdByParentId=new Map<Id,Id>();
        List<Message_Content__Share> shareRecords=new List<Message_Content__Share>();
        List<Message_Content__c> contentToBeInserted=new List<Message_Content__c>();

       if(parentObject=='Conversation_Note__c'){
        List<Conversation_Note__c> notes=(List<Conversation_Note__c>) scope;
        
        for(Conversation_Note__c note:notes){
            Message_Content__c content=new Message_Content__c();
            content.CRM_Message_Text__c=note.CRM_Conversation_Note__c;
            content.CRM_Parent_Record_Id__c=note.Id;
            contentToBeInserted.add(content);

            //get theme group message content related to this conv note
            if(note.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==FALSE && note.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='UGRADERT'){
                groupIdByParentId.put(note.Id,themeGroupId);
            }
            else if(note.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==TRUE && note.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='UGRADERT'){
                groupIdByParentId.put(note.Id,skjermetGroupId);
            }
            else if(note.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==FALSE && note.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='FORTROLIG'){
                groupIdByParentId.put(note.Id,fortroligGroupId);
            }
            else if(note.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==TRUE && note.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='FORTROLIG'){
                groupIdByParentId.put(note.Id,fortroligSkjermetGroupId);
            }
        }
        insert contentToBeInserted;
        
        for(Message_Content__c content:contentToBeInserted){
            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);

            //message content sharing
            Message_Content__Share share = new Message_Content__Share();
            share.ParentId = content.Id;
            share.UserOrGroupId = groupIdByParentId.get(content.CRM_Parent_Record_Id__c);
            share.AccessLevel = 'Edit';
            share.RowCause = 'Manual';
            if(groupIdByParentId.get(content.CRM_Parent_Record_Id__c)!=null){
                shareRecords.add(share);
            }
            
        }

        for(Conversation_Note__c note:notes){
            note.CRM_Message_Content__c=contentIdByParentId.get(note.Id);
        }
        update notes;
       }


       if(parentObject=='Message__c'){
        List<Message__c> messages=(List<Message__c>) scope;
        
        for(Message__c msg:messages){
            Message_Content__c content=new Message_Content__c();
            content.CRM_Message_Text__c=msg.CRM_Message_Text__c;
            content.CRM_Parent_Record_Id__c=msg.Id;
            contentToBeInserted.add(content);

              //get theme group message content related to this conv note
            if(msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==FALSE && msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='UGRADERT'){
                groupIdByParentId.put(msg.Id,themeGroupId);
            }
            else if(msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==TRUE && msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='UGRADERT'){
                groupIdByParentId.put(msg.Id,skjermetGroupId);
            }
            else if(msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==FALSE && msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='FORTROLIG'){
                groupIdByParentId.put(msg.Id,fortroligGroupId);
            }
            else if(msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_IsNavEmployee__c==TRUE && msg.CRM_Thread__r.CRM_Account__r.CRM_Person__r.INT_Confidential__c=='FORTROLIG'){
                groupIdByParentId.put(msg.Id,fortroligSkjermetGroupId);
            }
        }
        insert contentToBeInserted;

        for(Message_Content__c content:contentToBeInserted){
            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);

            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);

            //message content sharing
            Message_Content__Share share = new Message_Content__Share();
            share.ParentId = content.Id;
            share.UserOrGroupId = groupIdByParentId.get(content.CRM_Parent_Record_Id__c);
            share.AccessLevel = 'Edit';
            share.RowCause = 'Manual';
            if(groupIdByParentId.get(content.CRM_Parent_Record_Id__c)!=null){
                shareRecords.add(share);
            }
        }

        for(Message__c msg:messages){
            msg.CRM_Message_Content__c=contentIdByParentId.get(msg.Id);
        }
        update messages;
       }
       
       if(shareRecords.size()>0){
           insert shareRecords;
       }
     }
   
     public void finish(Database.BatchableContext context) {
       return;
     }
}
