public with sharing class AgentTargetUtils {

    public static void calculateMonthFinalFeeFromOpp(List<Opportunity> oppsChanged) {
        Set<Id> userIds = new Set<Id>();
        for (Opportunity opp : oppsChanged) {
            userIds.add(opp.OwnerId);
        }

        Date earliestDate;
        Date latestDate;
        for (Opportunity opp : oppsChanged) {
            if (earliestDate != null) {
                if (opp.CloseDate < earliestDate) {
                    earliestDate = opp.CloseDate;
                }
            } else {
                earliestDate = opp.CloseDate;
            }

            if (latestDate != null) {
                if (opp.CloseDate > latestDate) {
                    latestDate = opp.CloseDate;
                }
            } else {
                latestDate = opp.CloseDate;
            }
        }

        List<AgentTarget__c> targets = [
            SELECT Id, Agent__c, TargetStartDate__c, TargetEndDate__c, Month_Sales_Final_Fee__c, MonthFlexiFeeAfterSplit_trig__c
            FROM AgentTarget__c
            WHERE
                Agent__c IN :userIds
                AND TargetEndDate__c >= :earliestDate
                AND TargetStartDate__c <= :latestDate
        ];

        targets = calculateMonthFinalFee(targets, userIds);

        update targets;
    }

    public static void calculateMonthFinalFeeFromTarget(List<AgentTarget__c> targetsChanged) {
        Set<Id> userIds = new Set<Id>();
        for (AgentTarget__c target : targetsChanged) {
            userIds.add(target.Agent__c);
        }

        targetsChanged = calculateMonthFinalFee(targetsChanged, userIds);
    }

    public static List<AgentTarget__c> calculateMonthFinalFee(
        List<AgentTarget__c> targets,
        Set<Id> userIds
    ) {
        Date earliestTargetDate;
        Date latestTargetDate;
        for (AgentTarget__c target : targets) {
            if (earliestTargetDate != null) {
                if (target.TargetStartDate__c < earliestTargetDate) {
                    earliestTargetDate = target.TargetStartDate__c;
                }
            } else {
                earliestTargetDate = target.TargetStartDate__c;
            }

            if (latestTargetDate != null) {
                if (target.TargetEndDate__c > latestTargetDate) {
                    latestTargetDate = target.TargetEndDate__c;
                }
            } else {
                latestTargetDate = target.TargetEndDate__c;
            }
        }

        List<Opportunity> opps = [
            SELECT Id, OwnerId, Sales_Final_Fee__c, CloseDate, Amount
            FROM Opportunity
            WHERE
                OwnerId IN :userIds
                AND StageName = 'Closed Won'
                AND CloseDate >= :earliestTargetDate
                AND CloseDate <= :latestTargetDate
        ];

        Map<String, List<Opportunity>> userIdMonthYearToFeeMap = new Map<String, List<Opportunity>>();
        for (Opportunity opp : opps) {
            String userIdMonthYear =
                opp.OwnerId +
                opp.CloseDate.month().format() +
                opp.CloseDate.year().format();
            System.debug(userIdMonthYear);
            if (userIdMonthYearToFeeMap.containsKey(userIdMonthYear)) {
                List<Opportunity> mapOpps = userIdMonthYearToFeeMap.get(userIdMonthYear);
                mapOpps.add(opp);
                userIdMonthYearToFeeMap.put(userIdMonthYear, mapOpps);
            } else {
                List<Opportunity> mapOpps = new List<Opportunity>();
                mapOpps.add(opp);
                userIdMonthYearToFeeMap.put(userIdMonthYear, mapOpps);
            }
        }

        for (AgentTarget__c target : targets) {
            String userIdMonthYear =
                target.Agent__c +
                target.TargetStartDate__c.month().format() +
                target.TargetStartDate__c.year().format();
            System.debug(userIdMonthYear);
            List<Opportunity> mapOpps = userIdMonthYearToFeeMap.get(userIdMonthYear);
            Double feesSum = 0, flexiFeeSum = 0;
            if (mapOpps != null) {
                for (Opportunity opp : mapOpps) {
                    feesSum += opp.Sales_Final_Fee__c;
                    flexiFeeSum += opp.Amount;
                }
            }
            target.Month_Sales_Final_Fee__c = feesSum;
            target.MonthFlexiFeeAfterSplit_trig__c = flexiFeeSum;
        }

        return targets;
    }
}