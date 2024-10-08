import { LightningElement, api, track } from "lwc";
import headers from "./headers.js";

export default class PerformanceDashboardTable extends LightningElement {
    @track _tiers;
    @api get tiers() {
        return this._tiers;
    }
    set tiers(value) {
        this._tiers = value;
        let allAgents = [];

        if (this._tiers) {
            this._tiers.forEach((tier) => {
                allAgents = allAgents.concat(tier.members);
            });
        }

        const grandTotal = this.calculateTotal(allAgents);

        Object.keys(grandTotal).forEach((totalKey) => {
            this[totalKey] = grandTotal[totalKey];
        });
    }

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

    get headers() {
        return headers;
    }

    calculateTotal(agents = []) {
        const total = {
            monthlyTarget: 0,
            closedLastWeek: 0,
            closedThisWeek: 0,
            closedThisMonth: 0,
            expectedThisMonth: 0,
            predictedTotalThisMonth: 0,
            expectedTotalNextMonth: 0,
            totalLeads: 0,
            totalOpps: 0,
            arrangeViewings: 0,
            completedViewings: 0,
            deals: 0
        };

        let subTotalTotalOpps;
        let subTotalTotalLeads;
        agents.forEach((agent) => {
            if (agent.name === "Sub Total") {
                subTotalTotalOpps = agent.totalOpps;
                subTotalTotalLeads = agent.totalLeads;
            }
        });

        agents.forEach((agent) => {
            total.monthlyTarget += agent.monthlyTarget;
            total.closedLastWeek += agent.closedLastWeek;
            total.closedThisWeek += agent.closedThisWeek;
            total.closedThisMonth += agent.closedThisMonth;
            total.expectedThisMonth += agent.expectedThisMonth;
            total.predictedTotalThisMonth += agent.predictedTotalThisMonth;
            total.expectedTotalNextMonth += agent.expectedTotalNextMonth;
            total.totalLeads += agent.totalLeads;
            total.totalOpps += agent.totalOpps;
            total.arrangeViewings += agent.arrangeViewings;
            total.completedViewings += agent.completedViewings;
            total.deals += agent.deals;
        });

        return total;
    }

    @api getDataForExport() {
        let data = [
            headers,
            this.template
                .querySelector("c-performance-dashboard-row")
                .getRowDataForExport()
        ];

        this.template
            .querySelectorAll("c-performance-dashboard-tier-group")
            .forEach((tier) => {
                data = data.concat(tier.getRowDataForExport());
            });

        return data;
    }
}