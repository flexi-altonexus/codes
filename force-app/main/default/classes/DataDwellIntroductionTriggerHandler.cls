public class DataDwellIntroductionTriggerHandler {
    
    public static void handleAfterInsert(List<Introduction__c> newIntros) {
        if(DataDwellUserLicenseCheck.checkUserLicense('datadwell')) {
            if(newIntros.size() <= DataDwellHelper.maxIntroProcess) {
                DataDwellHelper.createIntroductionDigitalAssets(newIntros);
            } else {
                List<Introduction__c> runNow = new List<Introduction__c>();
                List<Id> runBatch = new List<Id>();
                for(Introduction__c intro : newIntros) {
                    if(runNow.size() < DataDwellHelper.maxIntroProcess) {
                        runNow.add(intro);
                    } else {
                        runBatch.add(intro.Id);
                    }
                }
                DataDwellHelper.createIntroductionDigitalAssets(runNow);
                DataDwellIntroductionBatch introBatch = new DataDwellIntroductionBatch(runBatch);
                database.executebatch(introBatch, DataDwellHelper.maxIntroProcess);
            }
        }
    }
    
}