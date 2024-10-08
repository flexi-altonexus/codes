@isTest
public class WepAPICallOutTest implements HttpCalloutMock {
        
        public static String locationJSONREsponse = '{"$id": "1","searchedTerm": "lon","error": false,"errorMessage": "","pageIndex": 0,"pageSize": 10,"totalCount": 4,"totalPageCount": 1,"timeStamp": "2019-10-08T11:14:28.069574+01:00", "latitude": 0.0,"longitude": 0.0,"data": [{"$id": "2","id": 179,"locationTypeName": "Region","name": "London","showName": "London","analyzedName": "London","latitude": 0.0,"longitude": 0.0,"priority": 0,"headerStatus": 200,"url": "/london", "removedFromAnchors": false,"removedFromUrls": false,"londonNearbyLocations": false,"londonNearbyBCs": false,"nearbyLocationsAndCities": false,"nearbyCountiesAndRegions": false,"popularLocationsLondon": false,"popularLocationsNonLondon": false,"geo": {"lat": 0.0,"lon": 0.0}}]}';
        public static String tokenExample = 'BdUhJc7W9x1eb6y67aChXNxLbE4DHzGCiIeNypIVuFOhyGkESl9zzRMoD-xvwtKAykYQB8BXWw0lAxNtAQ_6_wNKwySc-G7RldRuJciXeWkfUfVrGzvB3n5dV22ioRAg3DDhSD4LMHKYCOk4qHbhtaBSJxxMwy1LqyRDTDM3rt3SqD5CfGlu1Kfe5wPW3ukdZ2Rb_w5qC-COmGTs-HZ7erVcAyU14tuJB4sz4zQM7Qkf0h3Mm9BUMsiDRxuEHisPwYhCf0R_G8XBervdBZMAdGc5x9A7nK6zkwvoIFY4dgE';
        public static String BCJSONREsponse = '{"$id":"1","error":false,"errorMessage":"","timeStamp":"2019-10-08T11:32:58.4758188+01:00","data":[{"$id":"2","businessCentreId":"SF441599","cityId":1063,"distance":1,"countyId":56,"countryId":94,"centreName":"Fitzroy Square - W1T","bcCompanyId":2,"contactName":"Kate Williams","image":"FitzroySq20W1T.322082016160528_372.jpg","extraImage1":"FitzroySq20W1T.222082016160530_372.JPG","extraImage2":"FitzroySq20W1T.422082016160535_372.JPG","extraImage3":"FitzroySq20W1T.22082016160537_372.JPG","rating":"3","buildingName":"20","streetName":"Fitzroy Square","town":"Fitzrovia","county":"London","postcode":"W1T 6EJ","globalCityId":2283,"globalCountryId":75,"globalLat":"51.522788","globalLon":"-0.139342","telephone":"0207 874 1860","fax":"0207 8741861","description":"This Grade II listed building dates back to the 1700s and was designed by the Adam Brothers and is part of the only Adam designed square in London. A complete building refurbishment has recently been completed to an exceptional level whilst being sensitive to the buildings traditional style and historic features. Brand new facilities provide this building with all the benefits of modern performance.","locationDescription":"It is extremely well connected for Public transport with Warren Street, Euston, Great Portland Street  and Goodge Street Underground Stations ","typeOfBuilding":"Office","costCurrency":1,"officeCurrency":"£","costLowerAsNumber":0,"costTypeID":3,"sizeLower":0,"sizeUpper":0,"managedOffice":false,"virtualOffices":false,"meetingRooms":true,"telephoneAnswer":true,"isdn":true,"cat5":true,"airCon":true,"furniture":true,"reception":true,"vcon":true,"network":true,"parking":false,"voiceMail":true,"dateSubmitted":"2016-08-22T16:05:45.703","approved":true,"centreManagerName":"Kate Williams","centreManagerEmail":"reception@10fitzroy.com","centreManagerDdi":"0207 874 1860","furtherComment":"28.08.18 updated featuresCF","email":"reception@10fitzroy.com","costHigher":0,"broadband":true,"archived":false,"enhancedListing":false,"specialoffer":true,"specialofferdetails":"Payment in Advance Centre","specialterms":false,"tradeIcon":false,"gym":false,"loungeAreas":false,"modernBuilding":false,"periodBuilding":false,"sharedSpace":false,"unbrandedSpace":true,"showers":false,"bicycleParking":false,"accessNationwide":false,"accessWorldwide":false,"adminSupport":true,"mannedReception":true,"alarmSecurity":true,"cctv":true,"mannedSecurity":false,"telephoneSystem":true,"hr24":true,"disabledAccess":false,"lifts":false,"onsiteCafe":false,"premium":false,"cat6":false,"display":false,"disreputable":false,"chkFlexi":true,"chkCos":false,"chkOstr":false,"chkSos":false,"enhancedcomm":false,"isFeatured":1,"latitude":51.52279,"longitude":-0.139342,"fibreInternet":false,"kitchen":false,"breakOutAreas":true,"bikeRacks":false,"petsAllowed":false,"contemporaryDesign":false,"traditionalDesign":true,"coWorking":false,"isLondonPrime":false,"isEnhanced":false,"geo":{"lat":51.52279,"lon":-0.139342}}]}';
        public static String BCId {
             get{ 
                Account ac = TestFactory.createBC();
                insert ac;
                return (String)ac.Id;  
             }
        }

        public static String BCListJSONREsponse = '[{"$id":"2","businessCentreId":"'+ BCId+'","sendToC" : false,"sendToB" : false, "cityId":1063,"distance":1,"countyId":56,"countryId":94,"centreName":"Fitzroy Square - W1T","bcCompanyId":2,"contactName":"Kate Williams","image":"FitzroySq20W1T.322082016160528_372.jpg","extraImage1":"FitzroySq20W1T.222082016160530_372.JPG","extraImage2":"FitzroySq20W1T.422082016160535_372.JPG","extraImage3":"FitzroySq20W1T.22082016160537_372.JPG","rating":"3","buildingName":"20","streetName":"Fitzroy Square","town":"Fitzrovia","county":"London","postcode":"W1T 6EJ","globalCityId":2283,"globalCountryId":75,"globalLat":"51.522788","globalLon":"-0.139342","telephone":"0207 874 1860","fax":"0207 8741861","description":"This Grade II listed building dates back to the 1700s and was designed by the Adam Brothers and is part of the only Adam designed square in London. A complete building refurbishment has recently been completed to an exceptional level whilst being sensitive to the buildings traditional style and historic features. Brand new facilities provide this building with all the benefits of modern performance.","locationDescription":"It is extremely well connected for Public transport with Warren Street, Euston, Great Portland Street  and Goodge Street Underground Stations ","typeOfBuilding":"Office","costCurrency":1,"officeCurrency":"£","costLowerAsNumber":0,"costTypeID":3,"sizeLower":0,"sizeUpper":0,"managedOffice":false,"virtualOffices":false,"meetingRooms":true,"telephoneAnswer":true,"isdn":true,"cat5":true,"airCon":true,"furniture":true,"reception":true,"vcon":true,"network":true,"parking":false,"voiceMail":true,"dateSubmitted":"2016-08-22T16:05:45.703","approved":true,"centreManagerName":"Kate Williams","centreManagerEmail":"reception@10fitzroy.com","centreManagerDdi":"0207 874 1860","furtherComment":"28.08.18 updated featuresCF","email":"reception@10fitzroy.com","costHigher":0,"broadband":true,"archived":false,"enhancedListing":false,"specialoffer":true,"specialofferdetails":"Payment in Advance Centre","specialterms":false,"tradeIcon":false,"gym":false,"loungeAreas":false,"modernBuilding":false,"periodBuilding":false,"sharedSpace":false,"unbrandedSpace":true,"showers":false,"bicycleParking":false,"accessNationwide":false,"accessWorldwide":false,"adminSupport":true,"mannedReception":true,"alarmSecurity":true,"cctv":true,"mannedSecurity":false,"telephoneSystem":true,"hr24":true,"disabledAccess":false,"lifts":false,"onsiteCafe":false,"premium":false,"cat6":false,"display":false,"disreputable":false,"chkFlexi":true,"chkCos":false,"chkOstr":false,"chkSos":false,"enhancedcomm":false,"isFeatured":1,"latitude":51.52279,"longitude":-0.139342,"fibreInternet":false,"kitchen":false,"breakOutAreas":true,"bikeRacks":false,"petsAllowed":false,"contemporaryDesign":false,"traditionalDesign":true,"coWorking":false,"isLondonPrime":false,"isEnhanced":false,"geo":{"lat":51.52279,"lon":-0.139342}}]';
        public static String StatisticResponse = '{"$id": "1","urls": [{"$id": "2","url": "/london/soho","bcs": [{"$id": "3","id": "0013Y00002VvHWIQA3","i": "0","v": "27","q": "5"},{"$id": "4","id": "0013Y00002VvJ5aQAF","i": "0","v": "25","q": "8"}]}]}';
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public WepAPICallOutTest(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public WepAPICallOutTest(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }

            if (responseHeaders != null) {
                for (String key : responseHeaders.keySet()) {
                    resp.setHeader(key, responseHeaders.get(key));
                }
            }
            return resp;
        }
}