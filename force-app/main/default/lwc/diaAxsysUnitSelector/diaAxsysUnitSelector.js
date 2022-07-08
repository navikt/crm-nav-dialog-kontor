import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import AXSYS_UNITS_FIELD from '@salesforce/schema/User.INT_Units__c';
import DEPARTMENT_FIELD from '@salesforce/schema/User.Department';

export default class DiaAxsysUnitSelector extends LightningElement {
    axsysUnits;
    selectedUnitId;

    @api label;

    get unitOptions() {
        let options = [];

        if (this.axsysUnits) {
            this.axsysUnits.forEach((axUnit) => {
                options.push({ label: axUnit.name + ' (' + axUnit.id + ')', value: axUnit.id });
            });
        }
        return options;
    }

    get selectionDisabled() {
        return this.axsysUnits && this.axsysUnits.length === 1 ? true : false;
    }

    @api
    get selectedUnitName() {
        let name = '';
        if (this.selectedUnitId) {
            for (let index = 0; index < this.axsysUnits.length; index++) {
                const axUnit = this.axsysUnits[index];
                if (axUnit.id === this.selectedUnitId) {
                    name = axUnit.name;
                    break;
                }
            }
        }
        return name;
    }
    @api
    get selectedUnitNumber() {
        return this.selectedUnitId ? this.selectedUnitId : null;
    }

    handleSelect(event) {
        this.selectedUnitId = event.detail.value;
        this.cacheSelection();
    }

    cacheSelection() {
        localStorage.setItem('DIA_AXSYS_UNIT', this.selectedUnitId);
    }

    @wire(getRecord, { recordId: userId, fields: [AXSYS_UNITS_FIELD, DEPARTMENT_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            let axUnits = getFieldValue(data, AXSYS_UNITS_FIELD);
            this.axsysUnits = JSON.parse(axUnits);

            //If no unit is selected, automatically select the first one OR the cached version
            if (!this.selectedUnitId) {
                if (localStorage.getItem('DIA_AXSYS_UNIT')) {
                    this.selectedUnitId = localStorage.getItem('DIA_AXSYS_UNIT');
                } else {
                    this.selectedUnitId = this.unitOptions[0].value;
                    this.cacheSelection();
                }
            }
        } else if (error) {
            console.log('Error: ' + JSON.stringify(error, null, 2));
        }
    }
}
