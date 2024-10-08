@isTest
private class AgentCreateViewingsUtilTest {
    @isTest
    static void initBusinessCentres() {
        set<String> setIds = new Set<String>();
        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;

        Account ac = TestFactory.createBC(c.Id);
        insert ac;
        setIds.add(ac.Id);

        Account ac2 = TestFactory.createBC(c.Id);
        insert ac2;
        setIds.add(ac2.Id);

        Lead l = new Lead(
            LastName = 'TestLead',
            LeadSource = 'Telephone',
            Company = 'TestCompany'
        );
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
            BusinessCentre__c = ac.id
        );
        insert i1;
        Introduction__c i2 = new Introduction__c(
            Lead__c = l.id,
            RelatedToDeal__c = o.id,
            BusinessCentre__c = ac2.id
        );
        insert i2;

        setIds.add(i1.Id);
        setIds.add(i2.Id);

        String JSONBC = JSON.serialize(setIds);

        AgentCreateViewingsUtil.initBusinessCentresList(JSONBC);
        AgentCreateViewingsUtil.initReferencesIds(JSONBC);
    }

    @isTest
    static void MapLink() {
        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;
        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;

        insert ac;

        Account ac2 = TestFactory.createBC(c.Id);
        ac2.BillingStreet = 'Real 2';
        ac2.BillingPostalCode = '28700';
        ac2.BillingState = 'Madrid';
        ac2.BillingLatitude = 38.8951;
        ac2.BillingLongitude = -77.0364;
        insert ac2;

        Lead l = new Lead(
            LastName = 'TestLead',
            LeadSource = 'Telephone',
            Company = 'TestCompany'
        );
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
            BusinessCentre__c = ac.id
        );
        insert i1;
        Introduction__c i2 = new Introduction__c(
            Lead__c = l.id,
            RelatedToDeal__c = o.id,
            BusinessCentre__c = ac2.id
        );
        insert i2;

        list<AgentCreateViewingsUtil.ViwwingModel> newlist = new List<AgentCreateViewingsUtil.ViwwingModel>();

        AgentCreateViewingsUtil.ViwwingModel newRec = new AgentCreateViewingsUtil.ViwwingModel();
        AgentCreateViewingsUtil.ViwwingModel newRec2 = new AgentCreateViewingsUtil.ViwwingModel();
        Datetime vtime = system.now();

        newRec.order = 1;
        newRec.bcId = ac.Id;
        newRec.bcName = ac.Name;
        newRec.managerId = null;
        newRec.manager = 'test';
        newRec.managerphone = null;
        newRec.vtime = vtime;
        newRec.stime = vtime.format('HH:mm');
        newRec.manageremail = 'test@test.com';
        newRec.address = ac.BillingStreet + '-' + ac.BillingPostalCode;
        newRec.location = ac.BillingState;
        newRec.notes = null;

        newRec2.order = 1;
        newRec2.bcId = ac2.Id;
        newRec2.bcName = ac2.Name;
        newRec2.managerId = null;
        newRec2.manager = 'test';
        newRec2.managerphone = null;
        newRec2.vtime = vtime;
        newRec2.stime = vtime.format('HH:mm');
        newRec2.manageremail = 'test@test.com';
        newRec2.address = ac2.BillingStreet + '-' + ac2.BillingPostalCode;
        newRec2.location = ac2.BillingState;
        newRec2.notes = null;

        newlist.add(newRec);
        newlist.add(newRec2);

        AgentCreateViewingsUtil.createMapLink(null, JSON.serialize(newlist));

        ViewingSchedule__c vs = new ViewingSchedule__c();
        insert vs;
        Viewing__c v = new Viewing__c(
            ViewingSchedule__c = vs.id,
            BusinessCentre__c = ac.id
        );
        insert v;
        Viewing__c v2 = new Viewing__c(
            ViewingSchedule__c = vs.id,
            BusinessCentre__c = ac2.id
        );
        insert v2;

        AgentCreateViewingsUtil.createMapLink(vs.Id, JSON.serialize(newlist));
    }

    @isTest
    static void sendEmailTest() {
        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;

        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;

        insert ac;

        Account ac2 = TestFactory.createBC(c.Id);
        ac2.BillingStreet = 'Real 2';
        ac2.BillingPostalCode = '28700';
        ac2.BillingState = 'Madrid';
        ac2.BillingLatitude = 38.8951;
        ac2.BillingLongitude = -77.0364;
        insert ac2;

        ViewingSchedule__c vs = new ViewingSchedule__c();
        insert vs;
        Viewing__c v = new Viewing__c(
            ViewingSchedule__c = vs.id,
            BusinessCentre__c = ac.id
        );
        insert v;
        Viewing__c v2 = new Viewing__c(
            ViewingSchedule__c = vs.id,
            BusinessCentre__c = ac2.id
        );
        insert v2;

        AgentCreateViewingsUtil.sendEmailViewingSchedule(vs.Id);
        AgentCreateViewingsUtil.getHeaderInfo(vs.Id);
    }

    @isTest
    static void saveViewing() {
        Contact c = new Contact(
            LastName = 'TestContactMatch',
            Email = 'contactmatch@gmail.com'
        );
        insert c;

        Account ac = TestFactory.createBC(c.Id);
        ac.BillingStreet = 'Libertad 2';
        ac.BillingPostalCode = '28100';
        ac.BillingState = 'Madrid';
        ac.BillingLatitude = 38.8951;
        ac.BillingLongitude = -77.0364;

        insert ac;

        Account ac2 = TestFactory.createBC(c.Id);
        ac2.BillingStreet = 'Real 2';
        ac2.BillingPostalCode = '28700';
        ac2.BillingState = 'Madrid';
        ac2.BillingLatitude = 38.8951;
        ac2.BillingLongitude = -77.0364;
        insert ac2;

        set<String> setIds = new Set<String>();
        setIds.add(ac.Id);
        setIds.add(ac2.Id);

        Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Client')
            .getRecordTypeId();
        Account cli = new Account(
            Name = 'TestAccount',
            RecordTypeId = bcRecordTypeId
        );
        insert cli;

        Opportunity o = new Opportunity(
            Name = 'TestOpp',
            StageName = 'Qualified',
            CloseDate = Date.today()
        );
        insert o;

        ViewingSchedule__c vs = new ViewingSchedule__c();
        insert vs;
        Viewing__c v = new Viewing__c(
            ViewingSchedule__c = vs.id,
            BusinessCentre__c = ac.id
        );
        insert v;
        Viewing__c v2 = new Viewing__c(
            ViewingSchedule__c = vs.id,
            BusinessCentre__c = ac2.id
        );
        insert v2;

        list<AgentCreateViewingsUtil.ViwwingModel> newlist = new List<AgentCreateViewingsUtil.ViwwingModel>();

        AgentCreateViewingsUtil.ViwwingModel newRec = new AgentCreateViewingsUtil.ViwwingModel();
        AgentCreateViewingsUtil.ViwwingModel newRec2 = new AgentCreateViewingsUtil.ViwwingModel();
        Datetime vtime = system.now();

        newRec.order = 1;
        newRec.bcId = ac.Id;
        newRec.bcName = ac.Name;
        newRec.managerId = null;
        newRec.manager = 'test';
        newRec.managerphone = null;
        newRec.vtime = vtime;
        newRec.stime = vtime.format('HH:mm');
        newRec.manageremail = 'test@test.com';
        newRec.address = ac.BillingStreet + '-' + ac.BillingPostalCode;
        newRec.location = ac.BillingState;
        newRec.notes = null;

        newRec2.order = 1;
        newRec2.bcId = ac2.Id;
        newRec2.bcName = ac2.Name;
        newRec2.managerId = null;
        newRec2.manager = 'test';
        newRec2.managerphone = null;
        newRec2.vtime = vtime;
        newRec2.stime = vtime.format('HH:mm');
        newRec2.manageremail = 'test@test.com';
        newRec2.address = ac2.BillingStreet + '-' + ac2.BillingPostalCode;
        newRec2.location = ac2.BillingState;
        newRec2.notes = null;

        newlist.add(newRec);
        newlist.add(newRec2);

        Lead l = new Lead(
            LastName = 'TestLead',
            LeadSource = 'Telephone',
            Company = 'TestCompany'
        );
        insert l;

        AgentCreateViewingsUtil.saveViewingSCH(
            cli.Id,
            o.Id,
            l.Id,
            JSON.serialize(newlist),
            '2019-02-02',
            'Test',
            vs.Id
        );
        AgentCreateViewingsUtil.getviewingLines(
            JSON.serialize(setIds),
            JSON.serialize(newlist),
            vs.Id
        );
        AgentCreateViewingsUtil.getviewingLines(
            JSON.serialize(new Set<String>()),
            JSON.serialize(newlist),
            vs.Id
        );
    }

    //   @isTest static void updateContact () {

    //     Contact c = new Contact(LastName = 'TestContactMatch', Email='contactmatch@gmail.com');
    // insert c;

    //   	Account ac = TestFactory.createBC(c.Id);
    // 	ac.BillingStreet = 'Libertad 2';
    // 	ac.BillingPostalCode = '28100';
    // 	ac.BillingState = 'Madrid';
    // 	ac.BillingLatitude = 38.8951;
    // 	ac.BillingLongitude  = -77.0364;

    // 	insert ac;

    // 	Contact con = new Contact();
    // 	con.FirstName = 'Tst';
    // 	con.LastName = 'Tst';
    // 	con.AccountId = ac.Id;
    // 	insert con;

    //   	AgentCreateViewingsUtil.updateContactRow(con.Id, ac.Id);
    //   }
}