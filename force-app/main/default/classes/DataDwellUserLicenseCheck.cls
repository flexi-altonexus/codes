public class DataDwellUserLicenseCheck {
    /*
    * Checks the User has access to a Managed Package
    */
    @AuraEnabled
    public static Boolean checkUserLicense(String namespacePrefix) {
        List<UserPackageLicense> userPackageLicenses = [SELECT UserId FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: namespacePrefix AND UserId =: UserInfo.getUserId()];
        return !userPackageLicenses.isEmpty(); 
    }
}