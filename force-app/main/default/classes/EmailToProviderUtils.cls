/*
*   @Class          :   EmailToProviderUtils
*
*   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
*   @Created        :   16 Abril 2019
*   @Description    :   Class to store Data Model for XML generation 
*
*   */

global class EmailToProviderUtils {
	
	private static String kHexChars = '0123456789abcdef';
	public static emailServiceWrapper wrapRec {get;set;}

	public static String getEmailBody(Id introId){

		wrapRec = EmailToProviderUtils.getWrapperFromIntro(introId);
		
		if(wrapRec.emailType == 'Hubcreate/LeadDADI'){
			EmailServerMessageController.strFileName = 'LeadDADI.xml';
			return EmailToProviderUtils.getEmailBody();
		}else if(wrapRec.emailType == 'Ultrasoft CRM'){
			EmailServerMessageController.strFileName = EmailToProviderUtils.NewGuid()  + '.xml';
			return EmailToProviderUtils.getEmailBody();
		}

		return 'No Data';

	}

	public static String getXMLFile(){

		if(wrapRec.emailType == 'Hubcreate/LeadDADI'){
			return EmailToProviderUtils.getleadDADIXML();
		}else if(wrapRec.emailType == 'Ultrasoft CRM'){
			return EmailToProviderUtils.getultrasoftXML();
		}

		return '<?xml version="1.0" standalone="yes"?>';
	}



	public static String getEmailBody(){
		
		String result;
				
		result = '<div>';
		result += '<table width="600" cellspacing="5" cellpadding="0" bgcolor="#5A5B5D">';
		result += '<tbody><tr><td width="100%">';
		result += '<img src="https://ci4.googleusercontent.com/proxy/LphB8WFyVdazcMsoEZRdtQgKCZp5kY0CPJaniS18sJWH5LaaxJhZ73XdwSPBN7buLecljmlVV5AubYrbOxaD-ll5nKg=s0-d-e1-ft#http://recrm.flexioffices.co.uk/images/header.gif" alt="Logo" class="m_5668610040065688884m_-7473120367299621920m_3139822847388640538m_-5050211560336496370gmail-CToWUd CToWUd">'; 
		result += '</td></tr></tbody></table>'; 
		result += '<table width="600" cellspacing="5" cellpadding="0">'; 
		result += '<tbody><tr>'; 
		result += '<td width="50%">QUALIFIED LEAD from FlexiOffices</td>'; 
		result += '<td width="50%">Email sent: '+ date.today().format() + '</td>'; 
		result += '</tr></tbody></table>'; 
		result += '<hr style="width: 600px; border: 1px dotted #84B60E">'; 
		result += '<table width="600" cellspacing="5" cellpadding="0"> ';
		result += '<tbody><tr>'; 
		result += '<td><p>The Company below has expressed interest in renting space at your Business Centre(s). If you wish to accept or reject this introduction, please do so by replying to this email. If you wish to arrange a viewing, please contact the company directly.</p></td></tr>'; 
		result += '</tbody></table>'; 
		result += '<br>';  
		//Dynamic Information
		result += 'leadDADIID: {E0F8C8CE-90E6-4FA2-BE2B-<wbr>9611329FB787}<br>';  
		result += 'YOURREF:'+ wrapRec.yourRef +'<br>';  
		result += 'FIRSTNAME:'+ wrapRec.firstName +'<br>';  
		result += 'LASTNAME:'+ wrapRec.lastName +'<br>';  
		result += 'COMPANY:'+ wrapRec.company +'<br>';  
		result += 'ADDRESS1:'+ wrapRec.addrStreet +'<br>';  
		result += 'TOWN:'+ wrapRec.addrCity +'<br>';  
		result += 'COUNTY:'+ wrapRec.addrState +'<br>';  
		result += 'POSTCODE:'+ wrapRec.addrPostalcode +'<br>';  
		result += 'COUNTRY:'+ wrapRec.addrCountry +'<br>';  
		result += 'TELEPHONE:'+ wrapRec.phone +'<br>';  
		result += 'FAX:'+ wrapRec.fax +'<br>';  
		result += 'EMAIL:'+ wrapRec.email +'<br>';  
		result += 'WEBSITE:'+ wrapRec.website +'<br>';  
		result += 'INDUSTRY:'+ wrapRec.industry +'<br>';  

		result += 'NOOFWORKSTATIONS:'+ wrapRec.numDesk +'<br>';  //Meeting room
		result += 'LOCATION:'+ wrapRec.location +'<br>';  
        result += 'LOCATION CODE:' + wrapRec.locationCode + '<br>';
        result += 'BUILDING REFERENCE:' + wrapRec.buildingRef + '<br>';
		result += 'BUILDING OF INTEREST:' + wrapRec.bcName + '<br>';
		result += 'SPACE TYPE:'+ wrapRec.officeType +'<br>';  
		result += 'TIMING:'+ wrapRec.termMonths +'<br>';  
		result += 'AGENTCONTACT:'+ wrapRec.agentEmail +'<br>';  
		result += 'OTHER:'+ wrapRec.other +' <br><br>'; 
        result += 'FLEXIOFFICES AGENT QUALIFICATION<br><br>';
        result += 'Number of Desks: ' + wrapRec.numDesk + '<br>';
        result += 'Location: ' + wrapRec.location + '<br>';
		result += 'Building Reference:' + wrapRec.buildingRef + '<br>';
		result += 'Building of Interest:' + wrapRec.bcName + '<br>';
		result += 'Reason for move: ' + wrapRec.reasonForMove + '<br>';
		result += 'Start Date: ' + wrapRec.startDate + '<br>'; 
        result += 'Term: ' + wrapRec.termMonths + '<br>';
        result += 'Budget: ' + wrapRec.budget + '<br>';
		result += 'Key Driving Factors: ' + wrapRec.keyDrivingFactors + '<br>';
		result += 'Commentary: ' + wrapRec.comments + '<br>';
		//End Dynamic Information 
		result += '<br>';  
		result += '<hr style="width:600px;border:1px dotted rgb(132,182,14)">';  
		result += '<table width="600" cellspacing="5" cellpadding="0">';  
		result += '<tbody><tr>';  
		result += '<td><p>This referral is strictly for the benefit of the named recipient and should not under any circumstances be passed or sold on to any third party.</p></td>';  
		result += '</tr>';  
		result += '<tr>';  
		result += '<td><p>Should you already be aware of this applicant, please notify us by rejecting the introduction within 24 hours. Should we receive no response within 24 hours, the referral will be deemed accepted with fees payable should it convert to a letting. This referral has been sent out in accordance with our terms and conditions, a copy of which is available upon request. </p>';  
		result += '</td>';  
		result += '</tr>';  
		result += '<tr>';  
		result += '<td><p>Please visit <a href="http://www.flexioffices.co.uk/terms-of-use" target="_blank" data-saferedirecturl="https://www.google.com/url?q=http://www.flexioffices.co.uk/terms-of-use&source=gmail&ust=1560845768919000&usg=AFQjCNF5_UEGq9brz5bmX_4QbHLceOt5ng">http://www.flexioffices.co.uk/<wbr>terms-of-use</a> for our full Terms and Conditions. </p>';  
		result += '</td>';  
		result += '</tr>';  
		result += '<tr>';  
		result += '<td><p>FlexiOffices</p></td></tr></tbody></table>';  
		result += '</div>'; 

		return result;

	}

	
	public static String getleadDADIXML(){

		String result;
		
		result = '<?xml version="1.0" standalone="yes"?>'; 
		result += '<leadDADI>'; 
		result += '<LEAD>'; 
		result += '<leadDADIID>{E0F8C8CE-90E6-4FA2-BE2B-9611329FB787}</leadDADIID>'; 
		result += '<YOURREF>' + wrapRec.yourRef +'</YOURREF>'; 
		result += '<NAME>' + wrapRec.firstName + ' ' + wrapRec.lastName +'</NAME>'; 
		result += '<COMPANY>' + wrapRec.company +'</COMPANY>'; 
		result += '<ADDRESS1>' + wrapRec.addrStreet +'</ADDRESS1>'; 
		result += '<ADDRESS2></ADDRESS2>'; 
		result += '<ADDRESS3></ADDRESS3>'; 
		result += '<TOWN>' + wrapRec.addrCity +'</TOWN>'; 
		result += '<COUNTY>' + wrapRec.addrState +'</COUNTY>'; 
		result += '<POSTCODE>' + wrapRec.addrPostalcode +'</POSTCODE>'; 
		result += '<COUNTRY>' + wrapRec.addrCountry +'</COUNTRY>'; 
		result += '<TELEPHONE>' + wrapRec.phone +'</TELEPHONE>'; 
		result += '<FAX>' + wrapRec.fax +'</FAX>'; 
		result += '<EMAIL>' + wrapRec.email +'</EMAIL>'; 
		result += '<WEBSITE>' + wrapRec.website +'</WEBSITE>'; 
		result += '<INDUSTRY>' + wrapRec.industry +'</INDUSTRY>'; 
		result += '<NOOFWORKSTATIONS>' + wrapRec.numDesk +'</NOOFWORKSTATIONS>'; 
		result += '<SIZE>' + wrapRec.size +'</SIZE>'; 
		result += '<LOCATION>' + wrapRec.location +'</LOCATION>'; 
		result += '<TIMING>' + wrapRec.startDate +'</TIMING>'; 
		result += '<SPACETYPE>' + wrapRec.officeType +'</SPACETYPE>'; 
		result += '<QUALITYOFSPACE>' + wrapRec.quality +'</QUALITYOFSPACE>'; 
		result += '<DURATION>' + wrapRec.termMonths +'</DURATION>'; 
		result += '<AGENTCONTACT>' + wrapRec.agentEmail +'</AGENTCONTACT>'; 
		result += '<BUDGET>' + wrapRec.budget +'</BUDGET>'; 
		result += '<OTHER>' + wrapRec.other +'</OTHER>'; 
		result += '</LEAD>'; 
		result += '</leadDADI>'; 

		return result;
	}

	public static string getultrasoftXML(){
		
		String result;
			
		result = '<?xml version="1.0" standalone="yes"?>'; 
		result += '<DATAPACKET Version="2.0">'; 
		result += '<METADATA>'; 
		result += '<FIELDS>'; 
		result += '<FIELD attrname="UltraSoftCRMVersion" fieldtype="string" WIDTH="20" />'; 
		result += '<FIELD attrname="Title" fieldtype="string" WIDTH="15" />'; 
		result += '<FIELD attrname="FirstName" fieldtype="string" WIDTH="25" />'; 
		result += '<FIELD attrname="LastName" fieldtype="string" WIDTH="25" />'; 
		result += '<FIELD attrname="BusinessRole" fieldtype="string" WIDTH="40" />'; 
		result += '<FIELD attrname="CompanyName" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="AddressLine1" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="AddressLine2" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="City" fieldtype="string" WIDTH="40" />'; 
		result += '<FIELD attrname="StateCounty" fieldtype="string" WIDTH="40" />'; 
		result += '<FIELD attrname="ZipPostCode" fieldtype="string" WIDTH="10" />'; 
		result += '<FIELD attrname="Country" fieldtype="string" WIDTH="80" />'; 
		result += '<FIELD attrname="Email" fieldtype="string" WIDTH="80" />'; 
		result += '<FIELD attrname="Mobile" fieldtype="string" WIDTH="25" />'; 
		result += '<FIELD attrname="Phone" fieldtype="string" WIDTH="25" />'; 
		result += '<FIELD attrname="Fax" fieldtype="string" WIDTH="25" />'; 
		result += '<FIELD attrname="Location" fieldtype="string" WIDTH="80" />'; 
		result += '<FIELD attrname="Product" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="NumberOfWorkstations" fieldtype="i4" />'; 
		result += '<FIELD attrname="StartDate" fieldtype="dateTime" />'; 
		result += '<FIELD attrname="TermMonths" fieldtype="fixed" DECIMALS="2" WIDTH="15" />'; 
		result += '<FIELD attrname="EnquryDateTime" fieldtype="dateTime" />'; 
		result += '<FIELD attrname="Broker" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="BrokerContact" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="BrokerUniqueRef" fieldtype="string" WIDTH="50" />'; 
		result += '<FIELD attrname="BrokerComments" fieldtype="string" WIDTH="200" />'; 
		result += '</FIELDS>';  
		result += '<PARAMS />';  
		result += '</METADATA>';  
		result += '<ROWDATA>';  
		result += '<ROW UltraSoftCRMVersion="ultrasoft_crm_v8.0.2.1050"';
		
		//UltraSoft information
		result += ' Title="' + wrapRec.tittle + '"'; 
		result += ' FirstName="' + wrapRec.firstName + '"'; 
		result += ' LastName="' + wrapRec.lastName + '"'; 
		result += ' BusinessRole="' + wrapRec.businessRole + '"'; 
		result += ' CompanyName="' + wrapRec.company + '"'; 
		result += ' AddressLine1="' + wrapRec.addrStreet + '"';
		result += ' AddressLine2=""'; 
		result += ' City="' + wrapRec.addrCity + '"'; 
		result += ' StateCounty="' + wrapRec.addrState + '"'; 
		result += ' ZipPostCode="' + wrapRec.addrPostalcode + '"'; 
		result += ' Country="' + wrapRec.addrCountry + '"';
		result += ' Email="' + wrapRec.email + '"'; 
		result += ' Mobile="' + wrapRec.mobile + '"'; 
		result += ' Phone="' + wrapRec.phone + '"'; 
		result += ' Fax="' + wrapRec.fax + '"'; 
		result += ' Location="' + wrapRec.location + '"'; 
		result += ' Product="' + + '"'; 
		result += ' NumberOfWorkstations="' + wrapRec.numDesk + '"'; 
		result += ' StartDate="' + wrapRec.startDate + '"'; 
		result += ' TermMonths="' + wrapRec.termMonths + '"'; 
		result += ' EnquryDateTime="' +  + '"'; 
		result += ' Broker="Flexi Offices"'; 
		result += ' BrokerContact="'+ wrapRec.agentEmail + '"'; 
		result += ' BrokerUniqueRef="'+ wrapRec.yourRef +'"'; 
		result += ' BrokerComments="'+ wrapRec.comments +'" />'; 

		result += '</ROWDATA>';  
		result += '</DATAPACKET>'; 

		return result;
	}
   
    global static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += EmailToProviderUtils.getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += EmailToProviderUtils.getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    global static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }



	global class emailServiceWrapper{
		
		public String yourRef {get;set;}
		public String agentId {get;set;}
		public String agentEmail {get;set;}
		public String tittle {get;set;}
		public String firstName {get;set;}
		public String lastName {get;set;}
		public String company {get;set;}
		public String addrStreet {get;set;}
		public String addrCity {get;set;}
		public String addrState {get;set;}
		public String addrPostalcode {get;set;}
		public String addrCountry {get;set;}
		public String phone {get;set;}
		public String mobile {get;set;}
		public String fax {get;set;}
		public String email {get;set;}
		public String website {get;set;}
		public String industry {get;set;}
		public String officeType {get;set;}
		public String numDesk {get;set;}
		public String size {get;set;}
		public String quality {get;set;}
		public String budget {get;set;}
		public String other {get;set;}
		public String startDate {get;set;}
		public String termMonths {get;set;}
		public String location {get;set;}
		public String title {get;set;}
		public String businessRole {get;set;}
		public String product {get;set;}
		public String comments {get;set;}
		public String emailType {get;set;}
        public String keyDrivingFactors{get;set;}
        public String reasonForMove{get;set;}
        public String locationCode{get;set;}
		public String bcName{get;set;}
        public String buildingRef{get;set;}
		

	}

	public static emailServiceWrapper getWrapperFromIntro(String introId){

		emailServiceWrapper wrapRec = new emailServiceWrapper();

		String agentId = UserInfo.getUserId();
		String agentEmail = UserInfo.getUserEmail();

		//TODO Opportunity.Number of Desks & Location --> deberian de estar en Intro
		Introduction__c introRec = [SELECT BusinessCentre__c,
		BusinessCentre__r.name,
        BusinessCentre__r.Address_Formula__c,
        BusinessCentre__r.Building_Reference__c,
		BusinessCentre__r.EmailType__c,
		BusinessCentre__r.Location_Code__c,
		Client__c,
        Client__r.Name,
		Client__r.Address_Formula__c,
		Client__r.BillingCity,
		Client__r.BillingCountry,
		Client__r.BillingPostalCode,
		Client__r.BillingState,
		Client__r.BillingStreet,
		Client__r.Fax,
		Client__r.Website,
		Client__r.Industry, 
		Contact__c,
		Contact__r.Title,
		Contact__r.FirstName,
		Contact__r.LastName,
		Contact__r.Phone,
		Contact__r.MobilePhone,
        Contact__r.Email,
		Lead__c,
		Lead__r.Title,
		Lead__r.Company,
		Lead__r.City,
		Lead__r.Country,
		Lead__r.PostalCode,
		Lead__r.State,
		Lead__r.Street,
		Lead__r.Fax,
		Lead__r.Website,
		Lead__r.Industry,
		Lead__r.FirstName,
		Lead__r.LastName, 
		Lead__r.Phone,
		Lead__r.MobilePhone,
		Lead__r.Location__c,
		lead__r.Product__c,
		lead__r.NumberofDesks__c,
		lead__r.Budget__c,
		lead__r.Term__c,
		Lead__r.OtherReason__c,
		Lead__r.StartDate__c,
		Lead__r.Commentary__c,
        Lead__r.ReasonForMove__c, Lead__r.KeyDrivingFactors__c,
		Lead__r.Email,
		Lead__r.ConfidentialDetails__c,Contact__r.ConfidentialDetails__c,
		RelatedToDeal__c, 
        RelatedtoDeal__r.Location__c,
		RelatedtoDeal__r.NumberofDesks__c,
        RelatedtoDeal__r.Budget__c,
        RelatedtoDeal__r.StartDate__c,
		RelatedtoDeal__r.Term__c,
        RelatedtoDeal__r.Product__c,
        RelatedtoDeal__r.Commentary__c,
        RelatedtoDeal__r.KeyDrivingFactors__c,
        RelatedToDeal__r.ReasonForMove__c,
		IntroductionDateTime__c FROM Introduction__c WHERE Id =:introId][0];

		if(introRec!=null){
						
			wrapRec.yourRef = introRec.Client__c != null ? introRec.Client__c : introRec.Lead__c;
			wrapRec.yourRef = agentId + ' - ' + wrapRec.yourRef;
			//TODO not sure because of the number of characters.. we need to confirm before
			/*if(introRec.RelatedToDeal__c != null){
				wrapRec.yourRef = wrapRec.yourRef + ' - ' + introRec.RelatedToDeal__c;
			}*/

			wrapRec.agentId = agentId;
			wrapRec.agentEmail = agentEmail;
			wrapRec.bcName = introRec.BusinessCentre__r.Address_Formula__c;
            wrapRec.buildingRef = introRec.BusinessCentre__r.Building_Reference__c;
			wrapRec.emailType = introRec.BusinessCentre__r.EmailType__c != null ? introRec.BusinessCentre__r.EmailType__c :''; 
            wrapRec.locationCode = introRec.BusinessCentre__r.Location_Code__C != null ? introRec.BusinessCentre__r.Location_Code__c : '';

			if(introRec.Contact__c != null && introRec.Client__c != null){

				wrapRec.tittle = introRec.Contact__r.Title != null ? introRec.Contact__r.Title :'';
				wrapRec.firstName = introRec.Contact__r.FirstName != null ? introRec.Contact__r.FirstName :'';
				wrapRec.lastName = introRec.Contact__r.LastName!= null ? introRec.Contact__r.LastName :'';
				wrapRec.company = introRec.Client__r.Name!= null ? introRec.Client__r.Name :'';
				wrapRec.addrStreet = introRec.Client__r.BillingStreet!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Client__r.BillingStreet :'*Confidential*';
				wrapRec.addrCity = introRec.Client__r.BillingCity!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Client__r.BillingCity :'*Confidential*';
				wrapRec.addrState = introRec.Client__r.BillingState!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Client__r.BillingState :'*Confidential*';
				wrapRec.addrPostalcode = introRec.Client__r.BillingPostalCode!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Client__r.BillingPostalCode :'*Confidential*';
				wrapRec.addrCountry = introRec.Client__r.BillingCountry!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Client__r.BillingCountry :'*Confidential*';
				wrapRec.phone = introRec.Contact__r.Phone!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Contact__r.Phone :'*Confidential*';
				wrapRec.mobile = introRec.Contact__r.MobilePhone!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Contact__r.MobilePhone :'*Confidential*';
				wrapRec.fax = introRec.Client__r.Fax!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Client__r.Fax :'*Confidential*';
				wrapRec.email = introRec.Contact__r.Email!= null && introRec.Contact__r.ConfidentialDetails__c != TRUE ? introRec.Contact__r.Email :'*Confidential*';
				wrapRec.website =introRec.Client__r.Website!= null ? introRec.Client__r.Website :'';
				wrapRec.industry =introRec.Client__r.Industry!= null ? introRec.Client__r.Industry :'';
                
                wrapRec.location = introRec.RelatedtoDeal__r.Location__c!= null ? introRec.RelatedtoDeal__r.Location__c :'';
				wrapRec.numDesk  = introRec.RelatedtoDeal__r.NumberofDesks__c!= null ? String.valueof(introRec.RelatedtoDeal__r.NumberofDesks__c) :'';
				wrapRec.budget  = introRec.RelatedtoDeal__r.Budget__c!= null ? introRec.RelatedtoDeal__r.Budget__c :'';
				wrapRec.startDate  =  introRec.RelatedtoDeal__r.StartDate__c!= null ? introRec.RelatedtoDeal__r.StartDate__c :'';
				wrapRec.termMonths  = introRec.RelatedtoDeal__r.Term__c!= null ? introRec.RelatedtoDeal__r.Term__c :'';
				wrapRec.product = introRec.RelatedtoDeal__r.Product__c!= null ? introRec.RelatedtoDeal__r.Product__c :'';
				wrapRec.comments = introRec.RelatedtoDeal__r.Commentary__c!= null ? introRec.RelatedtoDeal__r.Commentary__c :'';
                wrapRec.reasonForMove = introRec.RelatedtoDeal__r.ReasonForMove__c != null ? introRec.RelatedtoDeal__r.ReasonForMove__c : '';
				wrapRec.keyDrivingFactors = introRec.RelatedtoDeal__r.KeyDrivingFactors__c != null ? introRec.RelatedtoDeal__r.KeyDrivingFactors__c : '';

			}else{

				wrapRec.tittle = introRec.Lead__r.Title != null ? introRec.Lead__r.Title :'';
				wrapRec.firstName = introRec.Lead__r.FirstName != null ? introRec.Lead__r.FirstName :'';
				wrapRec.lastName = introRec.Lead__r.LastName!= null ? introRec.Lead__r.LastName :'';
				wrapRec.company = introRec.Lead__r.Company != null ? introRec.Lead__r.Company :'';
				wrapRec.addrStreet = introRec.Lead__r.Street!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.Street :'*Confidential*';
				wrapRec.addrCity = introRec.Lead__r.City!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.City :'*Confidential*';
				wrapRec.addrState = introRec.Lead__r.State!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.State :'*Confidential*';
				wrapRec.addrPostalcode = introRec.Lead__r.PostalCode!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.PostalCode :'*Confidential*';
				wrapRec.addrCountry = introRec.Lead__r.Country!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.Country :'*Confidential*';
				wrapRec.phone = introRec.Lead__r.Phone!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.Phone :'*Confidential*';
				wrapRec.mobile = introRec.Lead__r.MobilePhone!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.MobilePhone :'*Confidential*';
				wrapRec.fax = introRec.Lead__r.Fax!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.Fax :'*Confidential*';
				wrapRec.email = introRec.Lead__r.Email!= null && introRec.Lead__r.ConfidentialDetails__c != TRUE ? introRec.Lead__r.Email :'*Confidential*';
				wrapRec.website =introRec.Lead__r.Website!= null ? introRec.Lead__r.Website :'';
				wrapRec.industry =introRec.Lead__r.Industry!= null ? introRec.Lead__r.Industry :'';

				wrapRec.location = introRec.Lead__r.Location__c!= null ? introRec.Lead__r.Location__c :'';
				wrapRec.numDesk  = introRec.Lead__r.NumberofDesks__c!= null ? String.valueof(introRec.Lead__r.NumberofDesks__c) :'';
				wrapRec.budget  = introRec.Lead__r.Budget__c!= null ? introRec.Lead__r.Budget__c :'';
				wrapRec.startDate  =  introRec.Lead__r.StartDate__c!= null ? introRec.Lead__r.StartDate__c :'';
				wrapRec.termMonths  = introRec.Lead__r.Term__c!= null ? introRec.Lead__r.Term__c :'';
				wrapRec.product = introRec.Lead__r.Product__c!= null ? introRec.Lead__r.Product__c :'';
				wrapRec.comments = introRec.Lead__r.Commentary__c!= null ? introRec.Lead__r.Commentary__c :'';
                wrapRec.reasonForMove = introRec.Lead__r.ReasonForMove__c != null ? introRec.Lead__r.ReasonForMove__c : '';
				wrapRec.keyDrivingFactors = introRec.Lead__r.KeyDrivingFactors__c != null ? introRec.Lead__r.KeyDrivingFactors__c : '';
			}

			wrapRec.officeType = 'Serviced Offices';
			wrapRec.size  = '';
			wrapRec.quality  = '';
			wrapRec.other  = '';
			wrapRec.businessRole = '';
		
		}

	    return wrapRec;
		
	}


	
}