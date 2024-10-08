@IsTest
public class AgentTargetCreatorScheduledTest {
    @TestSetup
    static void makeData() {
        AgentTarget__c testTarget = new AgentTarget__c(
            TargetStartDate__c = System.today().toStartOfMonth(),
            TargetEndDate__c = System.today().addMonths(1).toStartOfMonth().addDays(-1),
            Target__c = 1000,
            Active__c = true,
            Agent__c = UserInfo.getUserId()
        );

        insert testTarget;
    }

    @IsTest
    static void createNewTargetTest() {
        Test.startTest();
        System.schedule('Test Jon', '20 30 8 10 2 ?', new AgentTargetCreatorScheduled());
        Test.stopTest();

       // System.assertEquals(2, [SELECT COUNT() FROM AgentTarget__c]);
     //   System.assertEquals(1, [SELECT COUNT() FROM AgentTarget__c WHERE Active__c = false]);
     //   System.assertEquals(1, [SELECT COUNT() FROM AgentTarget__c WHERE Active__c = true]);

        AgentTarget__c testTarget = [
            SELECT Id, Target__c, Agent__c, TargetStartDate__c, TargetEndDate__c
            FROM AgentTarget__c
            WHERE Active__c = true
        ];

        System.assertEquals(testTarget.Target__c, 1000);
        System.assertEquals(testTarget.TargetStartDate__c, System.today().toStartOfMonth());
        System.assertEquals(testTarget.Agent__c, UserInfo.getUserId());
    }
}