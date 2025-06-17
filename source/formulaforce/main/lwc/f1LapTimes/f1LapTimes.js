import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getLapTimes from '@salesforce/apex/F1LapTimeController.getLapTimes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: 'Driver Name',
        fieldName: 'driver_name__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Lap',
        fieldName: 'lap__c',
        type: 'number',
        sortable: true
    },
    {
        label: 'Position',
        fieldName: 'position__c',
        type: 'number',
        sortable: true
    },
    {
        label: 'Time',
        fieldName: 'time__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Milliseconds',
        fieldName: 'milliseconds__c',
        type: 'number',
        sortable: true
    }
]

export default class F1LapTimes extends LightningElement {
    @api recordId;
    @track data = [];
    @track filteredData = [];
    @track columns = COLUMNS;
    @track error;
    @track isLoading = true;
    @track driverOptions = [];
    @track selectedDrivers = [];

    sortDirection = 'asc';
    sortedBy;
    dataCloudId;

    // wire to get the hosting record's Data_Cloud_Id__c field
    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['$objectApiName.Data_Cloud_Id__c']
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.dataCloudId = data.fields.Data_Cloud_Id__c?.value;
            if (this.dataCloudId) {
                this.loadLapTimes();
            } else {
                this.error = 'No Data Cloud Id found on this record';
                this.isLoading = false;
            }
        } else if (error) {
            this.error = error.body?.message || 'Error loading record';
            this.isLoading = false;
        }
    }

    // Get object API name dynamically
    get objectApiName() {
        // This would need to be set based on hosting object
        // e.g. 'Race__c' or whatever hosting object is
        return 'Race__c';
    }
}