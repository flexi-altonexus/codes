global class BatchDeleteIntroductionRecords implements Database.Batchable<SObject> {

    String fromDate = Label.FromDate;
    String toDate = Label.ToDate;

    global Integer totalDeletedRecords = 0;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(' FromDate from custom label: ' + fromDate);
        System.debug(' ToDate from custom label: ' + toDate);
        
        Date startDate = Date.valueOf(fromDate);
        
        try {
            Date endDate = Date.valueOf(toDate);
            System.debug('Parsed ToDate: ' + endDate);
            
            String query = 'SELECT Id FROM Introduction__c WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate';
            System.debug('Query: ' + query);
            
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Error parsing ToDate: ' + e.getMessage());
            return null; 
        }
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        delete scope;
        totalDeletedRecords += scope.size();
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch delete process complete. Total records deleted: ' + totalDeletedRecords);
    }
}