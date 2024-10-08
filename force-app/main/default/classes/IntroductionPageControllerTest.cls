@IsTest
public with sharing class IntroductionPageControllerTest {
    @IsTest(SeeAllData=true) public static void testIntroductionPageController() {
        Introduction__c intro = [
            SELECT Id, BusinessCentre__r.Name 
            FROM Introduction__c 
            WHERE 
            	BusinessCentre__c != null AND 
            	BusinessCentre__r.PrimaryImage__c != null AND 
            	BusinessCentre__r.AirConditioning__c != null AND 
            	Lead__c != null AND 
            	Lead__r.Owner.Type = 'User'
            ORDER BY 
            	CreatedDate DESC 
            LIMIT 1
        ];
        IntroductionPageController controller = new IntroductionPageController();
        PageReference pageRef = Page.IntroductionPage;
        pageRef.getParameters().put('id', intro.Id);
        Test.setCurrentPage(pageRef);
        IntroductionPageController.IntroductionObject introObject = controller.getIntroduction();
        System.assertEquals(intro.BusinessCentre__r.Name, introObject.BusinessCenterName);
        
        pageRef.getParameters().put('type', 'transport');
        controller.generateJSON();
        
        pageRef.getParameters().put('type', 'request_viewing');
        pageRef.getParameters().put('date', '01/01/1970');
        controller.generateJSON();

        pageRef.getParameters().put('type', 'shortlist');
        controller.generateJSON();

        pageRef.getParameters().put('type', 'shortlistremove');
        controller.generateJSON();
    }
}