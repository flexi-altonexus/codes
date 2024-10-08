@istest
public class DataDwellUserTriggerTest {
    
    @isTest(SeeAllData=true)
    public static void testAssignment() {
        
        // Get the permission set
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Sales_Enablement_Basic'];
        List<PermissionSetAssignment> psaExisting = null;
        
        // Get one system admin
        User usr = [SELECT Id, Data_Dwell_User__c FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true ORDER BY Data_Dwell_User__c DESC LIMIT 1];
                
        // Switch positions
        usr.Data_Dwell_User__c = !usr.Data_Dwell_User__c;
        update usr;
        
        // Permission set should be assigned if Data Dwell User is true
        psaExisting = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = :usr.Id];
        System.assertEquals(usr.Data_Dwell_User__c, psaExisting.size() == 1);
        
        // Switch positions again
        usr.Data_Dwell_User__c = !usr.Data_Dwell_User__c;
        update usr;
        
        // Permission set should be assigned if Data Dwell User is true
        psaExisting = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id AND AssigneeId = :usr.Id];
        System.assertEquals(usr.Data_Dwell_User__c, psaExisting.size() == 1);
    }
}