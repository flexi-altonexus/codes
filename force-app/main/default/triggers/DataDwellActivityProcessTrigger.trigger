trigger DataDwellActivityProcessTrigger on datadwell__DigitalDistributionActivity__c (after update) {
    Set<Id> distributionIds = new Set<Id>();
    Set<Id> activityIds = new Set<Id>();
    for(Integer i = 0; i < Trigger.new.size(); i++) {
        if(Trigger.new[i].datadwell__Closed__c == true && Trigger.old[i].datadwell__Closed__c == false) {
            //distributionIds.add(Trigger.new[i].datadwell__DigitalDistribution__c);
            activityIds.add(Trigger.new[i].Id);
        }
    }
    if(!activityIds.isEmpty()) {
        List<datadwell__DigitalDistributionActivity__c> acts = [
            SELECT Id, datadwell__DigitalDistribution__c 
            FROM datadwell__DigitalDistributionActivity__c
            WHERE Id IN :activityIds AND datadwell__DigitalAsset__r.Resource_Asset__c = false
        ];
        for(datadwell__DigitalDistributionActivity__c act : acts) {
            distributionIds.add(act.datadwell__DigitalDistribution__c);
        }
        if(!distributionIds.isEmpty()) {
            List<datadwell__DigitalDistribution__c> dists = [
                SELECT Id, Last_Not_Resource_Processed__c 
                FROM datadwell__DigitalDistribution__c 
                WHERE Id IN :distributionIds
            ];
            for(datadwell__DigitalDistribution__c dist : dists) {
                dist.Last_Not_Resource_Processed__c = DateTime.now();
            }
            update dists;
        }        
    }
}