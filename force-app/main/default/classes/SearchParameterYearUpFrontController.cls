public class SearchParameterYearUpFrontController{
    /**
     * createEnhancedListings Handles the enhanced listings creation from the LWC
     *
     * @param recordId (Id): The search parameter Id
     *
     * @return String: Message with success or error
     */
    @AuraEnabled
    public static String createEnhancedListings(Id recordId){
        String result = 'success';

        try{
            addYearUpFront(recordId);
        } catch (Exception e){
            result = e.getMessage();
        }

        return result;
    }

    /**
     * addYearUpFront Get last enhanced listing and creates one year up front (12 more enhanced listings)
     *
     * @param recordId (Id): The Search Parameter Id
     */
    public static void addYearUpFront(Id recordId){
        // Get related
        List<Enhanced_Listing__c> lstEnhancedListings = [SELECT Id, Month_Date__c, Search_Parameter__c
                                                         FROM Enhanced_Listing__c
                                                         WHERE Search_Parameter__c = :recordId AND Month_Date__c != null
                                                         ORDER BY Month_Date__c DESC
                                                         LIMIT 1];

        // Start month to create Enhanced listings
        Date dateMonth = System.Date.today().addmonths(1).toStartOfMonth();
        if (!lstEnhancedListings.isEmpty()) {
            dateMonth = lstEnhancedListings.get(0).Month_Date__c.addmonths(1).toStartOfMonth();
        }

        // New Listings
        list<Enhanced_Listing__c> lstNewListings = new list<Enhanced_Listing__c>();

        // Pass I for Insert
        for (Integer i = 0; i < 12; i++){
            Enhanced_Listing__c newRec = new Enhanced_Listing__c();
            newRec.Month_Date__c = dateMonth;
            newRec.Search_Parameter__c = recordId;
            // Add new listing
            lstNewListings.add(newRec);
            // Get next month
            dateMonth = dateMonth.addMonths(1);
        }

        insert lstNewListings;
    }

}