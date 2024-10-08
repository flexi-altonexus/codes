@IsTest
public class SearchParameterYearUpFrontControllerTest {
    
    @TestSetup
    static void makeData(){
        String url_param_1 = '/test/url';
        Search_Parameter__c searchParam_1 = new Search_Parameter__c(Url__c = url_param_1, Name = url_param_1);
        insert searchParam_1;
    }

    @IsTest
    public static void createEnhancedListingsTest() {
        List<Search_Parameter__c> lstSearchParam = [SELECT Id FROM Search_Parameter__c LIMIT 1];
        System.assert(!lstSearchParam.isEmpty(), 'A search parameter must be created already.');

        Search_Parameter__c test_param_1 = lstSearchParam.get(0);

        // Check for existings enhanced listings
        List<Enhanced_Listing__c> lstEnhancedListings_1 = [SELECT Id, Month_Date__c, Search_Parameter__c
                                                         FROM Enhanced_Listing__c
                                                         WHERE Search_Parameter__c = :test_param_1.Id AND Month_Date__c != null
                                                         ORDER BY Month_Date__c DESC];
        
        Integer enhancedListingSize_1stQuery = lstEnhancedListings_1.size();
        System.assertEquals(11, enhancedListingSize_1stQuery, 'The amount of enhanced listings created by default does not match 11.');
        
        
        SearchParameterYearUpFrontController.createEnhancedListings(test_param_1.Id);
        List<Enhanced_Listing__c> lstEnhancedListings_2 = [SELECT Id, Month_Date__c, Search_Parameter__c
                                                         FROM Enhanced_Listing__c
                                                         WHERE Search_Parameter__c = :test_param_1.Id AND Month_Date__c != null
                                                         ORDER BY Month_Date__c DESC];
        Integer enhancedListingSize_2ndQuery = lstEnhancedListings_2.size();
        // Check that 12 more listings were created
        System.assertEquals(12, enhancedListingSize_2ndQuery - enhancedListingSize_1stQuery, 'There should be 12 more listings created.');
        // Check the old last listing plus 12 months is equal to the new last one
        System.assertEquals(lstEnhancedListings_1.get(0).Month_Date__c.addMonths(12), lstEnhancedListings_2.get(0).Month_Date__c, 'The last enhanced listing month does not match with the old last one plus 12 months');
    }
}