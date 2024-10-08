trigger LeadTrigger on Lead (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {

    LeadHandler handler = new LeadHandler();

    if (Trigger.isBefore)
    {
        if(Trigger.isInsert ){
            handler.beforeInsert(Trigger.new);
        }else if(Trigger.isUpdate){
             handler.beforeUpdate(Trigger.newMap,Trigger.oldMap);
        }
        
        //else if(Trigger.isDelete)
        //  handler.beforeDelete(Trigger.old, Trigger.oldMap);
        //else if(Trigger.isUnDelete)
        //  handler.OnUndelete(Trigger.new);
    }
    else if (Trigger.isAfter) {
        
        if(Trigger.isInsert)
            handler.afterInsert(Trigger.new, Trigger.newMap);
        else if(Trigger.isUpdate)
            handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        /*else if(Trigger.isDelete)
            handler.afterDelete(Trigger.old, Trigger.oldMap);*/
    }
}