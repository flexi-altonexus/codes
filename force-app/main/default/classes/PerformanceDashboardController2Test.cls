@IsTest
private class PerformanceDashboardController2Test {
    @IsTest
    static void controllerTest() {
        PerformanceDashboardController2.getPerformanceData(System.today());
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
                StageName = PerformanceDashboardController2.EXPECTED_OPPS_NEXT_MONTH[0]
            )
        };

        List<Lead> agentLeads = new List<Lead>{
            new Lead(CreatedDate = System.today().addDays(-7))
        };
        PerformanceDashboardController2.oppViewings = new Map<Id, List<ViewingSchedule__c>>{
            '0063Y000012MYN9QAO' => new List<ViewingSchedule__c>()
        };

        PerformanceDashboardController2.setAgentOpportunityPerformanceData(
            agent,
            agentOpps,
            System.today()
        );

        PerformanceDashboardController2.setAgentLeadPerformance(agent, agentLeads, System.today());
    }

    // @IsTest
    // static void setOpportunityViewingData() {
    //     AgentPerformance ap = new AgentPerformance(UserInfo.getUserId(), 'User user');
    //     ViewingSchedule__c vs = new ViewingSchedule__c();
    //     insert vs;

    //     Viewing__c v = new Viewing__c(
    //         ViewingSchedule__c = vs.Id,
    //         Status__c = 'Completed',
    //         ViewingDateTime__c = Datetime.now()
    //     );
    //     insert v;

    //     Test.startTest();
    //     PerformanceDashboardController2.setOpportunityViewingData(
    //         [
    //             SELECT Id, (SELECT Id, Status__c, CreatedDate, ViewingDateTime__c FROM Viewings__r)
    //             FROM ViewingSchedule__c
    //         ],
    //         ap,
    //         Date.today()
    //     );
    //     Test.stopTest();
    // }

    @IsTest
    static void setAgentOpportunityPerformanceData() {
        AgentPerformance ap = new AgentPerformance(UserInfo.getUserId(), 'User user');
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Id = '0063Y000012OG6qQAG',
                Name = 'test',
                Amber_Jones__c = false,
                Corporate__c = false,
                CloseDate = Date.today().addDays(30),
                Amount = 100000,
                StageName = 'Qualified',
                ExpectedFee__c = 0.6,
                NumberofDesks__c = 52,
                Location__c = 'EC22'
            )
        };
        PerformanceDashboardDataAccess.londonPostalCodes = new Set<String>{ 'EC21' };

        PerformanceDashboardController2.oppViewings = new Map<Id, List<ViewingSchedule__c>>();

        Test.startTest();
        PerformanceDashboardController2.setAgentOpportunityPerformanceData(
            ap,
            opportunities,
            Date.today()
        );
        Test.stopTest();
    }

    @IsTest
    static void test_skipCriteria() {
        System.assert(PerformanceDashboardController2.isTier1(true, true, 1));
        System.assert(!PerformanceDashboardController2.isTier1(false, true, 1));
        System.assert(PerformanceDashboardController2.isTier2(true, 10));
        System.assert(PerformanceDashboardController2.isTier2(false, 11));
        System.assert(!PerformanceDashboardController2.isTier2(true, 90));
        System.assert(!PerformanceDashboardController2.isTier3(true, 15));
        System.assert(PerformanceDashboardController2.isTier3(false, 90));
    }

    @IsTest
    static void isLondonTierTest() {
        System.assert(PerformanceDashboardController2.isLondonTier('TIER 1 LONDON'));
    }

    @IsTest
    static void getNumberOfDesksTest() {
        Opportunity testOpp = new Opportunity(NumberofDesks__c = 5);
        System.assertEquals(5, PerformanceDashboardController2.getNumberOfDesks(testOpp));
    }

    @IsTest
    static void sortRecordsByTierTest() {
        PerformanceDashboardController2.sortRecordsByTier(
            new List<Opportunity>{ new Opportunity(Amber_Jones__c = true) }
        );
        PerformanceDashboardController2.sortRecordsByTier(
            new List<Lead>{ new Lead(AmberJones__c = true) }
        );
    }
}