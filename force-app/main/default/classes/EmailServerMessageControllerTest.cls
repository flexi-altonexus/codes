@isTest
private class EmailServerMessageControllerTest {
	
	@isTest static void testclass() {
		Account ac = TestFactory.createBC();
		ac.BillingStreet = 'Libertad 2';
		ac.BillingPostalCode = '28100';
		ac.BillingState = 'Madrid';
		ac.BillingLatitude = 38.8951;
		ac.BillingLongitude  = -77.0364;

		insert ac;
				
		Account ac2 = TestFactory.createBC();
		ac2.BillingStreet = 'Real 2';
		ac2.BillingPostalCode = '28700';
		ac2.BillingState = 'Madrid';
		ac2.BillingLatitude = 38.8951;
		ac2.BillingLongitude  = -77.0364;
		insert ac2;
		
		Lead l = new Lead(LastName='TestLead', LeadSource='Telephone',Company='TestCompany');
        insert l;
        Account a = new Account(Name='TestAccount');
        insert a;
        Contact c = new Contact(LastName='TestContact', AccountId = a.Id);
        insert c;
             
        Opportunity o = new Opportunity(Name='TestOpp', StageName='Qualified', CloseDate = Date.today());
        insert o;
        Introduction__c i1 = new Introduction__c(Lead__c = l.id, RelatedToDeal__c = o.id, BusinessCentre__c = ac.id);
        insert i1;
        Introduction__c i2 = new Introduction__c(Lead__c = l.id, RelatedToDeal__c = o.id, BusinessCentre__c = ac2.id,Contact__c=c.Id,Client__c = a.id);
        insert i2;

       
		EmailServerMessageController newIns = new EmailServerMessageController();
		newIns.introId = i1.Id;
		EmailServerMessageController.strFileName = 'Test';
        newIns.getstrBody();
        newIns.getstrXMLAttachment();
        
        EmailServerMessageController newIns2 = new EmailServerMessageController();
		newIns2.introId = i2.Id;
		EmailServerMessageController.strFileName = 'Test';
        newIns2.getstrBody();
        newIns2.getstrXMLAttachment();
		EmailToProviderUtils.getEmailBody();
        EmailToProviderUtils.getleadDADIXML();
        EmailToProviderUtils.getultrasoftXML();
	}
	
}