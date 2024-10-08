trigger EnhancedSlotTrigger on Enhanced_Slot__c (after insert, after delete, after update) {
    
    EnhancedSlotHandler handler = new EnhancedSlotHandler();
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
           handler.isAfterInsert(Trigger.new);
        } else if(Trigger.isUpdate){
           // handler.isAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isDelete){
           handler.isAfterDelete(Trigger.old);
        }
    }

}