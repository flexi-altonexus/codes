public class DataDwellHelper {

    public static Integer maxIntroProcess = 5;
    public static String portalName = 'Introduction Portal';
    public static String customFolderName = 'Your Options';
    private static Url cacheMicrositeUrl = null;

    public static Url getMicrositeUrl() {
        if(cacheMicrositeUrl == null) {
            List<datadwell__DDMicrosites__c> allMicrosites = datadwell__DDMicrosites__c.getAll().values();
            if(!allMicrosites.isEmpty() && allMicrosites.get(0).datadwell__Microsite_URL__c != null) {
                cacheMicrositeUrl = new Url(allMicrosites.get(0).datadwell__Microsite_URL__c);
            }
        }
        return cacheMicrositeUrl;
    }

    public static void createIntroductionDigitalAssets(List<Introduction__c> intros) {
        if(getMicrositeUrl() == null) {
            return;
        }
        Map<Id, List<Id>> objectAssetMap = new Map<Id, List<Id>>();
        Url siteUrl = getMicrositeUrl();
        Map<Id, String> introUrlMap = new Map<Id, String>();
        for(Introduction__c intro : intros) {
            if(intro.Digital_Asset__c == null) {
                introUrlMap.put(intro.Id, 'https://' + siteUrl.getHost() + '/apex/IntroductionPage?id=' + String.valueOf(intro.Id));
            } else {
                if(null != intro.Lead__c) {
                    if(!objectAssetMap.containsKey(intro.Lead__c)) {
                        objectAssetMap.put(intro.Lead__c, new List<Id>());
                    }
                    objectAssetMap.get(intro.Lead__c).add(intro.Digital_Asset__c);
                } else if(null != intro.RelatedToDeal__c) {
                    if(!objectAssetMap.containsKey(intro.RelatedToDeal__c)) {
                        objectAssetMap.put(intro.RelatedToDeal__c, new List<Id>());
                    }
                    objectAssetMap.get(intro.RelatedToDeal__c).add(intro.Digital_Asset__c);
                }
            }
        }
        if(!introUrlMap.keySet().isEmpty()) {
            Map<Id, Introduction__c> introsToUpdate = new Map<Id, Introduction__c>([
                SELECT 
                    Id, BusinessCentre__r.Name, Lead__c, RelatedToDeal__c, Digital_Asset__c
                FROM
                    Introduction__c
                WHERE
                    Id IN :introUrlMap.keySet()
            ]);
            
            // Create the assets for the portals
            createIntroductionAssets(introsToUpdate, introUrlMap);
            update introsToUpdate.values();

            for(Introduction__c intro : introsToUpdate.values()) {
                if(null != intro.Lead__c) {
                    if(!objectAssetMap.containsKey(intro.Lead__c)) {
                        objectAssetMap.put(intro.Lead__c, new List<Id>());
                    }
                    objectAssetMap.get(intro.Lead__c).add(intro.Digital_Asset__c);
                } else if(null != intro.RelatedToDeal__c) {
                    if(!objectAssetMap.containsKey(intro.RelatedToDeal__c)) {
                        objectAssetMap.put(intro.RelatedToDeal__c, new List<Id>());
                    }
                    objectAssetMap.get(intro.RelatedToDeal__c).add(intro.Digital_Asset__c);
                }
            }
        }
        if(!objectAssetMap.keySet().isEmpty()) {
            addAssetsToPortal(objectAssetMap);
        }
    }

    private static void addAssetsToPortal(Map<Id, List<Id>> objectAssetMap) {
        
        // Fetch the portals that have been created
        Map<Id, Id> leadPortalMap = new Map<Id, Id>();
        for(datadwell__DigitalDistribution__c portal : [SELECT Id, datadwell__Related_Id__c FROM datadwell__DigitalDistribution__c WHERE Name = :portalName AND datadwell__Related_Id__c = :objectAssetMap.keySet()]) {
            leadPortalMap.put(Id.valueOf(portal.datadwell__Related_Id__c), portal.Id);
        }
        
        // Create missing portals
        Map<Id, String> objectIdUrlMap = createMissingPortals(new Set<Id>(objectAssetMap.keySet()), leadPortalMap);
        if(!objectIdUrlMap.keySet().isEmpty()) {
            Set<Id> leadIds = new Set<Id>();
            Set<Id> oppIds = new Set<Id>();
            for(Id objectId : objectIdUrlMap.keySet()) {
                if('Lead' == String.valueOf(objectId.getSObjectType())) {
                    leadIds.add(objectId);
                } else {
                    oppIds.add(objectId);
                }
            }
            List<Lead> leads = [SELECT Id, Introduction_Portal_URL__c FROM Lead WHERE Id IN :leadIds];
            for(Lead lead : leads) {
                lead.Introduction_Portal_URL__c = objectIdUrlMap.get(lead.Id);
            }
            List<Opportunity> opps = [SELECT Id, Introduction_Portal_URL__c FROM Opportunity WHERE Id IN :oppIds];
            for(Opportunity opp : opps) {
                opp.Introduction_Portal_URL__c = objectIdUrlMap.get(opp.Id);
            }
            if(!leads.isEmpty()) {update leads;}
            if(!opps.isEmpty()) {update opps;}
        }
        
        // Fetch assets already in portals
        Map<Id, List<Id>> portalAssetMap = new Map<Id, List<Id>>();
        for(datadwell__DigitalDistributionActivity__c share : [SELECT Id, datadwell__DigitalDistribution__c, datadwell__DigitalAsset__c FROM datadwell__DigitalDistributionActivity__c WHERE datadwell__ActivityType__c = 'Shared' AND datadwell__DigitalDistribution__c = :leadPortalMap.values()]) {
            if(!portalAssetMap.containsKey(share.datadwell__DigitalDistribution__c)) {
                portalAssetMap.put(share.datadwell__DigitalDistribution__c, new List<Id>());
            }
            portalAssetMap.get(share.datadwell__DigitalDistribution__c).add(share.datadwell__DigitalAsset__c);
        }

        // Add assets to portals
        createPortalShares(leadPortalMap, objectAssetMap, portalAssetMap);
    }

    private static Map<Id, String> createMissingPortals(Set<Id> objectIds, Map<Id, Id> leadPortalMap) {
        Map<Id, String> idUrlMap = new Map<Id, String>();
        Set<Id> missingIds = objectIds;
        missingIds.removeAll(leadPortalMap.keySet());
        if(!missingIds.isEmpty()) {
            List<datadwell__DigitalDistribution__c> insertPortals = new List<datadwell__DigitalDistribution__c>();
            for(Id missingId : missingIds) {
                datadwell__DigitalDistribution__c dist = new datadwell__DigitalDistribution__c(
                    datadwell__Related_Id__c = String.valueOf(missingId),
                    Name = portalName,
                    datadwell__Main_Portal__c = true
                );
                if('Lead' == String.valueOf(missingId.getSObjectType())) {
                    dist.Lead__c = missingId;
                } else {
                    dist.datadwell__Opportunity__c = missingId;
                }
                insertPortals.add(dist);
            }
            insert insertPortals;
            for(datadwell__DigitalDistribution__c portal : insertPortals) {
                leadPortalMap.put(Id.valueOf(portal.datadwell__Related_Id__c), portal.Id);
            }
            Url siteUrl = getMicrositeUrl();
            for(datadwell__DigitalDistribution__c dist : [SELECT Id, datadwell__Related_Id__c, datadwell__Shorthand__c, Lead__c FROM datadwell__DigitalDistribution__c WHERE Id IN :leadPortalMap.values()]) {
                idUrlMap.put(Id.valueOf(dist.datadwell__Related_Id__c), siteUrl.toExternalForm() + '?id=' + dist.datadwell__Shorthand__c);
            }
        }
        return idUrlMap;
    }

    private static void createPortalShares(Map<Id, Id> leadPortalMap, Map<Id, List<Id>> objectAssetMap, Map<Id, List<Id>> portalAssetMap) {

        List<datadwell__DigitalDistributionActivity__c> insertShares = new List<datadwell__DigitalDistributionActivity__c>();
        for(Id objectId : objectAssetMap.keySet()) {
            Id portalId = leadPortalMap.get(objectId);
            List<Id> assetsInPortal = portalAssetMap.get(portalId);
            Set<Id> assetsAddPortal = new Set<Id>(objectAssetMap.get(objectId));
            if(assetsInPortal != null && !assetsInPortal.isEmpty()) {
                assetsAddPortal.removeAll(assetsInPortal);
            }
            if(!assetsAddPortal.isEmpty()) {
                for(Id assetId : assetsAddPortal) {
                    insertShares.add(new datadwell__DigitalDistributionActivity__c(
                        datadwell__ActivityType__c = 'Shared',
                        datadwell__DigitalAsset__c = assetId,
                        datadwell__DigitalDistribution__c = portalId,
                        datadwell__Custom_Folder__c = customFolderName
                    ));
                }
            }
        }
        if(!insertShares.isEmpty()) {
            insert insertShares;
        }

    }

    private static void createIntroductionAssets(Map<Id, Introduction__c> intros, Map<Id, String> introUrlMap) {

        Map<Id, ContentVersion> introCVMap = new Map<Id, ContentVersion>();
        Map<Id, Introduction__c> businessCenterNames = new Map<Id, Introduction__c>([SELECT BusinessCentre__r.Name FROM Introduction__c WHERE Id IN :intros.keySet()]);

        for(Id introId : introUrlMap.keySet()) {
            if(intros.containsKey(introId)) {
                String name = intros.get(introId).BusinessCentre__r.Name;
                String txtFile = '[InternetShortcut]\nURL=' + introUrlMap.get(introId) + '\nIconIndex=0';
                String base64Data = EncodingUtil.Base64Encode(Blob.valueOf( txtFile ));
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = EncodingUtil.base64Decode(base64Data);
                cv.Title = name;
                cv.PathOnClient = name+'.url';
                introCVMap.put(introId, cv);
            }
        }
        insert introCVMap.values();

        Map<Id, Id> contentVersionIntroMap = new Map<Id, Id>();
        Map<Id, Id> contentDocumentVersionMap = new Map<Id, Id>();
        for(Id introId : introCVMap.keySet()) {
            contentVersionIntroMap.put(introCVMap.get(introId).Id, introId);
        }

        List<ContentDocumentLink> contentDocumentLinksInsert = new List<ContentDocumentLink>();
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId from ContentVersion WHERE Id IN :contentVersionIntroMap.keySet()]);
        for(Id contentVersionId : contentVersionMap.keySet()) {
            Id contentDocumentId = contentVersionMap.get(contentVersionId).ContentDocumentId;
            contentDocumentVersionMap.put(contentDocumentId, contentVersionId);
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocumentId;
            cdl.LinkedEntityId = contentVersionIntroMap.get(contentVersionId);
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            contentDocumentLinksInsert.add(cdl);
        }
        insert contentDocumentLinksInsert;

        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        String sandboxParam = org.IsSandbox ? '&sandbox=1' : '';

        List<datadwell__DigitalAsset__c> assets = [SELECT Id, Name, datadwell__Download_URL__c, datadwell__URL__c, datadwell__Embed_URL__c, datadwell__Document_Id__c, datadwell__DigitalAssetFolder__c, datadwell__Shorthand__c FROM datadwell__DigitalAsset__c WHERE datadwell__Document_Id__c IN :contentDocumentVersionMap.keySet()];
        for(datadwell__DigitalAsset__c asset : assets) {
            Id contentVersionId = contentDocumentVersionMap.get(Id.valueOf(asset.datadwell__Document_Id__c));
            Id introId = contentVersionIntroMap.get(contentVersionId);
            String pdfFileName = EncodingUtil.urlEncode(businessCenterNames.get(introId).BusinessCentre__r.Name, 'UTF-8') + '.pdf';
            intros.get(introId).Digital_Asset__c = asset.Id;
            asset.datadwell__URL__c = introUrlMap.get(introId);
            asset.datadwell__Download_URL__c = 'https://services.datadwell.com/portals/flexioffices/?i=' + String.valueOf(introId) + '&name=' + pdfFileName + sandboxParam;
            asset.datadwell__Embed_URL__c = true;
        }
        update assets;
    }
    
}