public without sharing class ClearEnhancedFeeDataScheduler implements Schedulable {

        public void execute(SchedulableContext ctx) {
    
            ClearEnhancedFeeDataBatch batch = new ClearEnhancedFeeDataBatch();
            Database.executeBatch(batch);
        }
}