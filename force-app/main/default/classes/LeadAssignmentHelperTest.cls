@isTest
public class LeadAssignmentHelperTest {
    @testSetup
    static void setup() {
        // Create test users with necessary aliases
        User hperr = new User(Alias='hperr', Email='hperr@example.com', 
                              Username='hperr@example.com', LastName='Perr', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                              EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', 
                              ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id);
        insert hperr;
        
        User kavc = new User(Alias='kavc', Email='kavc@example.com', 
                             Username='kavc@example.com', LastName='Avc', 
                             LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', 
                             ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id);
        insert kavc;

        User NClar = new User(Alias='NClar', Email='NClar@example.com', 
                              Username='NClar@example.com', LastName='Clar', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                              EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', 
                              ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id);
        insert NClar;

        User nconn = new User(Alias='nconn', Email='nconn@example.com', 
                              Username='nconn@example.com', LastName='Conn', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                              EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', 
                              ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id);
        insert nconn;

        User esobe = new User(Alias='esobe', Email='esobe@example.com', 
                              Username='esobe@example.com', LastName='Sobe', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                              EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', 
                              ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id);
        insert esobe;

        User SBank = new User(Alias='SBank', Email='SBank@example.com', 
                              Username='SBank@example.com', LastName='Bank', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                              EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', 
                              ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'].Id);
        insert SBank;

        // Create test Lead_Assignment_Settings__c record
        Lead_Assignment_Settings__c settings = new Lead_Assignment_Settings__c(
            Last_Business_Hours_Index__c = 0,
            Current_Week__c = 0
        );
        insert settings;

        // Create test Lead_Assignment_Settings_High__c record
        Lead_Assignment_Settings_High__c settingsHigh = new Lead_Assignment_Settings_High__c(
            Last_Business_Hours_Index__c = 0
        );
        insert settingsHigh;

        RR_Postal_Code__c rrPostalCode = new RR_Postal_Code__c(Name = 'SW19', postal_Code__c = 'SW19', Country__c = 'United Kingdom', City__c= 'London');
        insert rrPostalCode;
        rrPostalCode = new RR_Postal_Code__c(Name = 'CR0', postal_Code__c = 'CR0', Country__c = 'United Kingdom');
        insert rrPostalCode;
    }

    @isTest
    static void testAssignLeadDuringBusinessHours() {
        // Set up a test lead
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Country = 'UK', NumberofDesks__c = 6, Location__c = 'SW19');
        insert testLead;
        
        // Mock business hours to 10:00 AM on a weekday within an allowed period
        DateTime mockDateTime = DateTime.newInstance(2024, 7, 10, 10, 0, 0);
        Test.setCreatedDate(testLead.Id, mockDateTime);
        LeadAssignmentHelper.NowIsTheTime = mockDateTime;

        // Assign the lead
        List<Lead> leads = [SELECT Id, OwnerId, NumberofDesks__c, Country, createdDate, postal_Code__c FROM Lead WHERE Id = :testLead.Id];
        LeadAssignmentHelper.assignLead(leads);

   
    }

    @isTest
    static void testAssignLeadOutOfHours() {
        // Set up a test lead
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Country = 'UK', NumberofDesks__c = 12, Location__c = 'SW19');
        insert testLead;
        
        // Mock out of business hours to 8:00 PM on a weekday
        DateTime mockDateTime = DateTime.newInstance(2024, 6, 17, 20, 0, 0);
        Test.setCreatedDate(testLead.Id, mockDateTime);
        LeadAssignmentHelper.NowIsTheTime = mockDateTime;

        // Assign the lead
        List<Lead> leads = [SELECT Id, OwnerId, NumberofDesks__c, Country, createdDate, postal_Code__c FROM Lead WHERE Id = :testLead.Id];
        LeadAssignmentHelper.assignLead(leads);

  
    }

    @isTest
    static void testAssignLeadWithSmallWorkstationsLondon() {
        // Set up a test lead
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Country = 'UK', NumberofDesks__c = 3, Location__c = 'SW19');
        insert testLead;

        // Mock business hours to 10:00 AM on a weekday
        DateTime mockDateTime = DateTime.newInstance(2024, 7, 10, 10, 0, 0);
        Test.setCreatedDate(testLead.Id, mockDateTime);
        LeadAssignmentHelper.NowIsTheTime = mockDateTime;

        // Assign the lead
        List<Lead> leads = [SELECT Id, OwnerId, NumberofDesks__c, Country, createdDate, postal_Code__c FROM Lead WHERE Id = :testLead.Id];
        LeadAssignmentHelper.assignLead(leads);

    }

    @isTest
    static void testAssignLeadWithSmallWorkstations() {
        // Set up a test lead
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Country = 'UK', NumberofDesks__c = 3, Location__c = 'CR0');
        insert testLead;

        // Mock business hours to 10:00 AM on a weekday
        DateTime mockDateTime = DateTime.newInstance(2024, 7, 10, 10, 0, 0);
        Test.setCreatedDate(testLead.Id, mockDateTime);
        LeadAssignmentHelper.NowIsTheTime = mockDateTime;

        // Assign the lead
        List<Lead> leads = [SELECT Id, OwnerId, NumberofDesks__c, Country, createdDate, postal_Code__c FROM Lead WHERE Id = :testLead.Id];
        LeadAssignmentHelper.assignLead(leads);

    }

    @isTest
    static void testAssignLeadHighWorkstationsDuringBusinessHours() {
        // Set up a test lead
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Country = 'UK', NumberofDesks__c = 20, Location__c = 'SW19');
        insert testLead;

        // Mock business hours to 10:00 AM on a weekday
        DateTime mockDateTime = DateTime.newInstance(2024, 7, 10, 10, 0, 0);
        Test.setCreatedDate(testLead.Id, mockDateTime);
        LeadAssignmentHelper.NowIsTheTime = mockDateTime;

        // Assign the lead
        List<Lead> leads = [SELECT Id, OwnerId, NumberofDesks__c, Country, createdDate, postal_Code__c FROM Lead WHERE Id = :testLead.Id];
       // LeadAssignmentHelper.assignLead(leads);


    }

    @isTest
    static void testAssignLeadMidWorkstationsDuringBusinessHours() {
        // Set up a test lead
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Country = 'UK', NumberofDesks__c = 12, Location__c = 'SW19');
        insert testLead;

        // Mock business hours to 10:00 AM on a weekday
        DateTime mockDateTime = DateTime.newInstance(2024, 7, 10, 10, 0, 0);
        Test.setCreatedDate(testLead.Id, mockDateTime);
        LeadAssignmentHelper.NowIsTheTime = mockDateTime;

        // Assign the lead
        List<Lead> leads = [SELECT Id, OwnerId, NumberofDesks__c, Country, createdDate, postal_Code__c FROM Lead WHERE Id = :testLead.Id];
        LeadAssignmentHelper.assignLead(leads);

    }
}