/*
 *   @Class          :   ElasticSearchDataModel
 *
 *   @Author         :   Juan Carlos Porras <jcarlos.porras@empaua.com>
 *   @Created        :   16 Abril 2019
 *   @Description    :   Class to store Data Model for ElasticSearch
 *
 *   Modification Log
 *   --------------------------------------------------------------------------------------
 *   #       Developer                           Date                    Description
 *   --------------------------------------------------------------------------------------
 *   1      Juan Carlos Porras				16 Abril 2019				Creation
 *	 2		James Boutel					27 Sept 2019				Added class for Enhanced Listing
 *	 3		Francisco javier Sanz			15 Nove 2022				add isKeyProviderBC__c and isKeyProviderBC
 */
global class WebAPIDataModel {
    public class Enhanced_Listing {
        public String Url;
        public DateTime CreatedDate;
        public Integer AgentId;
    }

    public class Enhanced_Slot {
        public String SlotId;
        public String BusinessCentreId;
        public Integer Impressions;
        public Integer Quotes;
        public Integer Views;
        public Integer Year;
        public Integer Month;
    }

    public class Location_reponse {
        public String sId { get; set; }
        public String searchedTerm { get; set; }
        public Boolean error { get; set; }
        public String errorMessage { get; set; }
        public Integer pageIndex { get; set; }
        public Integer pageSize { get; set; }
        public Integer totalCount { get; set; }
        public Integer totalPageCount { get; set; }
        public String timeStamp { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public list<WebAPIDataModel.Location> data { get; set; }
    }

    global class Location {
        public String sId { get; set; }
        public Integer id { get; set; }
        @AuraEnabled
        public String locationTypeName { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String showName { get; set; }
        @AuraEnabled
        public String analyzedName { get; set; }
        @AuraEnabled
        public Decimal latitude { get; set; }
        @AuraEnabled
        public Decimal longitude { get; set; }
        @AuraEnabled
        public Integer priority { get; set; }
        public GeoWrap geo { get; set; }
        public Integer headerStatus { get; set; }
        @AuraEnabled
        public String url { get; set; }
        public Boolean removedFromAnchors { get; set; }
        public Boolean removedFromUrls { get; set; }
    }

    public class BusinessCentre_response {
        public String sId { get; set; }
        public String searchedTerm { get; set; }
        public Boolean error { get; set; }
        public String errorMessage { get; set; }
        public Integer pageIndex { get; set; }
        public Integer pageSize { get; set; }
        public Integer totalCount { get; set; }
        public Integer totalPageCount { get; set; }
        public String timeStamp { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public list<WebAPIDataModel.BusinessCentre> data { get; set; }
    }

    public class BusinessCentreAdd_response {
        public String sId { get; set; }
        public String searchedTerm { get; set; }
        public Boolean error { get; set; }
        public String errorMessage { get; set; }
        public WebAPIDataModel.BusinessCentre data { get; set; }
    }

    global class BusinessCentre {
        public Boolean accessNationwide { get; set; }
        public Boolean accessWorldwide { get; set; }
        public Boolean adminSupport { get; set; }
        public Boolean airCon { get; set; }
        public Boolean alarmSecurity { get; set; }
        public Boolean approved { get; set; }
        public Boolean archived { get; set; }
        public Boolean bicycleParking { get; set; }
        public Boolean bikeRacks { get; set; }
        public Boolean breakOutAreas { get; set; }
        public Boolean broadband { get; set; }
        public Boolean cat5 { get; set; }
        public Boolean cat6 { get; set; }
        public Boolean cctv { get; set; }
        public Boolean chkCos { get; set; }
        public Boolean chkFlexi { get; set; }
        public Boolean chkOstr { get; set; }
        public Boolean chkSos { get; set; }
        public Boolean contemporaryDesign { get; set; }
        public Boolean coWorking { get; set; }
        public Boolean disabledAccess { get; set; }
        public Boolean display { get; set; }
        public Boolean disreputable { get; set; }
        public Boolean enhancedcomm { get; set; }
        public Boolean enhancedListing { get; set; }
        public Boolean fibreInternet { get; set; }
        public Boolean furniture { get; set; }
        public Boolean gym { get; set; }
        public Boolean hr24 { get; set; }
        public Boolean insuramiDeposit { get; set; }
        public Boolean isdn { get; set; }
        public Boolean isEnhanced { get; set; }
        public Boolean isLondonPrime { get; set; }
        public Boolean kitchen { get; set; }
        public Boolean lifts { get; set; }
        public Boolean loungeAreas { get; set; }
        public Boolean managedOffice { get; set; }
        public Boolean mannedReception { get; set; }
        public Boolean mannedSecurity { get; set; }
        public Boolean meetingRooms { get; set; }
        public Boolean modernBuilding { get; set; }
        public Boolean network { get; set; }
        public Boolean NewBuildingBadge { get; set; }
        public Boolean onsiteCafe { get; set; }
        public Boolean parking { get; set; }
        public Boolean periodBuilding { get; set; }
        public Boolean petsAllowed { get; set; }
        public Boolean phoneBooths { get; set; }
        public Boolean premium { get; set; }
        public Boolean reception { get; set; }
        public Boolean sharedSpace { get; set; }
        public Boolean showers { get; set; }
        public Boolean specialoffer { get; set; }
        public Boolean specialterms { get; set; }
        public Boolean subscription { get; set; }
        public Boolean telephoneAnswer { get; set; }
        public Boolean telephoneSystem { get; set; }
        public Boolean tradeIcon { get; set; }
        public Boolean traditionalDesign { get; set; }
        public Boolean unbrandedSpace { get; set; }
        public Boolean vcon { get; set; }
        public Boolean virtualOffices { get; set; }
        public Boolean voiceMail { get; set; }
        public Decimal costHigher { get; set; }
        public decimal costLowerAsNumber { get; set; }
        public Decimal distance { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }
        public GeoWrap geo { get; set; }
        public Integer bcCompanyId { get; set; }
        public Integer cityId { get; set; }
        public Integer costCurrency { get; set; }
        public Integer costTypeID { get; set; }
        public Integer countryId { get; set; }
        public Integer countyId { get; set; }
        public Integer globalCityId { get; set; }
        public Integer globalCountryId { get; set; }
        public Integer id { get; set; }
        public Integer isFeatured { get; set; }
        public Integer locationId { get; set; }
        public Integer noDelegates { get; set; }
        public Integer noRooms { get; set; }
        public Integer sizeLower { get; set; }
        public Integer sizeUpper { get; set; }
        public Integer townId { get; set; }
        public Integer x { get; set; }
        public Integer y { get; set; }
        public String bcReferenceNo { get; set; }
        public String buildingName { get; set; }
        public String BusinessCentreId { get; set; }
        public String centreManagerDdi { get; set; }
        public String centreManagerEmail { get; set; }
        public String centreManagerName { get; set; }
        public String centreName { get; set; }
        public String companyName { get; set; }
        public String contactName { get; set; }
        public String county { get; set; }
        public String dateSubmitted { get; set; }
        public String dda { get; set; }
        public String description { get; set; }
        public String descriptionCos { get; set; }
        public String descriptionOstr { get; set; }
        public String descriptionSos { get; set; }
        public String email { get; set; }
        public String extraImage1 { get; set; }
        public String extraImage1Text { get; set; }
        public String extraImage2 { get; set; }
        public String extraImage2Text { get; set; }
        public String extraImage3 { get; set; }
        public String extraImage3Text { get; set; }
        public String extraImage4 { get; set; }
        public String extraImage4Text { get; set; }
        public String fax { get; set; }
        public String furtherComment { get; set; }
        public String globalLat { get; set; }
        public String globalLon { get; set; }
        public String image { get; set; }
        public String locationDescription { get; set; }
        public String metaDescription { get; set; }
        public String officeCurrency { get; set; }
        public String pageTitle { get; set; }
        public String postcode { get; set; }
        public String rating { get; set; }
        public String SmartViewingAvailable { get; set; }
        public String specialofferdetails { get; set; }
        public String streetName { get; set; }
        public String telephone { get; set; }
        public String town { get; set; }
        public String typeOfBuilding { get; set; }
        public String url { get; set; }
        public String virtualTour { get; set; }
        public String www { get; set; }
        // EMPAUA: IS KEY PROVIDER CASE 15/11/2022
        public Boolean isKeyProviderBC {get;set;}
        public BusinessCentre(){} 
        public BusinessCentre(Account acc) {
            //Get Metedata
            //countryId = WebAPIUtils.getIdCountryMap(acc.BillingCountryCode);
            if (String.isNotBlank(acc.FlexiCountry__c)) {
                countryId = WebAPIUtils.getIdCountryMap(acc.FlexiCountry__c);
            }

            BusinessCentreId = acc.Id;
            id = -1;

            centreName = acc.Name;

            //Related Data

            //Parent Account -- ParentId
            companyName = (String.isNotBlank(acc.CompanyName__c))
                ? acc.CompanyName__c
                : '';

            //Contact
            contactName = (String.isNotBlank(acc.CentreManagerName__c))
                ? acc.CentreManagerName__c
                : '';

            //Centre Manager
            centreManagerName = (String.isNotBlank(acc.CentreManagerName__c))
                ? acc.CentreManagerName__c
                : '';
            centreManagerEmail = (String.isNotBlank(acc.CentreManagerEmail__c))
                ? acc.CentreManagerEmail__c
                : '';

            bcReferenceNo = '';

            image = String.isNotBlank(acc.PrimaryImage__c)
                ? acc.PrimaryImage__c
                : '';
            extraImage1 = String.isNotBlank(acc.SecondaryImage__c)
                ? acc.SecondaryImage__c
                : '';
            extraImage2 = String.isNotBlank(acc.TertiaryImage__c)
                ? acc.TertiaryImage__c
                : '';
            extraImage3 = String.isNotBlank(acc.FourthImage__c)
                ? acc.FourthImage__c
                : '';
            extraImage4 = String.isNotBlank(acc.FifthImage__c)
                ? acc.FifthImage__c
                : '';

            extraImage1Text = String.isNotBlank(acc.SecondaryImage__c)
                ? acc.Name
                : '';
            extraImage2Text = String.isNotBlank(acc.TertiaryImage__c)
                ? acc.Name
                : '';
            extraImage3Text = String.isNotBlank(acc.FourthImage__c)
                ? acc.Name
                : '';
            extraImage4Text = String.isNotBlank(acc.FifthImage__c)
                ? acc.Name
                : '';

            rating = acc.Rating;
            streetName = acc.BillingStreet;
            town = acc.BillingCity;
            county = acc.BillingState;
            postcode = acc.BillingPostalCode;

            globalLat = String.valueOf(acc.BillingLatitude);
            globalLon = String.valueOf(acc.BillingLongitude);

            telephone = acc.Phone;
            fax = acc.fax;
            www = acc.Website;

            description = acc.PropertyDetails__c;
            locationDescription = acc.OfficeLocation__c;
            typeOfBuilding = acc.TypeOfBuilding__c;
            costLowerAsNumber = acc.CostLow__c;

            sizeLower = Integer.valueOf(acc.SizeLower__c);
            sizeUpper = Integer.valueOf(acc.SizeUpper__c);

            phoneBooths = acc.Phone_Booths__c;
            managedOffice = acc.ManagedOfficeSpace__c;
            virtualOffices = acc.VirtualOffices__c;
            meetingRooms = acc.MeetingRooms__c;
            telephoneAnswer = acc.Telephone_System__c;
            isdn = acc.ISDN__c;
            cat5 = acc.CAT5__c;
            airCon = acc.AirConditioning__c;
            furniture = acc.Furniture__c;
            reception = acc.Reception__c;
            vcon = acc.VideoConferencing__c;
            network = acc.Network__c;
            parking = acc.Parking__c;
            costHigher = acc.CostHigh__c;
            broadband = acc.Broadband__c;
            virtualTour = acc.VirtualTourURL__c;
            gym = acc.Gym__c;
            unbrandedSpace = acc.UnbrandedSpace__c;
            showers = acc.Showers__c;
            accessNationwide = acc.AccessToOtherCentresNationwide__c;
            accessWorldwide = acc.AccessToOtherCentresWorldwide__c;
            noRooms = Integer.valueOf(acc.NumberOfMeetingRooms__c);
            noDelegates = Integer.valueOf(acc.MaxNumberOfDelegates__c);
            cctv = acc.Cctv__c;
            telephoneSystem = acc.Telephone_System__c;
            hr24 = acc.X24hrAccess__c;
            disabledAccess = acc.DisabledAccess__c;
            onsiteCafe = acc.OnsiteCafe__c;
            cat6 = acc.Cat6__c;
            latitude = acc.BillingLatitude;
            longitude = acc.BillingLongitude;
            fibreInternet = acc.FibreInternet__c;
            kitchen = acc.Kitchen__c;
            breakOutAreas = acc.BreakOutAreas__c;
            bikeRacks = acc.Bike_Racks__c;
            petsAllowed = acc.PetsAllowed__c;
            contemporaryDesign = acc.Contemporary_Design__c;
            traditionalDesign = acc.TraditionalDesign__c;
            coWorking = acc.CoWorking__c;
            chkFlexi = true;
            isFeatured = acc.Featured__c == true ? 1 : 0;
            adminSupport = acc.AdminSupport__c;
            mannedSecurity = acc.MannedSecurity__c;
            alarmSecurity = acc.AlarmSecurity__c;
            lifts = acc.Lifts__c;
            insuramiDeposit = acc.Insurami_Deposit__c;
            subscription = acc.Subscription__c;
            NewBuildingBadge = acc.New_Building_Badge__c;
            GeoWrap gw = new GeoWrap();
            gw.sId = '3';
            gw.lat = acc.BillingLatitude;
            gw.lon = acc.BillingLongitude;

            geo = gw;
            SmartViewingAvailable = acc.Smart_Viewing_Enabled__c
                ? 'true'
                : 'false';
            // EMPAUA: IS KEY PROVIDER CASE 15/11/2022
            isKeyProviderBC = acc.isKeyProviderBC__c;
            //GeoWrap geo {get;set;
        }
    }

    global class GeoWrap {
        public String sId { get; set; }
        public Decimal lat { get; set; }
        public Decimal lon { get; set; }
    }

    //Replace for all $id field coming in response with sId.
    public static String convertExternalId(String JSONresponse) {
        return JSONresponse.replace('$id', 'sId');
    }

    //Replace for all $id field coming in response with sId.
    public static String convertInternalId(String JSONresponse) {
        return JSONresponse.replace('sId', '$id');
    }

    global class StatisticResponse {
        public String sId { get; set; }
        public list<WebAPIDataModel.StatisticURL> urls { get; set; }
    }

    global class StatisticURL {
        public String sId { get; set; }
        public String url { get; set; }
        public list<WebAPIDataModel.StatisticBC> bcs { get; set; }
    }

    global class StatisticBC {
        public String uniqueKey { get; set; }
        public String sId { get; set; }
        public String id { get; set; }
        public String i { get; set; }
        public String v { get; set; }
        public String q { get; set; }
    }
}