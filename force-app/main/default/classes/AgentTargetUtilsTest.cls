@IsTest
public with sharing class AgentTargetUtilsTest {
    public static final Decimal FLEXI_FEE = 100;
    public static Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
    public static Date endDate = Date.newInstance(
        Date.today().year(),
        Date.today().month(),
        Date.daysInMonth(Date.today().year(), Date.today().month())
    );

    @TestSetup
    static void makeData() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test');
        insert con;
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            ClientName__c = con.Id,
            Name = 'Test',
            CloseDate = Date.today(),
            Expected_Start_Date__c = Date.today(),
            StageName = 'Qualified',
            OwnerId = UserInfo.getUserId(),
            NumberofWorkstations__c = 1,
            ClearedFundsDepositPaid__c = true,
            Amount = FLEXI_FEE,
            Invoice_1_Total__c = 1000,
            ContractStartDate__c = Date.today(),
            MonthlyRent__c = 50,
            AgentSplitRevenue__c = 200,
            Product__c = 'Serviced',
            Type = 'Expansion'
        );
        insert opp;
        PaymentSchedule__c paysched = new PaymentSchedule__c(
            Year__c = '1',
            Opportunity__c = opp.Id
        );
        insert paysched;
    }

    @IsTest
    static void opportunityUpdateTest() {
        AgentTarget__c target = new AgentTarget__c(
            TargetStartDate__c = startDate,
            TargetEndDate__c = endDate,
            Agent__c = UserInfo.getUserId()
        );
        insert target;

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.StageName = 'Closed Won';
        Test.startTest();
        update opp;
        Test.stopTest();

        target = [SELECT Month_Sales_Final_Fee__c, MonthFlexiFeeAfterSplit_trig__c FROM AgentTarget__c LIMIT 1];
        System.assertEquals((Decimal) 800, target.Month_Sales_Final_Fee__c);
        System.assertEquals( FLEXI_FEE, target.MonthFlexiFeeAfterSplit_trig__c);
    }

    @IsTest
    static void agentTargetInsertTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.StageName = 'Closed Won';
        update opp;

        AgentTarget__c target = new AgentTarget__c(
            TargetStartDate__c = startDate,
            TargetEndDate__c = endDate,
            Agent__c = UserInfo.getUserId()
        );
        Test.startTest();
        insert target;
        Test.stopTest();

        target = [SELECT Month_Sales_Final_Fee__c, MonthFlexiFeeAfterSplit_trig__c FROM AgentTarget__c LIMIT 1];
        System.assertEquals((Decimal) 800, target.Month_Sales_Final_Fee__c);
        System.assertEquals( FLEXI_FEE, target.MonthFlexiFeeAfterSplit_trig__c);
    }

    @IsTest
    static void agentTargetUpdateTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.StageName = 'Closed Won';
        update opp;

        AgentTarget__c target = new AgentTarget__c(
            TargetStartDate__c = startDate,
            TargetEndDate__c = endDate,
            Agent__c = UserInfo.getUserId()
        );
        insert target;

        target.Target__c = 1000;
        Test.startTest();
        update target;
        Test.stopTest();

        target = [SELECT Month_Sales_Final_Fee__c, MonthFlexiFeeAfterSplit_trig__c FROM AgentTarget__c LIMIT 1];
        System.assertEquals((Decimal) 800, target.Month_Sales_Final_Fee__c);
        System.assertEquals( FLEXI_FEE, target.MonthFlexiFeeAfterSplit_trig__c);
    }
}