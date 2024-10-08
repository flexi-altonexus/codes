@isTest
public class OpportunityHelperTest {
    
    public static Integer NUM_USERS = 6;

	@testSetup 
	private static void setupTestData() {
		Id roleId = TestFactory.createRole();
		List<User> userList = new List<User> ();
		for(Integer i = 0; i< NUM_USERS; i++){
			User u = TestFactory.createUser(roleId, 'TestUser ' + i);
			userList.add(u);
		}
		insert userList;
    }

    @isTest
    public static void OpportunityStageUpdatedEccommerce_SendToGA_Test() {
        createCommondData();

        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;
        insert ac;

		/********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		//Group 0
		
		Lead lead00 = TestFactory.createLead('lead00', '28001', 3); 
            lead00.London_Prime__c= true;
            lead00.GA_Client_ID__c = '12345678';
            lead00.pi__conversion_object_name__c = 'test - UK - get prices';
            lead00.User_Agent_string__c = 'test user agent string';
            lead00.status = 'Viewing Booked';
            lead00.email = 'test@test.com';
            lead00.Industry = 'Chemicals';
            lead00.Number_of_Employees__c = '1 - 10';
            lead00.viewingsAuto__c = 2;
		    leads.add(lead00);
        
        insert leads;

        ViewingSchedule__c viewingSchedule = new ViewingSchedule__c();
        insert viewingSchedule;
        Viewing__c viewing = new Viewing__c(
            ViewingSchedule__c = viewingSchedule.id,
            BusinessCentre__c = ac.id,
            Status__c = 'Completed'
            //LeadRef__c = leads[0].id
        );
        insert viewing;

        // CONVERT LEAD
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leads[0].id);     
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Opportunity testOpp = [SELECT Id,Stagename FROM Opportunity Limit 1];
        // Create Payment Schedule
        insert new PaymentSchedule__c(
            Month1__c = 1,
            Month2__c = 1,
            Month3__c = 1,
            Month4__c = 1,
            Month5__c = 1,
            Month6__c = 1,
            Month7__c = 1,
            Month8__c = 1,
            Month9__c = 1,
            Month10__c = 1,
            Month11__c = 1,
            Month12__c = 1,
            Opportunity__c = testOpp.id,
            Year__c = '1'
        );

        test.startTest();
        
        
        testOpp.Send_to_GA__c = null;
        testOpp.StageName = 'Closed Won';
        testOpp.ClearedFundsDepositPaid__c = true;
        testOpp.NumberofWorkstations__c = 16;
        testOpp.ContractStartDate__c = System.today();
        testOpp.ContractEndDate__c = System.today().addDays(365);
        testOpp.BreakClause__c = 'test';
        testOpp.RentFreePeriod__c = 'test';
        testOpp.ClearedFundsDepositPaid__c = true;
        testOpp.RoomNameNumber__c = 'test';
        testOpp.OfficeSizesqft__c = 12;
        testOpp.MonthlyRent__c = 10;
        testOpp.PaymentFrequency__c = 'Monthly';
        testOpp.Amount = 10000;
        testOpp.ClearedFundsDepositPaid__c  = true;
        testOpp.MonthlyRent__c = 100;
        testOpp.ContractStartDate__c = system.today();
        testOpp.AgentSplitRevenue__c = 1;
        testOpp.Expected_Start_Date__c = System.today();
        testOpp.Type = 'Renewal';
        testOpp.Product__c = 'Lease';
        
        update testOpp;

		test.stopTest();		
		system.debug('END TEST, Result: '+ [SELECT Id FROM Opportunity WHERE Send_to_GA__c != null].size());
        System.AssertEquals(leads.size() , [SELECT Id FROM Opportunity WHERE Send_to_GA__c != null].size());
        
    }
    @istest
    public static void OpportunityStageUpdated_SendToGATest() {
        createCommondData();

        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;
        insert ac;

        /********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		//Group 0
		
		Lead lead00 = TestFactory.createLead('lead00', '28000', 2); 
            lead00.London_Prime__c= true;
            lead00.NumberofDesks__c = 16;
            lead00.GA_Client_ID__c = '12345678';
            lead00.pi__conversion_object_name__c = 'test - UK - get prices';
            lead00.User_Agent_string__c = 'test user agent string';
            lead00.status = 'Viewing Booked';
            lead00.email = 'test@test.com';
            lead00.Industry = 'Chemicals';
            lead00.Number_of_Employees__c = '1 - 10';
            lead00.viewingsAuto__c = 2;
		    leads.add(lead00);
        
        insert leads;

        ViewingSchedule__c viewingSchedule = new ViewingSchedule__c();
        insert viewingSchedule;
        Viewing__c viewing = new Viewing__c(
            ViewingSchedule__c = viewingSchedule.id,
            BusinessCentre__c = ac.id,
            Status__c = 'Completed'
            //LeadRef__c = leads[0].id
        );
        insert viewing;

        test.startTest();

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leads[0].id);     
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
		

		test.stopTest();		
		system.debug('END TEST, Result: '+ [SELECT Id FROM Opportunity WHERE Send_to_GA__c != null].size());
		System.AssertEquals(leads.size() , [SELECT Id FROM Opportunity WHERE Send_to_GA__c != null].size());
    }

    @istest
    public static void OpportunityStageUpdated_SendToDCTest() {
        createCommondData();

        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;
        insert ac;

        /********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		
		Lead lead00 = TestFactory.createLead('lead00', '28000', 2); 
		lead00.London_Prime__c= true;
		lead00.NumberofDesks__c = 16;
		lead00.GA_Client_ID__c = '12345678';
		lead00.pi__conversion_object_name__c = 'test - UK - get prices';
		lead00.User_Agent_string__c = 'test user agent string';
        lead00.status = 'Viewing Booked';
        lead00.email = 'test@test.com';
        lead00.Industry = 'Chemicals';
        lead00.Number_of_Employees__c = '1 - 10';
        lead00.viewingsAuto__c = 2;
        leads.add(lead00);
		insert leads;

        ViewingSchedule__c viewingSchedule = new ViewingSchedule__c();
        insert viewingSchedule;
        Viewing__c viewing = new Viewing__c(
            ViewingSchedule__c = viewingSchedule.id,
            BusinessCentre__c = ac.id,
            Status__c = 'Completed'
            //LeadRef__c = leads[0].id
        );
        insert viewing;

		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leads[0].id);     
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
		
        Opportunity testOpp = [SELECT Id,Stagename FROM Opportunity Limit 1];
        // Create Payment Schedule
        insert new PaymentSchedule__c(
            Month1__c = 1,
            Month2__c = 1,
            Month3__c = 1,
            Month4__c = 1,
            Month5__c = 1,
            Month6__c = 1,
            Month7__c = 1,
            Month8__c = 1,
            Month9__c = 1,
            Month10__c = 1,
            Month11__c = 1,
            Month12__c = 1,
            Opportunity__c = testOpp.id,
            Year__c = '1'
        );

        test.startTest();
        
        
        testOpp.Send_to_DC__c = null;
        testOpp.StageName = '1st Viewing Completed';
        testOpp.ClearedFundsDepositPaid__c = true;
        testOpp.NumberofWorkstations__c = 16;
        testOpp.ContractStartDate__c = System.today();
        testOpp.ContractEndDate__c = System.today().addDays(365);
        testOpp.BreakClause__c = 'test';
        testOpp.RentFreePeriod__c = 'test';
        testOpp.ClearedFundsDepositPaid__c = true;
        testOpp.RoomNameNumber__c = 'test';
        testOpp.OfficeSizesqft__c = 12;
        testOpp.MonthlyRent__c = 10;
        testOpp.PaymentFrequency__c = 'Monthly';
        testOpp.Amount = 10000;
        testOpp.Expected_Start_Date__c = System.today();
        testOpp.Type = 'Renewal';
        testOpp.Product__c = 'Lease';
        update testOpp;
        
		test.stopTest();		
		system.debug('END TEST, Result: '+ [SELECT Id FROM Opportunity WHERE Send_to_DC__c != null].size());
		System.AssertEquals(leads.size() , [SELECT Id FROM Opportunity WHERE Send_to_DC__c != null].size());
    }
    @istest
    public static void checkIfGoogleAnalyticsCodeTest() {
        createCommondData();

        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;
        insert ac;

        /********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		Lead lead00 = TestFactory.createLead('lead00', '28000', 2); 
		lead00.London_Prime__c= true;
		lead00.NumberofDesks__c = 16;
		lead00.GA_Client_ID__c = '12345678';
		lead00.pi__conversion_object_name__c = 'test - UK - get prices';
		lead00.User_Agent_string__c = 'test user agent string';
        lead00.status = 'Viewing Booked';
        lead00.email = 'test@test.com';
        lead00.Industry = 'Chemicals';
        lead00.Number_of_Employees__c = '1 - 10';
        lead00.viewingsAuto__c = 2;
        leads.add(lead00);
		insert leads;

        ViewingSchedule__c viewingSchedule = new ViewingSchedule__c();
        insert viewingSchedule;
        Viewing__c viewing = new Viewing__c(
            ViewingSchedule__c = viewingSchedule.id,
            BusinessCentre__c = ac.id,
            Status__c = 'Completed'
            //LeadRef__c = leads[0].id
        );
        insert viewing;

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leads[0].id);     
        lc.setConvertedStatus(convertStatus.MasterLabel);
		    
        test.startTest();

        Database.LeadConvertResult lcr = Database.convertLead(lc);
		list<Opportunity> listOpp = [SELECT Id,AccountId,ClientName__c,GA_Client_ID__c,GA_Type__c FROM Opportunity WHERE  GA_Type__c = 'web'];
        System.AssertEquals(1 ,listOpp.size() );
        Opportunity noWebOpp = new Opportunity (
            name = 'test',
            AccountId = listOpp[0].AccountId,
            ClientName__c = listOpp[0].ClientName__c,
            CloseDate = system.today(),
            StageName = 'New',
            Amount = 10,
            ClearedFundsDepositPaid__c = true
        );
        insert noWebOpp;
        listOpp = [SELECT Id,AccountId,GA_Client_ID__c,GA_Type__c FROM Opportunity WHERE  GA_Type__c = 'non-web'];
        System.AssertEquals(1 ,listOpp.size() );
        
		test.stopTest();		
		
		
    }

    @istest
    public static void roundRobinOpportunitiesAssignmentTest() {
        createCommondData();

        Account ac = TestFactory.createBC();
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '280001';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;
        insert ac;

		List<RR_Postal_Code__c> postalCodes = [SELECT Id, Postal_Code__c FROM RR_Postal_Code__c LIMIT 1];
        Id testPostCodeId = postalCodes[0].Id;
        String testPostCode = postalCodes[0].Postal_Code__c;

        test.startTest();

        Opportunity newOpp = new Opportunity (
            name = 'test',
            AccountId = ac.Id,
            CloseDate = system.today(),
            StageName = 'New',
            Amount = 10,
            ClearedFundsDepositPaid__c = true,
            Location__c = testPostCode,
            RR_Location__c = testPostCodeId,
            NumberofDesks__c = 3
        );
        insert newOpp;
		test.stopTest();		
    }

    private static void createCommondData() {
        List<RR_Group__c> groups = new List<RR_Group__c>();
		List<RR_Postal_Code__c> postalCodes = new List<RR_Postal_Code__c>();
		
		for(Integer i = 0; i< 2; i++){
			RR_Group__c gr = TestFactory.createGroup('Group ' + i);
			RR_Postal_Code__c pc = TestFactory.createPostalCode( 'PostalCode ' + i, '2800'+i);
			groups.add(gr);
			postalCodes.add(pc); 
		}
		insert groups;
		insert postalCodes;

		List<User> users = [SELECT Id, Name FROM User WHERE Name LIKE '%TestUser%'];
		Datetime yesterday = System.today()-1;
		Datetime beforeYesterday = System.today()-2;
		
		/********** Members creation *****************/
		List<RR_Member__c> members = new List<RR_Member__c>();

		//Members group 0
		RR_Member__c member0 = TestFactory.createMember(groups.get(0).Id, yesterday,'Member 0', LeadHelper.STATUS_ACTIVE, users.get(0).Id); members.add(member0); ////should be third assigned

		
		//Members group 1
		RR_Member__c member3 = TestFactory.createMember(groups.get(1).Id, yesterday,'Member 3', LeadHelper.STATUS_ACTIVE, users.get(3).Id); members.add(member3);//should be second and fourth assigned
		insert members;

		/********** Postal Code Range Assigments creation *****************/
		List<RR_Postal_Code_Range_Assigment__c> rangesAssigm = new List<RR_Postal_Code_Range_Assigment__c>();		
		//Assigments Group 0
		RR_Postal_Code_Range_Assigment__c rangeAssig0 = TestFactory.createRangeAssig(groups.get(0).Id, postalCodes.get(0).Id, 'rangeAssig0', 1, 4); rangesAssigm.add(rangeAssig0);
		RR_Postal_Code_Range_Assigment__c rangeAssig1 = TestFactory.createRangeAssig(groups.get(0).Id, postalCodes.get(0).Id, 'rangeAssig1', 5, 9); rangesAssigm.add(rangeAssig1);

		//Assigments Group 1
		RR_Postal_Code_Range_Assigment__c rangeAssig2 = TestFactory.createRangeAssig(groups.get(1).Id, postalCodes.get(1).Id, 'rangeAssig2', 1, 4); rangesAssigm.add(rangeAssig2);
		RR_Postal_Code_Range_Assigment__c rangeAssig3 = TestFactory.createRangeAssig(groups.get(1).Id, postalCodes.get(1).Id, 'rangeAssig3', 5, 10); rangesAssigm.add(rangeAssig3);
		insert rangesAssigm;

    }
    
}