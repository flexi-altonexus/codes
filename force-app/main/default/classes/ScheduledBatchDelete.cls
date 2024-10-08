global class ScheduledBatchDelete implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchDeleteIntroductionRecords batch = new BatchDeleteIntroductionRecords();
        Database.executeBatch(batch, 200); 
    }
}