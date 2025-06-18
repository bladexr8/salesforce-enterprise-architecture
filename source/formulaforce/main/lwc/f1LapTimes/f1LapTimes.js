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
        fields: [`Race__c.Data_Cloud_Id__c`]
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.dataCloudId = data.fields.Data_Cloud_Id__c?.value;
            if (this.dataCloudId) {
                console.log(`Race Data Cloud Id = ${this.dataCloudId}`);
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
    //get objectApiName() {
        // This would need to be set based on hosting object
        // e.g. 'Race__c' or whatever hosting object is
    //    return 'Race__c';
    //}

    async loadLapTimes() {
        try {
            this.isLoading = true;
            const result = await getLapTimes({ raceId: this.dataCloudId });
            this.data = result || [];
            this.filteredData = [...this.data];
            this.createDriverOptions();
            this.sortData('driver_name__c', 'asc');
        } catch (error) {
            this.error = error.body?.message || 'Error loading lap times';
            this.showToast('Error', this.error, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    createDriverOptions() {
        const drivers = [... new Set(this.data.map(row => row.driver_name__c))];
        this.driverOptions = drivers.map(driver => ({ label: driver, value: driver }));
    }

    handleDriverFilter(event) {
        console.log('[handleDriverFilter] Filtering Laps...');
        this.selectedDrivers = event.detail.value;
        this.filterData();
        console.log('[handleDriverFilter] Finished Filtering Laps...');
    }

    filterData() {
        console.log('[filterData] Filtering Laps...');
        if (this.selectedDrivers.length === 0) {
            this.filteredData = [...this.data];
        } else {
            console.log(`Drivers Selected = ${this.selectedDrivers.length}`);
            this.filteredData = this.data.filter(row => this.selectedDrivers.includes(row.driver_name__c));
        }

        // Maintain current sortng after filtering
        if (this.sortedBy) {
            TickerSymbol.sortData(this.sortedBy, this.sortDirection);
        }
        console.log('[filterData] Finished Filtering Laps...');
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortData(sortedBy, sortDirection);
    }

    sortData(fieldName, direction) {
        this.sortedBy = fieldName;
        this.sortDirection = direction;

        const parseData = [... this.filteredData];
        
        const isReverse = direction === 'asc' ? 1: -1;
        
        parseData.sort((a, b) => {
            let aVal = a[fieldName] || '';
            let bVal = b[fieldName] || '';

            // Handle numeric fields
            if (fieldName === 'lap__c' || fieldName === 'position__c' || fieldName === 'milliseconds__c') {
                aVal = parseFloat(aVal) || 0;
                bVal = parseFloat(bVal) || 0;
            }

            // Primary sort
            let result = 0;
            if (aVal > bVal) result = 1;
            if (aVal < bVal) result = -1;

            // Secondary sort by lap number if sorting by driver name
            if (result === 0 && fieldName === 'driver_name__c') {
                const aLap = parseFloat(a.lap__c) || 0;
                const bLap = parseFloat(b.lap__c) || 0;
                if (aLap > bLap) result = 1;
                if (aLap < bLap) result = -1;
            }

            return result * isReverse;
        });

        this.filteredData = parseData;
    }

    handleRefresh() {
        this.loadLapTimes();
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    get hasData() {
        return this.filteredData && this.filteredData.length > 0;
    }

    get recordCount() {
        return this.filteredData ? this.filteredData.length : 0;
    }

    get shouldShowNoDataMessage() {
    return !this.hasData && !this.isLoading && !this.error;
}

}