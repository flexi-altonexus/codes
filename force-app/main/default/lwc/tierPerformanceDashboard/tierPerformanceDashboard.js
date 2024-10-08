import { LightningElement, track, wire } from 'lwc';
import queryDashboardData from '@salesforce/apex/PerformanceDashboardController2.getPerformanceData';

export default class TierPerformanceDashboard extends LightningElement {
    @track dashboardDate;
    @track loading = true;

    constructor() {
        super();
        this.dashboardDate = new Date().toISOString().substring(0, 10);
    }

    @track dashboardData;
    @wire(queryDashboardData, { dashboardDate: '$dashboardDate' })
    getDashboardData({ error, data }) {
        console.log(this.dashboardDate);
        if (error) {
            console.log(error);
        } else if (data) {
            this.dashboardData = data;
            this.loading = false;
            console.log(data);
        }
    }

    updateData(event) {
        if (this.dashboardDate !== event.target.value) {
            this.dashboardDate = event.target.value;
            this.loading = true;
        }
    }

    exportAsCSV() {
        const rowData = this.template
            .querySelector('c-tier-performance-dashboard-table')
            .getDataForExport();

        let csvRows = [];

        rowData.forEach(row => {
            csvRows.push(`${row.toString()}`);
        });

        const downloadLink = this.template.querySelector('[data-download-link]');
        downloadLink.setAttribute(
            'href',
            'data:text/csv;charset=utf-8,' + encodeURI(csvRows.join('\n'))
        );
        downloadLink.setAttribute('download', 'agent_performance.csv');
        downloadLink.click();
    }
}