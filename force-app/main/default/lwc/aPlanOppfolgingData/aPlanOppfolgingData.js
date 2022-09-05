import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOppfolgingsInfo from '@salesforce/apex/NKS_AktivitetsplanController.getOppfolgingsInfo';
import CASE_ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import ACCOUNT_PERSON_FIELD from '@salesforce/schema/Account.CRM_Person__c';
import PERSON_IDENT_FIELD from '@salesforce/schema/Person__c.Name';
import PERSON_ACTORID_FIELD from '@salesforce/schema/Person__c.INT_ActorId__c';
import PERSON_FIRST_NAME from '@salesforce/schema/Person__c.INT_FirstName__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class APlanOppfolgingData extends NavigationMixin(LightningElement) {
    @api actorId;
    @api recordId;
    @api objectApiName;
    accountField;
    url;
    veileder;
    oppfolgingsenhet;
    underOppfolging = false;
    firstName;
    actorId;
    name;
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

    viewOppfolging(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this.aktivitetsPageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Aktivitetsplan'
            },
            state: {
                c__ActorId: this.actorId,
                c__firstName: this.firstName,
                c__pName: this.name
            }
        };
        this[NavigationMixin.GenerateUrl](this.aktivitetsPageRef).then((url) => (this.url = url));
        this[NavigationMixin.Navigate](this.aktivitetsPageRef);
    }

    viewMeldekort(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this.aktivitetsPageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'NKS_Arenaytelser'
            },
            state: {
                c__personId: this.personId
            }
        };
        this[NavigationMixin.GenerateUrl](this.aktivitetsPageRef).then((url) => (this.url = url));
        this[NavigationMixin.Navigate](this.aktivitetsPageRef);
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
    wiredAccountInfo({ error, data }) {
        if (data) {
            this.personId = getFieldValue(data, ACCOUNT_PERSON_FIELD);
        }

        if (error) {
        }
    }

    @wire(getRecord, {
        recordId: '$personId',
        fields: [PERSON_ACTORID_FIELD, PERSON_IDENT_FIELD, PERSON_FIRST_NAME]
    })
    wiredPersonInfo({ error, data }) {
        if (data) {
            this.actorId = getFieldValue(data, PERSON_ACTORID_FIELD);
            this.name = getFieldValue(data, PERSON_IDENT_FIELD);
            this.firstName = getFieldValue(data, PERSON_FIRST_NAME);
        }

        if (error) {
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$accountField'
    })
    wiredRecordInfo({ error, data }) {
        if (data) {
            if (this.accountField) {
                this.accountId = getFieldValue(data, this.accountField[0]);
            }
        }
        if (error) {
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

    get oppfolgingIconVariant() {
        return this.underOppfolging === true ? '' : 'inverse';
    }
}
