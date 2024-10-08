public without sharing class ClearEnhancedFeeDataBatch implements Database.Batchable<sObject> {

    public List<Account> start(Database.BatchableContext bc) {
        Id BUSINESS_CENTRE_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Centre').getRecordTypeId(); 
        List<Account> accounts = [SELECT Id, Enhanced_Fee__c, Enhanced_Fee_End_Date__c FROM ACCOUNT WHERE RecordTypeId = :BUSINESS_CENTRE_RT AND Enhanced_Fee_End_Date__c = TODAY];
                
        return accounts;
    }

    public void execute(Database.BatchableContext bc, List<Account> accounts) {

        List<Account> accountsToUpdate = new List<Account>(); 
        for (Account account : accounts) {
            account.Enhanced_Fee__c = '';
            account.Enhanced_Fee_End_Date__c = null;
            accountsToUpdate.add(account);
        }

        if(!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
 
    public void finish(Database.BatchableContext bc) {
        
    }
}