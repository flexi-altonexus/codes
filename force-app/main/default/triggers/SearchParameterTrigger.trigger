trigger SearchParameterTrigger on Search_Parameter__c (after insert, after delete, after update) {
    
    SearchParameterHandler handler = new SearchParameterHandler();
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.isAfterInsert(Trigger.new);
        } else if(Trigger.isUpdate){
            handler.isAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isDelete){
            handler.isAfterDelete(Trigger.old);
        }
    }

}