trigger OpportunityTrigger on Opportunity (before Insert, after Insert, after Update) {

    OpportunityHandler handler = new OpportunityHandler();

    if (Trigger.isBefore){
        if(Trigger.isInsert ) 
            handler.beforeInsert(Trigger.new);
        //else if(Trigger.isUpdate)
        //  handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        //else if(Trigger.isDelete)
        //  handler.beforeDelete(Trigger.old, Trigger.oldMap);
        //else if(Trigger.isUnDelete)
        //  handler.OnUndelete(Trigger.new);
    
    }else if (Trigger.isAfter) {
       
        if(Trigger.isInsert)
            handler.afterInsert(Trigger.new, Trigger.newMap);
        else if(Trigger.isUpdate)
            handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        /*else if(Trigger.isDelete)
            handler.afterDelete(Trigger.old, Trigger.oldMap);*/
    }
}