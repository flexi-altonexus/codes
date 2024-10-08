@SuppressWarnings('PMD.ApexCRUDViolation')
public inherited sharing class PerformanceDashboardDataAccess {
    private static List<String> agentGroups;
    public static Set<String> londonPostalCodes;

    static {
        List<Agent_Public_Group__mdt> groups = [
            SELECT Group_API_Name__c
            FROM Agent_Public_Group__mdt
        ];

        agentGroups = new List<String>();

        if (!groups.isEmpty()) {
            for (Agent_Public_Group__mdt groupInfo : groups) {
                agentGroups.add(groupInfo.Group_API_Name__c);
            }
        }
    }

    static {
        if (londonPostalCodes == null) {
            londonPostalCodes = new Set<String>();

            for (PostalCode__mdt pcode : [
                SELECT Label
                FROM PostalCode__mdt
                WHERE Reference__c = 'London'
            ]) {
                londonPostalCodes.add(pcode.Label);
            }
        }
    }

    private static Map<String, Set<Id>> agentTierExclusions;
    {
        agentTierExclusions = getAgentTierExclusions();
    }

    private static Map<String, Set<Id>> getAgentTierExclusions() {
        return sortAgentTierExclusionsByTierName(
            [
                SELECT Agent_User_Id__c, Tier_Name__c
                FROM Agent_Tier_Exclusion__mdt
            ]
        );
    }

    @TestVisible
    private static Map<String, Set<Id>> sortAgentTierExclusionsByTierName(
        List<Agent_Tier_Exclusion__mdt> records
    ) {
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();

        for (Agent_Tier_Exclusion__mdt exclusion : records) {
            Set<Id> exclusionIds = result.get(exclusion.Tier_Name__c);
            if (exclusionIds == null) {
                exclusionIds = new Set<Id>();
                result.put(exclusion.Tier_Name__c, exclusionIds);
            }
            exclusionIds.add(exclusion.Agent_User_Id__c);
        }

        return result;
    }

    public Map<String, List<User>> getAgentsByGroup(
        Date startDate,
        Date endDate
    ) {
        return sortAgentsByGroup(
            [
                SELECT UserOrGroupId, Group.Name, Group.DeveloperName
                FROM GroupMember
                WHERE Group.DeveloperName IN :agentGroups
            ],
            new Map<Id, User>(
                [
                    SELECT
                        Id,
                        Name,
                        (
                            SELECT Id, Target__c, CreatedDate
                            FROM Agent_Targets__r
                            WHERE
                                TargetStartDate__c = :startDate
                                AND TargetEndDate__c = :endDate
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                        )
                    FROM User
                    WHERE Exclude_From_Performance_Report__c = FALSE
                ]
            ),
            agentTierExclusions
        );
    }

    @TestVisible
    private static Map<String, List<User>> sortAgentsByGroup(
        List<GroupMember> members,
        Map<Id, User> agents,
        Map<String, Set<Id>> exclusions
    ) {
        Map<String, List<User>> result = new Map<String, List<User>>();
        Map<Id, String> processedUsers = new Map<Id, String>();

        System.debug(agents.size());
        System.debug(members.size());
        System.debug(exclusions.size());

        for (GroupMember membership : members) {
            if (
                !processedUsers.keyset().contains(membership.UserOrGroupId) ||
                membership.Group.Name == 'Corporate' ||
                processedUsers.get(membership.UserOrGroupId) == 'Corporate'
            ) {
                if (
                    exclusions.containsKey(membership.Group.Name) &&
                    exclusions.get(membership.Group.Name)
                        .contains(membership.UserOrGroupId)
                ) {
                    continue;
                }

                List<User> usersInTier = result.get(membership.Group.Name);

                if (usersInTier == null) {
                    usersInTier = new List<User>();
                    result.put(membership.Group.Name, usersInTier);
                }

                User agent = agents.get(membership.UserOrGroupId);
                if (agent != null) {
                    usersInTier.add(agent);
                    processedUsers.put(
                        membership.UserOrGroupId,
                        membership.Group.Name
                    );
                }
            }
        }

        return result;
    }

    public List<Opportunity> getOpportunities(
        List<User> agents,
        Date startDate,
        Date endDate
    ) {
        return [
            SELECT
                Id,
                Amber_Jones__c,
                CloseDate,
                convertCurrency(Amount),
                convertCurrency(ExpectedFee__c),
                Corporate__c,
                CreatedDate,
                IsClosed,
                IsWon,
                Location__c,
                NumberofDesks__c,
                OwnerId,
                StageName,
                Division__c,
                (
                    SELECT Id, Status__c, ViewingDateTime__c, CreatedDate
                    FROM Viewings__r
                )
            FROM Opportunity
            WHERE
                OwnerId IN :agents
                AND ((CreatedDate >= :startDate
                AND CreatedDate <= :endDate)
                OR (CloseDate >= :startDate
                AND CloseDate <= :endDate.addMonths(1)))
            ORDER BY NumberOfDesks__c, Location__c NULLS LAST
        ];
    }

    public Map<Id, List<Opportunity>> getOpporunitiesForAgents(
        List<User> agents,
        Date startDate,
        Date endDate
    ) {
        return sortOpportunitiesByAgent(
            getOpportunities(agents, startDate, endDate)
        );
    }

    @TestVisible
    private static Map<Id, List<Opportunity>> sortOpportunitiesByAgent(
        List<Opportunity> records
    ) {
        Map<Id, List<Opportunity>> result = new Map<Id, List<Opportunity>>();

        for (Opportunity record : records) {
            addRelatedRecordToMapAndList(
                (Map<Id, List<SObject>>) result,
                (SObject) record
            );
        }

        return result;
    }

    public List<Lead> getLeads(
        List<User> agents,
        Date startDate,
        Date endDate
    ) {
        return [
            SELECT
                Id,
                AmberJones__c,
                Corporate__c,
                CreatedDate,
                Location__c,
                NumberofDesks__c,
                OwnerId,
                Division__c
            FROM Lead
            WHERE
                (OwnerId IN :agents
                OR AmberJones__c = TRUE)
                AND CALENDAR_MONTH(CreatedDate) = :startDate.month()
                AND CALENDAR_YEAR(CreatedDate) = :startDate.year()
        ];
    }

    public Map<Id, List<Lead>> getLeadsForAgent(
        List<User> agents,
        Date startDate,
        Date endDate
    ) {
        return sortLeadsByAgent(getLeads(agents, startDate, endDate));
    }

    @TestVisible
    private static Map<Id, List<Lead>> sortLeadsByAgent(List<Lead> records) {
        Map<Id, List<Lead>> result = new Map<Id, List<Lead>>();

        for (Lead record : records) {
            addRelatedRecordToMapAndList(
                (Map<Id, List<SObject>>) result,
                (SObject) record
            );
        }

        return result;
    }

    public Map<Id, List<ViewingSchedule__c>> getOpportunityViewings(
        List<Opportunity> opps
    ) {
        return sortOpportunityViewings(
            [
                SELECT
                    Id,
                    CreatedDate,
                    RelatedToDeal__c,
                    (
                        SELECT Id, Status__c, ViewingDateTime__c, CreatedDate
                        FROM Viewings__r
                    )
                FROM ViewingSchedule__c
                WHERE RelatedToDeal__c IN :opps
            ]
        );
    }

    @TestVisible
    private static Map<Id, List<ViewingSchedule__c>> sortOpportunityViewings(
        List<ViewingSchedule__c> records
    ) {
        Map<Id, List<ViewingSchedule__c>> result = new Map<Id, List<ViewingSchedule__c>>();

        for (ViewingSchedule__c schedule : records) {
            if (!result.containsKey(schedule.RelatedToDeal__c)) {
                result.put(
                    schedule.RelatedToDeal__c,
                    new List<ViewingSchedule__c>{ new ViewingSchedule__c() }
                );
            }
            List<ViewingSchedule__c> schedules = result.get(
                schedule.RelatedToDeal__c
            );
            schedules.add(schedule);
        }

        return result;
    }

    @TestVisible
    private static void addRelatedRecordToMapAndList(
        Map<Id, List<SObject>> agentRecords,
        SObject record
    ) {
        Id ownerId = (Id) record.get('OwnerId');

        List<SObject> relatedRecords = agentRecords.get(ownerId);
        if (relatedRecords == null) {
            if (record.getSObjectType() == opportunity.getSObjectType()) {
                relatedRecords = new List<Opportunity>();
            } else {
                relatedRecords = new List<Lead>();
            }

            agentRecords.put(ownerId, relatedRecords);
        }

        relatedRecords.add(record);
    }
}