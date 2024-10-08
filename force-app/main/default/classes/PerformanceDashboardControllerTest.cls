@IsTest
public class PerformanceDashboardControllerTest {
    @IsTest
    static void controllerTest() {
        PerformanceDashboardController.getPerformanceData(System.today());
    }

    @IsTest
    static void setAgentOpportunityPerformanceDataTest() {
        insert new AgentTarget__c(
            Agent__c = UserInfo.getUserId(),
            Active__c = true,
            TargetStartDate__c = System.today().toStartOfMonth(),
            TargetEndDate__c = System.today().toStartOfMonth().addMonths(1).addDays(-1)
        );

        AgentPerformance agent = new AgentPerformance(null, null);
        List<Opportunity> agentOpps = new List<Opportunity>{
            new Opportunity(
                Id = '0063Y000012OG6qQAG',
                CreatedDate = System.today(),
                CloseDate = System.today(),
                ExpectedFee__c = 1,
                Amber_Jones__c = true
            ),
            new Opportunity(
                Id = '0063Y000012Ns0fQAC',
                CreatedDate = System.today().addDays(-7),
                CloseDate = System.today().addDays(-7),
                ExpectedFee__c = 1
            ),
            new Opportunity(
                Id = '0063Y000012MYN9QAO',
                CreatedDate = System.today().addMonths(1),
                CloseDate = System.today().addMonths(1),
                ExpectedFee__c = 1,
                StageName = PerformanceDashboardController.EXPECTED_OPPS_NEXT_MONTH[0]
            )
        };

        List<Lead> agentLeads = new List<Lead>{
            new Lead(CreatedDate = System.today().addDays(-7))
        };
        PerformanceDashboardController.oppViewings = new Map<Id, List<ViewingSchedule__c>>{
            '0063Y000012MYN9QAO' => new List<ViewingSchedule__c>()
        };

        PerformanceDashboardController.setAgentOpportunityPerformanceData(
            agent,
            agentOpps,
            System.today()
        );

        PerformanceDashboardController.setAgentLeadPerformance(agent, agentLeads, System.today());
    }
}