@isTest
public class WebAPIUtilsTest {
   
    private final static Integer NUMBER_OF_RECORDS = 4;
    public final static string BC_URL= 'https://Test.com';
    public static Boolean MOCKLIMITS = false;
    public static Boolean MOCKERROR = false;

	@TestSetup
    static void makeData(){
        Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business_Centre')
            .getRecordTypeId();
        Account a = new Account(Name = 'TestAccount', RecordTypeId = bcRecordTypeId);
            insert a;
        Search_Parameter__c SP = new Search_Parameter__c();
        SP.Url__c = BC_URL;
        sp.name = 'SP1';
        insert SP;

    }
	
	@isTest static void createMitelCallBackTest() {
        
		System.debug('Entered sendCallBack');
	 	List<MitelAPIConnector.MitelCallBackClass> callbackList = new List<MitelAPIConnector.MitelCallBackClass>();
	 	map<Id,String> userQueueIdMap = new map<Id,String>();

	 	//Process Leads list to serialize into callback wrapper list, then send to queueable process.	 	
	 	for(integer i = 0; i<NUMBER_OF_RECORDS; i++){
     
            System.debug('Entered Mitel API Connector if statement');
            MitelAPIConnector.MitelCallBackClass newCallBack = new MitelAPIConnector.MitelCallBackClass();
        
            newCallBack.Name = 'Test ';//Needs to be user name.This isfor the popup.
            newCallBack.CountryName = 'Spain';
            newCallBack.CallerPhoneNumber =  '58741235'+i;
            newCallBack.DestinationNumber = '0dcf0ba0-9503-49c8-b119-5aeea9262fa3'; //User Queue Id
            newCallBack.OutboundWorkflowId = 'F8C67FAC-31E8-4ACF-8D99-28129548BCD4'; //0465d5d1-a14f-4d83-8f2d-13afae4b63eb
            newCallBack.Type = '1';

            callbackList.add(newCallBack);
	 		
	 	}

	 	//Send list to Queueable process
        Test.startTest();
       
	 	    WebAPIUtils.createMitelCallBack(callbackList);
           
        Test.stopTest();
        
	}
    @isTest static void getTokenTest() {
        Test.setMock(HttpCalloutMock.class, new webApiMockGenerator());
        Test.startTest();
            String Token = WebAPIUtils.getToken();
            System.assertEquals('12345678', Token);
        Test.stopTest();
		// Implement test code
	}
    @isTest static void getTokenExistingTest() {
        WebAPISetup__c newToken = new WebAPISetup__c();
        newToken.Token_Key__c = WepAPICallOutTest.tokenExample;
        newToken.Expires_Date__c = System.today().addmonths(1);
        newToken.Name = 'tokenRec';
        insert newToken;

        Test.startTest();
            String Token = WebAPIUtils.getToken();
            System.assertEquals(WepAPICallOutTest.tokenExample, Token);
        Test.stopTest();
		
	}
    @isTest static void sendPOSTCallBackToMitelTest() {
		System.debug('Entered sendCallBack');
	 	List<MitelAPIConnector.MitelCallBackClass> callbackList = new List<MitelAPIConnector.MitelCallBackClass>();
	 	map<Id,String> userQueueIdMap = new map<Id,String>();

	 	//Process Leads list to serialize into callback wrapper list, then send to queueable process.	 	
	 	for(integer i = 0; i<NUMBER_OF_RECORDS; i++){
     
            System.debug('Entered Mitel API Connector if statement');
            MitelAPIConnector.MitelCallBackClass newCallBack = new MitelAPIConnector.MitelCallBackClass();
        
            newCallBack.Name = 'Test ';//Needs to be user name.This isfor the popup.
            newCallBack.CountryName = 'Spain';
            newCallBack.CallerPhoneNumber =  '58741235'+i;
            newCallBack.DestinationNumber = '0dcf0ba0-9503-49c8-b119-5aeea9262fa3'; //User Queue Id
            newCallBack.OutboundWorkflowId = 'F8C67FAC-31E8-4ACF-8D99-28129548BCD4'; //0465d5d1-a14f-4d83-8f2d-13afae4b63eb
            newCallBack.Type = '1';

            callbackList.add(newCallBack);
	 		
	 	}

	 	//Send list to Queueable process
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new webApiMockGenerator());

	 	    WebAPIUtils.sendPOSTCallBackToMitel(JSON.serialize(callbackList));
           
           
        Test.stopTest();
        System.assertEquals(0,[SELECT Id FROM Debug_Log__c].size());
	}
    @isTest static void sendPOSTCallBackToMitelERRORTest() {
		System.debug('Entered sendCallBack');
	 	List<MitelAPIConnector.MitelCallBackClass> callbackList = new List<MitelAPIConnector.MitelCallBackClass>();
	 	map<Id,String> userQueueIdMap = new map<Id,String>();

	 	//Process Leads list to serialize into callback wrapper list, then send to queueable process.	 	
	 	for(integer i = 0; i<NUMBER_OF_RECORDS; i++){
     
            System.debug('Entered Mitel API Connector if statement');
            MitelAPIConnector.MitelCallBackClass newCallBack = new MitelAPIConnector.MitelCallBackClass();
        
            newCallBack.Name = 'Test ';//Needs to be user name.This isfor the popup.
            newCallBack.CountryName = 'Spain';
            newCallBack.CallerPhoneNumber =  '58741235'+i;
            newCallBack.DestinationNumber = '0dcf0ba0-9503-49c8-b119-5aeea9262fa3'; //User Queue Id
            newCallBack.OutboundWorkflowId = 'F8C67FAC-31E8-4ACF-8D99-28129548BCD4'; //0465d5d1-a14f-4d83-8f2d-13afae4b63eb
            newCallBack.Type = '1';

            callbackList.add(newCallBack);
	 		
	 	}

	 	//Send list to Queueable process
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new webApiMockGenerator());
            MOCKERROR = true;
	 	    WebAPIUtils.sendPOSTCallBackToMitel(JSON.serialize(callbackList));
          
           
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM Debug_Log__c].size());
	}
    @isTest static void sendPOSTMessageErrorTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new webApiMockGenerator());
        MOCKERROR = true;
        WebAPIUtils.sendPOSTMessage('addbusinesscentre','jsonToSend',[SELECT Id FROM Account LIMIT 1].id);
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM Debug_Log__c].size());
	}
    @isTest static void sendPOSTMessageTest() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new webApiMockGenerator());
            MOCKERROR = false;
            WebAPIUtils.sendPOSTMessage('addbusinesscentre','jsonToSend',[SELECT Id FROM Account LIMIT 1].id);
            System.assertEquals(1,[SELECT ID FROM Account WHERE APISync__c = true AND FlexiWebsiteLinkNew__c = :BC_URL].size());
        Test.stopTest();
        
	}
    @isTest static void getEndPointTest() {

        String strOrg = [SELECT IsSandbox FROM Organization].IsSandbox?'SBX' :'PRO';
        WebAPICredential__mdt WebAPICredential = [SELECT Endpoint__c, User__c, Password__c 
        FROM WebAPICredential__mdt WHERE DeveloperName = :strOrg];
        MitelAPIConfig__mdt MitelConf = [SELECT Endpoint__c 
        FROM MitelAPIConfig__mdt WHERE DeveloperName = :strOrg];
        Test.startTest();
		System.assertEquals(WebAPICredential.Endpoint__c,WebAPIUtils.getEndPoint('WebAPI'));
        System.assertEquals(MitelConf.Endpoint__c,WebAPIUtils.getEndPoint('Mitel'));
        Test.stopTest();
    
	}
    @isTest static void createLogTest() {
        Test.startTest();
		    WebAPIUtils.createLog('test','test','test',200,'test');
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM Debug_Log__c].size());
	}
    @isTest static void createLogSyncTest() {
		Test.startTest();
            Debug_Log__c log = WebAPIUtils.createLogSync('test','test','test',200,'test');
            insert log;
            System.assertEquals(1,[SELECT Id FROM Debug_Log__c WHERE Request_Status__c = 200].size());
        Test.stopTest();
        
	}
    @isTest static void AccessTokenResponseTest() {
        Test.startTest();
            WebAPIUtils.AccessTokenResponse WAPI= new WebAPIUtils.AccessTokenResponse();
            WAPI.access_token = '1234567';
            WAPI.expires_in = '1234567';
        Test.stopTest();
	}
    @isTest static void mDebugUntruncatedTest() {
        Test.startTest();
            WebAPIUtils.mDebugUntruncated('TEST');
        Test.stopTest();
    }
    
	@isTest static void getCountryIdMapTest() {
      
        Test.startTest();    
        map<Integer,String> testmap = WebAPIUtils.getCountryIdMap();
        System.assert(!testmap.isEmpty());
        Test.stopTest();
    
	}
    @isTest static void getCountryIdMapISOCodeTest() {
      
        Test.startTest();    
        integer CountryISOCode = WebAPIUtils.getIdCountryMap([SELECT CountryID__c,CountryISOCode__c 
                                                                    FROM WebAPICountry__mdt 
                                                                    WHERE CountryISOCode__c != null LIMIT 1].CountryISOCode__c);
        System.assertNotEquals(null,CountryISOCode);
        CountryISOCode = WebAPIUtils.getIdCountryMap('test');
        System.assertEquals(null,CountryISOCode );
        Test.stopTest();
    
	}
    @istest static void getWebAPIStatistics() {
        list<WebAPIDataModel.StatisticBC> response = new list<WebAPIDataModel.StatisticBC>();

        Test.startTest();
        response = WebAPIUtils.getWebAPIStatistics();
        System.assert(!response.isEmpty());
        Test.stopTest();
    }

    @istest static void sendGETMessageTest() {

        Test.startTest();
        try {
        string response = WebAPIUtils.sendGETMessage('autocomplete',true);
        MOCKERROR =true;
        response = WebAPIUtils.sendGETMessage('autocomplete',true);
        System.assert(true);
        }catch(Exception exc) {
            System.assert(false,exc.getMessage());
        }
       

        Test.stopTest();
    }
}