@isTest
private class AccountTriggerTest {
	
	@isTest static void newBCToWebAPI() {
		Account ac = TestFactory.createBC();
		insert ac;

		BC_sync_Fields__mdt newfields = new BC_sync_Fields__mdt();
		newfields.MasterLabel = 'Name';
		newfields.DeveloperName = 'Name';
		newfields.Field_API_Name__c = 'Name';

		ac.Status__c = AccountHelper.APPROVED_STATUS;
		update ac;

		ac.Name = 'Changed Name';
		update ac;

		ac.Status__c = null;
		update ac;

		delete ac;
	}
	
	
	
}