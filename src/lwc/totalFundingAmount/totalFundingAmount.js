import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/Account.Id';
import TotalAmmOverride_FIELD from '@salesforce/schema/Account.Total_Funding_Amount_Manual_Override__c';
import TotalFundAmmount_FIELD from '@salesforce/schema/Account.Total_Funding_Amount__c';

export default class TotalFundingAmount extends LightningElement {
    @api recordId;
    @track account;
    @track selectedValue;
    @track ammountVal;
    @track isDisabled;
    @track options = [];

    connectedCallback() {
        this.options.push({
            label: 'Calculated',
            value: 'Calculated'
        });
        this.options.push({
            label: 'Override',
            value: 'Override'
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name', 'Account.Total_Funding_Amount_Rollup__c', 'Account.Total_Funding_Amount_Manual_Override__c', 'Account.Total_Funding_Amount__c'] })
    getaccountRecord({ data, error }) {
        if (data) {
            this.account = data;

            console.log(JSON.parse(JSON.stringify(data)));
            this.selectedValue = JSON.parse(JSON.stringify(data.fields.Total_Funding_Amount_Manual_Override__c.value)) ? 'Override' : 'Calculated';
            this.ammountVal = this.selectedValue == 'Override' ? JSON.parse(JSON.stringify(data.fields.Total_Funding_Amount__c.value)) : JSON.parse(JSON.stringify(data.fields.Total_Funding_Amount_Rollup__c.value))
            this.isDisabled = this.selectedValue == 'Override' ? false : true;
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error));
        }
    }

    handleFundAmmountChange(event) {
        console.log(event.target.value);
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[TotalFundAmmount_FIELD.fieldApiName] = event.target.value;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {

            })
            .catch(error => {

            });
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[TotalAmmOverride_FIELD.fieldApiName] = (event.detail.value == 'Override');

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Total Funding Amount updated',
                        variant: 'success'
                    })
                );*/
                // Display fresh data in the form
                //return refreshApex(this.contact);
            })
            .catch(error => {
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );*/
            });
    }
}