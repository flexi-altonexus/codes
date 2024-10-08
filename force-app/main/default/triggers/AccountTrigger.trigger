trigger AccountTrigger on Account (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	AccountHandler handler = new AccountHandler();
		
	if (Trigger.isBefore) {
	    	//call your handler.before method
	    
	} else if (Trigger.isAfter) {
	    if(Trigger.isInsert) {
			//handler.afterInsert(Trigger.new, Trigger.newMap);
		}
		else if(Trigger.isUpdate){
			handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
		}
		else if(Trigger.isDelete){
			handler.afterDelete(Trigger.old);
		} 
	}
}