trigger AgentTargetTrigger on AgentTarget__c(before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AgentTargetUtils.calculateMonthFinalFeeFromTarget(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AgentTargetUtils.calculateMonthFinalFeeFromTarget(Trigger.new);
        }
    }
}