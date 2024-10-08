/*
 * @who     : James Boutel <james.boutel@empaua.com>
 * @when    : 23-10-2019
 * @what    : Trigger on introductions
 */
trigger IntroductionTrigger on Introduction__c (before insert, after insert) {

    IntroductionTriggerHandler handler = new IntroductionTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.isBeforeInsert(Trigger.new);
        }
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.isAfterInsert(Trigger.new);
        }
    }
}