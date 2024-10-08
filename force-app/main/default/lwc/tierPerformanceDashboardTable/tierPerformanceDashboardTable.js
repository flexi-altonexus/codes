import { api, track } from "lwc";
import PerformanceDashboardTable from "c/performanceDashboardTable";

export default class TierPerformanceDashboardTable extends PerformanceDashboardTable {
    @track _tiers;
    @track subTotalTotalOpps;
    @track subTotalTotalLeads;

    @api get tiers() {
        return this._tiers;
    }
    set tiers(value) {
        console.log(value);
        this._tiers = value;
        this.setupTiers(value);
    }

    @track visibleTiers;

    connectedCallback() {
        console.log(JSON.stringify(this.headers));
    }

    setupTiers(tiers = []) {
        const setupTiers = [];
        const totalTiers = [];
        const otherTiers = [];

        let previousTotalTier = 0;

        tiers.forEach((tier, index) => {
            let workingTier = { ...tier };

            if (tier.name.toUpperCase().includes("TOTAL")) {
                const tiersToTotal = [];

                setupTiers.slice(previousTotalTier, index).forEach((tier) => {
                    tiersToTotal.push(tier.performance);
                });

                workingTier = {
                    name: tier.name,
                    performance: this.calculateTotal(tiersToTotal),
                    isTotalRow: true
                };
                previousTotalTier = index;
                totalTiers.push(workingTier.performance);
            } else {
                otherTiers.push(workingTier.performance);
            }

            setupTiers.push(workingTier);
        });

        setupTiers.push({
            name: "Grand Total",
            performance: this.calculateTotal(otherTiers)
        });

        console.log(JSON.stringify(setupTiers));
        setupTiers.forEach((tier) => {
            if (tier.name === "Sub Total") {
                this.subTotalTotalOpps = tier.performance.totalOpps;
                this.subTotalTotalLeads = tier.performance.totalLeads;
            }
            if (tier.name === "Sub Total - With AJ") {
                tier.performance.monthlyTarget = null;
                tier.performance.closedLastWeek = null;
                tier.performance.closedThisWeek = null;
                tier.performance.closedThisMonth = null;
                tier.performance.expectedThisMonth = null;
                tier.performance.predictedTotalThisMonth = null;
                tier.performance.expectedTotalNextMonth = null;
                tier.performance.totalLeads = null;
                tier.performance.totalOpps = null;
                tier.performance.arrangeViewings = null;
                tier.performance.completedViewings = null;
            }
        });

        this.visibleTiers = setupTiers;
    }

    @api getDataForExport() {
        let data = [this.headers];

        this.template
            .querySelectorAll("c-performance-dashboard-row")
            .forEach((tier) => {
                data = data.concat([tier.getRowDataForExport()]);
            });

        return data;
    }
}