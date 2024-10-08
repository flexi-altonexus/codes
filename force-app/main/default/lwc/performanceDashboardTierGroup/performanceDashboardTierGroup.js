import { LightningElement, api, track } from 'lwc';

export default class PerformanceDashboardTierGroup extends LightningElement {
    @api tierName;
    @track monthlyTarget;
    @track closedLastWeek;
    @track closedThisWeek;
    @track closedThisMonth;
    @track expectedThisMonth;
    @track predictedTotalThisMonth;
    @track expectedTotalNextMonth;
    @track totalLeads;
    @track totalOpps;
    @track arrangeViewings;
    @track completedViewings;
    @track deals;

    @track expanded = false;

    connectedCallback() {
        this.template.host.style.display = 'table-row-group';
    }

    _tierMembers;
    members;
    tierDetails;
    @api get tierMembers() {
        return this._tierMembers;
    }

    set tierMembers(value) {
        this._tierMembers = value;
        const members = [];

        let monthlyTarget = 0;
        let closedLastWeek = 0;
        let closedThisWeek = 0;
        let closedThisMonth = 0;
        let expectedThisMonth = 0;
        let predictedTotalThisMonth = 0;
        let expectedTotalNextMonth = 0;
        let totalLeads = 0;
        let totalOpps = 0;
        let arrangeViewings = 0;
        let completedViewings = 0;
        let deals = 0;

        if (value) {
            value.forEach(member => {
                const memberDetails = JSON.parse(JSON.stringify(member));
                memberDetails.title = `${memberDetails.name} - ${this.tierName}`;

                monthlyTarget += memberDetails.monthlyTarget;
                closedLastWeek += memberDetails.closedLastWeek;
                closedThisWeek += memberDetails.closedThisWeek;
                closedThisMonth += memberDetails.closedThisMonth;
                expectedThisMonth += memberDetails.expectedThisMonth;
                predictedTotalThisMonth += memberDetails.predictedTotalThisMonth;
                expectedTotalNextMonth += memberDetails.expectedTotalNextMonth;
                totalLeads += memberDetails.totalLeads;
                totalOpps += memberDetails.totalOpps;
                arrangeViewings += memberDetails.arrangeViewings;
                completedViewings += memberDetails.completedViewings;
                deals += memberDetails.deals;

                members.push(memberDetails);
            });
        }

        this.members = members;

        this.monthlyTarget = monthlyTarget;
        this.closedLastWeek = closedLastWeek;
        this.closedThisWeek = closedThisWeek;
        this.closedThisMonth = closedThisMonth;
        this.expectedThisMonth = expectedThisMonth;
        this.predictedTotalThisMonth = predictedTotalThisMonth;
        this.expectedTotalNextMonth = expectedTotalNextMonth;
        this.totalLeads = totalLeads;
        this.totalOpps = totalOpps;
        this.arrangeViewings = arrangeViewings;
        this.completedViewings = completedViewings;
        this.deals = deals;
    }

    expandGroup() {
        this.expanded = !this.expanded;
    }

    get multipleMembers() {
        return this.members ? this.members.length > 0 : false;
    }

    @api getRowDataForExport() {
        const rowData = [];

        try {
            this.template.querySelectorAll('c-performance-dashboard-row').forEach(row => {
                rowData.push(row.getRowDataForExport());
            });
        } catch (e) {
            console.log(e);
        }

        return rowData;
    }
}