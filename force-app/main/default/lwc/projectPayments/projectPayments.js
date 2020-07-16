import { LightningElement, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import getProjectContacts from '@salesforce/apex/ProjectPaymentsController.getProjectPayments';

const PROJECT_FIELDS = [
    'Project__c.Total_Payments__c',
];
export default class ProjectPayments extends LightningElement {
    @api recordId;
    pageErrors;

    // Get the Project record for displaying summary info
    @wire(getRecord, { recordId: '$recordId', fields: PROJECT_FIELDS })
    project;

    // Get related Contacts along with their Payments
    @wire(getProjectContacts, {projectId: '$recordId'}) 
    contacts;

    get totalPayments(){
        return this.project.data.fields.Total_Payments__c.value;
    }

    get hasResults() {
		return (this.contacts.data.length > 0);
    }

    // Refresh in response to data changing in Contact payments
    refreshData(){
        refreshApex(this.project);
        refreshApex(this.contacts);

    }
}