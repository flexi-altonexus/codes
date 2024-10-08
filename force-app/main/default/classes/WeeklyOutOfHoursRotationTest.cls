@isTest
public class WeeklyOutOfHoursRotationTest {
    @testSetup
    static void setup() {
        // Create test Lead_Assignment_Settings__c record
        Lead_Assignment_Settings__c settings = new Lead_Assignment_Settings__c(
            Current_Week__c = 0
        );
        insert settings;
    }

    @isTest
    static void testWeeklyOutOfHoursRotation() {
        // Fetch the initial settings record
        Lead_Assignment_Settings__c settings = Lead_Assignment_Settings__c.getOrgDefaults();
        
        // Verify initial Current_Week__c value

        // Create an instance of the schedulable class
        WeeklyOutOfHoursRotation rotation = new WeeklyOutOfHoursRotation();
        
        // Execute the schedulable class
        Test.startTest();
        System.schedule('Test Weekly Rotation', '0 0 0 ? * MON *', rotation);
        Test.stopTest();
               
    }
}