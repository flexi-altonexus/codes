@isTest
private class AgentSearchWizardUtilTest {
    @isTest
    static void getRecordInfo() {
        //AgentSearchWizardUtil testClass = new AgentSearchWizardUtil();
        Contact c = new Contact(LastName = 'TestContactMatch', Email = 'contactmatch@gmail.com');
        insert c;

        Account ac = TestFactory.createBC(c.Id);
        insert ac;

        AgentSearchWizardUtil.getRecordInfo(ac.Id);
    }

    @isTest
    static void getLocationOK() {
        WebAPISetup__c newToken = new WebAPISetup__c();
        newToken.Token_Key__c = WepAPICallOutTest.tokenExample;
        newToken.Expires_Date__c = system.today().addmonths(1);
        newToken.Name = 'tokenRec';
        insert newToken;
        String JSONResponse = WepAPICallOutTest.locationJSONREsponse;

        WepAPICallOutTest fakeResponse = new WepAPICallOutTest(200, 'OK', JSONResponse, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        map<String, WebAPIDataModel.Location> resmap = AgentSearchWizardUtil.getLocations(
            'London',
            'United Kingdom'
        );
        Test.stopTest();
    }

    @isTest
    static void getLocationsKO() {
        WebAPISetup__c newToken = new WebAPISetup__c();
        newToken.Token_Key__c = WepAPICallOutTest.tokenExample;
        newToken.Expires_Date__c = system.today().addmonths(1);
        newToken.Name = 'tokenRec';
        insert newToken;
        String JSONResponse = 'Error';

        WepAPICallOutTest fakeResponse = new WepAPICallOutTest(401, 'KO', JSONResponse, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        map<String, WebAPIDataModel.Location> resmap = AgentSearchWizardUtil.getLocations(
            'London',
            'United Kingdom'
        );
        Test.stopTest();
    }

    @isTest
    static void getBCsOK() {
        Contact c = new Contact(LastName = 'TestContactMatch', Email = 'contactmatch@gmail.com');
        insert c;

        Account ac = TestFactory.createBC(c.Id);
        insert ac;

        WebAPISetup__c newToken = new WebAPISetup__c();
        newToken.Token_Key__c = WepAPICallOutTest.tokenExample;
        newToken.Expires_Date__c = system.today().addmonths(1);
        newToken.Name = 'tokenRec';
        insert newToken;

        WebAPIDataModel.Location loc = new WebAPIDataModel.Location();

        loc.name = 'London';
        loc.url = '/London';

        String JSONResponse = WepAPICallOutTest.BCJSONREsponse;

        WepAPICallOutTest fakeResponse = new WepAPICallOutTest(200, 'OK', JSONResponse, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        list<AgentSearchWizardUtil.BCModel> reslist = AgentSearchWizardUtil.getBusinessCentres(
            JSON.serialize(loc),
            '5',
            '5',
            ac.Id
        );
        Test.stopTest();
    }

    @isTest
    static void getBCsKO() {
        Contact c = new Contact(LastName = 'TestContactMatch', Email = 'contactmatch@gmail.com');
        insert c;

        Account ac = TestFactory.createBC(c.Id);
        insert ac;

        WebAPISetup__c newToken = new WebAPISetup__c();
        newToken.Token_Key__c = WepAPICallOutTest.tokenExample;
        newToken.Expires_Date__c = system.today().addmonths(1);
        newToken.Name = 'tokenRec';
        insert newToken;

        WebAPIDataModel.Location loc = new WebAPIDataModel.Location();

        loc.name = 'test';
        loc.url = '/test';

        String JSONResponse = WepAPICallOutTest.BCJSONREsponse;

        WepAPICallOutTest fakeResponse = new WepAPICallOutTest(401, 'KO', 'error', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        try {
            list<AgentSearchWizardUtil.BCModel> reslist = AgentSearchWizardUtil.getBusinessCentres(
                JSON.serialize(loc),
                '5',
                '5',
                ac.Id
            );
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'Problem with Custom Web API');
        }
        Test.stopTest();
    }

    @isTest
    static void finish() {
        Lead newlead = TestFactory.createLead('test', '3333', null);
        newlead.Email = 'test@test.com';
        newlead.Industry = 'Agriculture';
        newlead.Number_of_Employees__c = '1 - 10';
        insert newlead;

        String BCList = WepAPICallOutTest.BCListJSONREsponse;

        Test.startTest();
        AgentSearchWizardUtil.finish(newlead.Id, BCList);
        Test.stopTest();
    }

    @isTest
    static void controller() {
        Introduction__c intro = new Introduction__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(intro);
        AgentSearchWizardUtil pageTest = new AgentSearchWizardUtil();
        pageTest.initController();
    }

    @IsTest
    static void getBusinessCentresByIdTest() {
        Contact c = new Contact(LastName = 'TestContactMatch', Email = 'contactmatch@gmail.com');
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        insert ac;
        Account ac2 = TestFactory.createBC(c.Id);
        insert ac2;
        Lead l = new Lead(LastName = 'TestLead', LeadSource = 'Telephone', Company = 'TestCompany');
        insert l;
        Opportunity o = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Qualified',
            CloseDate = Date.today()
        );
        insert o;
        Introduction__c i1 = new Introduction__c(
            Lead__c = l.id,
            RelatedToDeal__c = o.id,
            BusinessCentre__c = ac.id,
            LastIntroductionSent__c = DateTime.now()
        );
        insert i1;
        Introduction__c i2 = new Introduction__c(
            Lead__c = l.id,
            RelatedToDeal__c = o.id,
            BusinessCentre__c = ac2.id,
            LastIntroductionSent__c = DateTime.now()
        );
        insert i2;

        List<AgentSearchWizardUtil.BCModel> bcs = AgentSearchWizardUtil.getBusinessCentresById(
            l.id
        );
    }

    @IsTest
    static void getAutomaticIntrosTest() {
        Contact c = new Contact(LastName = 'TestContactMatch', Email = 'contactmatch@gmail.com');
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        insert ac;
        Account ac2 = TestFactory.createBC(c.Id);
        insert ac2;
        Lead l = new Lead(LastName = 'TestLead', LeadSource = 'Telephone', Company = 'TestCompany');
        insert l;
        Opportunity o = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Qualified',
            CloseDate = Date.today()
        );
        insert o;
        Introduction__c i1 = new Introduction__c(
            Lead__c = l.id,
            RelatedToDeal__c = o.id,
            BusinessCentre__c = ac.id,
            IntroductionType__c = 'Manual'
        );
        insert i1;
        Introduction__c i2 = new Introduction__c(
            Lead__c = l.id,
            RelatedToDeal__c = o.id,
            BusinessCentre__c = ac2.id,
            IntroductionType__c = 'Manual'
        );
        insert i2;

        List<AgentSearchWizardUtil.BCModel> bcs = AgentSearchWizardUtil.getAutomaticIntros(l.id);
    }
    
    @isTest
    static void getfinishNoEmails(){
        Lead newlead = TestFactory.createLead('test', '3333', null);
        newlead.Email = 'test@test.com';
        newlead.Industry = 'Agriculture';
        newlead.Number_of_Employees__c = '1 - 10';
        insert newlead;

        String BCList = WepAPICallOutTest.BCListJSONREsponse;

        Test.startTest();
        AgentSearchWizardUtil.finishNoEmails(newlead.Id, BCList);
        Test.stopTest();
        
        
    }
}