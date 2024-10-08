@isTest
private class BatchToDeleteTest {
	
	@isTest static void test_method_one() {
		BatchConvertImagesFields ss = new BatchConvertImagesFields();
		ss.goUp();
	}
	
	@isTest static void test_method_two() {
		
		BatchSyncBCWithCustomWeb ss = new BatchSyncBCWithCustomWeb();
		ss.goUp();
	}

	@isTest static void test_method_three() {
		
		BatchConvertImagesToAWS ss = new BatchConvertImagesToAWS();
		ss.goUp();
	}
	
}