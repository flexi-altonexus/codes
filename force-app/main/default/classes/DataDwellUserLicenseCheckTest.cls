@IsTest 
public class DataDwellUserLicenseCheckTest {
    @istest
    public static void licenseCheckTest() {
        Boolean hasLicense = DataDwellUserLicenseCheck.checkUserLicense('namespacenotexists');
        System.assertEquals(false, hasLicense);
    }
}