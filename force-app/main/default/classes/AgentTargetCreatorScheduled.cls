@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class AgentTargetCreatorScheduled implements Schedulable {
    public void execute(SchedulableContext context) {
        List<AgentTarget__c> currentTargets = this.getCurrentTargetRecords();

        if (!currentTargets.isEmpty()) {
            this.createNewTargetRecords(currentTargets);
            this.deactiveOldTargets(currentTargets);
        }
    }

    @TestVisible
    private List<AgentTarget__c> getCurrentTargetRecords() {
        return [
            SELECT Id, Agent__c, Target__c, Active__c, TargetStartDate__c, TargetEndDate__c
            FROM AgentTarget__c
            WHERE
                Active__c = true
                AND TargetEndDate__c < :System.today()
                AND Agent__r.IsActive = true
        ];
    }

    @TestVisible
    private void createNewTargetRecords(List<AgentTarget__c> currentTargets) {
        List<AgentTarget__c> newTargets = new List<AgentTarget__c>();

        Date targetStartDate = System.today().toStartOfMonth();
        Date targetEndDate = targetStartDate.addMonths(1).addDays(-1);

        for (AgentTarget__c target : currentTargets) {
            AgentTarget__c newTarget = target.clone(false, true, false, false);
            newTarget.TargetStartDate__c = targetStartDate;
            newTarget.TargetEndDate__c = targetEndDate;
            newTargets.add(newTarget);
        }

        insert newTargets;
    }

    private void deactiveOldTargets(List<AgentTarget__c> oldTargets) {
        for (AgentTarget__c target : oldTargets) {
            target.Active__c = false;
        }

        update oldTargets;
    }
}