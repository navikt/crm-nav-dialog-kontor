import { LightningElement, api, wire } from 'lwc';
import getmessages from '@salesforce/apex/DIA_ThreadViewController.getMessagesFromThread';
import getconvnotes from '@salesforce/apex/DIA_ThreadViewController.getConvNotes';

export default class DiaThreadViewer extends LightningElement {
    @api threadId;
    @api convNoteId;
    messages;
    error;

    @wire(getmessages, { threadId: '$threadId' }) //Calls apex and extracts messages related to this record
    wiremessages(result) {
        if (result.error) {
            this.error = result.error;
            console.log('Error: ' + JSON.stringify(error, null, 2));
        } else if (result.data) {
            this.messages = result.data;
        }
    }

    @wire(getconvnotes, { convNoteId: '$convNoteId' }) //Calls apex and converts conversation notes into the message wrapper model
    wireNotes(result) {
        if (result.error) {
            this.error = result.error;
            console.log('Error: ' + JSON.stringify(error, null, 2));
        } else if (result.data) {
            this.messages = this.convertConvNoteToMessages(result.data);
        }
    }

    convertConvNoteToMessages(convNotes) {
        let messages = [];

        convNotes.forEach((convNote) => {
            messages.push({
                CRM_External_Message__c: false,
                CRM_Message_Text__c: convNote.CRM_Conversation_Note__c,
                CRM_Sent_date__c: convNote.CRM_Date_Time_Registered__c,
                CRM_From_First_Name__c:
                    convNote.CRM_Created_By_Ident__c + ' (NAV-enhet ' + convNote.CRM_Created_By_NAV_Unit__c + ')',
                CRM_From_User__c: convNote.CreatedById
            });
        });

        return messages;
    }
}
