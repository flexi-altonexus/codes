@isTest
private class LeadHelperTest {

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

	/*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Test method for LeadHelper.roundRobinLeadsAssigment
	 */
	@isTest static void roundRobinTest() {
		
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
		RR_Member__c member1 = TestFactory.createMember(groups.get(0).Id, beforeYesterday,'Member 1', LeadHelper.STATUS_ACTIVE, users.get(1).Id); members.add(member1); //should be second assigned
		RR_Member__c member2 = TestFactory.createMember(groups.get(0).Id, NULL,'Member 2', LeadHelper.STATUS_ACTIVE, users.get(2).Id); members.add(member2); //should be first assigned
		
		//Members group 1
		RR_Member__c member3 = TestFactory.createMember(groups.get(1).Id, yesterday,'Member 3', LeadHelper.STATUS_ACTIVE, users.get(3).Id); members.add(member3);//should be second and fourth assigned
		RR_Member__c member4 = TestFactory.createMember(groups.get(1).Id, NULL,'Member 4', LeadHelper.STATUS_INACTIVE, users.get(4).Id); members.add(member4); // should not be assigned because is inactive 
		RR_Member__c member5 = TestFactory.createMember(groups.get(1).Id, NULL,'Member 5', LeadHelper.STATUS_ACTIVE, users.get(5).Id); members.add(member5); // should be first and third assigned
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

		/********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		//Group 0
		Lead lead00 = TestFactory.createLead('lead00', '28000', 2); leads.add(lead00);
		Lead lead01 = TestFactory.createLead('lead01', '28000', 3); leads.add(lead01);
		Lead lead02 = TestFactory.createLead('lead02', '28000', 6); leads.add(lead02);
		//Group 1
		Lead lead10 = TestFactory.createLead('lead10', '28001', 3); leads.add(lead10);
		Lead lead11 = TestFactory.createLead('lead11', '28001', 2); leads.add(lead11);
		Lead lead12 = TestFactory.createLead('lead12', '28001', 10); leads.add(lead12);
		Lead lead13 = TestFactory.createLead('lead13', '28001', 8); leads.add(lead13);

		Test.startTest();
        User thisUser = [SELECT Id FROM User WHERE Name = 'Flexioffices Search' LIMIT 1];
        System.runAs(thisUser) {
			insert leads;
		}
		Test.stopTest();

		List<Lead> leadsAfter = [SELECT Id, LastName, OwnerId, NumberofDesks__c, Location__c, RR_Group__c FROM Lead];
		
		// Round robin should assign the owners in this order of users
		/*****First Group ****/
		System.assertEquals(users.get(2).Id,leadsAfter.get(0).OwnerId);
		System.assertEquals(members.get(0).RR_Group__c,leadsAfter.get(0).RR_Group__c);

		System.assertEquals(users.get(1).Id,leadsAfter.get(1).OwnerId);
		System.assertEquals(members.get(1).RR_Group__c,leadsAfter.get(1).RR_Group__c);

		System.assertEquals(users.get(0).Id,leadsAfter.get(2).OwnerId);
		System.assertEquals(members.get(0).RR_Group__c,leadsAfter.get(2).RR_Group__c);

		/*****Second Group ****/
		System.assertEquals(users.get(5).Id,leadsAfter.get(3).OwnerId);
		System.assertEquals(members.get(5).RR_Group__c,leadsAfter.get(3).RR_Group__c);

		System.assertEquals(users.get(3).Id,leadsAfter.get(4).OwnerId);
		System.assertEquals(members.get(3).RR_Group__c,leadsAfter.get(4).RR_Group__c);

		System.assertEquals(users.get(5).Id,leadsAfter.get(5).OwnerId);
		System.assertEquals(members.get(5).RR_Group__c,leadsAfter.get(5).RR_Group__c);

		System.assertEquals(users.get(3).Id,leadsAfter.get(6).OwnerId);
		System.assertEquals(members.get(3).RR_Group__c,leadsAfter.get(6).RR_Group__c);

		List<RR_Member__c> membersAfter = [SELECT Id, Name, Last_Lead_assignment__c, Last_Assignment__c FROM RR_Member__c];

		System.assertEquals(leads.get(2).Id, membersAfter.get(0).Last_Lead_assignment__c);
		System.assertEquals(System.today(), membersAfter.get(0).Last_Assignment__c.date());

		System.assertEquals(leads.get(1).Id, membersAfter.get(1).Last_Lead_assignment__c);
		System.assertEquals(System.today(), membersAfter.get(1).Last_Assignment__c.date());

		System.assertEquals(leads.get(0).Id, membersAfter.get(2).Last_Lead_assignment__c);
		System.assertEquals(System.today(), membersAfter.get(2).Last_Assignment__c.date());

		System.assertEquals(leads.get(6).Id, membersAfter.get(3).Last_Lead_assignment__c);
		System.assertEquals(System.today(), membersAfter.get(3).Last_Assignment__c.date());
		
		Boolean expecteLeadAssig = membersAfter.get(4).Last_Lead_assignment__c == NULL ? true: false;
		Boolean expecteDate = membersAfter.get(4).Last_Assignment__c == NULL ? true: false;
		System.assertEquals(true, expecteLeadAssig);
		System.assertEquals(true, expecteDate);
		
		System.assertEquals(leads.get(5).Id, membersAfter.get(5).Last_Lead_assignment__c);
		System.assertEquals(System.today(), membersAfter.get(5).Last_Assignment__c.date());

	}

	
	@isTest static void GAAPiTrackingTest() {
			
		createCommondData();
		/********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		//Group 0
		Lead lead00 = TestFactory.createLead('lead00', '28000', 2);
		lead00.London_Prime__c= true;
		lead00.NumberofDesks__c = 16;
		lead00.GA_Client_ID__c = '12345678';
		leads.add(lead00);
		insert leads;

		test.startTest();
			for(Lead lLead :leads) {
				lLead.pi__conversion_object_name__c = 'TEST OBJECT NAME';
			}
			update leads;
		test.stopTest();

		system.debug('END TEST, Result: '+ [SELECT Id FROM Lead WHERE Send_to_GA__c != null].size());
		System.AssertEquals(leads.size() , [SELECT Id FROM Lead WHERE Send_to_GA__c != null].size());
	}
	@isTest static void DCAPiTrackingTest() {
			
		createCommondData();
		/********** Leads creation *****************/
		List<Lead> leads = new List<Lead>();
		//Group 0
		
		Lead lead00 = TestFactory.createLead('lead00', '28000', 2); 
		lead00.London_Prime__c= true;
		lead00.NumberofDesks__c = 16;
		lead00.GA_Client_ID__c = '12345678';
		lead00.pi__conversion_object_name__c = 'test - UK - get prices';
		lead00.status = 'No Contact';
		lead00.User_Agent_string__c = 'test user agent string';
		leads.add(lead00);
		
		insert leads;
		test.startTest();
		system.debug(leads[0].status);
		leads[0].status = 'Qualified';
		update leads;

		test.stopTest();		
		system.debug('END TEST, Result: '+ [SELECT Id FROM Lead WHERE Send_to_DC__c != null].size());
		System.AssertEquals(leads.size() , [SELECT Id FROM Lead WHERE Send_to_DC__c != null].size());

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

		//Assigments Group 1
		RR_Postal_Code_Range_Assigment__c rangeAssig2 = TestFactory.createRangeAssig(groups.get(1).Id, postalCodes.get(1).Id, 'rangeAssig2', 1, 4); rangesAssigm.add(rangeAssig2);
		insert rangesAssigm;
	}
}