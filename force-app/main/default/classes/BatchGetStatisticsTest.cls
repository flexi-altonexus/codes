@isTest
private class BatchGetStatisticsTest {
	
	@isTest static void runBatch() {
		Database.executeBatch(new BatchGetStatistics(),200);
	}
	
	
	
}