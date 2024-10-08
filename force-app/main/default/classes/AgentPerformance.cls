public class AgentPerformance {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;

    @AuraEnabled
    public Decimal monthlyTarget = 0;
    @AuraEnabled
    public Decimal closedLastWeek = 0;
    @AuraEnabled
    public Decimal closedThisWeek = 0;
    @AuraEnabled
    public Decimal closedThisMonth = 0;
    @AuraEnabled
    public Decimal expectedThisMonth = 0;
    @AuraEnabled
    public Decimal predictedTotalThisMonth = 0;
    @AuraEnabled
    public Decimal expectedTotalNextMonth = 0;

    @AuraEnabled
    public Integer totalLeads = 0;
    @AuraEnabled
    public Integer totalOpps = 0;
    @AuraEnabled
    public Integer arrangeViewings = 0;
    @AuraEnabled
    public Integer completedViewings = 0;
    @AuraEnabled
    public Integer deals = 0;

    public AgentPerformance(Id agentId, String agentName) {
        this.id = agentId;
        this.name = agentName;
    }

    public void setMonthlyTarget(Decimal target) {
        this.monthlyTarget = target;
    }

    public void addClosedThisWeek(Decimal amount) {
        this.closedThisWeek += amount != null ? amount : 0;
    }

    public void addClosedLastWeek(Decimal amount) {
        this.closedLastWeek += amount != null ? amount : 0;
    }

    public void addClosedThisMonth(Decimal amount) {
        this.closedThisMonth += amount != null ? amount : 0;
    }

    public void addExpectedThisMonth(Decimal amount) {
        this.expectedThisMonth += amount != null ? amount : 0;
    }

    public void addPredictedTotalThisMonth(Decimal amount) {
        this.predictedTotalThisMonth += amount != null ? amount : 0;
    }

    public void addExpectedTotalNextMonth(Decimal amount) {
        this.expectedTotalNextMonth += amount != null ? amount : 0;
    }

    public void addAdditionalOpp() {
        this.totalOpps += 1;
    }

    public void addArrangedViewing() {
        this.arrangeViewings += 1;
    }

    public void addCompletedViewing() {
        this.completedViewings += 1;
    }

    public void addCompletedDeal() {
        this.deals += 1;
    }

    public void addLeads(Integer count) {
        this.totalLeads += count;
    }

    public static AgentPerformance groupAll(List<AgentPerformance> performances) {
        AgentPerformance result = new AgentPerformance(null, null);

        for (AgentPerformance ap : performances) {
            result.monthlyTarget += ap.monthlyTarget;
            result.closedThisWeek += ap.closedThisWeek;
            result.closedLastWeek += ap.closedLastWeek;
            result.closedThisMonth += ap.closedThisMonth;
            result.expectedThisMonth += ap.expectedThisMonth;
            result.predictedTotalThisMonth += ap.predictedTotalThisMonth;
            result.expectedTotalNextMonth += ap.expectedTotalNextMonth;
            result.totalOpps += ap.totalOpps;
            result.arrangeViewings += ap.arrangeViewings;
            result.completedViewings += ap.completedViewings;
            result.deals += ap.deals;
            result.totalLeads += ap.totalLeads;
        }

        return result;
    }
}