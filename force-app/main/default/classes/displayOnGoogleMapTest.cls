/*
 * @who		: David Sanchez <david.sanchez@empaua.com>
 * @when	: 12-04-2019
 * @what	: Test class for the displayOnGoogleMap Class
 */
@isTest
public class displayOnGoogleMapTest {
    @isTest public static void loadLocationsTest(){
        Id providerRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider').getRecordTypeId();
        Account provider = TestFactory.createAccount('Test Provider',providerRecId);
        System.debug('---Provider: '+provider);
        insert provider;

        Id recId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
        Account acct1 = TestFactory.createAccount('Roberto Client Best',recId);
        acct1.ParentId = provider.Id;
        acct1.billingLongitude = -0.17567;
        acct1.billingLatitude = 51.518582;
        acct1.billingStreet = '2 Merchant Square Praed Street';
        acct1.billingCity = 'London';
        acct1.billingPostalcode = 'W2 1NH';
        acct1.billingCountry = 'United Kingdom';
        acct1.Type = 'Prospect';
        insert acct1;

        Account acct2 = TestFactory.createAccount('Miguel Client Also',recId);
        acct2.ParentId = provider.Id;
        acct2.billingLongitude = -0.0693747;
        acct2.billingLatitude = 51.609827;
        acct2.billingStreet = '98 Langhedge Close';
        acct2.billingCity = 'London';
        acct2.billingPostalcode = 'W2 1NH';
        acct2.billingCountry = 'United Kingdom';
        acct2.Type = 'Prospect';
        insert acct2;

        Map<String,String> fields = new Map<String,String>{'longitude' =>'billingLongitude',
                                                           'latitude' =>'billingLatitude',
                                                           'name' =>'name',
                                                           'address' => 'billingStreet, billingCity, billingPostalcode,billingCountry'
                                                          };

        test.startTest();
            List<Object> locations = displayOnGoogleMap.getLocations('Account',fields, 'Type = \'Prospect\'');
        test.stopTest();

        System.debug('---loadLocationsTest: locations: '+locations);
        System.assertEquals(2, locations.size(),'Locations');
    }
}