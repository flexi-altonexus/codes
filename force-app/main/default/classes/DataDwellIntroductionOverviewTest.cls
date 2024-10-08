@IsTest
public class DataDwellIntroductionOverviewTest {
    
    @TestSetup
    static void setup() {

        // Create Account
        Id businessCentreRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Centre').getRecordTypeId();
        Account account = new Account();
        account.recordTypeId = businessCentreRecId;
        account.Name = 'Test Account';
        insert account;
        
        // Create Lead
        Lead lead = new Lead();
        lead.LastName = 'Test';
        lead.Company = 'Test Company';
        insert lead;

        // Create Opportunity
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test Opportunity';
        opportunity.AccountId = account.Id;
        opportunity.CloseDate = Date.today() + 15;
        opportunity.StageName = 'Qualified'; 
        insert opportunity;

        // Create datadwell__DigitalDistribution__c (Portal)
        datadwell__DigitalDistribution__c ddDigitalDistribution = new datadwell__DigitalDistribution__c();
        ddDigitalDistribution.Lead__c = lead.Id;
        ddDigitalDistribution.datadwell__Opportunity__c = opportunity.Id;
        ddDigitalDistribution.Name = 'Introduction Portal';
        insert ddDigitalDistribution;

        // Create Digital_Asset__c
        datadwell__DigitalAsset__c digitalAsset = new datadwell__DigitalAsset__c();
        digitalAsset.Name = 'Test asset';
        digitalAsset.datadwell__URL__c = 'https://www.test.com';
        digitalAsset.datadwell__Embed_URL__c = true;
        insert digitalAsset;

        // Insert Introduction
        Introduction__c introduction = new Introduction__c();
        introduction.Lead__c = lead.Id;
        introduction.RelatedToDeal__c = opportunity.Id;
        introduction.BusinessCentre__c = account.Id;
        introduction.Digital_Asset__c = digitalAsset.Id;
        insert introduction;

        datadwell__DigitalDistributionActivity__c dist = new datadwell__DigitalDistributionActivity__c();
        dist.datadwell__DigitalAsset__c = digitalAsset.Id;
        dist.datadwell__ActivityType__c = 'Shared';
        dist.datadwell__DigitalDistribution__c = ddDigitalDistribution.Id;
        dist.datadwell__Custom_Folder__c = DataDwellHelper.customFolderName;
        insert dist;
    }

    @IsTest
    public static void testClassForLeads() {
        
        Introduction__c intro = [SELECT Id, Digital_Asset__c, Lead__c FROM Introduction__c WHERE Digital_Asset__c != null AND Lead__c != null LIMIT 1];
        
        datadwell__DigitalDistributionActivity__c act = [
            SELECT datadwell__DigitalDistribution__r.datadwell__Opportunity__c, datadwell__DigitalAsset__r.Id, datadwell__DigitalDistribution__c
            FROM datadwell__DigitalDistributionActivity__c 
            WHERE 
                datadwell__DigitalAsset__c = :intro.Digital_Asset__c AND 
                datadwell__ActivityType__c = 'Shared' AND 
                datadwell__DigitalAsset__r.datadwell__URL__c != null AND 
                datadwell__DigitalAsset__r.datadwell__Embed_URL__c = true
            LIMIT 1
        ];
        
        testTheClass(intro.Lead__c, intro.Id, act.datadwell__DigitalAsset__c, act.datadwell__DigitalDistribution__c);
    }
    
    @IsTest
    public static void testClassForOpps() {
        
        Introduction__c intro = [SELECT Id, Digital_Asset__c, RelatedToDeal__c FROM Introduction__c WHERE Digital_Asset__c != null AND RelatedToDeal__c != null LIMIT 1];
        
        datadwell__DigitalDistributionActivity__c act = [
            SELECT datadwell__DigitalDistribution__r.datadwell__Opportunity__c, datadwell__DigitalAsset__c, datadwell__DigitalDistribution__c
            FROM datadwell__DigitalDistributionActivity__c 
            WHERE 
                datadwell__DigitalAsset__c = :intro.Digital_Asset__c AND 
                datadwell__ActivityType__c = 'Shared' AND 
                datadwell__DigitalAsset__r.datadwell__URL__c != null AND 
                datadwell__DigitalAsset__r.datadwell__Embed_URL__c = true
            LIMIT 1
        ];
        
        testTheClass(intro.RelatedToDeal__c, intro.Id, act.datadwell__DigitalAsset__c, act.datadwell__DigitalDistribution__c);
        
    }
    
    private static void testTheClass(Id recordId, Id introId, Id assetId, Id distId) {
        
        String jsonIntros = DataDwellIntroductionOverviewController.fetchIntroductions(recordId);
        System.assertNotEquals('[]', jsonIntros);
        
        DataDwellIntroductionOverviewController.removeFromPortal(recordId, introId);
        List<datadwell__DigitalDistributionActivity__c> zeroActs = [
            SELECT Id FROM datadwell__DigitalDistributionActivity__c 
            WHERE datadwell__DigitalDistribution__c = :distId AND datadwell__ActivityType__c = 'Shared' AND datadwell__DigitalAsset__c = :assetId
        ];
        System.assertEquals(0, zeroActs.size());
        
        DataDwellIntroductionOverviewController.addToPortal(recordId, introId);
        List<datadwell__DigitalDistributionActivity__c> oneActs = [
            SELECT Id FROM datadwell__DigitalDistributionActivity__c 
            WHERE datadwell__DigitalDistribution__c = :distId AND datadwell__ActivityType__c = 'Shared' AND datadwell__DigitalAsset__c = :assetId
        ];
        System.assertEquals(1, oneActs.size());
    }
}