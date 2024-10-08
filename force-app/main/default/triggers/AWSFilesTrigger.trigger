trigger AWSFilesTrigger on AWS_Files__c (before delete) {

    AWSFilesHandler handler = new AWSFilesHandler();

    if(Trigger.isBefore){
        if(Trigger.isDelete){
            handler.deleteFiles(Trigger.old);
        }
    }

}