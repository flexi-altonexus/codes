trigger EnhancedListingTrigger on Enhanced_Listing__c (after insert, after delete, after update) {
    
    EnhancedSListingHandler handler = new EnhancedSListingHandler();
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
           handler.isAfterInsert(Trigger.new);
        } else if(Trigger.isUpdate){
            handler.isAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isDelete){
          // handler.isAfterDelete(Trigger.old);
        }
    }

}