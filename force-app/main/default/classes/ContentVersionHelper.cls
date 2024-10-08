public class ContentVersionHelper {
	
	public static void createpublicLink(List<ContentVersion> newlist){
	
		map<String,String> mastermap = new map<String,String>();
		set<Id> AccountSet = new set<Id>();
		set<Id> bcSetIds = new set<Id>();
		set<Id> cvSetIds = new set<Id>();
		
		for(ContentVersion cv:newlist){
			if(String.valueOf(cv.FirstPublishLocationId).left(3) == '001'){
				AccountSet.add(cv.FirstPublishLocationId);
			}
		}

		for(Account acc:[Select Id from Account where recordtype.DeveloperName = 'Business_Centre' and Id IN:AccountSet]){
			bcSetIds.add(acc.Id);
		}

		System.debug('bcSetIds'+bcSetIds);
		
		list<ContentDistribution> ContentDistributionList = new list<ContentDistribution>();

		for(ContentVersion cv:newlist){
			if(String.valueOf(cv.FirstPublishLocationId).left(3) == '001' && bcSetIds.contains(cv.FirstPublishLocationId)){
				
				cvSetIds.add(cv.Id);

	            ContentDistribution cd = new ContentDistribution (
                ContentVersionId = cv.Id,
                PreferencesLinkLatestVersion = true,
                PreferencesAllowViewInBrowser = true,
                Name = cv.title,
                PreferencesNotifyOnVisit = false,
                PreferencesPasswordRequired = false,
                PreferencesNotifyRndtnComplete =false);

	           	ContentDistributionList.add(cd);
			}
		}
		System.debug('cvSetIds'+cvSetIds);
	  system.debug('JCContentDistributionList'+ContentDistributionList);
      
      insert ContentDistributionList;

      for(ContentDistribution cd:[SELECT ContentDocumentId, ContentDownloadUrl, DistributionPublicUrl, ContentVersionId FROM ContentDistribution WHERE ContentVersionId IN:cvSetIds]){
       	   mastermap.put(cd.ContentVersionId,ContentVersionHelper.convertDonwloadLinkToShareLink(cd.ContentDownloadUrl));
      }

      List<ContentVersion> cvListToUpdate = new List<ContentVersion>([select Id, Public_Link__c from ContentVersion WHERE Id IN:cvSetIds]);

      for(ContentVersion cv:cvListToUpdate){
      	cv.Public_Link__c = mastermap.get(cv.Id);
      }

      update cvListToUpdate;


	}


	public static String convertDonwloadLinkToShareLink(String strContentDownloadUrl){

	    String resultURL = null;

	    Integer posIni= strContentDownloadUrl.indexOf('/sfc/');

	    if(posIni > 0){
	        String webDomain = strContentDownloadUrl.substring(0,posIni);
	        //String webDomain = 'https://flexioffices--empauadev--c.cs105.content.force.com';

	        PageReference pageURL = new PageReference(strContentDownloadUrl);
	        String cvId = pageURL.getParameters().get('ids');
	        String d = pageURL.getParameters().get('d');
	        String oid = pageURL.getParameters().get('oid');

	        //resultURL = webDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+ cvId + '&operationContext=DELIVERY&d=' + d + '&oid='+ oid;

	        resultURL = webDomain + '/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId='+ cvId + '&d=' + d + '&oid='+ oid;
	    }

	    return resultURL;

   }

}