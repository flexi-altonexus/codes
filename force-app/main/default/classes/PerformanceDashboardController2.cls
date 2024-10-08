public with sharing class PerformanceDashboardController2 {
    private static final Id AMBER_JONES_ID = PerformanceDashboardController.AMBER_JONES_ID;
    private static final Id PARDOT_ID = PerformanceDashboardController.PARDOT_ID;

    private static final String COMPLETED_VIEWING_STAGE = PerformanceDashboardController.COMPLETED_VIEWING_STAGE;
    @TestVisible
    private static final List<String> EXPECTED_OPPS_STAGES = PerformanceDashboardController.EXPECTED_OPPS_STAGES;
    @TestVisible
    private static final List<String> STRONG_INTEREST_OPP_STAGES = PerformanceDashboardController.STRONG_INTEREST_OPP_STAGES;
    @TestVisible
    private static final List<String> EXPECTED_OPPS_NEXT_MONTH = PerformanceDashboardController.EXPECTED_OPPS_NEXT_MONTH;

    private static final String AUSTRALIA = 'Australia';
    private static final String BUSINESS_DEVELOPMENT = 'Business Development';
    private static final String AMBER_JONES = 'Amber Jones';
    private static final String PARDOT = 'Pardot';
    private static final String TIER_1 = 'Tier 1';
    private static final String TIER_2 = 'Tier 2';
    private static final String TIER_3 = 'Tier 3';

    @TestVisible
    private static final List<String> TIERS = new List<String>{
        BUSINESS_DEVELOPMENT,
        'Tier 1 UK',
        'Tier 1 LONDON',
        TIER_2,
        TIER_3,
        'Sub Total',
        AMBER_JONES,
        'Sub Total - With AJ',
        PARDOT,
        'Total',
        AUSTRALIA
    };

    @TestVisible
    private static PerformanceDashboardDataAccess dataAccess = new PerformanceDashboardDataAccess();

    private static AgentPerformance amberJonesAgent = new AgentPerformance(
        AMBER_JONES_ID,
        'Amber Jones'
    );
    // private static Map<Id, AgentPerformance> corporateAgents = new Map<Id, AgentPerformance>();
    @TestVisible
    private static Map<Id, List<ViewingSchedule__c>> oppViewings;

    @AuraEnabled(cacheable=true)
    public static List<TierPerformanceDetails> getPerformanceData(Date dashboardDate) {
        Map<String, AgentPerformance> agentTiers = new Map<String, AgentPerformance>();
        Date dashboardMonthStart = dashboardDate.toStartOfMonth();
        Date dashboardMonthEnd = Date.newInstance(
            dashboardMonthStart.year(),
            dashboardMonthStart.month(),
            Date.daysInMonth(dashboardMonthStart.year(), dashboardMonthStart.month())
        );

        Map<String, List<User>> agentsInTier = dataAccess.getAgentsByGroup(
            dashboardMonthStart,
            dashboardMonthEnd
        );

        List<User> allAgents = new List<User>();
        for (List<User> tierAgents : agentsInTier.values()) {
            allAgents.addAll(tierAgents);
        }

        List<Opportunity> opportunities = dataAccess.getOpportunities(
            allAgents,
            dashboardMonthStart,
            dashboardMonthEnd
        );
        List<Lead> leads = dataAccess.getLeads(allAgents, dashboardMonthStart, dashboardMonthEnd);

        oppViewings = dataAccess.getOpportunityViewings(opportunities);

        // if (agentsInTier.containsKey('Corporate')) {
        //     for (User agent : agentsInTier.get('Corporate')) {
        //         corporateAgents.put(agent.Id, new AgentPerformance(agent.Id, agent.Name));
        //     }
        // }

        Map<String, List<Opportunity>> opportunitiesByTier = sortOpportunitiesByTier(opportunities);
        Map<String, List<Lead>> leadsByTier = sortLeadsByTier(leads);

        PerformanceDashboardController.addAmberJonesLeads(amberJonesAgent, dashboardDate);
        agentTiers.put('Amber Jones', amberJonesAgent);

        for (String tierName : TIERS) {
            if (!agentTiers.containsKey(tierName)) {
                agentTiers.put(tierName, new AgentPerformance(null, tierName));
            }

            AgentPerformance tierAgent = agentTiers.get(tierName);

            if (opportunitiesByTier.containsKey(tierName)) {
                setAgentOpportunityPerformanceData(
                    tierAgent,
                    opportunitiesByTier.get(tierName),
                    dashboardDate
                );
            }

            if (leadsByTier.containsKey(tierName)) {
                setAgentLeadPerformance(tierAgent, leadsByTier.get(tierName), dashboardDate);
            }

            agentTiers.put(tierName, tierAgent);
        }

        agentTiers.put('Pardot', PerformanceDashboardController.getPardotAgent(dashboardDate));

        List<TierPerformanceDetails> performanceDetails = new List<TierPerformanceDetails>();

        for (String tierName : TIERS) {
            performanceDetails.add(new TierPerformanceDetails(tierName, agentTiers.get(tierName)));
        }

        return performanceDetails;
    }

    private static Map<String, List<Opportunity>> sortOpportunitiesByTier(
        List<Opportunity> records
    ) {
        return (Map<String, List<Opportunity>>) sortRecordsByTier(records);
    }

    private static Map<String, List<Lead>> sortLeadsByTier(List<Lead> records) {
        return (Map<String, List<Lead>>) sortRecordsByTier(records);
    }

    @TestVisible
    private static Map<String, List<SObject>> sortRecordsByTier(List<SObject> records) {
        Map<String, List<SObject>> result = new Map<String, List<SObject>>();

        for (SObject record : records) {
            for (String tierName : TIERS) {
                if (!meetsSkipCriteria(tierName, record)) {
                    if (!result.containsKey(tierName)) {
                        result.put(tierName, new List<SObject>());
                    }
                    result.get(tierName).add(record);
                    break;
                }
            }
            System.debug('Record not valid for any criteria ' + record.Id);
        }

        System.debug(JSON.serialize(result));

        return result;
    }

    @TestVisible
    private static void setAgentOpportunityPerformanceData(
        AgentPerformance agent,
        List<Opportunity> agentOpportunities,
        Date dashboardDate
    ) {
        if (agentOpportunities == null) {
            return;
        }

        Date dashboardMonthStart = dashboardDate.toStartOfMonth();

        for (Opportunity opp : agentOpportunities) {
            PerformanceDashboardController.setAgentOpportunityPerformanceData(
                agent,
                opp,
                oppViewings.get(opp.Id),
                dashboardDate,
                dashboardMonthStart
            );
        }
    }

    private static Set<Id> processLeads = new Set<Id>();

    @TestVisible
    private static void setAgentLeadPerformance(
        AgentPerformance agent,
        List<Lead> agentLeads,
        Date dashboardDate
    ) {
        AgentPerformance workingAgent = agent;

        if (agentLeads != null && !agentLeads.isEmpty()) {
            Date dashboardMonthStart = dashboardDate.toStartOfMonth();

            for (Lead lead : agentLeads) {
                if (
                    lead.CreatedDate.date() <= dashboardDate &&
                    lead.CreatedDate.date() >= dashboardMonthStart
                ) {
                    workingAgent.addLeads(1);
                }

                processLeads.add(lead.Id);
            }
        }
    }

    @TestVisible
    private static Boolean meetsSkipCriteria(String tierName, SObject record) {
        String division = (String) record.get('Division__c');

        if (tierName == AMBER_JONES) {
            if (
                (record.getSObjectType() == Opportunity.getSObjectType() &&
                (Boolean) record.get('Amber_Jones__c'))
            ) {
                return false;
            }

            return true;
        } else if (
            (record.getSObjectType() == Opportunity.getSObjectType() &&
            (Boolean) record.get('Amber_Jones__c')) ||
            (record.getSObjectType() == Lead.getSObjectType() &&
            (Boolean) record.get('AmberJones__c'))
        ) {
            return true;
        }

        if (tierName == division && (tierName == AUSTRALIA || tierName == BUSINESS_DEVELOPMENT)) {
            return false;
        } else if (division == AUSTRALIA || division == BUSINESS_DEVELOPMENT) {
            return true;
        }

        Integer deskCount = getNumberOfDesks(record);
        Boolean isLondon = isLondon(String.valueOf(record.get('Location__c')));
        Boolean isLondonTier = isLondonTier(tierName);

        if (tierName.contains('Tier 1')) {
            return !isTier1(isLondon, isLondonTier, deskCount);
        } else if (tierName.contains('Tier 2')) {
            return !isTier2(isLondon, deskCount);
        } else if (tiername.contains('Tier 3')) {
            return !isTier3(isLondon, deskCount);
        }

        return true;
    }

    @TestVisible
    private static Boolean isTier1(Boolean isLondon, Boolean isLondonTier, Integer deskCount) {
        if ((isLondon && !isLondonTier) || (!isLondon && isLondonTier)) {
            return false;
        }

        if (deskCount <= 0) {
            return false;
        }

        if (isLondon && deskCount < 10) {
            return true;
        }

        return deskCount <= 10;
    }

    @TestVisible
    private static Boolean isTier2(Boolean isLondon, Integer deskCount) {
        if (isLondon && deskCount >= 10 && deskCount <= 15) {
            return true;
        } else if (!isLondon && deskCount > 10 && deskCount <= 50) {
            return true;
        }

        return false;
    }

    @TestVisible
    private static Boolean isTier3(Boolean isLondon, Integer deskCount) {
        if (isLondon) {
            return deskCount > 15;
        }

        return deskCount > 50;
    }

    @TestVisible
    private static Boolean isLondon(String location) {
        return PerformanceDashboardDataAccess.londonPostalCodes.contains(location);
    }

    @TestVisible
    private static Boolean isLondonTier(String tierName) {
        return tierName.contains('LONDON');
    }

    // private static Boolean isNumberBetween(Integer val, Integer a, Integer b) {
    //     return val > a && val < b;
    // }
    @TestVisible
    private static Integer getNumberOfDesks(SObject record) {
        Decimal deskCount = (Decimal) record.get('NumberofDesks__c');

        return deskCount != null ? Integer.valueOf(deskCount) : 0;
    }

    public class TierPerformanceDetails {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public AgentPerformance performance;

        private TierPerformanceDetails(String name, AgentPerformance performance) {
            this.name = name;
            this.performance = performance;
        }
    }
}