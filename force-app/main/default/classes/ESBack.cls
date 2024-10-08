global class ESBack implements Database.Batchable <sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Enhanced_Listing__c, Business_Center__c, Number_of_Quotes__c, Slot__c, Views__c, Impressions__c, APISync__c, Unique_key__c FROM Enhanced_Slot__c ALL ROWS';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Enhanced_Slot__c> esList) {
        
        // process each batch of records default size is 200

        List<ESBack__c> deletedSlots = new List<ESBack__c>();
        for(Enhanced_Slot__c es : esList) {        
              
            deletedSlots.add(new ESBack__c(
                Name=es.Name,
            APISync__c = es.APISync__c,
            Enhanced_Listing__c = es.Enhanced_Listing__c,
            Business_Center__c=es.Business_Center__c,
            Slot__c= es.Slot__c,
            Unique_Key__c=es.Unique_key__c,
            CreatedDate =es.CreatedDate,
            CreatedByID =es.CreatedById,
            LastModifiedDate=es.LastModifiedDate,
            LastModifiedById=es.LastModifiedById,
            Views__c=es.Views__c,
            Impressions__c=es.Impressions__c,
            Number_of_Quotes__c=es.Number_of_Quotes__c));
        }
        try {
            // Update the Account Record
            insert deletedSlots;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}