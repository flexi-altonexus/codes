/*
 * @who		: James Boutle <james.boutel@empaua.com>
 * @when	: 12-04-2019
 * @what	: Test class for the EmailController Class
 */
@isTest
public class EmailControllerTest {
    /*
     * @method      : test()
     * @description : Test Method
     * @return      : void
     * @params      : N/A
     */
    @isTest
    public static void populatedListTest() {
        Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business_Centre')
            .getRecordTypeId();
        Group g1 = new Group(Name = 'Amber_Jones', type = 'Queue');
        insert g1;
        QueueSObject q1 = new QueueSObject(QueueID = g1.Id, SObjectType = 'Lead');
        insert q1;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(Name = 'TestAccount', RecordTypeId = bcRecordTypeId);
            insert a;
            Contact c = new Contact(LastName = 'testContact', Email = 'Testemail@test.com');
            insert c;
            a.CentreManager__c = c.Id;
            update a;
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
            Introduction__c i = new Introduction__c(
                Lead__c = l.id,
                RelatedToDeal__c = o.id,
                BusinessCentre__c = a.id,
                Send_to_BC__c = true,
                Send_to_Customer__c = true
            );
            ViewingSchedule__c vs = new ViewingSchedule__c();
            insert vs;
            Viewing__c v = new Viewing__c(ViewingSchedule__c = vs.id, BusinessCentre__c = a.id);

            insert i;
            insert v;
            Test.startTest();
            EmailController ec = new EmailController();
            ec.viewingScheduleId = vs.id;
            ec.leadId = l.Id;
            List<Viewing__c> viewingsReturned = ec.getViewings();
            List<Introduction__c> introsReturned = ec.getIntros();

            //System.assertEquals(false, introsReturned.isEmpty());
            System.assertEquals(false, viewingsReturned.isEmpty());

            ec.leadId = null;
            ec.oppId = o.id;
            introsReturned = ec.getIntros();
            //System.assertEquals(false, introsReturned.isEmpty());
            Test.stopTest();
        }

    }

    @isTest
    public static void populatedListTest2() {
        Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business_Centre')
            .getRecordTypeId();
        Group g1 = new Group(Name = 'Amber_Jones', type = 'Queue');
        insert g1;
        QueueSObject q1 = new QueueSObject(QueueID = g1.Id, SObjectType = 'Lead');
        insert q1;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(Name = 'TestAccount', RecordTypeId = bcRecordTypeId);
            insert a;
            Contact c = new Contact(LastName = 'testContact', Email = 'Testemail@test.com');
            insert c;
            a.CentreManager__c = c.Id;
            update a;
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
            Introduction__c i = new Introduction__c(
                Lead__c = l.id,
                RelatedToDeal__c = o.id,
                BusinessCentre__c = a.id,
                Send_to_BC__c = true,
                Send_to_Customer__c = true
            );
            ViewingSchedule__c vs = new ViewingSchedule__c();
            insert vs;
            Viewing__c v = new Viewing__c(ViewingSchedule__c = vs.id, BusinessCentre__c = a.id);

            insert i;
            insert v;
            Test.startTest();
            EmailController ec = new EmailController();
            ec.viewingId = v.id;
            ec.viewingScheduleId = vs.id;
            ec.leadId = l.Id;
            List<Viewing__c> viewingsReturned = ec.getViewings();
            List<Introduction__c> introsReturned = ec.getIntros();

            //System.assertEquals(false, introsReturned.isEmpty());
            System.assertEquals(false, viewingsReturned.isEmpty());

            ec.leadId = null;
            ec.oppId = o.id;
            introsReturned = ec.getIntros();
            //System.assertEquals(false, introsReturned.isEmpty());
            Test.stopTest();
        }

    }
    @isTest
    public static void emptyListTest() {
        Group g1 = new Group(Name = 'Amber_Jones', type = 'Queue');
        insert g1;
        QueueSObject q1 = new QueueSObject(QueueID = g1.Id, SObjectType = 'Lead');
        insert q1;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(thisUser) {
            Test.startTest();
            Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Business_Centre')
                .getRecordTypeId();
            Account a = new Account(Name = 'TestAccount', RecordTypeId = bcRecordTypeId);
            insert a;
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
            EmailController ec = new EmailController();
            ec.oppId = o.Id;
            List<Viewing__c> viewingsReturned = ec.getViewings();
            List<Introduction__c> introsReturned = ec.getIntros();
            Test.stopTest();
            System.assertEquals(true, introsReturned.isEmpty());
            System.assertEquals(null, viewingsReturned);
        }
    }

    @IsTest
    public static void getViewingWrappersTest() {
        Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business_Centre')
            .getRecordTypeId();
        Group g1 = new Group(Name = 'Amber_Jones', type = 'Queue');
        insert g1;
        QueueSObject q1 = new QueueSObject(QueueID = g1.Id, SObjectType = 'Lead');
        insert q1;

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(Name = 'TestAccount', RecordTypeId = bcRecordTypeId);
            insert a;
            Contact c = new Contact(LastName = 'testContact', Email = 'Testemail@test.com');
            insert c;
            a.CentreManager__c = c.Id;
            update a;
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
            Introduction__c i = new Introduction__c(
                Lead__c = l.id,
                RelatedToDeal__c = o.id,
                BusinessCentre__c = a.id,
                Send_to_BC__c = true,
                Send_to_Customer__c = true
            );
            ViewingSchedule__c vs = new ViewingSchedule__c();
            insert vs;
            Viewing__c v = new Viewing__c(
                ViewingSchedule__c = vs.id,
                BusinessCentre__c = a.id,
                ViewingDateTime__c = Date.today()
            );

            insert i;
            insert v;
            Test.startTest();
            EmailController ec = new EmailController();
            ec.viewingId = v.id;
            ec.viewingScheduleId = vs.id;
            ec.leadId = l.Id;
            List<EmailController.ViewingWrapper> viewingWrappers = ec.getViewingWrappers();
            Test.stopTest();
        }

    }
}