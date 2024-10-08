@isTest
private class AWSFilesHandlerTest {
	
	@isTest static void test_method_one() {
		
		
		AmazonS3__c setting = new AmazonS3__c();

		setting.Name = 'AWSS3';
		setting.Bucket__c = 'Bucket__c';
		insert setting;

		Account BCrec = TestFactory.createBC();
		insert BCrec;

	    AWS_Files__c newRec = new AWS_Files__c();
        newRec.Tittle__c  = 'test';
        newRec.URL__c = 'newUrl';
        newRec.Business_Centre__c = BCrec.Id;
        insert newRec;

        delete newRec;
	}

	@isTest static void test_method_two() {
		 
		 AmazonS3__c setting = new AmazonS3__c();

		 setting.Name = 'AWSS3';
		 setting.Bucket__c = 'Bucket__c';
		 insert setting;

		 Account BCrec = TestFactory.createBC();
		 insert BCrec;

		AWS_Files__c newRec = new AWS_Files__c();
        newRec.Tittle__c  = 'test';
        newRec.URL__c = 'newUrl';
        newRec.Business_Centre__c = BCrec.Id;
        insert newRec;

         AWS_FileUploadController controller1 = new AWS_FileUploadController();
		 ApexPages.standardController controller = new ApexPages.standardController(BCrec);

		 AWS_FileUploadController pag = new AWS_FileUploadController(controller);
		 pag.idImg = '{name:TEst.jpg}';

		 PageReference pageRef = Page.AWS_FileUpload;
    	 Test.setCurrentPage(pageRef); 
         
         pag.createImg();
         pag.refreshData();
    	 pag.saveData();  
    
	}

	
	
	
	
}