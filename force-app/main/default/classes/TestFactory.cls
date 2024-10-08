public class TestFactory {
	/*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create Role
	 */
	public static Id createRole(){
		UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		insert r;
	return r.Id;
	}

	/*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create User
	 */
	 public static User createUser(Id roleId, String lastName){
		User u = new User(
	    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
	    LastName = lastName,
	    Email = 'puser000@amamama.com',
	    Username = 'puser000@amamama.com' + System.currentTimeMillis(),
	    CompanyName = 'TEST',
	    Title = 'title',
	    Alias = 'alias',
	    TimeZoneSidKey = 'America/Los_Angeles',
	    EmailEncodingKey = 'UTF-8',
	    LanguageLocaleKey = 'en_US',
	    LocaleSidKey = 'en_US',
	    UserRoleId = roleId,
	    QueueId__c = 'TestQueeeID'
		);
		return u;
	 }

	 /*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create RR_Group
	 */
	 public static RR_Group__c createGroup(String name){
	 	return new RR_Group__c(Name =name);
	}

	/*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create RR_Member__c
	 */
	 public static RR_Member__c createMember(Id groupId, Datetime lastAssig, String name, String status, Id userId){
	 	return new RR_Member__c(Name = name,
	 							Last_Assignment__c = lastAssig,
	 							RR_Group__c = groupId,
	 							Status__c = status,
	 							User__c = userId);
	}

	 /*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create RR_Postal_Code__c
	 */
	 public static RR_Postal_Code__c createPostalCode(String name, String postalCode){
	 	return new RR_Postal_Code__c(Name =name,
	 							Postal_Code__c = postalCode);
	}

	/*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create RR_Postal_Code_Range_Assigment__c
	 */
	 public static RR_Postal_Code_Range_Assigment__c createRangeAssig(Id groupId, Id postalCodeId, String name, Integer deskMin, Integer deskMax){
	 	return new RR_Postal_Code_Range_Assigment__c(Name = name,
	 												RR_Group__c = groupId,
	 												RR_Postal_Code__c = postalCodeId,
	 												Number_of_Desks_min__c = deskMin,
	 												Number_of_Desks_Max__c = deskMax);
	}

	/*
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   April 4, 2019
	 * @Description     :   Create a Lead
	 */
	 public static Lead createLead(String lastName, String postalCode, Integer numDesks){
	 	return new Lead (LastName = lastName,
	 					Status = 'Qualified',
	 					Company = 'example' + Math.random(),
	 					Location__c = postalCode,
	 					Phone = '455545444',
						 NumberofDesks__c = numDesks,
						 Expected_Close_Date__c = system.today().addDays(10)
	 					);
	 }

	/*
	 * @Author          :   David Sanchez <david.sanchez@empaua.com>
	 * @Created         :   2019-05-24
	 * @Description     :   Create a Opportunity
	 */
	 public static Opportunity createOpportunity(Id acctId){
	 	return new Opportunity (
			 				Name = 'Test',
							AccountId = acctid,
							CloseDate = Date.today() + 15,
							StageName = 'Qualified'
	 					);
	 }

	/*
	 * @Author          :   David Sanchez <david.sanchez@empaua.com>
	 * @Created         :   2019-05-24
	 * @Description     :   Create a Account
	 */
	 public static Account createAccount(String name, Id recId){
	 	return new Account(Name=name, RecordTypeId = recId);
	 }

	 /*
	 * @Author          :   David Sanchez <david.sanchez@empaua.com>
	 * @Created         :   2019-05-24
	 * @Description     :   Create a Account
	 */
	 public static Account createBC(){
	 	Account ac = new Account();
	 	ac.Name = 'BC Test' + String.valueof(Math.random())+String.valueof(Math.random());
	 	ac.RecordtypeId = AccountHelper.BUSINESS_CENTRE_RT;
	 	ac.BillingLongitude = 1.01;
        ac.BillingLatitude = 1.12;
          
        return ac;
	 }

	  /*
	 * @Author          :   David Sanchez <david.sanchez@empaua.com>
	 * @Created         :   2019-05-24
	 * @Description     :   Create a Account
	 */
	 public static Account createBC(Id ManagerId){
	 	Account ac = new Account();
	 	ac.Name = 'BC Test'+ String.valueof(Math.random())+String.valueof(Math.random());
	 	ac.RecordtypeId = AccountHelper.BUSINESS_CENTRE_RT;
	 	ac.BillingLongitude = 1.01;
        ac.BillingLatitude = 1.12;
        ac.CentreManager__c = ManagerId;
        return ac;
    }
}