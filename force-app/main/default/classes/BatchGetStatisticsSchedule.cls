global class BatchGetStatisticsSchedule implements Schedulable{

    public BatchGetStatisticsSchedule() {}

    global void execute(SchedulableContext sc) {
                
        Database.executeBatch(new  BatchGetStatistics(),200); 
        
    }
}