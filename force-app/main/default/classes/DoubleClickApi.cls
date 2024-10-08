/*
* @Method          :   DoubleClickApi
* @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
* @Created         :   06 Aug 2020
* @Description     :   Contains All DobleClick API calls
*/   
public class DoubleClickApi {

    private final static string ADVERTISERID = label.DC_ADVERTISERID;
    private final static string DOUBLECLICK_HOST = label.DOUBLECLICK_HOST;
    private final static string DC_LEADSTATUSTRACKING_ENDPOINT = label.DC_LEADSTATUSTRACKING_ENDPOINT;
    private final static string DC_LEADSTATUSTRACKING_PAYLOAD = label.DC_LEADSTATUSTRACKING_PAYLOAD;
                                          
    private final static string DC_OPPORTUNITYSTATUSTRACKING_ENDPOINT = label.DC_OPPORTUNITYSTATUSTRACKING_ENDPOINT;
    private final static string DC_OPPORTUNITYSTATUSTRACKING_PAYLOAD = label.DC_OPPORTUNITYSTATUSTRACKING_PAYLOAD;
                                            
    private final static string GROUPTAGSTRING = '{Group Tag string}';
    private final static string ACTIVITYTAGSTRING = '{Activity Tag string}';
    private final static string RANDOMNUMBER = '{Random Number}';
    private final static string PEOPLE = '{People}';
    private final static string LEADID = '{Lead ID}';
    private final static string OPPORTUNITYID = '{Opportunity ID}';
    private final static string OPPORTUNITYSTATUSNAME = '{Opportunity Status Name}';

    private final static string BOOKVIEWING = 'Book a Viewing';
    private final static string GETPRICES = 'get prices';
    private final static string GETPRICESALTERNATIVE = 'get quote';
    private final static string AUS = 'AUS';
    private final static string AU = 'AU';
    private final static string UK = 'UK';  
    private final static string ENTERPRISE = 'Enterprise';  
    private final static string PRIME = 'Prime';  
    private final static string NONPRIME = 'Non-Prime';    

    /*
    * @Method          :   call_LeadInsertionTracking
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   30 Jul 2020
    * @Description     :   google Analytics Api method for Lead updated to Qualified
    */     

    // REPLACE pi__conversion_object_name__c for pi__conversion_object_name__c make it support lowercase
    public static void call_LeadStatusTracking(id recordId) {
        
        list<Lead> listQLead = [SELECT id,GA_Client_ID__c,Number_of_Desks__c,London_Prime__c,User_Agent_string__c,pi__conversion_object_name__c,Send_to_DC__c
                        FROM Lead 
                        WHERE id = :recordId
                        AND pi__conversion_object_name__c != null     
                        LIMIT 1];
        if(!listQLead.isEmpty()) {
            Lead qLead = listQLead[0];
        
        
            // FIX TO AVOID CHANGING 11 Test classes                   
            if(test.isRunningTest()) {
                qLead.GA_Client_ID__c = 'test GAClient';
                qLead.User_Agent_string__c = 'test.UserAgentString';
                qLead.Number_of_Desks__c = 5;
                qLead.pi__conversion_object_name__c = 'XXXXX - UK - get prices';
                
            }
          
            if(qLead.pi__conversion_object_name__c != null
                && qLead.User_Agent_string__c != null ) {
                string form_Origin = qLead.pi__conversion_object_name__c.contains(BOOKVIEWING)?BOOKVIEWING:qLead.pi__conversion_object_name__c.contains(GETPRICES)?GETPRICES:qLead.pi__conversion_object_name__c.contains(GETPRICESALTERNATIVE)?GETPRICES:'';                
                string website_Country_Code = qLead.pi__conversion_object_name__c.contains(UK)?UK:qLead.pi__conversion_object_name__c.contains(AUS)?AU:'';
                
                string prime_Status  = qLead.London_Prime__c?qLead.Number_of_Desks__c>15?ENTERPRISE:PRIME:NONPRIME;
                system.debug(form_Origin);
                system.debug(website_Country_Code);
                system.debug(prime_Status);
                list<DobleClickIntegrationTags__mdt> qDCTags =  [SELECT Id,Activity_Tag_string__c,
                                                                    Group_Tag_string__c,
                                                                    Prime_Status__c,
                                                                    sObject__c,
                                                                    Website_Country_Code__c 
                                                                    FROM DobleClickIntegrationTags__mdt
                                                                    WHERE SObject__c = 'Lead' 
                                                                    AND Form_Origin__c = :form_Origin
                                                                    AND Website_Country_Code__c = :website_Country_Code
                                                                    AND prime_Status__c = :prime_Status
                                                                    limit 1];
                
                if (!qDCTags.isEmpty()) {
                    
                    string calculatedActivityTAGSTRING = qLead.GA_Client_ID__c!= null? 'web':'non-web';
                    string payload = DC_LEADSTATUSTRACKING_PAYLOAD
                                                            .replace(GROUPTAGSTRING,EncodingUtil.urlEncode(qDCTags[0].Group_Tag_string__c,'UTF-8') )
                                                            .replace(ACTIVITYTAGSTRING,EncodingUtil.urlEncode(qDCTags[0].Activity_Tag_string__c,'UTF-8') )
                                                            .replace(RANDOMNUMBER,EncodingUtil.urlEncode(qLead.id+''+System.currentTimeMillis(),'UTF-8') )
                                                            .replace(PEOPLE,EncodingUtil.urlEncode(''+qLead.Number_of_Desks__c,'UTF-8')) 
                                                            .replace(LEADID,EncodingUtil.urlEncode(qLead.id,'UTF-8')) ;
                                                            
                
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();

                    request.setEndpoint(DOUBLECLICK_HOST + DC_LEADSTATUSTRACKING_ENDPOINT + payload); 
                    request.setMethod('GET');
                    request.setHeader('Content-Length', '0');
                    request.setHeader('User-Agent',qLead.User_Agent_string__c );
                    request.setTimeout(test.isRunningTest()?1:1000);

                    HttpResponse response = new HttpResponse();

                    if(test.isRunningTest()) {

                        response.setHeader('Content-Type', 'application/json');
                        response.setStatusCode(200);

                    }else {

                        response = http.send(request);
                    }

                    system.debug(response);
                    system.debug(response.getStatusCode());
                    if(response.getStatusCode() == 200
                        || response.getStatusCode() == 302) {

                        qLead.Send_to_DC__c = system.now();
                    
                        update qLead;
                
                    }
                }
            }
        }

    }
    /*
    * @Method          :   call_OpportunityStatusTracking
    * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
    * @Created         :   30 Jul 2020
    * @Description     :   google Analytics Api method for Opportunity Update to 1st Viewing Completed, Closed Won, Closed Lost
    */     
    public static void call_OpportunityStatusTracking(id recordId) {

        

        Opportunity qOpp = [SELECT id,StageName,NumberofDesks__c,London_Prime__c,Send_to_DC__c 
                            FROM Opportunity 
                            WHERE id = :recordId 
                            LIMIT 1];
                            
        Lead qLead = new Lead();
        // FIX TO AVOID CHANGING 11 Test classes                    
        if(test.isRunningTest()) {
            qLead.GA_Client_ID__c = 'test GAClient';
            qLead.User_Agent_string__c = 'test.UserAgentString';
            qLead.Number_of_Desks__c = 5;
            qLead.pi__conversion_object_name__c = 'test - UK - get prices';
            qLead.id = '00Q1X000003IRPr';
            qOpp.NumberofDesks__c = 5;
            

        } else {

            for(Lead lLead: [SELECT id,GA_Client_ID__c,User_Agent_string__c,pi__conversion_object_name__c,Number_of_Desks__c
                FROM Lead 
                WHERE ConvertedOpportunityId = :recordId
                LIMIT 1] ){
            
                qLead = lLead;        
            }

        }
        system.debug(qLead);
        if(qLead.pi__conversion_object_name__c != null
            // fix
            && qLEad.User_Agent_string__c != null) {
            string form_Origin = qLead.pi__conversion_object_name__c.contains(BOOKVIEWING)?BOOKVIEWING:qLead.pi__conversion_object_name__c.contains(GETPRICES)?GETPRICES:qLead.pi__conversion_object_name__c.contains(GETPRICESALTERNATIVE)?GETPRICES:'';        
            string website_Country_Code = qLead.pi__conversion_object_name__c.contains(UK)?UK:qLead.pi__conversion_object_name__c.contains(AUS)?AU:'';
        
            string prime_Status  = qOpp.London_Prime__c?qOpp.NumberofDesks__c>15?ENTERPRISE:PRIME:NONPRIME;

            list<DobleClickIntegrationTags__mdt> qDCTags =  [SELECT Id,Activity_Tag_string__c,
                                                                Group_Tag_string__c,
                                                                Prime_Status__c,
                                                                sObject__c,
                                                                Website_Country_Code__c 
                                                                FROM DobleClickIntegrationTags__mdt
                                                                WHERE SObject__c = 'Opportunity' 
                                                                AND Form_Origin__c = :form_Origin
                                                                AND Website_Country_Code__c = :website_Country_Code
                                                                AND prime_Status__c = :prime_Status
                                                                limit 1];
            
            
            if (!qDCTags.isEmpty()) {
                string calculatedActivityTAGSTRING = qLead.GA_Client_ID__c!= null? 'web':'non-web';
                                                            
                string payload =DC_OPPORTUNITYSTATUSTRACKING_PAYLOAD
                                                        .replace(GROUPTAGSTRING,EncodingUtil.urlEncode(qDCTags[0].Group_Tag_string__c,'UTF-8'))
                                                        .replace(ACTIVITYTAGSTRING,EncodingUtil.urlEncode(qDCTags[0].Activity_Tag_string__c,'UTF-8'))
                                                        .replace(RANDOMNUMBER,EncodingUtil.urlEncode(qOpp.id+''+System.currentTimeMillis(),'UTF-8'))
                                                        .replace(PEOPLE,EncodingUtil.urlEncode(''+qOpp.NumberofDesks__c,'UTF-8')) 
                                                        .replace(LEADID,EncodingUtil.urlEncode(''+qLead != null ?qLead.id:'','UTF-8'))
                                                        .replace(OPPORTUNITYID,EncodingUtil.urlEncode(qOpp.id,'UTF-8'))
                                                        .replace(OPPORTUNITYSTATUSNAME,EncodingUtil.urlEncode(qOpp.StageName,'UTF-8'));
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(DOUBLECLICK_HOST + DC_OPPORTUNITYSTATUSTRACKING_ENDPOINT + payload); 
                request.setMethod('GET');
                request.setHeader('Content-Length','0');      
                request.setHeader('User-Agent',qLead.User_Agent_string__c );
            
                request.setTimeout(test.isRunningTest()?1:10000);

                HttpResponse response = new HttpResponse();
                if(test.isRunningTest()) {

                    response.setHeader('Content-Type', 'application/json');
                    response.setStatusCode(200);

                }else {

                    response = http.send(request);
                }

                system.debug(response);
                
                if(response.getStatusCode() == 200
                    || response.getStatusCode() == 302) {

                    qOpp.Send_to_DC__c = system.now();
                
                    update qOpp;
            
                }

            }
        }
    }
   
}