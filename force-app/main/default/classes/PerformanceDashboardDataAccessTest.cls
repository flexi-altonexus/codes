@IsTest
public class PerformanceDashboardDataAccessTest {
    @IsTest
    static void test_getAgentsbyGroupTest() {
        PerformanceDashboardDataAccess dao = new PerformanceDashboardDataAccess();
        dao.getAgentsByGroup(System.today(), System.today());
    }

    @IsTest
    static void test_getPostalCodes() {
        System.assertNotEquals(
            null,
            PerformanceDashboardDataAccess.londonPostalCodes
        );
    }

    @IsTest
    static void test_addRelatedRecordToMapAndList() {
        PerformanceDashboardDataAccess.addRelatedRecordToMapAndList(
            new Map<Id, List<SObject>>{
                null => new List<Opportunity>{
                    new Opportunity(
                        OwnerId = UserInfo.getUserId(),
                        Name = 'Test'
                    )
                }
            },
            new Opportunity(OwnerId = UserInfo.getUserId(), Name = 'Test')
        );
    }

    @IsTest
    static void test_sortAgentsByGroup() {
        List<GroupMember> members = new List<GroupMember>();
        Map<Id, User> agents = new Map<Id, User>();
        Map<String, Set<Id>> exclusions = new Map<String, Set<Id>>();

        members.add(
            new GroupMember(
                Group = new Group(Name = 'Test'),
                UserOrGroupId = UserInfo.getUserId()
            )
        );
        agents.put(UserInfo.getUserId(), new User(Id = UserInfo.getUserId()));

        Test.startTest();
        Map<String, List<User>> result = PerformanceDashboardDataAccess.sortAgentsByGroup(
            members,
            agents,
            exclusions
        );
        Test.stopTest();
    }

    @IsTest
    static void test_sortOpportunityViewings() {
        List<ViewingSchedule__c> records = new List<ViewingSchedule__c>{
            new ViewingSchedule__c(RelatedToDeal__c = '0063Y000012OG6qQAG')
        };

        Test.startTest();
        Map<Id, List<ViewingSchedule__c>> result = PerformanceDashboardDataAccess.sortOpportunityViewings(
            records
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_sortAgentTierExclusionsByTierName() {
        Agent_Tier_Exclusion__mdt exclusionItem = new Agent_Tier_Exclusion__mdt();
        exclusionItem.Tier_Name__c = 'Test';
        exclusionItem.Agent_User_Id__c = UserInfo.getUserId();

        Test.startTest();
        PerformanceDashboardDataAccess.sortAgentTierExclusionsByTierName(
            new List<Agent_Tier_Exclusion__mdt>{ exclusionItem }
        );
        Test.stopTest();
    }

    @IsTest
    static void test_sortOpportunitiesByAgent() {
        Test.startTest();
        Map<Id, List<Opportunity>> result = PerformanceDashboardDataAccess.sortOpportunitiesByAgent(
            new List<Opportunity>{
                new Opportunity(OwnerId = UserInfo.getUserId())
            }
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_getOpporunitiesForAgents() {
        Test.startTest();
        Map<Id, List<Opportunity>> result = new PerformanceDashboardDataAccess()
            .getOpporunitiesForAgents(
                new List<User>{ new User(Id = UserInfo.getUserId()) },
                Date.today().addDays(-30),
                Date.today()
            );
        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @IsTest
    static void test_sortLeadsByAgent() {
        Test.startTest();
        Map<Id, List<Lead>> result = PerformanceDashboardDataAccess.sortLeadsByAgent(
            new List<Lead>{ new Lead(OwnerId = UserInfo.getUserId()) }
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void test_getLeadsForAgent() {
        Test.startTest();
        Map<Id, List<Lead>> result = new PerformanceDashboardDataAccess()
            .getLeadsForAgent(
                new List<User>{ new User(Id = UserInfo.getUserId()) },
                Date.today().addDays(-30),
                Date.today()
            );
        Test.stopTest();

        System.assertEquals(0, result.size());
    }
}