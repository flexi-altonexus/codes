@isTest
public class ESBackTest {
    public static testMethod void testBatch() {
        List <Enhanced_Slot__c> ess = new List<Enhanced_Slot__c>();

        Search_Parameter__c sp = new Search_Parameter__c(
                    Name='testEL',
                    Url__c='/sfdc/test_endpoint'
                );
            insert(sp);

            Enhanced_Listing__c enl = new Enhanced_Listing__c(
                Name='testEL',
                Search_Parameter__c = sp.id   
            );
        insert(enl);

          for(integer i = 0; i<50; i++){
                Enhanced_Slot__c a = new Enhanced_Slot__c(
                    //Name='testAccount'+ i, 
                Number_of_Quotes__c = i,
                Enhanced_Listing__c = enl.id,
                Unique_Key__c = 'es.Unique_Key__c' + i,
                APISync__c = true);
                  ess.add(a);
               }
                
        insert ess;
        
        Test.StartTest();
        ESBack esb = new ESBack();
        ID batchprocessid = Database.executeBatch(esb);
        Test.StopTest();
     
        System.AssertEquals(
                database.countquery('SELECT COUNT()'
                   +' FROM ESBack__c'),
                50);  
        
        }
     }