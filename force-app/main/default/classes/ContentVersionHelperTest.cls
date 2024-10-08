@isTest
public with sharing class ContentVersionHelperTest {
	

	@isTest static void  ContentVersionHelperTest() {
		
		Account bc = TestFactory.createBC();
		insert bc;

		//Create ContentVersion
		ContentVersion cv = new ContentVersion();
		cv.VersionData = Blob.valueof('test');  
		cv.title = 'test2.pdf';
		cv.Description = 'test';
		//cv.FirstPublishLocationId = acc.id; 
		cv.PathOnClient = 'test2.pdf';
		cv.FirstPublishLocationId = bc.Id;

		insert cv;

	}
}