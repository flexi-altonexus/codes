public with sharing class AgentSearchWizardUtil {
    ApexPages.StandardSetController ssc;
    public list<Id> introIds { get; set; }
    public String customIdsStr { get; set; }
    public String viewSchId { get; set; }
    public class MyException extends Exception {
    }

    public AgentSearchWizardUtil() {
        this.viewSchId = apexpages.currentpage().getparameters().get('schViewId');
    }

    public AgentSearchWizardUtil(ApexPages.StandardSetController controller) {
        this.ssc = controller;
        this.introIds = new List<Id>();

        for (Introduction__c t : (list<Introduction__c>) ssc.getSelected()) {
            this.introIds.add(t.Id);
        }

        this.customIdsStr = JSON.serialize(introIds);
        this.viewSchId = null;
    }

    public void initController() {
        this.viewSchId = apexpages.currentpage().getparameters().get('schViewId');
    }

    /*
     *   @Method          :   getLocations
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Autocomplete request to Custom Web API with a search text param
     *
     **/

    @AuraEnabled(cacheable=true)
    public static map<String, WebAPIDataModel.Location> getLocations(
        String searchString,
        String strCountry
    ) {
        String searchContry = '';
        /*
        string searchContry = '';
        if(strCountry == 'United Kingdom'){
          searchContry = '/94';
        }else if(strCountry == 'Australia'){
          searchContry = '/3';
        }else if(strCountry == 'Ireland'){
          searchContry = '/33';
        }*/

        Integer countryId = WebAPIUtils.getIdCountryMap(strCountry);
        if (countryId != null) {
            searchContry = '/' + String.valueof(countryId);
        }

        map<String, WebAPIDataModel.Location> returnmap = new Map<String, WebAPIDataModel.Location>();

        try {
            //String JSONresponse = WebAPIUtils.sendGETMessage('/api/locations/autocomplete/1/' + searchString + searchContry,false);
            String JSONresponse = WebAPIUtils.sendGETMessage(
                '/api/locations/autocompletebycountry/' +
                EncodingUtil.urlEncode(searchString, 'UTF-8') +
                searchContry,
                false
            );
            if (JSONresponse != 'Error') {
                JSONresponse = WebAPIDataModel.convertExternalId(JSONresponse);
                WebAPIDataModel.Location_reponse returnResult = (WebAPIDataModel.Location_reponse) JSON.deserialize(
                    JSONresponse,
                    WebAPIDataModel.Location_reponse.class
                );

                for (WebAPIDataModel.Location wLocation : returnResult.data) {
                    //returnmap.put(wLocation.Name,wLocation.url);
                    returnmap.put(wLocation.Name, wLocation);
                }
            } else {
                returnmap.put('Error on Web API', null);
            }
        } catch (Exception ex) {
            returnmap.put('Error on Web API', null);
        }

        return returnmap;
    }

    @AuraEnabled
    public static List<AgentSearchWizardUtil.BCModel> getBusinessCentresById(Id recordId) {
        List<AgentSearchWizardUtil.BCModel> returnlist = new List<AgentSearchWizardUtil.BCModel>();

        for (Introduction__c intro : [
            SELECT
                Id,
                LastIntroductionSent__c,
                BusinessCentre__c,
                BusinessCentre__r.Name,
                BusinessCentre__r.BillingPostalCode,
                BusinessCentre__r.BillingStreet,
                BusinessCentre__r.BillingCity,
                BusinessCentre__r.BillingState,
                BusinessCentre__r.BillingCountry,
                BusinessCentre__r.BillingLatitude,
                BusinessCentre__r.BillingLongitude,
                BusinessCentre__r.Subscription__c,
                BusinessCentre__r.TypeOfBuilding__c,
                BusinessCentre__r.SizeLower__c,
                BusinessCentre__r.Phone,
                BusinessCentre__r.Parent.Name,
                BusinessCentre__r.PaymentInAdvance__c,
                BusinessCentre__r.PaymentFrequency__c,
                BusinessCentre__r.Enhanced_Fee__c,
                BusinessCentre__r.PrimaryImage__c,
                BusinessCentre__r.FlexiWebsiteLink__c,
                BusinessCentre__r.isKeyProviderBC__c,
                Term_Length__c,
                Available_from__c,
                Option_size__c,
                Monthly_quoting_rate__c,
                Monthly_cost_of_occupation__c,
                Notes__c

            FROM Introduction__c
            WHERE
                (RelatedToDeal__c = :recordId
                OR Lead__c = :recordId)
                AND Status__c != 'Cancelled'
                AND BusinessCentre__c != NULL
                //AND LastIntroductionSent__c != NULL
        ]) {
            AgentSearchWizardUtil.BCModel wrapperRec = new AgentSearchWizardUtil.BCModel();

            wrapperRec.BusinessCentreId = intro.BusinessCentre__c;
            wrapperRec.name = intro.BusinessCentre__r.Name;
            wrapperRec.ltName =
                intro.BusinessCentre__r.Name +
                '-' +
                intro.BusinessCentre__r.BillingStreet +
                '-' +
                intro.BusinessCentre__r.BillingPostalCode;
            wrapperRec.ltName += (intro.BusinessCentre__r.Parent.Name != null)
                ? ' (' + intro.BusinessCentre__r.Parent.Name + ')'
                : '';
            wrapperRec.street = intro.BusinessCentre__r.BillingStreet;
            wrapperRec.city = intro.BusinessCentre__r.BillingCity;
            wrapperRec.postalCode = intro.BusinessCentre__r.BillingPostalCode;
            wrapperRec.state = intro.BusinessCentre__r.BillingState;
            wrapperRec.country = null;
            wrapperRec.latitude = intro.BusinessCentre__r.BillingLatitude;
            wrapperRec.longitude = intro.BusinessCentre__r.BillingLongitude;
            wrapperRec.distance = '';
            wrapperRec.subscription = intro.BusinessCentre__r.Subscription__c;
            wrapperRec.stype = intro.BusinessCentre__r.TypeOfBuilding__c;
            wrapperRec.phone = intro.BusinessCentre__r.Phone;
            wrapperRec.bccompany = (intro.BusinessCentre__r.Parent.Name != null)
                ? intro.BusinessCentre__r.Parent.Name
                : '';
            wrapperRec.isEnhanced = false;
            wrapperRec.isKeyProviderBC = intro.BusinessCentre__r.isKeyProviderBC__c;
            wrapperRec.otherEnhanced = false;
            wrapperRec.primaryImage = intro.BusinessCentre__r.PrimaryImage__c;
            wrapperRec.url = intro.BusinessCentre__r.FlexiWebsiteLink__c;
            wrapperRec.lastIntroDate = intro.LastIntroductionSent__c?.formatGMT(
                'yyyy-MM-dd (HH:mm)'
            );
            wrapperRec.fromIntro = false;
            wrapperRec.introId = intro.Id;
            wrapperRec.paymentAd = intro.BusinessCentre__r.PaymentInAdvance__c != null
                ? intro.BusinessCentre__r.PaymentInAdvance__c
                : 'No';

            wrapperRec.enhancedFee = intro.BusinessCentre__r.Enhanced_Fee__c != null
            ? intro.BusinessCentre__r.Enhanced_Fee__c
            : '';

            wrapperRec.paymentFrequency = intro.BusinessCentre__r.PaymentFrequency__c != null
            ? intro.BusinessCentre__r.PaymentFrequency__c
            : '';

            wrapperRec.termLength = intro.Term_Length__c;
            wrapperRec.availableFrom = intro.Available_from__c;
            wrapperRec.optionSize = intro.Option_size__c;
            wrapperRec.monthlyQuotingRate = intro.Monthly_quoting_rate__c;
            wrapperRec.monthlyCostOccupation = intro.Monthly_cost_of_occupation__c;
            wrapperRec.notes = intro.Notes__c;
            //wrapperRec.ear
            returnlist.add(wrapperRec);
        }

        return returnlist;
    }

    /*
     *   @Method          :   getBusinessCentres
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Get Business Centres from a URL, we will process records to get lastintruduction Date & isEnhanced in other location attributes.
     *
     **/

    @AuraEnabled
    public static list<AgentSearchWizardUtil.BCModel> getBusinessCentres(
        String locationJSON,
        String radius,
        String pagesize,
        String recordId
    ) {
        Organization Org = [SELECT IsSandbox FROM Organization];

        String webSiteDomain = (Org.IsSandbox)
            ? 'https://staging-flexioffice.co.uk/'
            : 'https://www.flexioffices.co.uk/';

        //TODO Callout to Custom Web API to get BC records
        WebAPIDataModel.Location loc = (WebAPIDataModel.Location) JSON.deserialize(
            locationJSON,
            WebAPIDataModel.Location.class
        );
        list<AgentSearchWizardUtil.BCModel> returnlist = new List<AgentSearchWizardUtil.BCModel>();

        //Results not enhanced for the location used to find if these record are enhanced in any other location
        map<String, Boolean> enhancedMap = new Map<String, Boolean>();
        //Results for Last Introduction Date
        map<String, String> lastIntroMap = new Map<String, String>();
        //BC Set Ids
        set<String> setBCRecords = new Set<String>();

        //BC Set Ids
        set<String> setBCRecordsPaymentAd = new Set<String>();
        Map<String, String> BCRecordsPaymentFrequencyMap = new Map<String, String>();
        Map<String, String> BCRecordsEnhancedFeeMap = new Map<String, String>();

        //String JSONresponse = WebAPIUtils.sendGETMessage('/api/businesscentre/getwithgeo/?latitude=' + String.valueOf(loc.latitude) + '&longitude=' + String.valueOf(loc.longitude) + '&siteId=1&url='+ String.valueOf(loc.url) + '&pageIndex=0&pageSize=' + pageSize + '&radius='+ radius,false);

        // Set list size according to area: Mike Chadwick 25 May 2023
        Integer listSize = 50;
        if(String.valueOf(loc.url).toUppercase().contains('/LONDON')) {
            listSize = 100;
        }

        String JSONresponse = WebAPIUtils.sendGETMessage(
            '/api/businesscentre/getbusinesscentresbyurl?url=' +
            String.valueOf(loc.url) +
            '&pageIndex=0&pageSize=' + listSize,
            false
        );

        if (JSONresponse != 'Error') {
            try {
                JSONresponse = WebAPIDataModel.convertExternalId(JSONresponse);
                WebAPIDataModel.BusinessCentre_response returnResult = (WebAPIDataModel.BusinessCentre_response) JSON.deserialize(
                    JSONresponse,
                    WebAPIDataModel.BusinessCentre_response.class
                );

                //Get BC Ids
                for (WebAPIDataModel.BusinessCentre wCentre : returnResult.data) {
                    if (String.isNotBlank(wCentre.BusinessCentreId)) {
                        setBCRecords.add(wCentre.BusinessCentreId);
                    }
                }

                //Get Set of records with Payment in Advance
                for (Account acc : [
                    SELECT Id
                    FROM ACCOUNT
                    WHERE Id IN :setBCRecords AND PaymentInAdvance__c = 'Yes'
                ]) {
                    setBCRecordsPaymentAd.add(acc.Id);
                }

                //Get map of records with Payment Frequency
                for (Account acc : [
                    SELECT Id, PaymentFrequency__c
                    FROM ACCOUNT
                    WHERE Id IN :setBCRecords AND PaymentFrequency__c != ''
                ]) {
                    BCRecordsPaymentFrequencyMap.put(acc.Id, acc.PaymentFrequency__c);
                }

                //Get map of records with Enhanced Fee
                for (Account acc : [
                    SELECT Id, Enhanced_Fee__c
                    FROM ACCOUNT
                    WHERE Id IN :setBCRecords AND Enhanced_Fee__c != ''
                ]) {
                    BCRecordsEnhancedFeeMap.put(acc.Id, acc.Enhanced_Fee__c);
                }

                for (WebAPIDataModel.BusinessCentre wCentre : returnResult.data) {
                    AgentSearchWizardUtil.BCModel wrapperRec = new AgentSearchWizardUtil.BCModel();

                    wrapperRec.BusinessCentreId = wCentre.BusinessCentreId;
                    wrapperRec.name = wCentre.centreName;
                    wrapperRec.ltName =
                        wCentre.centreName +
                        '-' +
                        wCentre.streetName +
                        '-' +
                        wCentre.postcode;
                    wrapperRec.ltName += (wCentre.companyName != null)
                        ? ' (' + wCentre.companyName + ')'
                        : '';
                    wrapperRec.street = wCentre.streetName;
                    wrapperRec.city = wCentre.town;
                    wrapperRec.postalCode = wCentre.postcode;
                    wrapperRec.state = wCentre.county;
                    wrapperRec.country = null;
                    wrapperRec.latitude = wCentre.latitude.setScale(7);
                    wrapperRec.longitude = wCentre.longitude.setScale(7);

                    //TODO -- replace with distance attribute.. this is calculated on Elastic
                    /*Location loc1 = Location.newInstance(loc.latitude,loc.longitude);
            Location loc2 = Location.newInstance(wCentre.latitude,wCentre.longitude);
            Decimal distance = Location.getDistance(loc1,loc2,'mi');
            */

                    if (wCentre.distance != null) {
                        wrapperRec.distance = String.valueOf(wCentre.distance.setScale(3)) + ' mi';
                    } else {
                        wrapperRec.distance = '';
                    }

                    wrapperRec.subscription = wCentre.subscription;
                    wrapperRec.stype = wCentre.typeOfBuilding;
                    wrapperRec.lower = '£' + String.valueOf(wCentre.costLowerAsNumber);
                    wrapperRec.phone = wCentre.telephone;
                    wrapperRec.bccompany = (wCentre.companyName != null) ? wCentre.companyName : '';
                    wrapperRec.isEnhanced = wCentre.isEnhanced;
                    wrapperRec.isKeyProviderBC = wCentre.isKeyProviderBC;
                    wrapperRec.lastIntroDate = '';
                    wrapperRec.primaryImage = wCentre.extraImage1;
                    wrapperRec.url = webSiteDomain + wCentre.url;
                    wrapperRec.fromIntro = false;
                    wrapperRec.introId = null;

                    wrapperRec.otherEnhanced = false; //Default

                    if (wrapperRec.latitude != null && wrapperRec.longitude != null) {
                        returnlist.add(wrapperRec);
                    }

                    if (!wCentre.isEnhanced) {
                        enhancedMap.put(wCentre.BusinessCentreId, false);
                    }

                    //Payment in advanced
                    if (setBCRecordsPaymentAd.contains(wCentre.BusinessCentreId)) {
                        wrapperRec.paymentAd = 'Yes';
                    } else {
                        wrapperRec.paymentAd = 'No';
                    }

                    //Payment Frequency
                    if (BCRecordsPaymentFrequencyMap != null && !BCRecordsPaymentFrequencyMap.isEmpty()) {
                        String paymentFrequencyValue = BCRecordsPaymentFrequencyMap.get(wCentre.BusinessCentreId);
                        if(paymentFrequencyValue != null) {
                            wrapperRec.paymentFrequency = paymentFrequencyValue;
                        } else {
                            wrapperRec.paymentFrequency = '';
                        }
                    }

                    //Enhanced Fee
                    if (BCRecordsEnhancedFeeMap != null && !BCRecordsEnhancedFeeMap.isEmpty()) {
                        String enhancedFeeValue = BCRecordsEnhancedFeeMap.get(wCentre.BusinessCentreId);
                        if(enhancedFeeValue != null) {
                            wrapperRec.enhancedFee = enhancedFeeValue;
                        } else {
                            wrapperRec.enhancedFee = '';
                        }
                    }
                }

                //Process Last Introduction Dates
                if (String.isNotBlank(recordId)) {
                    //Get type of record using Lead - Contact - Opp
                    String strCustomer = 'null';
                    String strContact = null;
                    String strOpportunity = null;
                    String strLead = 'null';

                    //Get Record type
                    Id myId = recordId;
                    Schema.SObjectType sobjectType = myId.getSObjectType();
                    String sobjectName = sobjectType.getDescribe().getName();

                    //Inform variables
                    if (sobjectName == 'Lead') {
                        strLead = myId;
                    } else if (sobjectName == 'Contact') {
                        Contact con = [SELECT AccountId FROM Contact WHERE Id = :myId][0];
                        strContact = myId;
                        strCustomer = con.AccountId;
                    } else if (sobjectName == 'Opportunity') {
                        Opportunity opp = [
                            SELECT AccountId, ClientName__c
                            FROM Opportunity
                            WHERE Id = :myId
                        ][0];
                        strContact = opp.ClientName__c;
                        strCustomer = opp.AccountId;
                        strOpportunity = myId;
                    }

                    AggregateResult[] groupedResults = [
                        SELECT BusinessCentre__c, MAX(IntroductionDateTime__c) maxDate
                        FROM Introduction__c
                        WHERE
                            Status__c != NULL
                            AND Status__c != 'Rejected'
                            AND Status__c != 'Cancelled'
                            AND (Client__c = :strCustomer
                            OR Lead__c = :strLead)
                            AND BusinessCentre__c IN :setBCRecords
                        GROUP BY BusinessCentre__c
                    ];

                    for (AggregateResult groupedRec : groupedResults) {
                        Datetime dt = (Datetime) groupedRec.get('maxDate');
                        String formatted = dt.formatGMT('yyyy-MM-dd (HH:mm)');

                        lastIntroMap.put((String) groupedRec.get('BusinessCentre__c'), formatted);
                        //returnmap.get((String)groupedRec.get('BusinessCentre__c')).lastIntroDate = formatted;
                    }
                }

                //Process Other Enhanced
                enhancedMap = processOtherEnhanced(enhancedMap, loc.url);

                for (AgentSearchWizardUtil.BCModel bcentreRec : returnlist) {
                    if (
                        enhancedMap.containskey(bcentreRec.BusinessCentreId) &&
                        enhancedMap.get(bcentreRec.BusinessCentreId)
                    ) {
                        bcentreRec.otherEnhanced = true;
                    }

                    if (lastIntroMap.containskey(bcentreRec.BusinessCentreId)) {
                        bcentreRec.lastIntroDate = lastIntroMap.get(bcentreRec.BusinessCentreId);
                    }
                }
            } catch (Exception ex) {
                system.debug(ex.getMessage());
                system.debug(ex.getStackTraceString());
            }
        } else {
            throw new MyException('Problem with Custom Web API');
        }

        return returnlist;
    }

    /*
     *   @Method          :   getRecordInfo
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Get Information about Salesforce Record we are working with (we will create introduction for that record).
     *
     **/

    @AuraEnabled
    public static String getRecordInfo(String recordId) {
        String result;
        Id myId = recordId;

        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();

        SObject record = Database.query(
            'Select Id, Name From ' +
            sobjectName +
            ' Where Id = :myId'
        );

        return (String) record.get('Name');
    }

    /*
     *   @Method          :   getRecordInfo
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Get Information about Salesforce Record we are working with (we will create introduction for that record).
     *
     **/

    @AuraEnabled
    public static list<AgentSearchWizardUtil.BCModel> getAutomaticIntros(String recordId) {
        String result;
        Id myId = recordId;

        Schema.SObjectType sobjectType = myId.getSObjectType();

        list<AgentSearchWizardUtil.BCModel> returnlist = new List<AgentSearchWizardUtil.BCModel>();

        if (
            sobjectType.getDescribe().getName() == 'Opportunity' ||
            sobjectType.getDescribe().getName() == 'Lead'
        ) {
            //LastIntroductionSent__c != null?? Criteria: Introduction type "Manual" where it hasn't been introduced to the client already.
            for (Introduction__c intro : [
                SELECT
                    Id,
                    LastIntroductionSent__c,
                    BusinessCentre__c,
                    BusinessCentre__r.Name,
                    BusinessCentre__r.BillingPostalCode,
                    BusinessCentre__r.BillingStreet,
                    BusinessCentre__r.BillingCity,
                    BusinessCentre__r.BillingState,
                    BusinessCentre__r.BillingCountry,
                    BusinessCentre__r.BillingLatitude,
                    BusinessCentre__r.BillingLongitude,
                    BusinessCentre__r.Subscription__c,
                    BusinessCentre__r.TypeOfBuilding__c,
                    BusinessCentre__r.SizeLower__c,
                    BusinessCentre__r.Phone,
                    BusinessCentre__r.Parent.Name,
                    BusinessCentre__r.PaymentInAdvance__c,
                    BusinessCentre__r.Enhanced_Fee__c,
                    BusinessCentre__r.PaymentFrequency__c,
                    BusinessCentre__r.PrimaryImage__c,
                    BusinessCentre__r.FlexiWebsiteLink__c,
                    BusinessCentre__r.isKeyProviderBC__c
                FROM Introduction__c
                WHERE
                    (RelatedToDeal__c = :recordId
                    OR Lead__c = :recordId)
                    AND Status__c != 'Cancelled'
                    AND BusinessCentre__c != NULL
                    AND LastIntroductionSent__c = NULL
                    AND IntroductionType__c = 'Manual'
            ]) {
                AgentSearchWizardUtil.BCModel wrapperRec = new AgentSearchWizardUtil.BCModel();

                wrapperRec.BusinessCentreId = intro.BusinessCentre__c;
                wrapperRec.name = intro.BusinessCentre__r.Name;
                wrapperRec.ltName =
                    intro.BusinessCentre__r.Name +
                    '-' +
                    intro.BusinessCentre__r.BillingStreet +
                    '-' +
                    intro.BusinessCentre__r.BillingPostalCode;
                wrapperRec.ltName += (intro.BusinessCentre__r.Parent.Name != null)
                    ? ' (' + intro.BusinessCentre__r.Parent.Name + ')'
                    : '';
                wrapperRec.street = intro.BusinessCentre__r.BillingStreet;
                wrapperRec.city = intro.BusinessCentre__r.BillingCity;
                wrapperRec.postalCode = intro.BusinessCentre__r.BillingPostalCode;
                wrapperRec.state = intro.BusinessCentre__r.BillingState;
                wrapperRec.country = null;
                wrapperRec.latitude = intro.BusinessCentre__r.BillingLatitude;
                wrapperRec.longitude = intro.BusinessCentre__r.BillingLongitude;
                wrapperRec.distance = '';
                wrapperRec.subscription = intro.BusinessCentre__r.Subscription__c;
                wrapperRec.stype = intro.BusinessCentre__r.TypeOfBuilding__c;
                //wrapperRec.lower = '£' + String.valueOf(intro.BusinessCentre__r.SizeLower__c);
                wrapperRec.phone = intro.BusinessCentre__r.Phone;

                wrapperRec.bccompany = (intro.BusinessCentre__r.Parent.Name != null)
                    ? intro.BusinessCentre__r.Parent.Name
                    : '';
                wrapperRec.isEnhanced = false;
                wrapperRec.isKeyProviderBC = intro.BusinessCentre__r.isKeyProviderBC__c;
                wrapperRec.otherEnhanced = false;
                //wrapperRec.paymentAd = null; //intro.BusinessCentre__r.Specialoffer ? 'Yes' : 'No'; //intro.BusinessCentre__r.PaymentInAdvance__c; //specialofferdetails
                wrapperRec.primaryImage = intro.BusinessCentre__r.PrimaryImage__c;
                wrapperRec.url = intro.BusinessCentre__r.FlexiWebsiteLink__c;
                wrapperRec.lastIntroDate = '';
                wrapperRec.fromIntro = true;
                wrapperRec.introId = intro.Id;
                wrapperRec.paymentAd = intro.BusinessCentre__r.PaymentInAdvance__c != null
                    ? intro.BusinessCentre__r.PaymentInAdvance__c
                    : 'No';

                wrapperRec.enhancedFee = intro.BusinessCentre__r.Enhanced_Fee__c != null
                ? intro.BusinessCentre__r.Enhanced_Fee__c
                : '';                

                wrapperRec.paymentFrequency = intro.BusinessCentre__r.PaymentFrequency__c != null
                ? intro.BusinessCentre__r.PaymentFrequency__c
                : '';                

                returnlist.add(wrapperRec);
            }
        }

        return returnlist;
    }

    /*
     *   @Method          :  finish
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Introduction creation
     *
     **/

    @AuraEnabled
    public static boolean finish(String recordId, String recordsList) {
        list<AgentSearchWizardUtil.BCModel> recList;
        list<Introduction__c> IntrosToInsertList = new List<Introduction__c>();
        list<Introduction__c> IntrosToUpdateList = new List<Introduction__c>();
        map<Id, Introduction__c> valuesmap = new Map<Id, Introduction__c>();
		System.debug('Testing debugger');
                
        String strCustomer = null;
        String strContact = null;
        String strOpportunity = null;
        String strLead = null;

        //Get Record type
        Id myId = recordId;
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();

        //Inform variables
        if (sobjectName == 'Lead') {
            strLead = myId;
        } else if (sobjectName == 'Contact') {
            Contact con = [SELECT AccountId FROM Contact WHERE Id = :myId][0];
            strContact = myId;
            strCustomer = con.AccountId;
        } else if (sobjectName == 'Opportunity') {
            Opportunity opp = [
                SELECT AccountId, ClientName__c
                FROM Opportunity
                WHERE Id = :myId
            ][0];
            strContact = opp.ClientName__c;
            strCustomer = opp.AccountId;
            strOpportunity = myId;
        }

        System.debug('strContact: ' + strContact);
        System.debug('strCustomer: ' + strCustomer);
        System.debug('strOpportunity: ' + strOpportunity);

        System.debug('string.isNotBlank(recordsList) && String.isNotBlank(recordId)');
        System.debug(string.isNotBlank(recordsList) && String.isNotBlank(recordId));
        if (string.isNotBlank(recordsList) && String.isNotBlank(recordId)) {
            recList = (list<AgentSearchWizardUtil.BCModel>) System.JSON.deserialize(
                recordsList,
                list<AgentSearchWizardUtil.BCModel>.class
            );

            List<String> clientIds = new List<String>();
            boolean isIntroToUpdate = false;
            boolean isIntroToInsert = false;

            System.debug('rec list size: ' + recList.size());
            for (AgentSearchWizardUtil.BCModel rec : recList) {
                Introduction__c newIntro = new Introduction__c();

                newIntro.Client__c = strCustomer;
                newIntro.Contact__c = strContact;
                newIntro.BusinessCentre__c = rec.BusinessCentreId;
                newIntro.IntroductionDateTime__c = Datetime.now();
                newIntro.IntroductionType__c = 'Manual';
                newIntro.Lead__c = strLead;
                newIntro.RelatedToDeal__c = strOpportunity;
                newIntro.Status__c = 'New';
                newIntro.Send_to_BC__c = rec.sendToB;
                System.debug('rec.sendToC from controller!! ##  ' + rec.sendToC);
                System.debug('rec.sendToB from controller!! ##  ' + rec.sendToB);
                System.debug('rec from controller!! ##  ' + rec);
                newIntro.Term_Length__c = rec.termLength;
                newIntro.Available_from__c = rec.availableFrom;
                newIntro.Option_size__c = rec.optionSize;
                newIntro.Monthly_quoting_rate__c = rec.monthlyQuotingRate;
                newIntro.Monthly_cost_of_occupation__c = rec.monthlyCostOccupation;
                newIntro.Notes__c = rec.notes;

                //Added logic so that the customer only recieves one email for multiple introductions
                if (!clientIds.contains(strContact) && !clientIds.contains(strLead)) {
                    newIntro.Send_to_customer__c = rec.sendToC;

                    if (strContact != null) {
                        clientIds.add(strContact);
                    } else {
                        clientIds.add(strLead);
                    }
                } else {
                    
                    newIntro.Re_Send_Email_to_Customer__c = rec.sendToC;
                }
				System.debug('newIntro.Re_Send_Email_to_Customer__c: ' + newIntro.Re_Send_Email_to_Customer__c);
                //Always add it to update list
                if (String.isNotBlank(rec.introId)) {
                    isIntroToUpdate = true;
                    newIntro.Id = rec.introId;
                    IntrosToUpdateList.add(newIntro);
                } else {
                    isIntroToInsert = true;
                    IntrosToInsertList.add(newIntro);
                }
            }

            System.debug('----- isIntroToUpdate: '+isIntroToInsert+' --> '+IntrosToInsertList);
            System.debug('----- isIntroToUpdate: '+isIntroToUpdate+' --> '+IntrosToUpdateList);

            //Insert Directly if we don´t have any update
            if (!isIntroToUpdate && isIntroToInsert) {
                System.debug('Only insert');
                insert IntrosToInsertList;
            }

            //We only have updates
            if (isIntroToUpdate && !isIntroToInsert) {
                System.debug('Only update');
                update IntrosToUpdateList;
            }

            //We have insert and update, before insert with not sent email.. and then we update all because we want all records out in the same email
            if (isIntroToUpdate && isIntroToInsert) {
                System.debug('Insert and update');
                System.debug('IntrosToInsertList: ' + IntrosToInsertList.size());
                for (Introduction__c introrec : IntrosToInsertList) {
                    //Clone values about sending emails and save them in the map
                    Introduction__c newIntro = new Introduction__c();
                    newIntro.Send_to_BC__c = introrec.Send_to_BC__c;
                    newIntro.Send_to_customer__c = introrec.Send_to_customer__c;
                    newIntro.Re_Send_Email_to_Customer__c = introrec.Re_Send_Email_to_Customer__c;
                	System.debug('introrec.Send_to_BC__c: ' + introrec.Send_to_BC__c);
                	System.debug('introrec.Send_to_customer__c: ' + introrec.Send_to_customer__c);
                	System.debug('introrec.Re_Send_Email_to_Customer__c: ' + introrec.Re_Send_Email_to_Customer__c);

                    valuesmap.put(introrec.BusinessCentre__c, newIntro);

                    //Clear values for insert
                    introrec.Send_to_BC__c = false;
                    introrec.Send_to_customer__c = false;
                    introrec.Re_Send_Email_to_Customer__c = false;
                    
                    System.debug('################################');
                    System.debug('RelatedToDeal__c: ' + introrec.RelatedToDeal__c);
                    System.debug('Lead__c: ' + introrec.Lead__c);
                    System.debug('Digital_Asset__c: ' + introrec.Digital_Asset__c);
                    System.debug('Contact__c: ' + introrec.Contact__c);
                    System.debug('Client__c: ' + introrec.Client__c);
                    System.debug('#################################');
                }

                //Insert
                insert IntrosToInsertList;

                //Put values back
                for (Introduction__c introrec : IntrosToInsertList) {
                    introrec.Send_to_BC__c = valuesmap.get(introrec.BusinessCentre__c)
                        .Send_to_BC__c;
                    introrec.Send_to_customer__c = valuesmap.get(introrec.BusinessCentre__c)
                        .Send_to_customer__c;
                    introrec.Re_Send_Email_to_Customer__c = valuesmap.get(
                            introrec.BusinessCentre__c
                        )
                        .Re_Send_Email_to_Customer__c;
                }

                IntrosToUpdateList.addall(IntrosToInsertList);
                //Final update
                update IntrosToUpdateList;
            }
        } else {
            return false;
        }

        return true;
    }

    /*
     *   @Method          :  finish
     *
     *   @Author         :   Luke Toland
     *   @Created        :   7 July 2022
     *   @Description    :   just want to update records with emails being sent
     *
     **/

    @AuraEnabled
    public static boolean finishNoEmails(String recordId, String recordsList) {
        list<AgentSearchWizardUtil.BCModel> recList;
        list<Introduction__c> IntrosToInsertList = new List<Introduction__c>();
        list<Introduction__c> IntrosToUpdateList = new List<Introduction__c>();
        map<Id, Introduction__c> valuesmap = new Map<Id, Introduction__c>();

        String strCustomer = null;
        String strContact = null;
        String strOpportunity = null;
        String strLead = null;

        //Get Record type
        Id myId = recordId;
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();

        //Inform variables
        if (sobjectName == 'Lead') {
            strLead = myId;
        } else if (sobjectName == 'Contact') {
            Contact con = [SELECT AccountId FROM Contact WHERE Id = :myId][0];
            strContact = myId;
            strCustomer = con.AccountId;
        } else if (sobjectName == 'Opportunity') {
            Opportunity opp = [
                SELECT AccountId, ClientName__c
                FROM Opportunity
                WHERE Id = :myId
            ][0];
            strContact = opp.ClientName__c;
            strCustomer = opp.AccountId;
            strOpportunity = myId;
        }

        if (string.isNotBlank(recordsList) && String.isNotBlank(recordId)) {
            recList = (list<AgentSearchWizardUtil.BCModel>) System.JSON.deserialize(
                recordsList,
                list<AgentSearchWizardUtil.BCModel>.class
            );

            List<String> clientIds = new List<String>();
            boolean isIntroToUpdate = false;
            boolean isIntroToInsert = false;

            for (AgentSearchWizardUtil.BCModel rec : recList) {
                Introduction__c newIntro = new Introduction__c();

                newIntro.Client__c = strCustomer;
                newIntro.Contact__c = strContact;
                newIntro.BusinessCentre__c = rec.BusinessCentreId;
                newIntro.IntroductionDateTime__c = Datetime.now();
                newIntro.IntroductionType__c = 'Manual';
                newIntro.Lead__c = strLead;
                newIntro.RelatedToDeal__c = strOpportunity;
                newIntro.Status__c = 'New';
                newIntro.Send_to_BC__c = false;
                newIntro.Term_Length__c = rec.termLength;
                newIntro.Available_from__c = rec.availableFrom;
                newIntro.Option_size__c = rec.optionSize;
                newIntro.Monthly_quoting_rate__c = rec.monthlyQuotingRate;
                newIntro.Monthly_cost_of_occupation__c = rec.monthlyCostOccupation;
                newIntro.Notes__c = rec.notes;
                newIntro.Send_to_customer__c = false;
                newIntro.Re_Send_Email_to_Customer__c = false;
                newIntro.Send_to_customer__c = false;

                //Always add it to update list
                if (String.isNotBlank(rec.introId)) {
                    isIntroToUpdate = true;
                    newIntro.Id = rec.introId;
                    IntrosToUpdateList.add(newIntro);
                } else {
                    isIntroToInsert = true;
                    IntrosToInsertList.add(newIntro);
                }
            }

            //Insert Directly if we don´t have any update
            if (!isIntroToUpdate && isIntroToInsert) {
                insert IntrosToInsertList;
            }

            //We only have updates
            if (isIntroToUpdate && !isIntroToInsert) {
                update IntrosToUpdateList;
            }
        } else {
            return false;
        }

        return true;
    }

    /*
     *   @Method          :  processOtherEnhanced
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Generate map for BC set Ids to review if are enhanced in other URL location.
     *
     **/

    public static map<String, Boolean> processOtherEnhanced(
        map<String, Boolean> resultsMap,
        String locationURL
    ) {
        for (Enhanced_Slot__c eslot : [
            SELECT Id, Business_Center__c
            FROM Enhanced_Slot__c
            WHERE
                Business_Center__c IN :resultsMap.keyset()
                AND Enhanced_Listing__r.Month_Date__c = THIS_MONTH
                AND Enhanced_Listing__r.Search_Parameter__r.Url__c != :locationURL
        ]) {
            resultsMap.put(eslot.Business_Center__c, true);
        }

        return resultsMap;
    }

    /*
     *   @Method          :  finish
     *
     *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
     *   @Created        :   16 Abril 2019
     *   @Description    :   Introduction creation
     *
     **/

    @AuraEnabled
    public static List<String> getPicklist() {
        List<String> countries = new List<String>();
        Schema.DescribeFieldResult field = User.Flexi_Country__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
            countries.add(f.getLabel());
        return countries;
    }

    @AuraEnabled
    public static map<String, String> getPickListMap() {
        map<String, String> countriesmap = new Map<String, String>();
        Schema.DescribeFieldResult field = User.Flexi_Country__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
            countriesmap.put(f.getValue(), f.getLabel());
        return countriesmap;
    }

    @AuraEnabled
    public static String getCountry() {
        String strCountry = 'UK';
        String searchCountry = '';
        try {
            searchCountry = [SELECT Flexi_Country__c FROM User WHERE Id = :UserInfo.getUserId()][0]
            .Flexi_Country__c;
        } catch (Exception e) {
        }
        return searchCountry == null ? strCountry : searchCountry;
    }

    public class BCModel {
        @AuraEnabled
        public String BusinessCentreId { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String ltname { get; set; }

        @AuraEnabled
        public String street { get; set; }

        @AuraEnabled
        public String city { get; set; }

        @AuraEnabled
        public String postalCode { get; set; }

        @AuraEnabled
        public String state { get; set; }

        @AuraEnabled
        public String country { get; set; }

        @AuraEnabled
        public Decimal latitude { get; set; }

        @AuraEnabled
        public Decimal longitude { get; set; }

        @AuraEnabled
        public String distance { get; set; }

        @AuraEnabled
        public Boolean subscription { get; set; }

        @AuraEnabled
        public String stype { get; set; }

        @AuraEnabled
        public String lower { get; set; }

        @AuraEnabled
        public String bccompany { get; set; }

        /* @AuraEnabled
         public String providerName {get; set;}*/

        @AuraEnabled
        public boolean enhanced { get; set; }

        @AuraEnabled
        public boolean sendToC { get; set; }

        @AuraEnabled
        public boolean sendToB { get; set; }

        @AuraEnabled
        public String paymentAd { get; set; }

        @AuraEnabled
        public String enhancedFee { get; set; }

        @AuraEnabled
        public String paymentFrequency { get; set; }

        @AuraEnabled
        public String lastIntroDate { get; set; }

        @AuraEnabled
        public Boolean isEnhanced { get; set; }

        @AuraEnabled
        public Boolean isKeyProviderBC { get; set; }

        @AuraEnabled
        public Boolean otherEnhanced { get; set; }

        @AuraEnabled
        public String primaryImage { get; set; }

        @AuraEnabled
        public String url { get; set; }

        @AuraEnabled
        public String notes { get; set; }

        @AuraEnabled
        public boolean fromIntro { get; set; }

        @AuraEnabled
        public String introId { get; set; }

        @AuraEnabled
        public String phone { get; set; }

        @AuraEnabled
        public String termLength { get; set; }

        @AuraEnabled
        public String availableFrom { get; set; }

        @AuraEnabled
        public String optionSize { get; set; }

        @AuraEnabled
        public String monthlyQuotingRate { get; set; }

        @AuraEnabled
        public String monthlyCostOccupation { get; set; }

        public BCModel() {
            this.BusinessCentreId = null;
            this.name = null;
            this.ltname = null;
            this.street = null;
            this.city = null;
            this.postalCode = null;
            this.state = null;
            this.country = null;
            this.latitude = null;
            this.longitude = null;
            this.distance = null;
            this.subscription = null;
            this.stype = null;
            this.lower = null;
            this.phone = null;
            this.bccompany = null;
            /*this.providerName = null;*/
            this.enhanced = false;
            this.sendToC = true;
            this.sendToB = true;
            this.paymentAd = null;
            this.lastIntroDate = null;
            this.isEnhanced = null;
            this.isKeyProviderBC = false;
            this.otherEnhanced = null;
            this.primaryImage = null;
            this.url = null;
            this.notes = null;
            this.fromIntro = null;
            this.introId = null;
            this.termLength = null;
            this.availableFrom = null;
            this.optionSize = null;
            this.monthlyQuotingRate = null;
            this.monthlyCostOccupation = null;
            this.enhancedFee = null;
        }
    }
}