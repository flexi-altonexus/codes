public with sharing class PerformanceDashboardController {
    public static final Id AMBER_JONES_ID = '00G1t000000skHLEAY';
    public static final Id PARDOT_ID = '0051t000003P8XwAAK';

    public static final String COMPLETED_VIEWING_STAGE = 'Completed';
    public static final List<String> EXPECTED_OPPS_STAGES = new List<String>{
        'Contract Issued',
        'Contract Signed',
        'Fund Cleared with Confirmation'
    };
    public static final List<String> STRONG_INTEREST_OPP_STAGES = new List<String>{
        'Negotiations',
        'Verbal Agreement'
    };
    public static final List<String> EXPECTED_OPPS_NEXT_MONTH = new List<String>{
        'Qualified',
        '1st Viewing Completed',
        'Short List Agreed',
        'Negotiations',
        'Verbal Agreement',
        'Contract Issued',
        'Contract Signed',
        'Fund Cleared with Confirmation'
    };

    @TestVisible
    private static PerformanceDashboardDataAccess dataAccess = new PerformanceDashboardDataAccess();

    private static AgentPerformance amberJonesAgent = new AgentPerformance(
        AMBER_JONES_ID,
        'Amber Jones'
    );
    private static Map<Id, AgentPerformance> corporateAgents = new Map<Id, AgentPerformance>();

    @TestVisible
    private static Map<Id, List<ViewingSchedule__c>> oppViewings;

    @AuraEnabled(cacheable=true)
    public static Map<String, List<AgentPerformance>> getPerformanceData(Date dashboardDate) {
        Map<String, List<AgentPerformance>> agentTiers = new Map<String, List<AgentPerformance>>();
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

        Map<Id, List<Opportunity>> agentOpportunities = dataAccess.getOpporunitiesForAgents(
            allAgents,
            dashboardMonthStart,
            dashboardMonthEnd
        );
        Map<Id, List<Lead>> agentLeads = dataAccess.getLeadsForAgent(
            allAgents,
            dashboardMonthStart,
            dashboardMonthEnd
        );

        List<Opportunity> allOpps = new List<Opportunity>();
        for (List<Opportunity> opps : agentOpportunities.values()) {
            allOpps.addAll(opps);
        }
        oppViewings = dataAccess.getOpportunityViewings(allOpps);

        //We need to seperate corporate opps from no corporate opps for agents in both
        if (agentsInTier.containsKey('Corporate')) {
            for (User agent : agentsInTier.get('Corporate')) {
                corporateAgents.put(agent.Id, new AgentPerformance(agent.Id, agent.Name));
            }
        }

        for (String tier : agentsInTier.keySet()) {
            agentTiers.put(tier, new List<AgentPerformance>());
        }

        List<String> tiers = new List<String>();
        tiers.addAll(agentsInTier.keySet());

        //Backwards loop over the tiers so corporate comes last, quick way of deduping opps/leads
        for (Integer i = tiers.size() - 1; i >= 0; i--) {
            String tier = tiers[i];
            List<AgentPerformance> tierAgents = agentTiers.get(tier);

            for (User agent : agentsInTier.get(tier)) {
                AgentPerformance agentData = tier != 'Corporate'
                    ? new AgentPerformance(agent.Id, agent.Name)
                    : corporateAgents.get(agent.Id);

                if (
                    agentOpportunities.containsKey(agent.Id) ||
                    agentLeads.containsKey(agent.Id) ||
                    !agent.Agent_Targets__r.isEmpty()
                ) {
                    setAgentOpportunityPerformanceData(
                        agentData,
                        agentOpportunities.get(agent.Id),
                        dashboardDate
                    );

                    setAgentLeadPerformance(agentData, agentLeads.get(agent.Id), dashboardDate);

                    if (!agent.Agent_Targets__r.isEmpty()) {
                        //There should only be a single target record per month
                        agentData.setMonthlyTarget(agent.Agent_Targets__r[0].Target__c);
                    }

                    tierAgents.add(agentData);
                }
            }
        }

        //Add the additional assigned amber jones leads that dont have an agent as an owner
        addAmberJonesLeads(amberJonesAgent, dashboardDate);

        //Assign the special tiers to the map at the end so they appear last in the chat
        agentTiers.put('Amber Jones', new List<AgentPerformance>{ amberJonesAgent });
        agentTiers.put('Pardot', new List<AgentPerformance>{ getPardotAgent(dashboardDate) });

        return agentTiers;
    }

    private static Set<Id> processOpps = new Set<Id>();

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

        AgentPerformance workingAgent;
        AgentPerformance actualAgent = agent;

        for (Opportunity opp : agentOpportunities) {
            if (processOpps.contains(opp.Id)) {
                continue;
            }

            workingAgent = getWorkingAgent(actualAgent, opp.Amber_Jones__c, opp.Corporate__c);

            setAgentOpportunityPerformanceData(
                workingAgent,
                opp,
                oppViewings.get(opp.Id),
                dashboardDate,
                dashboardMonthStart
            );

            //Amber Jones /Corporate opportunities need to be seperated
            processOpps.add(opp.Id);
        }
    }

    public static void setAgentOpportunityPerformanceData(
        AgentPerformance workingAgent,
        Opportunity opp,
        List<ViewingSchedule__c> viewings,
        Date dashboardDate,
        Date dashboardMonthStart
    ) {
        Boolean closedThisWeek = opp.CloseDate.toStartOfWeek() == dashboardDate.toStartOfWeek();
        Boolean closedLastWeek =
            opp.closeDate.toStartOfWeek() == dashboardDate.addDays(-7).toStartOfWeek();

        if (opp.isClosed && opp.IsWon && closedThisWeek) {
            workingAgent.addClosedThisWeek(opp.Amount);
        } else if (opp.isClosed && opp.IsWon && closedLastWeek) {
            workingAgent.addClosedLastWeek(opp.Amount);
        }

        if (
            opp.isClosed &&
            opp.IsWon &&
            opp.closeDate >= dashboardMonthStart &&
            opp.closeDate <= dashboardDate
        ) {
            workingAgent.addClosedThisMonth(opp.Amount);
            workingAgent.addCompletedDeal();
        } else if (
            opp.closeDate >= dashboardDate &&
            opp.closeDate < dashboardMonthStart.addMonths(1) &&
            EXPECTED_OPPS_STAGES.contains(opp.StageName)
        ) {
            workingAgent.addExpectedThisMonth(opp.ExpectedFee__c);
        } else if (
            opp.closeDate >= dashboardDate &&
            opp.closeDate < dashboardMonthStart.addMonths(1) &&
            opp.closeDate.month() == dashboardDate.month() &&
            STRONG_INTEREST_OPP_STAGES.contains(opp.StageName)
        ) {
            workingAgent.addPredictedTotalThisMonth(opp.ExpectedFee__c);
        } else if (
            opp.closeDate.month() == dashboardDate.addMonths(1).month() &&
            EXPECTED_OPPS_NEXT_MONTH.contains(opp.StageName)
        ) {
            workingAgent.addExpectedTotalNextMonth(opp.ExpectedFee__c);
        }

        if (opp.CreatedDate <= dashboardDate && opp.CreatedDate >= dashboardMonthStart) {
            workingAgent.addAdditionalOpp();
        }

        setOpportunityViewingData(viewings, workingAgent, dashboardDate);
    }

    private static Set<Id> processLeads = new Set<Id>();

    @TestVisible
    private static void setAgentLeadPerformance(
        AgentPerformance agent,
        List<Lead> agentLeads,
        Date dashboardDate
    ) {
        AgentPerformance workingAgent;
        AgentPerformance actualAgent = agent;

        if (agentLeads != null && !agentLeads.isEmpty()) {
            Date dashboardMonthStart = dashboardDate.toStartOfMonth();

            for (Lead lead : agentLeads) {
                if (processLeads.contains(lead.Id) || lead.AmberJones__c) {
                    continue;
                }

                workingAgent = getWorkingAgent(actualAgent, lead.AmberJones__c, lead.Corporate__c);
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

    public static void setOpportunityViewingData(
        List<ViewingSchedule__c> schedules,
        AgentPerformance agent,
        Date dashboardDate
    ) {
        if (schedules == null || schedules.isEmpty()) {
            return;
        }

        Date dashboardMonthStart = dashboardDate.toStartOfMonth();

        for (ViewingSchedule__c schedule : schedules) {
            Boolean hasArrangedViewing = false;
            Boolean hasCompletedViewing = false;

            for (Viewing__c viewing : schedule.Viewings__r) {
                if (
                    viewing.CreatedDate <= dashboardDate &&
                    viewing.CreatedDate >= dashboardMonthStart
                ) {
                    hasArrangedViewing = true;
                }
                if (
                    viewing.ViewingDateTime__c.date() <= dashboardDate &&
                    viewing.ViewingDateTime__c.date() >= dashboardMonthStart &&
                    viewing.Status__c == COMPLETED_VIEWING_STAGE
                ) {
                    hasCompletedViewing = true;
                }
                if (hasArrangedViewing && hasCompletedViewing) {
                    break;
                }
            }
            if (hasArrangedViewing) {
                agent.addArrangedViewing();
            }
            if (hasCompletedViewing) {
                agent.addCompletedViewing();
            }
        }
    }

    private static AgentPerformance getWorkingAgent(
        AgentPerformance baseAgent,
        Boolean amberJones,
        Boolean corporate
    ) {
        if (amberJones) {
            System.debug('Using amber jones agent');
            return amberJonesAgent;
        } else if (corporate && corporateAgents.containsKey(baseAgent.id)) {
            System.debug('Using corporate agent for ' + baseAgent.name);
            return corporateAgents.get(baseAgent.id);
        }

        return baseAgent;
    }

    public static AgentPerformance getPardotAgent(Date dashboardDate) {
        //Id hardcoded to the pardot user, purely for performance reasons when sent to LWC
        AgentPerformance pardotAgent = new AgentPerformance(PARDOT_ID, 'Pardot');
        pardotAgent.addLeads(
            [
                SELECT COUNT()
                FROM Lead
                WHERE
                    (Owner.Alias = 'Pardot'
                    OR Owner.Name = 'Emma Butler'
                    OR Owner.Name = 'Jo Ponting')
                    AND CALENDAR_MONTH(CreatedDate) = :dashboardDate.month()
                    AND CALENDAR_YEAR(CreatedDate) = :dashboardDate.year()
                    AND CreatedDate <= :dashboardDate
                    AND RecordType.DeveloperName = 'Client_Lead'
            ]
        );

        return pardotAgent;
    }

    public static AgentPerformance addAmberJonesLeads(AgentPerformance agent, Date dashboardDate) {
        agent.addLeads(
            [
                SELECT COUNT()
                FROM Lead
                WHERE
                    Owner.Name = 'Amber Jones'
                    AND CALENDAR_MONTH(CreatedDate) = :dashboardDate.month()
                    AND CALENDAR_YEAR(CreatedDate) = :dashboardDate.year()
                    AND CreatedDate <= :dashboardDate
                    AND AmberJones__c = TRUE
            ]
        );

        return agent;
    }
}