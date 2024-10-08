/*
*   @Class          :   WebAPIUtils
*
*   @Author         :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
*   @Created        :   16 April 2019
*   @Description    :   Util class for ElasticSearch
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer                           Date                    Description
*   --------------------------------------------------------------------------------------
*   1       Lisis Rodriguez 				16 Abril 2019				Creation            
*
*/
public class WebAPIUtils {

	/*
	 * @Method          :   createMessage
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   Call queueable class and creates message 
	 */
	public static void createMessage(String strType, List<sObject> records){
		
		System.debug('Dentro de createMessage');
		WebAPIQueueable queueableItem;
		Id jobId;
		
		for(sObject rec:records){
			queueableItem = new WebAPIQueueable(strType, new list<sObject>{rec});
			jobId = System.enqueueJob(queueableItem);
		}
	}

	/*
	 * @Method          :   create callback
	 * @Author          :   Juan Carlos Porras Blanco
	 * @Created         :   17 Sep 2019
	 * @Description     :   Call queueable class and creates message taken in consideration callout limit on async context. 
	 */
	public static void createMitelCallBack(List<MitelAPIConnector.MitelCallBackClass> records){
		
		
		//Integer callOutLimit = limits.getLimitAsyncCalls(); getQueueableJobs getLimitQueueableJobs()  getLimitCallouts
		Integer callOutLimit = Limits.getLimitCallouts();
		Integer cont = 0;
		list<MitelAPIConnector.MitelCallBackClass> callbackList = new list<MitelAPIConnector.MitelCallBackClass>();
        Id jobId;
        MitelAPIConnector queueableItem;

		for(MitelAPIConnector.MitelCallBackClass callbackRec:records){
			
			if(cont <= callOutLimit){
				
				callbackList.add(callbackRec);
				cont++;
			
			}else{
				
				queueableItem = new MitelAPIConnector(callbackList);
				
				if(Limits.getLimitQueueableJobs() > Limits.getQueueableJobs()){
					jobId = System.enqueueJob(queueableItem);
				}

				callbackList.clear();
				cont = 0;

			}
		}

		if(callbackList.size()>0){
			queueableItem = new MitelAPIConnector(callbackList);
			if(Limits.getLimitQueueableJobs() > Limits.getQueueableJobs()){
				jobId = System.enqueueJob(queueableItem);
			}
		}
	
	}

	/*
	 * @Method          :   getToken
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   Call out to Web API to Get Token and store it in Saleforce
	 */
	public static String getToken(){
		
		//Get existing valid Token
		list<WebAPISetup__c> recTokenList = new list<WebAPISetup__c>([SELECT Token_Key__c, Expires_Date__c FROM WebAPISetup__c WHERE Name = 'tokenRec']);

		if(recTokenList.size() > 0 
			&& recTokenList[0].Token_Key__c != null 
			&& recTokenList[0].Expires_Date__c != null 
			&& recTokenList[0].Expires_Date__c > system.now()){
				System.debug('Out for existing Token');
				return recTokenList[0].Token_Key__c;
		}

		//construct an HTTP request
		Http http = new Http();
        HttpRequest req = new HttpRequest();

        //Get Custom Setting
        WebAPICredential__mdt WebAPICredential;

        try{
            //Query to know is SBX Enviroment
            Organization Org = [SELECT IsSandbox FROM Organization];

            String strOrg = (Org.IsSandbox)?'SBX' :'PRO';

            WebAPICredential = [SELECT Endpoint__c, User__c, Password__c 
            FROM WebAPICredential__mdt WHERE DeveloperName = :strOrg];
                    
        }catch(Exception e){}  

        if(WebAPICredential!=null && WebAPICredential.User__c != null && WebAPICredential.Password__c != null && WebAPICredential.Endpoint__c != null){

        	String endpoint = WebAPICredential.Endpoint__c + '/token';
			
			//Add Header format
			req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

			//Create and add Payload
			String payload = 'username='+EncodingUtil.urlEncode(WebAPICredential.User__c,'UTF-8')+'&password='+EncodingUtil.urlEncode(WebAPICredential.Password__c,'UTF-8')+'&grant_type=password';
			req.setBody(payload);
			
			//Set End Point
	        req.setEndpoint(endpoint);
	        //Method
	        req.setMethod('GET');

	        try{
	       		HttpResponse res = http.send(req);

	       		AccessTokenResponse AccessTokenReq = (AccessTokenResponse)JSON.deserialize(res.getBody(), AccessTokenResponse.class);

	       		WebAPISetup__c recToUpdate;

	       		if(recTokenList.size() > 0){
	       			recToUpdate = recTokenList[0];
	       		}else{
	       			recToUpdate = new WebAPISetup__c();
	       			recToUpdate.Name = 'tokenRec';
	       		}

	       		DateTime dt = System.now(); 
       			//Time minus 1 Hour for safety
       			Integer intSeconds = Integer.valueOf(AccessTokenReq.expires_in) - 3600;
				DateTime adjustedDt = dt.addSeconds(intSeconds);
       			recToUpdate.Token_Key__c = AccessTokenReq.access_token;
       			recToUpdate.Expires_Date__c = adjustedDt;

       			//upsert recToUpdate Name;

        		return AccessTokenReq.access_token;

	       	}catch(Exception e){
	       		return 'Error';
	       	}   

        }else{
        	return 'Error';
        }
	}

	
	 /*
	 * @Method          :   sendGETMessage
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   Call out to Wep API 
	 */
	public static String sendGETMessage(String service, Boolean tracklog){
		
		String JSONResponse = 'ERROR';

		String access_token = 'Bearer ' + getToken();
		system.debug(service);
		system.debug(access_token);

		if(String.isNotBlank(access_token) && access_token != 'Error'){
			//construct an HTTP request
			Http http = new Http();
	        HttpRequest req = new HttpRequest();
	        String strEndPoint = getEndPoint('WebAPI');

	        req.setMethod('GET');
	        req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', access_token);
        	req.setTimeout(120000);
        	
        	req.setEndpoint(strEndPoint + service);
			system.debug(strEndPoint);

	        try {
	             HttpResponse res = http.send(req);
	             
	             if(res.getStatusCode() != 200){
	                system.debug('Endpoint'+ getEndPoint('WebAPI') + service);
	                system.debug('Response'+ res.getbody());
	                if(tracklog){
	                	WebAPIUtils.createlog('',  res.getBody(),  strEndPoint + service,  res.getStatusCode(),  'Error StatusCode' + String.valueOf(res.getStatusCode()));
	                }
	                //return 'Error:' + String.valueOf(res.getStatusCode()) +  res.getBody();
	             }else{
	        		return res.getbody();
	             }
	                     
	        } catch(Exception e) {
	            System.debug('ERROR: '+ e.getMessage() + e.getStackTraceString());
	            if(tracklog){
	            	WebAPIUtils.createlog('',  'Not response, error before callout',  strEndPoint + service, 0, e.getMessage() + '-' + e.getStackTraceString());
	            }
	        }

	    }else{
	    	system.debug('Error get TOKEN');
	    }

		return JSONResponse;
	}
     
      /*
	 * @Method          :   sendPOSTMessage
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   Call out to Wep API 
	 */
	public static void sendPOSTCallBackToMitel(String jsonToSend){
		String JSONResponse = 'ERROR';
		
		//construct an HTTP request
		Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        
        String strEndPoint = getEndPoint('Mitel'); 

        //Set End Point
        req.setEndpoint(strEndPoint);
        //Method
        req.setMethod('POST');
        //Header & Options
        req.setTimeout(120000);
        //Content
        req.setBody(jsonToSend);

        
        try {
             HttpResponse res = http.send(req);
             
             if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
                System.debug('ERROR: '+ res.getStatusCode() + ' ' + res.getBody());
                WebAPIUtils.createlog(jsonToSend,  res.getBody(), 'Mitel CallBack' + strEndPoint,  res.getStatusCode(),  'Error StatusCode' + String.valueOf(res.getStatusCode()));
             } else{
                 System.debug('SUCCESS: '+ res.getStatusCode() + ' ' + res.getBody());
                 mDebugUntruncated(res.getBody());
             }
                     
        } catch(Exception e) {
            System.debug('ERROR: '+ e.getMessage() + e.getStackTraceString());
            WebAPIUtils.createlog(jsonToSend,  'Not response, error before callout', 'Mitel CallBack' + strEndPoint, 0, e.getMessage() + '-' + e.getStackTraceString());
        }
    
	}


	 /*
	 * @Method          :   sendPOSTMessage
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   Call out to Wep API
	 */
	public static void sendPOSTMessage(String service, String jsonToSend,Id recordId){
		String JSONResponse = 'ERROR';

		String access_token = 'Bearer ' + getToken();
		system.debug(access_token);

		if(String.isNotBlank(access_token) && access_token != 'Error'){
			//construct an HTTP request
			Http http = new Http();
	        HttpRequest req = new HttpRequest();
	        req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', access_token);
	       	        
	        //Set End Point
	        req.setEndpoint(getEndPoint('WebAPI') + service);
	        //Method
	        req.setMethod('POST');
	        //Header & Options
	        req.setTimeout(120000);
	        //Content
	        req.setBody(jsonToSend);

	        
	        try {
	             HttpResponse res = http.send(req);
	             System.debug(res.getBody());
	             if(res.getStatusCode() != 200){
	                System.debug('ERROR: '+ res.getStatusCode() + ' ' + res.getBody());
	                WebAPIUtils.createlog(jsonToSend,  res.getBody(),  service,  res.getStatusCode(),  'Error StatusCode' + String.valueOf(res.getStatusCode()));
	             }else{
	             	//TODO update lastsyncAPI field with recordId
	             	SObject recordToUpdate = recordId.getSObjectType().newSObject(recordId);
	             	
	             	//Save New URL
					System.debug(res.getBody());
	             	if(recordId.getSObjectType() == Schema.Account.getSObjectType()){
	             		WebAPIDataModel.BusinessCentreAdd_response returnRec = (WebAPIDataModel.BusinessCentreAdd_response)JSON.deserialize(res.getBody(),WebAPIDataModel.BusinessCentreAdd_response.class);
	             		if(returnRec != null &&  returnRec.data != null && returnRec.data.url !=null){
	             			recordToUpdate.put('FlexiWebsiteLinkNew__c',returnRec.data.url);
	             		}
	             	}
	             	recordToUpdate.put('APISync__c',true);
	             	update recordToUpdate;
	             }

	             system.debug('Callout Success');
	             system.debug(res.getBody());
	                     
	        } catch(Exception e) {
	            System.debug('ERROR: '+ e.getMessage() + e.getStackTraceString());
	            WebAPIUtils.createlog(jsonToSend,  'Not response, error before callout',  service, 0, e.getMessage() + '-' + e.getStackTraceString());
	        }
        }
	}

	/*
	 * @Method          :   getEndPoint
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   get End Point 
	 */
	public static String getEndPoint(String strType){
		String endpoint;
		
		try{
            //Query to know is SBX Enviroment
            Organization Org = [SELECT IsSandbox FROM Organization];

            String strOrg = (Org.IsSandbox)?'SBX' :'PRO';

            if(strType == 'WebAPI'){	
	            
	            WebAPICredential__mdt WebAPICredential = [SELECT Endpoint__c, User__c, Password__c 
	            FROM WebAPICredential__mdt WHERE DeveloperName = :strOrg];

	            if(WebAPICredential!=null && WebAPICredential.Endpoint__c != null){
	            	return WebAPICredential.Endpoint__c;
	            }

	        }else if(strType == 'Mitel'){

	        	MitelAPIConfig__mdt MitelConf = [SELECT Endpoint__c 
	            FROM MitelAPIConfig__mdt WHERE DeveloperName = :strOrg];

	            if(MitelConf!=null && MitelConf.Endpoint__c != null){
	            	return MitelConf.Endpoint__c;
	            }	
	        }
                    
        }catch(Exception e){}  

		return endpoint;
	}

	/*
	 * @Method          :   createLog
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description 
	 */
	 @future
	 public static void createLog(String jsonToSend, String response, String service, Integer status, String message){
	 	Debug_Log__c newlog = new Debug_Log__c();

        newlog.Request_Body__c    = jsonToSend;
        newlog.Request_Respond__c = response;
        newlog.Request_Service__c = service;
        newlog.Request_Status__c  = status;
        newlog.Error_message__c   = message;

        insert newlog;

	 }

	 /*
	 * @Method          :   createLog
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description 
	 */
	 
	 public static Debug_Log__c createLogSync(String jsonToSend, String response, String service, Integer status, String message){
	 	
	 	Debug_Log__c newlog = new Debug_Log__c();

        newlog.Request_Body__c    = jsonToSend;
        newlog.Request_Respond__c = response;
        newlog.Request_Service__c = service;
        newlog.Request_Status__c  = status;
        newlog.Error_message__c   = message;

        return newlog;

	 }

	 public Class AccessTokenResponse{
        public String access_token {get;set;}
        public String expires_in {get;set;}
    }
    public static void mDebugUntruncated(String sMsg) {
        for (Integer i = 0; i < sMsg.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (sMsg.length()-1) ? sMsg.length()-1 : i+300);
            System.debug(sMsg.substring(i,iEffectiveEnd));
        }
    }



	/*
	 * @Method          :   getCountryIdMap
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   get getCountryIdMap
	 */
	public static map<Integer,String> getCountryIdMap(){

		map<Integer,String> countryIdMap = new map<Integer,String>();
         
        for(WebAPICountry__mdt mdtRec:[SELECT CountryID__c,CountryISOCode__c FROM WebAPICountry__mdt]){
            if(mdtRec.CountryID__c != null && mdtRec.CountryISOCode__c!= null){
            	countryIdMap.put(Integer.valueof(mdtRec.CountryID__c),mdtRec.CountryISOCode__c);
            }
        }

        return countryIdMap;

    
	}

	/*
	 * @Method          :   getIdCountryMap
	 * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
	 * @Created         :   17 April 2019
	 * @Description     :   get getCountryIdMap
	 */
	public static Integer getIdCountryMap(String strCountryISOCode){

		for(WebAPICountry__mdt mdtRec:[SELECT CountryID__c,CountryISOCode__c FROM WebAPICountry__mdt WHERE CountryISOCode__c=:strCountryISOCode]){
            if(mdtRec.CountryID__c != null){
            	return Integer.valueof(mdtRec.CountryID__c);
            }
        }

        return null;

    
	}

	public static List<WebAPIDataModel.StatisticBC> getWebAPIStatistics(){
		
		//WebAPIDataModel.StatisticResponse  StatisticURL StatisticBC
		Integer intCurrentYear =  System.Date.today().adddays(-1).year();
		Integer intCurrentMonth =  System.Date.today().adddays(-1).month();
		for (WebApi_getWebAPIStatistics__mdt webAPISettings :[SELECT Id,CustomDate__c,useCustomDate__c 
															FROM WebApi_getWebAPIStatistics__mdt 
															WHERE useCustomDate__c = true 
															AND CustomDate__c != null LIMIT 1]) {
			intCurrentYear = webAPISettings.CustomDate__c.year();
			intCurrentMonth =  webAPISettings.CustomDate__c.month();
		}
		
		//First day of this month
        Date dateMonth = System.Date.today().adddays(-1).toStartOfMonth();

		String currentYear = String.valueof(intCurrentYear);
		String currentMonth =  String.valueof(intCurrentMonth);

		set<String> setExistingURL = new set<String>();
		map<String,Search_Parameter__c> newURLsToInsertMap = new map<String,Search_Parameter__c>();
		list<Enhanced_Listing__c> newEnhancedToInsert = new list<Enhanced_Listing__c>();
		//return List
		List<WebAPIDataModel.StatisticBC> returnlist = new List<WebAPIDataModel.StatisticBC>();

		map<String,String> enhancedlistingsMap = new map<String,String>();
		List<WebAPIDataModel.StatisticBC> incomingBC = new List<WebAPIDataModel.StatisticBC>();

		try{
    		
			String JSONresponse;
	        if(Test.isRunningTest()){
	       	  JSONresponse = WepAPICallOutTest.StatisticResponse;
	       	}else{
	          JSONresponse = WebAPIUtils.sendGETMessage('/api/enhancedlistings/getstatistics?year='+ currentYear +'&month=' + currentMonth,true);
	       	}
	        	    	
			system.debug('JSON Response:'+JSONresponse);
			if(JSONresponse !='Error'){
	    		JSONresponse = WebAPIDataModel.convertExternalId(JSONresponse);
	    		WebAPIDataModel.StatisticResponse returnResult = (WebAPIDataModel.StatisticResponse)JSON.deserialize(JSONresponse,WebAPIDataModel.StatisticResponse.class);
				
	    		//Get Enchanced keys
	    		for(WebAPIDataModel.StatisticURL wurl:returnResult.urls){
	    			
	    			system.debug('URL'+wurl);
	    			enhancedlistingsMap.put(wurl.url,null);
	    			for(WebAPIDataModel.StatisticBC wbc:wurl.bcs){
	    				incomingBC.add(wbc);
	    			}
	    		}

	    		//Query URLS NOT IN
	    		for(Search_Parameter__c url: [SELECT Id, Url__c FROM Search_Parameter__c WHERE Url__c IN:enhancedlistingsMap.keyset()]){
	    			setExistingURL.add(url.Url__c);
	    		}

	    		if(enhancedlistingsMap.size() != setExistingURL.size()){
	    			for(String strURL:enhancedlistingsMap.keyset()){
	    				if(!setExistingURL.contains(strURL)){
	    					
	    					//New URl
	    					Search_Parameter__c newRec = new Search_Parameter__c();
	    					newRec.Url__c = strURL;
	    					newURLsToInsertMap.put(strURL,newRec);
  					
	    				}
	    			}
	    		}

	    		System.debug('>>>>>>>>>>>>newURLsToInsertMap'+newURLsToInsertMap);
	    		insert newURLsToInsertMap.values();

	    		for(String strUrl:newURLsToInsertMap.keyset()){
	    			//New Enhanced
					Enhanced_Listing__c newRecEn = new Enhanced_Listing__c();
					newRecEn.Month_Date__c = dateMonth;
					newRecEn.Search_Parameter__c = newURLsToInsertMap.get(strUrl).Id;
					newEnhancedToInsert.add(newRecEn);
					enhancedlistingsMap.put(strURL, null);
	    		}

	    		System.debug('>>>>>>>>>>>>newEnhancedToInsert'+newEnhancedToInsert);
	    		insert newEnhancedToInsert;

	    		//Query Enhanced Records  Month_Date__c

	    		for(Enhanced_Listing__c el:[SELECT Id,Search_Parameter__r.Url__c FROM Enhanced_Listing__c WHERE Search_Parameter__r.Url__c IN:enhancedlistingsMap.keyset() 
	    			AND CALENDAR_MONTH(Month_Date__c) = :intCurrentMonth
	    			AND CALENDAR_YEAR(Month_Date__c) = :intCurrentYear]){

	    				if(enhancedlistingsMap.containskey(el.Search_Parameter__r.Url__c)){
	    					enhancedlistingsMap.put(el.Search_Parameter__r.Url__c, el.id);
	    				}

	    		}

	    		//Get Enchanced keys
	    		for(WebAPIDataModel.StatisticURL wurl:returnResult.urls){
	    			if(enhancedlistingsMap.containskey(wurl.url) && enhancedlistingsMap.get(wurl.url) != null) {
						System.debug(wurl);
						for(WebAPIDataModel.StatisticBC wbc:wurl.bcs){
							
							System.debug(wbc);
							if(string.isnotBlank(wbc.Id)){
								wbc.uniqueKey = enhancedlistingsMap.get(wurl.url) + wbc.Id;
								returnlist.add(wbc);
							}
						}
					}
	    	    			
	    		}

	    	}
		}catch(Exception ex){
		    		
		}

        system.debug('>>>>>>>>>SIZE incomingBC :'+incomingBC.size());
		system.debug('>>>>>>>>>SIZE resultList:'+returnlist.size());

		return returnlist;

	}
	
		
}