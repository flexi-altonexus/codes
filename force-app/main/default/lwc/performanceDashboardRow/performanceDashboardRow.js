import { LightningElement, api } from "lwc";
import CURRENCY_CODE from "@salesforce/i18n/currency";

export default class PerformanceDashboardRow extends LightningElement {
    @api rowName;
    @api monthlyTarget;
    @api closedLastWeek;
    @api closedThisWeek;
    @api closedThisMonth;
    @api expectedThisMonth;
    @api predictedTotalThisMonth;
    @api expectedTotalNextMonth;
    @api totalLeads;
    @api totalOpps;
    @api arrangeViewings;
    @api completedViewings;
    @api deals;

    @api subTotalOpps;
    @api subTotalLeads;

    @api expandable = false;
    @api expanded = false;

    @api highlightLowPredicted = false;

    connectedCallback() {
        this.template.host.style.display = "table-row";

        // if (this.rowName === "Sub Total - With AJ") {
        //     this.setupSubTotalAj();
        // }
    }

    get totalForecastForMonth() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.closedThisMonth + this.expectedThisMonth;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get leadsArrangeViewingPercentage() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.arrangeViewings / this.totalLeads;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get leadsCompletedViewingsPercentage() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.completedViewings / this.totalLeads;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get arrangedCompletedViewingsPercentage() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.completedViewings / this.arrangeViewings;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get leadsDealsPercentage() {
        if (this.rowName === "Sub Total - With AJ") {
            const result = this.deals / this.subTotalLeads;
            return !isNaN(result) && result !== Infinity ? result : 0;
        }
        const result = this.deals / this.totalLeads;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get completedViewingsDealsPercentage() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.deals / this.completedViewings;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get leadsToOpportunities() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.totalOpps / this.totalLeads;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get leadsToCompletedViewings() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.completedViewings / this.totalLeads;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get oppsToCompletedViewings() {
        if (this.rowName === "Sub Total - With AJ") {
            return null;
        }
        const result = this.completedViewings / this.totalOpps;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    get oppsToDeals() {
        if (this.rowName === "Sub Total - With AJ") {
            const result = this.deals / this.subTotalOpps;
            return !isNaN(result) && result !== Infinity ? result : 0;
        }
        const result = this.deals / this.totalOpps;
        return !isNaN(result) && result !== Infinity ? result : 0;
    }

    expandRow() {
        this.dispatchEvent(new CustomEvent("expand"));
    }

    get expandIcon() {
        return this.expanded ? "utility:chevrondown" : "utility:chevronright";
    }

    get currency() {
        return CURRENCY_CODE;
    }

    // setupSubTotalAj() {
    //     this.monthlyTarget = null;
    //     this.closedLastWeek = null;
    //     this.closedThisWeek = null;
    //     this.closedThisMonth = null;
    //     this.expectedThisMonth = null;
    //     this.predictedTotalThisMonth = null;
    //     this.expectedTotalNextMonth = null;
    //     this.totalLeads = null;
    //     this.totalOpps = null;
    //     this.arrangeViewings = null;
    //     this.completedViewings = null;
    // }

    @api getRowDataForExport() {
        return [
            this.rowName,
            this.monthlyTarget,
            this.closedLastWeek,
            this.closedThisWeek,
            this.closedThisMonth,
            this.expectedThisMonth,
            this.predictedTotalThisMonth,
            this.totalForecastForMonth,
            this.expectedTotalNextMonth,
            this.totalLeads,
            this.totalOpps,
            this.arrangeViewings,
            this.completedViewings,
            this.deals,
            this.leadsToOpportunities,
            this.leadsArrangeViewingPercentage,
            this.leadsCompletedViewingsPercentage,
            this.oppsToCompletedViewings,
            this.arrangedCompletedViewingsPercentage,
            this.completedViewingsDealsPercentage,
            this.oppsToDeals,
            this.leadsDealsPercentage
        ];
    }
}