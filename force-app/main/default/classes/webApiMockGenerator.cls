@istest
global class webApiMockGenerator implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        // AUTENTICATION ENDPOINT
        if (req.getEndpoint().contains('token')) {
            res.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            WebAPIUtils.AccessTokenResponse bodyResponse =  new WebAPIUtils.AccessTokenResponse();
            bodyResponse.access_token = '12345678';
            bodyResponse.expires_in = '12345678';
            res.setBody(JSON.serialize(bodyResponse));
            res.setStatusCode(200);
            return res;
            // GET FULL AUDIT ENDPOINT
        } 
        else if (req.getEndpoint().contains('miccsdk')) {
            System.debug('WebAPIUtilsTest.MOCKERROR '+ WebAPIUtilsTest.MOCKERROR);
            res.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            String bodyResponse = WebAPIUtilsTest.MOCKERROR?'KO':'OK';
            res.setBody(JSON.serialize(bodyResponse));
            res.setStatusCode(WebAPIUtilsTest.MOCKERROR?400:200);
            System.debug(res);
            return res;
            // CREATE AUDIT ENDPOINT
        }else if (req.getEndpoint().contains('addbusinesscentre')) {
            res.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            WebAPIDataModel.BusinessCentreAdd_response bodyResponse = createBCAddresponse();
            res.setBody(WebAPIUtilsTest.MOCKERROR?'ERROR':JSON.serialize(bodyResponse));
            res.setStatusCode(WebAPIUtilsTest.MOCKERROR?400:200);
            return res;
        }else if (req.getEndpoint().contains('getstatistics')) {
            res.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            WebAPIDataModel.StatisticResponse bodyResponse = createStatisticResponse();
            res.setBody(WebAPIUtilsTest.MOCKERROR?'ERROR':JSON.serialize(bodyResponse));
            res.setStatusCode(WebAPIUtilsTest.MOCKERROR?400:200);
            return res;
        }else if (req.getEndpoint().contains('autocomplete')) {
            res.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            res.setBody(WebAPIUtilsTest.MOCKERROR?'ERROR':'OK');
            res.setStatusCode(WebAPIUtilsTest.MOCKERROR?400:200);
            return res;
        }
        return res;
    }

    private static WebAPIDataModel.BusinessCentreAdd_response createBCAddresponse() {
        WebAPIDataModel.BusinessCentreAdd_response record = new WebAPIDataModel.BusinessCentreAdd_response();
        record.data = new WebAPIDataModel.BusinessCentre();
        record.data.url = WebAPIUtilsTest.BC_URL;
        return record;
    }
    private static WebAPIDataModel.StatisticResponse createStatisticResponse() {
        WebAPIDataModel.StatisticResponse statisticResponse = new WebAPIDataModel.StatisticResponse();
        StatisticResponse.sId = '0';
        statisticResponse.urls = new List <WebAPIDataModel.StatisticURL>();
        WebAPIDataModel.StatisticURL statisticURL = new WebAPIDataModel.StatisticURL();
        statisticURL.sId = '0';
        statisticURL.url = WebAPIUtilsTest.BC_URL;
        statisticResponse.urls.add(statisticURL);

        return statisticResponse;
    }
}