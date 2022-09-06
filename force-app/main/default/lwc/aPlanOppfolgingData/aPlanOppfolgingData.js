import { LightningElement, wire, api } from 'lwc';
import getOppfolgingsInfo from '@salesforce/apex/DIA_AktivitetsplanController.getOppfolgingsInfo';
import CASE_ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNT_PERSON_FIELD from '@salesforce/schema/Account.CRM_Person__c';
import PERSON_ACTORID_FIELD from '@salesforce/schema/Person__c.INT_ActorId__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class APlanOppfolgingData extends LightningElement {
    //@api actorId;
    @api recordId;
    @api objectApiName;
    accountField;
    veileder;
    oppfolgingsenhet;
    underOppfolging = false;
    actorId;
    isLoading = false;

    personId;
    accountId;

    connectedCallback() {
        this.isLoading = true;

        if (this.objectApiName === 'Case') {
            this.accountField = [CASE_ACCOUNT_FIELD];
            return;
        }
        if (this.objectApiName === 'Account') {
            this.accountId = this.recordId;
            this.accountField = [ACCOUNT_ID_FIELD];
            return;
        }
    }

    @wire(getOppfolgingsInfo, { actorId: '$actorId' })
    wireOppInfo({ data, error }) {
        if (data) {
            this.veileder = data.primaerVeileder;
            this.oppfolgingsenhet = data.OppfolgingsEnhet;
            this.underOppfolging = data.underOppfolging;
            this.isLoading = false;
        }
        if (error) {
            this.isLoading = false;
        }
    }

    @wire(getRecord, {
        recordId: '$accountId',
        fields: [ACCOUNT_PERSON_FIELD]
    })
    wiredAccountInfo({ data }) {
        if (data) {
            this.personId = getFieldValue(data, ACCOUNT_PERSON_FIELD);
        }
    }

    @wire(getRecord, {
        recordId: '$personId',
        fields: [PERSON_ACTORID_FIELD]
    })
    wiredPersonInfo({ data }) {
        if (data) {
            this.actorId = getFieldValue(data, PERSON_ACTORID_FIELD);
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$accountField'
    })
    wiredRecordInfo({ data }) {
        if (data) {
            if (this.accountField) {
                this.accountId = getFieldValue(data, this.accountField[0]);
            }
        }
    }

    //##################//
    //     GETTERS     //
    //##################//

    get cardTitle() {
        return this.underOppfolging === true
            ? 'Brukeren er under arbeidsrettet oppfølging'
            : 'Brukeren er ikke under arbeidsrettet oppfølging';
    }

    get ikkeUnderOppfolging() {
        return !this.underOppfolging;
    }
}
