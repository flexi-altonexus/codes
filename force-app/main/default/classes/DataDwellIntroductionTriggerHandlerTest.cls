@IsTest
public with sharing class DataDwellIntroductionTriggerHandlerTest {
    
    @IsTest(SeeAllData=true) public static void testExistingLead() {
        Lead ld = [SELECT Id FROM Lead WHERE Owner.Type = 'User' ORDER BY CreatedDate DESC LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity ORDER BY CreatedDate DESC LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE PrimaryImage__c != null AND AirConditioning__c != null ORDER BY CreatedDate DESC LIMIT 1];
        List<Introduction__c> intros = new List<Introduction__c>();
        intros.add(new Introduction__c(BusinessCentre__c = acc.Id, Lead__c=ld.Id));
        intros.add(new Introduction__c(BusinessCentre__c = acc.Id, RelatedToDeal__c=opp.Id));
        insert intros;
        Introduction__c intro = [SELECT Id, Digital_Asset__c FROM Introduction__c WHERE Id = :intros.get(0).Id];
        Introduction__c anotherIntro = new Introduction__c(BusinessCentre__c = acc.Id, Lead__c=ld.Id, Digital_Asset__c = intro.Digital_Asset__c);
        insert anotherIntro;
    }
    
    @IsTest(SeeAllData=true) public static void testBatchProcess() {
        Lead ld = [SELECT Id FROM Lead WHERE Owner.Type = 'User' ORDER BY CreatedDate DESC LIMIT 1];
        Integer batchAmount = DataDwellHelper.maxIntroProcess + 1;
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id FROM Account WHERE PrimaryImage__c != null AND AirConditioning__c != null ORDER BY CreatedDate DESC LIMIT :batchAmount]);
        List<Introduction__c> intros = new List<Introduction__c>();
        for(Id accountId : accMap.keySet()) {
            intros.add(new Introduction__c(
                BusinessCentre__c = accountId, 
                Lead__c=ld.Id
            ));
        }
        insert intros;
    }
    
    @IsTest(SeeAllData=true) public static void testNewLead() {
        Lead ld = TestFactory.createLead('DataDwell', '90210', 3);
        Account acc = [SELECT Id FROM Account WHERE PrimaryImage__c != null AND AirConditioning__c != null ORDER BY CreatedDate DESC LIMIT 1];
        Introduction__c intro = new Introduction__c(BusinessCentre__c = acc.Id, Lead__c=ld.Id);
        insert intro;
    }
    
}