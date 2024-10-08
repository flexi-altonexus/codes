@istest
public with sharing class IntroductionTriggerHandlerTestBK {
    @testSetup
    public static void testSetup(){
        String bcRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Centre').getRecordTypeId();
        String clientRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
        Account bc = new Account(RecordTypeId = bcRecordType, Name='Test Business Centre');
        Account acc = new Account(RecordTypeId = clientRecordType, Name='Test Client', ShippingCountry = 'United Kingdom');
        insert acc;
        insert bc;
        Lead l = new Lead(Company = 'EMPAUA', LastName = 'TestLeadMatch', Email='leadmatch@gmail.com');
        insert l;
        Contact c = new Contact(LastName = 'TestContactMatch', Email='contactmatch@gmail.com', AccountId = acc.iD);
        insert c; 

        bc.CentreManager__c = c.Id;
        update bc;

    }
    
    @isTest
    public static void testAutomaticIntro(){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=TRUE];
        Account bc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        Test.startTest();
        //Set NOW() to 00AM, outside of Business Hours
        IntroductionHelper.now = DateTime.newInstance(2019,12,1,00,00,0);
        Introduction__c i = new Introduction__c(BusinessCentre__c = bc.id);
        insert i;
        Test.stopTest();
        Introduction__c updatedIntro = [SELECT Id, IntroductionType__c FROM Introduction__c];
        System.assertEquals('Automatic', updatedIntro.IntroductionType__c);
    }
    @isTest
    public static void testManualIntro(){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=TRUE];
        Account bc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        Contact c = new Contact(LastName = 'TestContactMatch', Email='contactmatch@gmail.com', AccountId = bc.iD);
        insert c; 
        bc.CentreManager__c = c.Id;
        update bc;
        Test.startTest();
        //Set NOW() to 10AM, within Business Hours
        IntroductionHelper.now = DateTime.newInstance(2019,12,1,10,00,0);
        Introduction__c i = new Introduction__c(BusinessCentre__c = bc.id);
        insert i;
        Test.stopTest();
        Introduction__c updatedIntro = [SELECT Id, IntroductionType__c FROM Introduction__c];
        //System.assertEquals('Manual', updatedIntro.IntroductionType__c);
    }
    @isTest
    public static void testIntroMatchedToLead(){
        Account bc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        List<Introduction__c> intros = new List<Introduction__c>();
        Introduction__c i = new Introduction__c(NumberOfDesks__c = 50,BusinessCentre__c = bc.id, Email__c = 'leadmatch@gmail.com');
        Introduction__c i2 = new Introduction__c(NumberOfDesks__c = 50,BusinessCentre__c = bc.id, Email__c = 'leadmatch@gmail.com');
        intros.add(i);
        intros.add(i2);
        insert intros;
        
        Lead l = [SELECT Id, (SELECT Id FROM Introductions__r) FROM Lead WHERE LastName = 'TestLeadMatch'];
        // Test that this matched Lead has two introductions against it now
        //System.assertEquals(2, l.Introductions__r.size());
    }
    @isTest
    public static void testIntroMatchedToContact(){
        
        Test.startTest();
        Account bc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        List<Introduction__c> intros = new List<Introduction__c>();
        Introduction__c i = new Introduction__c(Phone__c = '09876543', NumberOfDesks__c = 50,BusinessCentre__c = bc.id, Email__c = 'contactmatch@gmail.com');
        Introduction__c i2 = new Introduction__c(Phone__c = '09876543', NumberOfDesks__c = 50,BusinessCentre__c = bc.id, Email__c = 'contactmatch@gmail.com');
        intros.add(i);
        intros.add(i2);
        insert intros;
        Test.stopTest();
        
        Contact c = [SELECT Name, Account.Name FROM Contact WHERE LastName = 'TestContactMatch'];
        String searchterm = '%'+c.Account.Name+'%';
        List<Opportunity> opps = [SELECT Name, (SELECT Id FROM Introductions__r) FROM Opportunity WHERE Name LIKE :searchterm];
        // Test that this matched Contact has made a new Opp
        System.assertEquals(1,opps.size());
        // Test that this new Opp has 2 introductions against it
        //System.assertEquals(2, opps[0].Introductions__r.size());

    }   
    @isTest
    public static void testIntroNotMatched(){
        
        Account bc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        List<Introduction__c> intros = new List<Introduction__c>();
        Introduction__c i = new Introduction__c(NumberOfDesks__c = 50,BusinessCentre__c = bc.id, Email__c = 'nomatch@gmail.com', LastName__c = 'LeadLastName', Company__c = 'LeadCompany');
        Introduction__c i2 = new Introduction__c(NumberOfDesks__c = 50,BusinessCentre__c = bc.id, Email__c = 'nomatch@gmail.com', LastName__c = 'LeadLastName', Company__c = 'LeadCompany');
        intros.add(i);
        intros.add(i2);
        insert intros;
        
        Lead l = [SELECT Id, (SELECT Id FROM Introductions__r) FROM Lead WHERE LastName = 'LeadLastName'];
        // Test that this new Lead has two introductions against it
        //System.assertEquals(2, l.Introductions__r.size());
    }
    
    @isTest
    public static void testIntroAmberJones(){
        Account bc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        Id amberJonesId = [SELECT Id FROM Group WHERE DeveloperName = 'Amber_Jones' AND Type ='Queue'].Id;
        Lead leadExisting = [SELECT Id, OwnerId FROM Lead WHERE Email ='leadmatch@gmail.com'];
        leadExisting.OwnerId = amberJonesId;
        update leadExisting;
        List<Introduction__c> intros = new List<Introduction__c>();
        Introduction__c i = new Introduction__c(OutwardCode__c = 'CM21',NumberOfDesks__c = 1,BusinessCentre__c = bc.id, Email__c = 'leadmatch@gmail.com', LastName__c = 'LeadLastName', Company__c = 'LeadCompany');
        Introduction__c i2 = new Introduction__c(OutwardCode__c = 'CM21',NumberOfDesks__c = 1,BusinessCentre__c = bc.id, Email__c = 'leadmatch@gmail.com', LastName__c = 'LeadLastName', Company__c = 'LeadCompany');
        intros.add(i);
        intros.add(i2);
        insert intros;

    }
}