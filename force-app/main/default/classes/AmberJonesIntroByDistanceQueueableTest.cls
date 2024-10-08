@IsTest
public class AmberJonesIntroByDistanceQueueableTest {
    @TestSetup
    static void makeData(){
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

        RR_Postal_Code__c rrpc = new RR_Postal_Code__c(Name = 'AB32', Postal_Code__c = 'AB32');
        insert rrpc;
        RR_Group__c rrg = new RR_Group__c(Name = 'Amber Jones');
        insert rrg;
        RR_Postal_Code_Range_Assigment__c rrpcra = new RR_Postal_Code_Range_Assigment__c(RR_Postal_Code__c = rrpc.Id, Name = 'AB32Amber Jones1-2', Number_of_Desks_Max__c = 99, Number_of_Desks_min__c = 1, RR_Group__c = rrg.Id);
        insert rrpcra;
    }

    @IsTest
    static void AmberJonesIntroByDistanceQueueableTest() {
        Account acc = [SELECT Id FROM Account WHERE Name='Test Business Centre'];
        Introduction__c intro = new Introduction__c(FirstName__c='test', LastName__c='jess', Email__c='jessica.leung+may19@empaua.com', BusinessCentre__c=acc.Id, Company__c = 'TIER 1 LON', NumberofDesks__c = 2, CountryID__c = 94, OutwardCode__c = 'AB32');
        insert intro;

        System.assert(true);
    }
}