public class DataDwellIntroductionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private List<Id> introIds;

    public DataDwellIntroductionBatch(List<Id> ids) {
        this.introIds = ids;
    }
    
    public List<Sobject> start(Database.BatchableContext BC) {
        String slackQuery = 'SELECT Id, Lead__c, Digital_Asset__c, RelatedToDeal__c FROM Introduction__c WHERE Id IN :introIds';
        return database.query(slackQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Introduction__c> scope) {
        DataDwellHelper.createIntroductionDigitalAssets(scope);
    }
    
    public void finish(Database.BatchableContext BC) {}
}