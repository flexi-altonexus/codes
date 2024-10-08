@istest
public class DataDwellActivityProcessTriggerTest {

    @istest(SeeAllData=true)
    public static void testTrigger() {
        
        datadwell__DigitalDistributionActivity__c distAct = [
            SELECT Id, datadwell__Closed__c 
            FROM datadwell__DigitalDistributionActivity__c 
			WHERE datadwell__DigitalAsset__r.Resource_Asset__c = false
            ORDER BY CreatedDate
            DESC LIMIT 1
        ];
        
        distAct.datadwell__Closed__c = false;
        update distAct;
        
        distAct.datadwell__Closed__c = true;
        update distAct;
    }
    
}