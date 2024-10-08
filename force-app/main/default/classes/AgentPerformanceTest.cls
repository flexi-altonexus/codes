@IsTest
public class AgentPerformanceTest {
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static final Id AGENT_ID = '5000C0000035isuQAA';
    private static final String AGENT_NAME = 'Test Agent';

    @IsTest
    static AgentPerformance getTestAgent() {
        AgentPerformance agent = new AgentPerformance(AGENT_ID, AGENT_NAME);
        System.assertEquals(AGENT_ID, agent.id);
        System.assertEquals(AGENT_NAME, agent.name);

        return agent;
    }

    @IsTest
    static void setMonthlyTargetTest() {
        AgentPerformance agent = getTestAgent();
        agent.setMonthlyTarget(1);
        System.assertEquals(1, agent.monthlyTarget);
    }
    @IsTest
    static void addClosedThisWeekTest() {
        AgentPerformance agent = getTestAgent();
        agent.addClosedThisWeek(1);
        System.assertEquals(1, agent.closedThisWeek);
    }
    @IsTest
    static void addClosedLastWeekTest() {
        AgentPerformance agent = getTestAgent();
        agent.addClosedLastWeek(1);
        System.assertEquals(1, agent.closedLastWeek);
    }
    @IsTest
    static void addClosedThisMonthTest() {
        AgentPerformance agent = getTestAgent();
        agent.addClosedThisMonth(1);
        System.assertEquals(1, agent.closedThisMonth);
    }
    @IsTest
    static void addExpectedThisMonthTest() {
        AgentPerformance agent = getTestAgent();
        agent.addExpectedThisMonth(1);
        System.assertEquals(1, agent.expectedThisMonth);
    }
    @IsTest
    static void addPredictedTotalThisMonthTest() {
        AgentPerformance agent = getTestAgent();
        agent.addPredictedTotalThisMonth(1);
        System.assertEquals(1, agent.predictedTotalThisMonth);
    }
    @IsTest
    static void addExpectedTotalNextMonthTest() {
        AgentPerformance agent = getTestAgent();
        agent.addExpectedTotalNextMonth(1);
        System.assertEquals(1, agent.expectedTotalNextMonth);
    }
    @IsTest
    static void addAdditionalOppTest() {
        AgentPerformance agent = getTestAgent();
        agent.addAdditionalOpp();
        System.assertEquals(1, agent.totalOpps);
    }
    @IsTest
    static void addArrangedViewingTest() {
        AgentPerformance agent = getTestAgent();
        agent.addArrangedViewing();
        System.assertEquals(1, agent.arrangeViewings);
    }
    @IsTest
    static void addCompletedViewingTest() {
        AgentPerformance agent = getTestAgent();
        agent.addCompletedViewing();
        System.assertEquals(1, agent.completedViewings);
    }
    @IsTest
    static void addCompletedDealTest() {
        AgentPerformance agent = getTestAgent();
        agent.addCompletedDeal();
        System.assertEquals(1, agent.deals);
    }
    @IsTest
    static void addLeadsTest() {
        AgentPerformance agent = getTestAgent();
        agent.addLeads(1);
        System.assertEquals(1, agent.totalLeads);
    }
}