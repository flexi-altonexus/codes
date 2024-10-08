@isTest
private with sharing class ClearEnhancedFeeSchedulerTest {
    
    @isTest
    static void testExecute() {
        
        // Setup test account
        Id BUSINESS_CENTRE_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Centre').getRecordTypeId(); 

        Account account = new Account();
        account.Name = 'Test Account';
        account.Enhanced_Fee__c = 'Test enhanced fee text.';
        account.Enhanced_Fee_End_Date__c = System.Date.today();
        account.RecordTypeId = BUSINESS_CENTRE_RT;
        insert account;

        // Set up a test context
        Test.startTest();
        
        // Create a new instance of the scheduler class
        ClearEnhancedFeeDataScheduler scheduler = new ClearEnhancedFeeDataScheduler();
        
        // Execute the scheduler
        scheduler.execute(null);
        
        // Verify that the batch job was started
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'ClearEnhancedFeeDataBatch' AND Status != 'Aborted'];
        System.assertEquals(1, jobs.size(), 'Expected 1 batch job to be started.');
        System.assertEquals('Queued', jobs[0].Status, 'Expected batch job to be in Queued status.');
        
        // End the test context
        Test.stopTest();
    }
}