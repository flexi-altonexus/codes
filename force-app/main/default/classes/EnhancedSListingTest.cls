@isTest
public class EnhancedSListingTest{
	@isTest static void createNewSearhParameter() {
		
		Account ac = TestFactory.createBC();
		insert ac;

		Search_Parameter__c newSearchParam = new Search_Parameter__c();
		newSearchParam.Url__c = '/Test';
		newSearchParam.Name = 'Test';
		insert newSearchParam;

		newSearchParam.Url__c = '/Test2';
		update newSearchParam;

		delete newSearchParam;
		
		
	}

	@isTest static void updateSlot() {
		
		Account ac = TestFactory.createBC();
		insert ac;

		Account ac2 = TestFactory.createBC();
		insert ac2;

		Account ac3 = TestFactory.createBC();
		insert ac3;

		Search_Parameter__c newSearchParam = new Search_Parameter__c();
		newSearchParam.Url__c = '/Test';
		newSearchParam.Name = 'Test';
		insert newSearchParam;

		list<Enhanced_Listing__c> newEnLis = new list<Enhanced_Listing__c>([SELECT Id, First_Listing_Slot__c, Second_Listing_Slot__c, Third_Listing_Slot__c FROM Enhanced_Listing__c WHERE Search_Parameter__c=:newSearchParam.Id lIMIT 1]);
		
		newEnLis[0].First_Listing_Slot__c = ac.Id;
		newEnLis[0].Second_Listing_Slot__c = ac2.Id;
		newEnLis[0].Third_Listing_Slot__c = ac3.Id;

		update newEnLis;

		newEnLis[0].First_Listing_Slot__c = null;
		newEnLis[0].Second_Listing_Slot__c = null;
		newEnLis[0].Third_Listing_Slot__c = null;

		update newEnLis;
	
	}
}