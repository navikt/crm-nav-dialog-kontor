public with sharing class DIA_MessageContentMigrator implements Database.Batchable<sObject> {
    private String query='';
    private String parentObject;
   
    public DIA_MessageContentMigrator(String parentObject){
        this.parentObject=parentObject;

        if(this.parentObject=='Conversation_Note__c'){
           query='SELECT Id, CRM_Message_Content__c, CRM_Conversation_Note__c FROM Conversation_Note__c WHERE CRM_Message_Content__c=null';
        }

        if(this.parentObject=='Message__c'){
            query='SELECT Id, CRM_Message_Content__c, CRM_Message_Text__c FROM Message__c WHERE CRM_Message_Content__c=null';
         }

    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }
    

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        Map<Id,Id> contentIdByParentId=new Map<Id,Id>();
        List<Message_Content__c> contentToBeInserted=new List<Message_Content__c>();

       if(parentObject=='Conversation_Note__c'){
        List<Conversation_Note__c> notes=(List<Conversation_Note__c>) scope;
        
        for(Conversation_Note__c note:notes){
            Message_Content__c content=new Message_Content__c();
            content.CRM_Message_Text__c=note.CRM_Conversation_Note__c;
            content.CRM_Parent_Record_Id__c=note.Id;
            contentToBeInserted.add(content);
        }
        insert contentToBeInserted;

        for(Message_Content__c content:contentToBeInserted){
            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);
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
        }
        insert contentToBeInserted;

        for(Message_Content__c content:contentToBeInserted){
            contentIdByParentId.put(content.CRM_Parent_Record_Id__c,content.Id);
        }

        for(Message__c msg:messages){
            msg.CRM_Message_Content__c=contentIdByParentId.get(msg.Id);
        }
        update messages;
       }
     }
   
     public void finish(Database.BatchableContext context) {
       return;
     }
}
