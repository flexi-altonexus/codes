public class DataDwellIntroductionOverviewController {

    public class DataDwellIntroduction {
        public Id id;
        public Id businessCenterId;
        public String businessCenterName;
        public Boolean hasOptions;
        public Boolean shortlisted;
        public Integer shared = 0;
        public Integer opened = 0;
    }
    
    @AuraEnabled
    public static String fetchIntroductions(Id recordId) {
        List<Introduction__c> intros;
        
        // Is Lead
        if(String.valueOf(recordId).substring(0,3) == '00Q') {
            intros = [SELECT 
                      	Id, BusinessCentre__c, BusinessCentre__r.Name,BusinessCentre__r.Parent.name, Term_Length__c, Available_from__c,
            			Option_size__c, Monthly_quoting_rate__c, Monthly_cost_of_occupation__c, Notes__c,
                      	Digital_Asset__c, Shortlisted__c
                      FROM 
                      	Introduction__c 
                      WHERE 
                      	Lead__c = :recordId
                      ORDER BY
                      	BusinessCentre__r.Name
                     ];
        } else {
            intros = [SELECT 
                      	Id, BusinessCentre__c, BusinessCentre__r.Name,BusinessCentre__r.Parent.name, Term_Length__c, Available_from__c,
            			Option_size__c, Monthly_quoting_rate__c, Monthly_cost_of_occupation__c, Notes__c,
                      	Digital_Asset__c, Shortlisted__c
                      FROM 
                      	Introduction__c 
                      WHERE 
                      	RelatedToDeal__c = :recordId
                      ORDER BY
                      	BusinessCentre__r.Name
                     ];
        }
        if(!intros.isEmpty()) {
            Map<Id, DataDwellIntroduction> ddIntros = new Map<Id, DataDwellIntroduction>();
            Set<Id> assetIds = new Set<Id>();
            Map<Id, Id> assetIntroMap = new Map<Id, Id>();
            for(Introduction__c intro : intros) {
                
                assetIds.add(intro.Digital_Asset__c);
                assetIntroMap.put(intro.Digital_Asset__c, intro.Id);
                
                DataDwellIntroduction ddIntro = new DataDwellIntroduction();
                ddIntro.id = intro.Id;
                ddIntro.businessCenterId = intro.BusinessCentre__c;
                ddIntro.businessCenterName = intro.BusinessCentre__r.Parent.name != null?intro.BusinessCentre__r.Name  +'-'+ intro.BusinessCentre__r.Parent.name:intro.BusinessCentre__r.Name ;
                ddIntro.shortlisted = intro.Shortlisted__c;
                ddIntro.hasOptions = 
                    intro.Term_Length__c != null || 
                    intro.Available_from__c != null || 
                    intro.Option_size__c != null || 
                    intro.Monthly_quoting_rate__c != null || 
                    intro.Monthly_cost_of_occupation__c != null || 
                    intro.Notes__c != null;
                ddIntros.put(intro.Id, ddIntro);
            }
            
            List<datadwell__DigitalDistributionActivity__c> activities = [
                SELECT datadwell__DigitalAsset__c, datadwell__ActivityType__c 
                FROM datadwell__DigitalDistributionActivity__c
                WHERE datadwell__DigitalAsset__c IN :assetIds
            ];
            
            for(datadwell__DigitalDistributionActivity__c activity : activities) {
                if(activity.datadwell__ActivityType__c == 'Opened') {
                    ddIntros
                        .get(assetIntroMap.get(activity.datadwell__DigitalAsset__c))
                        .opened++;
                } else if(activity.datadwell__ActivityType__c == 'Shared') {
                    ddIntros
                        .get(assetIntroMap.get(activity.datadwell__DigitalAsset__c))
                        .shared++;
                }
            }
            
            return JSON.serialize(ddIntros.values());
        } else {
            return '[]';
        }
    }
    
    @AuraEnabled
    static public void addToPortal(Id recordId, Id introId) {
        datadwell__DigitalDistribution__c portal = getPortal(recordId);
        Introduction__c intro = [SELECT Id, Digital_Asset__c FROM Introduction__c WHERE Id = :introId];
        if(intro.Digital_Asset__c == null) {
            List<Introduction__c> introList = new List<Introduction__c>{intro};
            DataDwellHelper.createIntroductionDigitalAssets(introList);
            intro = [SELECT Id, Digital_Asset__c FROM Introduction__c WHERE Id = :introId];
        }
        List<datadwell__DigitalDistributionActivity__c> acts = [SELECT Id FROM datadwell__DigitalDistributionActivity__c WHERE datadwell__DigitalDistribution__c = :portal.Id AND datadwell__ActivityType__c = 'Shared' AND datadwell__DigitalAsset__c = :intro.Digital_Asset__c];
        if(acts.isEmpty()) {
            insert new datadwell__DigitalDistributionActivity__c(
                datadwell__DigitalAsset__c = intro.Digital_Asset__c,
                datadwell__ActivityType__c = 'Shared',
                datadwell__DigitalDistribution__c = portal.Id,
                datadwell__Custom_Folder__c = DataDwellHelper.customFolderName
            );
        }
    }
    
    @AuraEnabled
    static public void removeFromPortal(Id recordId, Id introId) {
        datadwell__DigitalDistribution__c portal = getPortal(recordId);
        Introduction__c intro = [SELECT Id, Digital_Asset__c FROM Introduction__c WHERE Id = :introId];
        if(intro.Digital_Asset__c != null) {
            List<datadwell__DigitalDistributionActivity__c> acts = [SELECT Id FROM datadwell__DigitalDistributionActivity__c WHERE datadwell__DigitalDistribution__c = :portal.Id AND datadwell__ActivityType__c = 'Shared' AND datadwell__DigitalAsset__c = :intro.Digital_Asset__c];
            if(!acts.isEmpty()) {
                delete acts;
            }
        }
    }
    
    static public datadwell__DigitalDistribution__c getPortal(Id recordId) {
        if(String.valueOf(recordId).substring(0,3) == '00Q') {
            return [SELECT Id FROM datadwell__DigitalDistribution__c WHERE Lead__c = :recordId AND Name = 'Introduction Portal' LIMIT 1];
        } else {
            return [SELECT Id FROM datadwell__DigitalDistribution__c WHERE datadwell__Opportunity__c = :recordId AND Name = 'Introduction Portal' LIMIT 1];
        }
    }
    
    
}