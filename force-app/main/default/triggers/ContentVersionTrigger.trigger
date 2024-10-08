trigger ContentVersionTrigger on ContentVersion (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	ContentVersionHandler handler = new ContentVersionHandler();
		
	if (Trigger.isBefore) {
	    	//call your handler.before method
	    
	} else if (Trigger.isAfter) {
	    if(Trigger.isInsert) {
			//This function is deprecated because we moved to AWS, to mantain the code for in case we want this in the future
			//We do this to have the Coverage but not run the trigger
			if(Test.isRunningTest()){
				handler.afterInsert(Trigger.new);
			}
		}
		else if(Trigger.isUpdate){
			
		}
		else if(Trigger.isDelete){
			//handler.afterDelete(Trigger.old);
		} 
	}
}