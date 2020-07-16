import { LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import savePayments from '@salesforce/apex/ContactPaymentsController.savePayments';
import deletePayment from '@salesforce/apex/ContactPaymentsController.deletePayment';

import CONTACT from '@salesforce/schema/Payment__c.Contact__c';
import PROJECT from '@salesforce/schema/Payment__c.Project__c';
import PAYMENT_DATE from '@salesforce/schema/Payment__c.Payment_Date__c';
import PAYMENT_AMOUNT from '@salesforce/schema/Payment__c.Payment_Amount__c';
import ID_FIELD from '@salesforce/schema/Payment__c.Id';

const columns = [
    { label: 'Payment Number', fieldName: 'Name'},
    { label: 'Payment Amount', fieldName: 'Payment_Amount__c', editable: true, type: 'currency', typeAttributes: { currencyCode: 'USD'}},
    { 
        label: 'Payment Date', 
        fieldName: 'Payment_Date__c', 
        editable: true, 
        type: 'date-local'
    },
    {
        type: 'button-icon',
        fixedWidth: 40,
        typeAttributes: {
            iconName: 'utility:delete',
            name: 'delete', 
            title: 'Delete',
            variant: 'border-filled',
            alternativeText: 'delete',
            disabled: false
        }
    },
];

export default class ContactPayments extends LightningElement {

    columns = columns;

    @track draftValues = [];
    @track tableErrors;
    @track pageErrors;

    @track contact;
    @track data;
    @api projectid;

    @api
    get contactRecord(){
        return this.contact;
    }
    set contactRecord(value) {
        this.contact = value;
        this.data = [].concat(this.contact.Payments__r);
    }
    
    handleSave(event){

        let recordsToSave = [];
        let eventDraftValues = event.detail.draftValues;
        let areTableErrors = false;

        // Iterate through inserted and updated values, validate, and create records to send to the server
        for(var i=0; i<eventDraftValues.length; i++){
            // Only process rows that have changed
            var item = eventDraftValues[i];
            var dataitem = this.findDataItemById(item.Id);
            if(!item.Payment_Date__c) item.Payment_Date__c = dataitem.Payment_Date__c;
            if(!item.Payment_Amount__c) item.Payment_Amount__c = dataitem.Payment_Amount__c;
            item.Contact__c = dataitem.Contact__c;
            item.Project__c = dataitem.Project__c;

            let errorMessages = [];
            let errorFieldNames = [];

            // Validate Amount field
            var amountErrors = this.validateAmount(item.Payment_Amount__c);
            if(amountErrors != 'No Errors'){
                areTableErrors = true;
                errorMessages.push(amountErrors);
                errorFieldNames.push('Payment_Amount__c');
            }
            
            // Validate Date field
            var dateErrors = this.validateDate(item.Payment_Date__c);
            if(dateErrors != 'No Errors'){
                areTableErrors = true;
                errorMessages.push(dateErrors);
                errorFieldNames.push('Payment_Date__c');
            }

            // Post any errors that were found from field validation
            if(errorMessages.length > 0){
                this.addRowError(item.Id, 'Error with Payment', errorMessages, errorFieldNames);
            }

            // If there are no errors in the table them construct a record for upsert
            if(!areTableErrors){
                const recordFields = {};
                // Clean out Id values for new rows
                if(item.Id.includes('NEWRECORD'))
                    recordFields[ID_FIELD.fieldApiName] = null;
                else
                    recordFields[ID_FIELD.fieldApiName] = item.Id;
                

                recordFields[CONTACT.fieldApiName] = item.Contact__c;
                recordFields[PROJECT.fieldApiName] = item.Project__c;
                recordFields[PAYMENT_AMOUNT.fieldApiName] = item.Payment_Amount__c;
                recordFields[PAYMENT_DATE.fieldApiName] = item.Payment_Date__c;

                recordsToSave.push(recordFields);
            }
        }

        // If there were errors in the table then post them
        if(areTableErrors){
            this.addTableError('Payment Errors', ['There are one or more errors']);
        }
        // Otherwise, send records to the server
        else{
            savePayments({payments : recordsToSave})
            .then(() => {
                // Post a success message, retrieve updated contact and payments, and reset draft values
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Success',
                        message : `Records saved succesfully!`,
                        variant : 'success',
                    }),
                )
                this.draftValues = [];
                this.tableErrors = undefined;
                this.dispatchEvent(new CustomEvent('requestdatarefresh'));
            })
            .catch((error) => {
                console.log("Error in savePayments callback:", error);
                this.pageErrors = error;
            })
            .finally(() => {
            });
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        // Leaving this switched to leave room for more row actions later
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            default:
        }
    }

    // Delete a row from the payments table
    deleteRow(row) {
        if(confirm('WARNING: You are about to delete a Payment record!')){
            if(row.Id.includes('NEWRECORD')){
                const rowIndex = this.findDataIndexById(row.Id);
                const rows = [].concat(this.data);
                rows.splice(rowIndex, 1);
                this.data = rows;
            }
            else{
                // Send updates to server
                deletePayment({paymentId : row.Id})
                .then(() => {
                    // Post a success message, retrieve updated contact and payments, and reset draft values
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title : 'Success',
                            message : `Payment Record Deleted`,
                            variant : 'success',
                        }),
                    )
                    this.draftValues = [];
                    this.dispatchEvent(new CustomEvent('requestdatarefresh'));
                })
                .catch(error => {
                    console.log("Error in deleteRow callback:", error);
                })
                .finally(() => {
                });
            }
        }
    }

    handleAddPayment(event){
        var newList = [].concat(this.data);
        newList.push({
            Contact__c : this.contact.Id, 
            Project__c : this.projectid, 
            Id : 'NEWRECORD'+Math.random().toString(36).substring(2, 7), 
            Payment_Date__c : null,
            Payment_Amount__c : null
        });
        this.data = newList;
    }

    findDataItemById(idValue){
        for(var i=0; i<this.data.length; i++){
            if(this.data[i].Id == idValue)
                return this.data[i];
        }
        return null;
    }
    findDataIndexById(idValue){
        for(var i=0; i<this.data.length; i++){
            if(this.data[i].Id == idValue)
                return i;
        }
        return null;
    }

    validateAmount(amount){
        if(!amount)
            return 'An amount is required for every payment';

        // This is largely unnecessary with the PayemntAmount column 
        // set to a type of Currency, but it was specifically called out
        // in the requirements
        var currencyRegex  = /^\d+(?:\.?\d{0,2})$/;
        if (!currencyRegex.test(amount))
            return 'Amount must be a valid currency value';
        
        return 'No Errors';
    }

    validateDate(dateValue){

        // Verify that there is a date value provided
        if(!dateValue)
            return 'A date value is required for every payment';

        // This is largely unnecessary with the PaymentDate column 
        // set to a type of date-local in the datatable, but it was specifically called out
        // in the requirements
        var dateRegex  = /^(19|20)\d\d-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/;
        if (!dateRegex.test(dateValue))
            return 'Invalid Date Value';

        return 'No Errors';
    }

    addRowError(rowKey, errorTitle, errorMessages, errorFieldNames){
        if(this.tableErrors==undefined || this.tableErrors==null ){
            this.tableErrors = { rows: {}, table: {} };
        }
        this.tableErrors.rows[rowKey] = {title: errorTitle, messages: errorMessages, fieldNames: errorFieldNames};
    }

    addTableError(errorTitle, errorMessages){
        if(this.tableErrors==undefined || this.tableErrors==null ){
            this.tableErrors = { rows: {}, table: {} };
        }
        this.tableErrors['table'] = {title: errorTitle, messages: errorMessages};
    }
}