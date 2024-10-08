@isTest
public class AgentReSendIntroEmailsControllerTest {
    
    @isTest public static void test(){
        Lead l = new Lead(LastName='TestLead', LeadSource='Telephone',Company='TestCompany');
        insert l;
        Id bcRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Centre').getRecordTypeId();
        Account a = new Account(Name='TestAccount', RecordTypeId = bcRecordTypeId);
        insert a;
        Opportunity o = new Opportunity(Name='TestOpp', StageName='Qualified', CloseDate = Date.today());
        insert o;
        Introduction__c i = new Introduction__c(Lead__c = l.id, RelatedToDeal__c = o.id, BusinessCentre__c = a.id);
        insert i;
        List<String> intros = new List<String>();
        intros.add(i.Id);

        List<AgentReSendIntroEmailsController.IntroWrapper> testList = AgentReSendIntroEmailsController.getIntroductions(JSON.serialize(intros));
        System.assertEquals(1, testList.size());
        testList.clear();

        AgentReSendIntroEmailsController.IntroWrapper originalData = new AgentReSendIntroEmailsController.IntroWrapper(i.Id, 'TestIntro',a.Id,a.Name,true,true,'testContact','testLead');
        AgentReSendIntroEmailsController.IntroWrapper newData = new AgentReSendIntroEmailsController.IntroWrapper(i.Id, null,null,null,false,true,null,null);
        List<AgentReSendIntroEmailsController.IntroWrapper> newDataList = new List<AgentReSendIntroEmailsController.IntroWrapper>();

        testList.add(originalData);
        newDataList.add(newData);

        List<AgentReSendIntroEmailsController.IntroWrapper> testSaveList = AgentReSendIntroEmailsController.saveIntroductions(JSON.serialize(newDataList), JSON.serialize(testList));
        System.assertEquals(1, testSaveList.size());
        testSaveList.clear();
        newDataList.clear();
        newData.ReSendEmailtoCustomer = false;
        newData.ReSendEmailtoProvider = true;
        newDataList.add(newData);
        testSaveList = AgentReSendIntroEmailsController.saveIntroductions(JSON.serialize(newDataList), JSON.serialize(testList));
        System.assertEquals(1, testSaveList.size());

        AgentReSendIntroEmailsController.Response responseSuccess = AgentReSendIntroEmailsController.sendEmailsApex(JSON.serialize(testList));
        System.assertEquals(responseSuccess.type, 'success');
    }
    
}