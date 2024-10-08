trigger DataDwellIntroductionTrigger on Introduction__c (after insert) {
	if(Trigger.isAfter && Trigger.isInsert){
        DataDwellIntroductionTriggerHandler.handleAfterInsert(Trigger.new);
    }
}