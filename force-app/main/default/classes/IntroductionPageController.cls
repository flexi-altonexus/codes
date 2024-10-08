public class IntroductionPageController {

    public String outputJson {get; set;}
    public IntroductionObject introduction;
    private IntroductionObject cachedIntroduction = null;
    private static String googleApiKey = 'AIzaSyBH09yeOCioV4BvJ9TPX4PwZ74_STb5jsU';

    public class BusinessCenterAmenity {
        
        public String Name {get; set;}
        public String Id {get; set;}
        
    }
    
    public class IntroductionObject {
        
        public Id Id {get; set;}

        public String BusinessCenterName {get; set;}
        public String BusinessCenterAddress {get; set;}
        public String BusinessCenterAddressEscaped {get; set;}
        public String BusinessCenterOfficeLocation {get; set;}
        public String BusinessCenterPropertyDetails {get; set;}
        public String BusinessCenterPhotoPrimary {get; set;}
        public Boolean BusinessCenterShortlisted {get; set;}
        public String BusinessCenterTransportJSON {get; set;}
        public String BusinessCenterViewRequest {get; set;}
        public Decimal BusinessCenterCostLow {get; set;}
        public Decimal BusinessCenterCostHigh {get; set;}
        public List<String> BusinessCenterPhotoOther {get; set;}
        public List<BusinessCenterAmenity> BusinessCenterAmenities {get; set;}
        
        public String UserName {get; set;}
        public String UserEmail {get; set;}
        public String UserPhone {get; set;}
        public String UserPhoto {get; set;}
        
        public String OptionTermLength {get; set;}
        public String OptionAvailableFrom {get; set;}
        public String OptionOptionSize {get; set;}
        public String OptionMonthlyQuotingRate {get; set;}
        public String OptionCostOfOccupancy {get; set;}
        public String OptionNotes {get; set;}
        
    }
    
    public IntroductionObject getIntroduction() {
        if(cachedIntroduction == null) {
            List<String> amenities = new List<String>{
                'X24hrAccess__c', 'AirConditioning__c', 'Broadband__c', 'BreakOutAreas__c', 'Bike_Racks__c', 
                'Cctv__c', 'CAT5__c', 'Cat6__c', 'CoWorking__c', 'Contemporary_Design__c', 'DisabledAccess__c', 
                'FibreInternet__c', 'Furniture__c', 'Gym__c', 'AccessToOtherCentresNationwide__c', 
                'AccessToOtherCentresWorldwide__c', 'MannedSecurity__c', 'AlarmSecurity__c', 'ISDN__c', 'Kitchen__c', 
                'ManagedOfficeSpace__c', 'Network__c', 'OnsiteCafe__c', 'PetsAllowed__c', 'Parking__c', 'Reception__c', 
                'Showers__c', 'Telephone_System__c', 'TraditionalDesign__c', 'UnbrandedSpace__c', 
                'VideoConferencing__c', 'VirtualOffices__c', 'AdminSupport__c', 'Lifts__c', 'Major_Transport_Links__c'
            };
            
            List<String> amenitiesLabel = new List<String>{
                '24hr Access', 'Air Conditioning', 'Broadband', 'Break-Out Areas', 'Bike Racks', 
                'CCTV', 'CAT6', 'CAT5', 'Co-Working', 'Contemporary Design', 'Disabled Access',
                'Fibre Internet', 'Furniture', 'Gym', 'Access to Other Centres Nationwide', 
                'Access to Other Centres Worldwide', 'Manned Security', 'Alarm Security', 'ISDN', 'Kitchen',
                'Managed Office Space', 'Network', 'Onsite Cafe', 'Pets Allowed', 'Parking', 'Reception',
                'Showers', 'Telephone System', 'Traditional Design', 'Unbranded Space', 
                'Video Conferencing', 'Virtual Offices', 'Admin Support', 'Lifts', 'Major Transport Links'
            };
            Id introId = Id.valueOf(getValueFromParam('id'));
            Introduction__c intro = [
                SELECT 
                    BusinessCentre__c, RelatedToDeal__r.OwnerId, Lead__r.OwnerId, Term_Length__c, Available_from__c, Option_size__c, Monthly_quoting_rate__c, 
                    Monthly_cost_of_occupation__c, Notes__c, Shortlisted__c, ViewingDate__c
                FROM 
                    Introduction__c 
                WHERE 
                    Id = :introId
            ];

			Id ownerId = null != intro.Lead__r.OwnerId ? intro.Lead__r.OwnerId : intro.RelatedToDeal__r.OwnerId;
            
            User ownerInfo = null;
            List<User> ownerInfos = [
                SELECT 
                    Id, Name, Email, Phone, FullPhotoUrl 
                FROM 
                    User 
                WHERE 
                    Id = :ownerId
            ];
            if(!ownerInfos.isEmpty()) {
                ownerInfo = ownerInfos.get(0);
            }
            Account businessCenter = [
                SELECT 
                    Id, Name, Address_Formula__c, PrimaryImage__c, SecondaryImage__c, TertiaryImage__c, 
                    FourthImage__c, FifthImage__c, OfficeLocation__c, PropertyDetails__c, X24hrAccess__c, 
                    AirConditioning__c, Broadband__c, BreakOutAreas__c, Bike_Racks__c, Cctv__c, CAT5__c, 
                    Cat6__c, CoWorking__c, Contemporary_Design__c, DisabledAccess__c, FibreInternet__c, 
                    Furniture__c, Gym__c, AccessToOtherCentresNationwide__c, 
                    AccessToOtherCentresWorldwide__c, MannedSecurity__c, AlarmSecurity__c, ISDN__c, 
                    Kitchen__c, ManagedOfficeSpace__c, Network__c, OnsiteCafe__c, PetsAllowed__c, 
                    Parking__c, Reception__c, Showers__c, Telephone_System__c, 
                    TraditionalDesign__c, UnbrandedSpace__c, VideoConferencing__c, VirtualOffices__c, 
                    AdminSupport__c, DisabilityAccess__c, Lifts__c, Transport_JSON__c, CostLow__c, 
                    CostHigh__c, CentreManager__r.Name, CentreManagerEmail__c, CentreManagerMobile__c, 
                    Centre_Manager_Phone__c, Major_Transport_Links__c
                FROM 
                    Account 
                WHERE 
                    Id = :intro.BusinessCentre__c
            ];
            // DisabilityAccess__c | Disability Access
            IntroductionObject introObject = new IntroductionObject();
            
            introObject.Id = introId;


            if(ownerInfo == null || ownerInfo.Name == 'Amber Jones' || ownerInfo.Name == 'Kate Jones') {
                introObject.UserName = businessCenter.CentreManager__r.Name;
                introObject.UserPhone = businessCenter.CentreManagerMobile__c != null ? businessCenter.CentreManagerMobile__c : businessCenter.Centre_Manager_Phone__c;
                introObject.UserEmail = businessCenter.CentreManagerEmail__c;
            } else {
                introObject.UserName = ownerInfo.Name;
                introObject.UserPhone = ownerInfo.Phone;
                introObject.UserEmail = ownerInfo.Email;
                introObject.UserPhoto = ownerInfo.FullPhotoUrl;
            }
            
            introObject.OptionTermLength = intro.Term_Length__c;
            introObject.OptionAvailableFrom = intro.Available_from__c;
            introObject.OptionOptionSize = intro.Option_size__c;
            introObject.OptionMonthlyQuotingRate = intro.Monthly_quoting_rate__c;
            introObject.OptionCostOfOccupancy = intro.Monthly_cost_of_occupation__c;
            introObject.OptionNotes = intro.Notes__c;
            
            String businessCenterAddress = businessCenter.Address_Formula__c;
            
            if(businessCenterAddress.endsWith(',')) {
                businessCenterAddress = businessCenterAddress.substring(0, businessCenterAddress.length()-1);
            }
            
            introObject.BusinessCenterName = businessCenter.Name;
            introObject.BusinessCenterAddress = businessCenterAddress.replace(',', ', ').replace('  ', ' ');
            if(introObject.BusinessCenterAddress.substring(introObject.BusinessCenterAddress.length()-1) == ',') {
                introObject.BusinessCenterAddress = introObject.BusinessCenterAddress.substring(0, introObject.BusinessCenterAddress.length()-1);
            }
            introObject.BusinessCenterAddressEscaped = businessCenterAddress.replace(' ', '+');
            introObject.BusinessCenterOfficeLocation = businessCenter.OfficeLocation__c != null ? businessCenter.OfficeLocation__c : '';
            introObject.BusinessCenterPropertyDetails = businessCenter.PropertyDetails__c != null ? businessCenter.PropertyDetails__c : '';
            introObject.BusinessCenterShortlisted = intro.Shortlisted__c == true;
            introObject.BusinessCenterViewRequest = intro.ViewingDate__c;
            introObject.BusinessCenterTransportJSON = businessCenter.Transport_JSON__c;
            introObject.BusinessCenterPhotoOther = new List<String>();
            introObject.BusinessCenterAmenities = new List<BusinessCenterAmenity>();
            introObject.BusinessCenterCostLow = businessCenter.CostLow__c;
            introObject.BusinessCenterCostHigh = businessCenter.CostHigh__c;
            
            for(Integer i = 0; i < amenities.size(); i++) {
                if(Boolean.valueOf(businessCenter.get(amenities.get(i)))) {
                    BusinessCenterAmenity bca = new BusinessCenterAmenity();
                    bca.Name = amenitiesLabel.get(i);
                    bca.Id = amenitiesLabel.get(i);
                    introObject.BusinessCenterAmenities.add(bca);
                }
            }
            
            if(businessCenter.SecondaryImage__c != null) {
                introObject.BusinessCenterPhotoOther.add(prepPhotoUrl(businessCenter.SecondaryImage__c));
            }
            if(businessCenter.TertiaryImage__c != null) {
                introObject.BusinessCenterPhotoOther.add(prepPhotoUrl(businessCenter.TertiaryImage__c));
            }
            if(businessCenter.FourthImage__c != null) {
                introObject.BusinessCenterPhotoOther.add(prepPhotoUrl(businessCenter.FourthImage__c));
            }
            if(businessCenter.FifthImage__c != null) {
                introObject.BusinessCenterPhotoOther.add(prepPhotoUrl(businessCenter.FifthImage__c));
            }
            
            if(businessCenter.PrimaryImage__c != null) {
                introObject.BusinessCenterPhotoPrimary = prepPhotoUrl(businessCenter.PrimaryImage__c);
            } else if(!introObject.BusinessCenterPhotoOther.isEmpty()) {
                introObject.BusinessCenterPhotoPrimary = prepPhotoUrl(introObject.BusinessCenterPhotoOther.get(0));
                introObject.BusinessCenterPhotoOther.remove(0);
            }
            cachedIntroduction = introObject;
        }
        return cachedIntroduction;
    }

    public static String prepPhotoUrl(String url) {
        List<String> urlSplit = url.split('/');
        String fileName = urlSplit.get(urlSplit.size()-1);
        urlSplit.remove(urlSplit.size()-1);
        urlSplit.add(EncodingUtil.urlEncode(fileName, 'UTF-8'));
        return String.join(urlSplit, '/').replace('%2B', '+');
    }
    
    public static String getValueFromParam(String paramKey) {
        String toReturn = null;
        if(ApexPages.currentPage().getParameters().containsKey(paramKey)) {         
            toReturn = ApexPages.currentPage().getParameters().get(paramKey);     
        }
        return toReturn;
    }

    public PageReference generateJSON() {
        String type = getValueFromParam('type');
        switch on type {
            when 'export' {
                IntroductionObject intro = getIntroduction();
                outputJson = JSON.serialize(intro);
            }
            when 'transport' {
                Id introId = Id.valueOf(getValueFromParam('id'));
                Introduction__c intro = [SELECT BusinessCentre__c FROM Introduction__c WHERE Id = :introId];
                Account businessCenter = [SELECT Id, Address_Formula__c, Transport_JSON__c, Transport_JSON_Updated__c FROM Account WHERE Id = :intro.BusinessCentre__c];
                outputJson = '[]';
                if(null != businessCenter.Address_Formula__c) {
                    Datetime currentTime = Datetime.now();
                    Datetime lastYear = Datetime.newInstance(currentTime.year()-1, currentTime.month(), currentTime.day());
                    if(null == businessCenter.Transport_JSON__c || businessCenter.Transport_JSON_Updated__c > lastYear) {
                        String latLng = getLatLng(businessCenter.Address_Formula__c);
                        if(null != latLng) {
                            String stationsJson = getStations(latLng);
                            if(null != stationsJson) {
                                businessCenter.Transport_JSON__c = stationsJson;
                                businessCenter.Transport_JSON_Updated__c = currentTime;
                                outputJson = stationsJson;
                            } else {
                                businessCenter.Transport_JSON__c = outputJson;
                                businessCenter.Transport_JSON_Updated__c = Datetime.newInstance(currentTime.year()-1, currentTime.month(), currentTime.day()+7);
                            }
                            update businessCenter;
                        }
                    } else {
                        outputJson = businessCenter.Transport_JSON__c;
                    }
                }
            }
            when 'request_viewing' {
                Id introId = Id.valueOf(getValueFromParam('id'));
                Introduction__c intro = [
                    SELECT 
                        Id, ViewingDate__c
                    FROM 
                        Introduction__c 
                    WHERE 
                        Id = :introId
                ];
                intro.ViewingDate__c = getValueFromParam('date');
                update intro;
                outputJson = '{"success":true}';
            }
            when 'shortlist' {

                Id introId = Id.valueOf(getValueFromParam('id'));
                Introduction__c intro = [
                    SELECT 
                        Id, Shortlisted__c, Lead__c, RelatedToDeal__c, Digital_Asset__c
                    FROM 
                        Introduction__c 
                    WHERE 
                        Id = :introId
                ];
                if(intro.Shortlisted__c != true) {
                    intro.Shortlisted__c = true;
                    update intro;
                    Id relatedId = null != intro.Lead__c ? intro.Lead__c : intro.RelatedToDeal__c;
                    if(null != relatedId) {
                        List<datadwell__DigitalDistribution__c> dists = [SELECT Id FROM datadwell__DigitalDistribution__c WHERE datadwell__Related_Id__c = :relatedId AND Name = :DataDwellHelper.portalName];
                        if(!dists.isEmpty()) {
                            Id distId = dists.get(0).Id;
                            insert new datadwell__DigitalDistributionActivity__c(
                                datadwell__ActivityType__c = 'Shared',
                                datadwell__DigitalAsset__c = intro.Digital_Asset__c,
                                datadwell__DigitalDistribution__c = distId,
                                datadwell__Custom_Folder__c = 'Shortlist'
                            );
                        }
                    }
                }
                outputJson = '{"shortlisted": true}';
            }
            when 'shortlistremove' {

                Id introId = Id.valueOf(getValueFromParam('id'));
                Introduction__c intro = [
                    SELECT 
                        Id, Shortlisted__c, Lead__c, RelatedToDeal__c, Digital_Asset__c
                    FROM 
                        Introduction__c 
                    WHERE 
                        Id = :introId
                ];
                if(intro.Shortlisted__c != null && intro.Shortlisted__c == true) {
                    intro.Shortlisted__c = true;
                    update intro;
                    Id relatedId = null != intro.Lead__c ? intro.Lead__c : intro.RelatedToDeal__c;
                    if(null != relatedId) {
                        List<datadwell__DigitalDistribution__c> dists = [SELECT Id FROM datadwell__DigitalDistribution__c WHERE datadwell__Related_Id__c = :relatedId AND Name = :DataDwellHelper.portalName];
                        if(!dists.isEmpty()) {
                            Id distId = dists.get(0).Id;
                            List<datadwell__DigitalDistributionActivity__c> acts = [
                                SELECT Id FROM datadwell__DigitalDistributionActivity__c 
                                WHERE 
                                    datadwell__ActivityType__c = 'Shared' AND 
                                    datadwell__DigitalAsset__c = :intro.Digital_Asset__c AND 
                                    datadwell__DigitalDistribution__c = :distId AND 
                                    datadwell__Custom_Folder__c = 'Shortlist'
                            ];
                            if(!acts.isEmpty()) {
                                delete acts;
                            }
                        }
                    }
                }
                outputJson = '{"shortlisted": false}';
            }
        }
        return null;
    }

    public static String getLatLng(String address) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key=' + googleApiKey + '&address=' + EncodingUtil.urlEncode(address, 'UTF-8'));
        req.setMethod('GET');
        
        Http http = new Http();
        String jsonGeo;
        if(!Test.isRunningTest()) {
        	HTTPResponse res = http.send(req);
        	jsonGeo = res.getBody();
        } else {
            jsonGeo = '{"results": [{"geometry": {"location": {"lat": 51.5214974,"lng": -0.1564347}}}]}';
        }
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonGeo);
        
        List<Object> results = (List<Object>)m.get('results');
        if(!results.isEmpty()) {
            Map<String, Object> addressObject = (Map<String, Object>) results.get(0);
            Map<String, Object> geometry = (Map<String, Object>)addressObject.get('geometry');
            Map<String, Object> location = (Map<String, Object>)geometry.get('location');
            String lat = String.valueOf((Decimal)location.get('lat'));
            String lng = String.valueOf((Decimal)location.get('lng'));
            return lat + ',' + lng;
        }
        return null;
    }

    public static List<Map<String, String>> fetchStationsAPI(String latLng, String stationType) {

        List<Map<String, String>> stations = new List<Map<String, String>>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=' + googleApiKey + '&type=' + stationType + '&radius=1000&location=' + latLng);
        req.setMethod('GET');
        
        Http http = new Http();
        String jsonStations;
        if(!Test.isRunningTest()) {
        	HTTPResponse res = http.send(req);
        	jsonStations = res.getBody();
        } else {
            jsonStations = '{"results": [{"geometry": {"location": {"lat": 51.5231577,"lng": -0.156863},"viewport": {"northeast": {"lat": 51.5241607802915,"lng": -0.155354419708498},"southwest": {"lat": 51.5214628197085,"lng": -0.158052380291502}}},"name": "Baker Street Station"}]}}';
        }
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonStations);
        List<Object> results = (List<Object>)m.get('results');
        for(Integer i = 0; i < results.size(); i++) {
            Map<String, String> station = new Map<String, String>();
            Map<String, Object> row = (Map<String, Object>) results.get(i);
            station.put('name', (String)row.get('name'));
            station.put('type', stationType);
            Map<String, Object> geometry = (Map<String, Object>)row.get('geometry');
            Map<String, Object> location = (Map<String, Object>)geometry.get('location');
            station.put('lat', String.valueOf((Decimal)location.get('lat')));
            station.put('lng', String.valueOf((Decimal)location.get('lng')));
            stations.add(station);
        }
        return stations;
    }

    public static Map<String, String> getDistance(String originLatLng, String destLatLng) {

        Map<String, String> distance = new Map<String, String>();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://maps.googleapis.com/maps/api/distancematrix/json?origins=' + originLatLng + '&key=' + googleApiKey + '&destinations=' + destLatLng + '&units=imperial');
        req.setMethod('GET');
        
        String jsonStations;
        Http http = new Http();
        if(!Test.isRunningTest()) {
        	HTTPResponse res = http.send(req);
        	jsonStations = res.getBody();
        } else {
            jsonStations = '{"rows": [{"elements": [{"distance": {"text": "0.8 mi","value": 1313},"duration": {"text": "6 mins","value": 388}}]}]}';
        }
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonStations);
        List<Object> rows = (List<Object>)m.get('rows');
        for(Integer i = 0; i < rows.size(); i++) {
            Map<String, Object> row = (Map<String, Object>) rows.get(i);
            List<Object> elements = (List<Object>)row.get('elements');
            Map<String, Object> element = (Map<String, Object>)elements.get(0);
            Map<String, Object> distanceObject = (Map<String, Object>)element.get('distance');
            Map<String, Object> durationObject = (Map<String, Object>)element.get('duration');
            distance.put('distance', (String) distanceObject.get('text'));
            distance.put('duration', (String) durationObject.get('text'));
        }

        return distance;
    }

    public static String getStations(String latLng) {

        List<Map<String, String>> allStations = new List<Map<String, String>>();

        for(String stationType :  new List<String>{'train_station', 'subway_station'}) {
            allStations.addAll(fetchStationsAPI(latLng, stationType));
        }

        for(Map<String, String> station : allStations) {
            Map<String, String> distance = getDistance(latLng, station.get('lat')+','+station.get('lng'));
            station.put('distance', distance.get('distance'));
            station.put('duration', distance.get('duration'));

        }

        return JSON.serialize(allStations);
    }
}